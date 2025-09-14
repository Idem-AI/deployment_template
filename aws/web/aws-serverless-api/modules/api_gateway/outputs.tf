output "rest_api_id" { value = aws_api_gateway_rest_api.this.id }
output "invoke_url" {
  value = format("https://%s.execute-api.%s.amazonaws.com/%s", aws_api_gateway_rest_api.this.id, data.aws_region.current.name, var.stage_name)
}
