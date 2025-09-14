locals {
  base_tags = merge({ Name = var.name }, var.tags)
  funcs_map = { for f in var.functions : f.name => f }
}

# Bucket unique par module
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.name}-lambda-code"
  acl    = "private"
  tags   = local.base_tags
}

# Clone & zip chaque fonction
resource "null_resource" "clone_and_zip" {
  for_each = local.funcs_map

  provisioner "local-exec" {
    command = <<EOT
      rm -rf /tmp/${each.key}
      git clone --branch ${each.value.git_branch} ${each.value.git_repo} /tmp/${each.key}
      cd /tmp/${each.key}
      zip -r /tmp/${each.key}.zip .
    EOT
  }

  triggers = {
    repo   = each.value.git_repo
    branch = each.value.git_branch
  }
}

# Upload dans S3
resource "aws_s3_object" "lambda_zip" {
  for_each = local.funcs_map
  bucket   = aws_s3_bucket.lambda_bucket.id
  key      = "${each.key}.zip"
  source   = "/tmp/${each.key}.zip"

  depends_on = [null_resource.clone_and_zip]
}

# Déployer la Lambda
resource "aws_lambda_function" "fn" {
  for_each      = local.funcs_map
  function_name = "${var.name}-${each.key}"
  handler       = each.value.handler
  runtime       = each.value.runtime
  memory_size   = each.value.memory
  timeout       = each.value.timeout
  publish       = each.value.publish

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_zip[each.key].key

  role = each.value.role_arn

  environment {
    variables = each.value.env
  }

  dynamic "vpc_config" {
    for_each = (
      contains(keys(each.value), "vpc_config") &&
      length(each.value.vpc_config.subnet_ids) > 0 &&
      length(each.value.vpc_config.security_group_ids) > 0
    ) ? [each.value.vpc_config] : []

    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = local.base_tags
}

# Outputs
output "function_arns" {
  value = { for k, v in aws_lambda_function.fn : k => v.arn }
}

output "function_names" {
  value = { for k, v in aws_lambda_function.fn : k => v.function_name }
}
