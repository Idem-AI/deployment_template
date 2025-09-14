output "sql_instance_connection_name" {
  value       = var.engine == "sql" ? google_sql_database_instance.db[0].connection_name : null
  description = "Connection string pour Cloud SQL"
}

output "sql_credentials" {
  value = var.engine == "sql" ? {
    username = var.db_user
    password = var.db_password
    database = var.db_name
    host     = google_sql_database_instance.db[0].connection_name
  } : null
  sensitive = true
}

output "spanner_instance_name" {
  value       = var.engine == "spanner" ? google_spanner_instance.default[0].name : null
}

output "spanner_database_name" {
  value       = var.engine == "spanner" ? google_spanner_database.default[0].name : null
}

output "spanner_connection_uri" {
  value = var.engine == "spanner" ? "projects/${var.project_id}/instances/${google_spanner_instance.default[0].name}/databases/${google_spanner_database.default[0].name}" : null
  description = "URI de connexion pour Spanner"
}