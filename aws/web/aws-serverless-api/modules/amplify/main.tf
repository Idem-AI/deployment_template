locals { base_tags = merge({ Name = var.name }, var.tags) }

resource "aws_iam_role" "amplify" {
  count = var.create_iam_role && var.iam_service_role_arn == "" ? 1 : 0
  name = "${var.name}-amplify-role"
  assume_role_policy = jsonencode({ Version="2012-10-17", Statement=[{Effect="Allow", Principal={Service="amplify.amazonaws.com"}, Action="sts:AssumeRole"}] })
  tags = local.base_tags
}

resource "aws_iam_role_policy_attachment" "amplify_attach" {
  count = var.create_iam_role && var.iam_service_role_arn == "" ? 1 : 0
  role = aws_iam_role.amplify[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_amplify_app" "this" {
  name       = var.app_name
  repository = var.repository
  iam_service_role_arn = var.iam_service_role_arn != "" ? var.iam_service_role_arn : (var.create_iam_role ? aws_iam_role.amplify[0].arn : null)
  tags = local.base_tags
}

resource "aws_amplify_branch" "branch" {
  app_id      = aws_amplify_app.this.id
  branch_name = var.branch
  tags = local.base_tags
}

resource "aws_amplify_domain_association" "domain" {
  count = var.domain_name != "" ? 1 : 0
  app_id = aws_amplify_app.this.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = aws_amplify_branch.branch.branch_name
    prefix = ""
  }
  sub_domain {
    branch_name = aws_amplify_branch.branch.branch_name
    prefix = "www"
  }

  wait_for_verification = true
}
