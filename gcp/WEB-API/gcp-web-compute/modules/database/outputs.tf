output "instance_connection_name" {
  value       = google_sql_database_instance.db.connection_name
  description = "Connection name de l'instance SQL"
}

output "db_instance_name" {
  value       = google_sql_database_instance.db.name
  description = "Nom de l'instance Cloud SQL"
}

output "database_endpoint" {
  value       = google_sql_database_instance.db.private_ip_address
  description = "Adresse interne de la base"
}