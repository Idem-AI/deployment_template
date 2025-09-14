
variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région par défaut pour Cloud Run et ressources associées"
  type        = string
  default     = "europe-west1"
}

variable "dns_zone" {
  description = "Nom de la zone DNS gérée dans Cloud DNS"
  type        = string
}

variable "dns_ttl" {
  description = "TTL des enregistrements DNS (en secondes)"
  type        = number
  default     = 300
}

variable "deployment_name" {
  description = "Préfixe unique pour nommer les ressources"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
}

variable "common_labels" {
  description = "Labels communs à appliquer à toutes les ressources"
  type        = map(string)
  default     = {}
}

variable "run_roles" {
  description = "Liste des rôles IAM à lier au Service Account Cloud Run"
  type        = map(string)
  default     = {
    "roles/run.admin" = ""
    "roles/logging.logWriter" = ""
  }
}


variable "db_engine" {
  description = "Type de moteur de base de données : 'sql' ou 'spanner'"
  type        = string
  default     = "sql"
  
}

##############################################################################
#                          SERVICES DYNAMIQUES                               #
##############################################################################
variable "services" {
  type = map(object({
    name         = string
    image        = string
    port         = number
    needs_database = optional(bool, false)
    ingress      = optional(string, "INGRESS_TRAFFIC_ALL")
    vpc_connector = optional(string, "")
    vpc_egress   = optional(string, "ALL_TRAFFIC")
    cloudsql_instances = optional(list(string), [])
    environment  = optional(list(object({ name = string, value = string })), [])
    resources    = object({ cpu = string, memory = string })
    scaling      = object({ min = number, max = number })
    expose_lb    = optional(bool, true)
    enable_cdn   = optional(bool, false)
    domain_name  = optional(string, "")
    enable_waf   = optional(bool, false)
    waf_rules    = optional(list(object({
      priority      = number
      action        = string
      source_ranges = list(string)
    })), [])
  }))
}

###############################################################################
#                         DATABASES VARIABLES                                #
###############################################################################

variable "engine" {
  description = "Type de moteur : 'sql' ou 'spanner'"
  type        = string
  default     = "sql"
}

# Common


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

# Observability

variable "enable_observability" {
  description = "Activer Cloud Trace, Logging et Error Reporting pour les services Cloud Run"
  type        = bool
  default     = false
}


# REDIS
variable "enable_redis" {
  description = "Activer ou non Redis"
  type        = bool
  default     = false
}


variable "redis_memory_size_gb" {
  description = "Taille mémoire de Redis en Go"
  type        = number
  default     = 1
}

variable "labels" {
  description = "Labels à appliquer"
  type        = map(string)
  default     = {}
}

variable "redis_tier" {
  description = "Type de l'instance Redis (ex: BASIC, STANDARD_HA)"
  type        = string
  default     = "BASIC"
}

variable "redis_version" {
  description = "Version de Redis à utiliser (ex: REDIS_6_X, REDIS_7_X)"
  type        = string
  default     = "REDIS_6_X"
}

variable "redis_primary_zone" {
  description = "Zone primaire pour l'instance Redis (ex: us-central1-b)"
  type        = string
  default     = null
}
variable "redis_secondary_zone" {
  description = "Zone secondaire pour l'instance Redis (ex: us-central1-c)"
  type        = string
  default     = null
}