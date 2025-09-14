locals {
  base_tags = merge({ Name = var.name }, var.tags)
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  # Définition des attributs
  attribute {
    name = var.hash_key
    type = "S"
  }

  # Capacités seulement si PROVISIONED
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  tags = local.base_tags
}

# Outputs
output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_name" {
  value = aws_dynamodb_table.this.name
}
