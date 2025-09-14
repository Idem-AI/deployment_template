

locals {
  base_tags = merge({ Name = var.name }, var.tags)
  lambda_statements = concat(
    [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ],
    var.dynamodb_table_arn != "" ? [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DeleteItem"
        ]
        Resource = var.dynamodb_table_arn
      }
    ] : []
  )
}


# Lambda execution role (minimal)
resource "aws_iam_role" "lambda_role" {
  count = var.create_lambda_role ? 1 : 0
  name  = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={Service="lambda.amazonaws.com"}, Action="sts:AssumeRole"}]
  })
  tags = local.base_tags
}

resource "aws_iam_role_policy" "lambda_policy" {
  count  = var.create_lambda_role ? 1 : 0
  name   = "${var.name}-lambda-policy"
  role   = aws_iam_role.lambda_role[0].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.lambda_statements
  })

  lifecycle { ignore_changes = [policy] }
}