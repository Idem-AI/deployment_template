provider "aws" {
  region = var.aws_region
}

# IAM module: create convenience roles if requested
module "iam" {
  source = "./modules/iam"
  count = var.create_iam_for_dev ? 1 : 0
  name  = var.name
  create_lambda_role = var.create_iam_for_dev
  create_amplify_role = var.create_iam_for_dev
  dynamodb_table_arn = "" # will set later if dynamodb created; we can't forward circular easily
  tags = var.tags
}

# DynamoDB
module "dynamodb" {
  source      = "./modules/dynamodb"
  count       = var.enable_dynamodb ? 1 : 0
  name        = var.name
  table_name  = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key    = var.dynamodb_hash_key

  # Capacités requises seulement si billing_mode = "PROVISIONED"
  read_capacity  = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_read_capacity : null
  write_capacity = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_write_capacity : null

  tags        = var.tags
}


# Lambda functions (uses either provided role_arn from each function or iam.lambda_role_arn if created)
locals {
  # map of roles: prefer function-specific role, else root var.lambda_role_arn, else module.iam
  default_lambda_role = var.lambda_role_arn != "" ? var.lambda_role_arn : (
    length(module.iam) > 0 ? module.iam[0].lambda_role_arn : ""
  )

  lambda_functions_in = [
    for f in var.functions : {
      name       = f.name
      handler    = f.handler
      runtime    = lookup(f, "runtime", "python3.11")
      memory     = lookup(f, "memory", 128)
      timeout    = lookup(f, "timeout", 10)
      publish    = lookup(f, "publish", true)

      # Git repository instead of S3
      git_repo   = f.git_repo
      git_branch = lookup(f, "git_branch", "main")

      env       = lookup(f, "env", {})
      role_arn  = f.role_arn != "" ? f.role_arn : local.default_lambda_role
      vpc_config = lookup(f, "vpc_config", {
        subnet_ids         = []
        security_group_ids = []
      })
    }
  ]
}

module "lambda" {
  source = "./modules/lambda"
  count  = length(local.lambda_functions_in) > 0 ? 1 : 0

  name      = var.name
  functions = local.lambda_functions_in
  tags      = var.tags
}


# API Gateway - pass lambda ARNs as function identifier strings (use full invoke_arn)
# Convert module.lambda outputs to map name->arn (if present)
locals {
  lambda_arn_map = length(module.lambda) > 0 ? module.lambda[0].function_arns : {}
}

# create routes: we expect api_routes to reference lambda names matching lambda_functions[].name
module "api" {
  source = "./modules/api_gateway"
  count = var.enable_api ? 1 : 0
  name  = "${var.name}-api"
  rest_api_name = "${var.name}-api"
  rest_api_description = "API for ${var.name}"
  api_routes = [
    for r in var.api_routes : {
      path = r.path
      methods = [
        for m in r.methods : {
          http_method = m.http_method
          lambda_name = lookup(local.lambda_arn_map, m.lambda_name, m.lambda_name) # use arn if available, otherwise pass name (module handles)
          authorization = lookup(m, "authorization", "NONE")
          enable_cors = lookup(m, "enable_cors", true)
        }
      ]
    }
  ]
  stage_name = "prod"
  tags = var.tags
}

# Amplify
module "amplify" {
  source = "./modules/amplify"
  count = var.enable_amplify && var.amplify.app_name != "" ? 1 : 0
  name = var.name
  app_name = var.amplify.app_name
  repository = var.amplify.repository
  branch = var.amplify.branch
  domain_name = var.amplify.domain_name
  iam_service_role_arn = var.amplify_role_arn != "" ? var.amplify_role_arn : ""
  create_iam_role = var.create_iam_for_dev
  tags = var.tags
  depends_on = [ module.api ]
}
