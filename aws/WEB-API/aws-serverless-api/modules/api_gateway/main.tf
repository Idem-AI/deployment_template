locals {
  base_tags = merge({ Name = var.name }, var.tags)
  # flatten methods and create unique key path|METHOD
  methods_flat = flatten([
    for r in var.api_routes : [
      for m in r.methods : {
        key         = "${r.path}|${upper(m.http_method)}"
        path        = r.path
        method      = upper(m.http_method)
        lambda_name = m.lambda_name
        authorization = lookup(m, "authorization", "NONE")
        enable_cors = lookup(m, "enable_cors", true)
      }
    ]
  ])
  methods_map = { for mm in local.methods_flat : mm.key => mm }
}

# API
resource "aws_api_gateway_rest_api" "this" {
  name        = var.rest_api_name
  description = var.rest_api_description
  endpoint_configuration { types = ["REGIONAL"] }
  tags = local.base_tags
}

# resources (one per path)
resource "aws_api_gateway_resource" "route" {
  for_each   = { for r in var.api_routes : r.path => r }
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.key
}

# methods
resource "aws_api_gateway_method" "method" {
  for_each    = local.methods_map
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.route[each.value.path].id
  http_method = each.value.method
  authorization = each.value.authorization
}

# integration using Lambda invocation URI (we expect lambda ARN to be provided at root and replaced later via parent module)
resource "aws_api_gateway_integration" "integration" {
  for_each = local.methods_map
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.route[each.value.path].id
  http_method = aws_api_gateway_method.method[each.key].http_method
  integration_http_method = "POST"
  type = "AWS"
  uri  = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${each.value.lambda_name}/invocations"
  passthrough_behavior = "WHEN_NO_MATCH"
}

# method responses + integration responses (CORS header)
resource "aws_api_gateway_method_response" "method_resp" {
  for_each = local.methods_map
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.route[each.value.path].id
  http_method = aws_api_gateway_method.method[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = { "application/json" = "Empty" }
}

resource "aws_api_gateway_integration_response" "integration_resp" {
  for_each = local.methods_map
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.route[each.value.path].id
  http_method = aws_api_gateway_method.method[each.key].http_method
  status_code = aws_api_gateway_method_response.method_resp[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

# Lambda permission - allow API to call lambda
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_lambda_permission" "allow" {
  for_each = local.methods_map
  statement_id  = format("%s-allow-%s", var.name, replace(each.key, "|", "-"))
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/${each.value.path}"
}

# OPTIONS at root (simple global preflight)
resource "aws_api_gateway_method" "options_root" {
  count = 1
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_root_integration" {
  count = 1
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.options_root[0].http_method
  type = "MOCK"
  request_templates = { "application/json" = jsonencode({ statusCode = 200 }) }
}

resource "aws_api_gateway_method_response" "options_response" {
  count = 1
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.options_root[0].http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  count = 1
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.options_root[0].http_method
  status_code = aws_api_gateway_method_response.options_response[0].status_code
  response_templates = { "application/json" = "" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}

# Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  #stage_name  = var.stage_name

  triggers = {
    redeployment = sha1(jsonencode(
      concat(
        values(aws_api_gateway_resource.route)[*].id,
        values(aws_api_gateway_method.method)[*].id,
        values(aws_api_gateway_integration.integration)[*].id
      )
    ))
  }

  lifecycle { create_before_destroy = true }
  depends_on = [aws_api_gateway_integration.integration]
}
