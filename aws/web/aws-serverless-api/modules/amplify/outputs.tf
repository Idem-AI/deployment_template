output "app_id" { value = aws_amplify_app.this.id }
output "branch_name" { value = aws_amplify_branch.branch.branch_name }
output "domain_association_id" { value = try(aws_amplify_domain_association.domain[0].id, "") }
