output "db_endpoint" {
  value = var.db_engine_type == "aurora" ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.primary[0].endpoint
}

output "db_reader_endpoint" {
  value = var.db_engine_type == "aurora" ? aws_rds_cluster.aurora[0].reader_endpoint : (var.enable_read_replica ? aws_db_instance.replica[0].endpoint : null)
}

output "db_engine" {
  value = var.engine
}

output "db_name" {
  value = var.db_name
}
