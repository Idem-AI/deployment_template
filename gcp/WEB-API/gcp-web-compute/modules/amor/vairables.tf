variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe pour nommer la policy Armor"
}

variable "enable_armor" {
  type        = bool
  description = "Active l’attachement de la policy au backend"
}

variable "iam_binding_member" {
  type        = string
  description = "Service account ou membre IAM pour l’attachement"
}

variable "custom_rules" {
  type = map(object({
    priority       = number
    action         = string            // "allow" | "deny(403)"
    description    = string
    versioned_expr = string            // ex: "SRC_IPS_V1" | "CUSTOM_EXPR_V1"
    src_ip_ranges  = list(string)
    custom_expr    = string            // Expression CEL : condition personnalisée
  }))
  description = "Map de règles Cloud Armor personnalisées"
}


variable "enable_cdn" {
  description = "Active l’utilisation de Cloud CDN pour le load balancer externe"
  type        = bool
  default     = false
}

variable "backend_group_ids" {
  description = "Liste des self_links des groupes d’instances ou NEG à attacher au backend externe"
  type        = list(string)
}

variable "domains" {
  type        = list(string)
  description = "Liste des domaines pour le certificat SSL"
}

variable "health_check_port" {
  type        = number
  description = "Port pour les health checks externes"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Chemin pour les health checks externes"
  default     = "/"
}
