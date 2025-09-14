# variables.tf
##############################################################################
#                             GLOBAL VARIABLES                               #
##############################################################################
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

variable "enable_apis" {
  type        = string
  description = "Whether or not to enable underlying apis in this solution. ."
  default     = true
}

variable "db_engine" {
  description = "Type de moteur de base de données : 'sql' ou 'spanner'"
  type        = string
  default     = "sql"
  
}

variable "vpc_connector" {
  description = "Nom du VPC Access Connector à utiliser pour Cloud Run"
  type        = string
  default     = ""
  
}

variable "host" {
  description = "Nom d'hôte ou adresse IP de la base de données"
  type        = string
  default     = ""
  
}

variable "username" {
  description = "Nom d'utilisateur pour la base de données"
  type        = string
  default     = ""
  
}

variable "spanner_instance" {
  description = "Nom de l'instance Spanner à utiliser"
  type        = string
  default     = ""
}

variable "spanner_connection_uri" {
  description = "URI de connexion pour Spanner (format : projects/{project}/instances/{instance}/databases/{database})"
  type        = string
  default     = ""
  
}

variable "spanner_database" {
  description = "Nom de la base de données Spanner à utiliser"
  type        = string
  default     = ""
}

variable "password" {
  description = "Mot de passe pour la base de données"
  type        = string
  default     = ""
  
}

variable "connection_name" {
  description = "Nom de connexion pour Cloud SQL (format : project:region:instance)"
  type        = string
  default     = ""
  
}
variable "db_name" {
  description = "Nom de la base de données à créer"
  type        = string
  default     = "default_db"
  
}
##############################################################################
#                          SERVICES DYNAMIQUES                               #
##############################################################################
variable "services" {
  description = <<-EOT
    Map d'objets décrivant chaque service à déployer :
    - key : identifiant unique
    - name : nom Cloud Run
    - image : image Docker
    - port : port d'écoute
    - environment : liste de vars d'environnement
    - resources : { cpu = string, memory = string }
    - scaling : { min = number, max = number }
    - expose_lb : bool (si true, crée LB + domaine + SSL)
    - enable_cdn : bool
    - domain_name : string (ex. "api.mondomain.com")
    - enable_waf : bool
    - waf_rules : list d'objets { priority, action, source_ranges }
  EOT

  type = map(object({
    name         = string
    image        = string
    port         = number
    needs_database = optional(bool, false)
    ingress      = optional(string, "INGRESS_TRAFFIC_ALL")
    vpc_connector = optional(string, "")
    vpc_egress   = optional(string, "ALL_TRAFFIC")
   # cloudsql_instances = optional(list(string), [])
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

variable "enable_observability" {
  description = "Activer Cloud Trace, Logging et Error Reporting pour les services Cloud Run"
  type        = bool
  default     = false
}

variable "enable_redis" {
  description = "Activer Redis pour les services Cloud Run"
  type        = bool
  default     = false
}

variable "redis_host" {
  description = "Adresse IP ou nom d'hôte de l'instance Redis"
  type        = string
  default     = ""
}

variable "redis_port" {
  description = "Port Redis"
  type        = number
  default     = 6379
}

##############################################################################
#                                EXAMPLES                                    #
##############################################################################
# Example pour déployer 2 services :
# services = {
#   web = {
#     name        = "frontend"
#     image       = "gcr.io/projet/frontend:latest"
#     port        = 80
#     environment = [{ name="ENV", value="prod" }]
#     resources   = { cpu="1", memory="512Mi" }
#     scaling     = { min=1, max=5 }
#     expose_lb   = true
#     enable_cdn  = true
#     domain_name = "www.exemple.com"
#     enable_waf  = true
#     waf_rules   = [{ priority=1000, action="deny(403)", source_ranges=["0.0.0.0/0"] }]
#   }
#   api = {
#     name        = "backend-api"
#     image       = "gcr.io/projet/api:latest"
#     port        = 8080
#     resources   = { cpu="0.5", memory="256Mi" }
#     scaling     = { min=1, max=3 }
#     expose_lb   = false
#   }
# }
