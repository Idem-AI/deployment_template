############################
# variables.tf
############################

variable "engine" {
  description = "Type de moteur : 'sql' ou 'spanner'"
  type        = string
  default     = "sql"
}

# Common
variable "project_id" {}
variable "region" {}
variable "name" {}
variable "db_name" {}

# SQL (MySQL / PostgreSQL)
variable "db_version" { default = "MYSQL_8_0" }
variable "db_tier" { default = "db-f1-micro" }
variable "disk_size_gb" { default = 10 }
variable "disk_type" { default = "PD_SSD" }
variable "enable_ha" { default = false }
variable "enable_replication" { default = false }
variable "enable_binlog" { default = true }
variable "backup_start_time" { default = "03:00" }
variable "private_network_id" { default = null }
variable "db_user" { default = "admin" }
variable "db_password" {}
variable "enable_deletion_protection" { default = true }

# Spanner
variable "spanner_nodes" { default = 1 }
variable "spanner_processing_units" { default = null }
variable "spanner_multi_region" { default = false }
variable "spanner_ddl" {
  description = "Liste de requêtes DDL (schema)"
  type        = list(string)
  default     = []
}

variable "network_self_link" {
  type = string
  description = "Self link du réseau VPC pour Cloud SQL"
  default = null
}