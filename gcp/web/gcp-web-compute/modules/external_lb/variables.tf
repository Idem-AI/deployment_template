variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe nommage des ressources external LB"
}

variable "domains" {
  type        = list(string)
  description = "Liste des domaines pour le certificat SSL"
}

variable "backend_group_ids" {
  type        = list(string)
  description = "Liste des instance_group self_link à rattacher"
}

variable "health_check_port" {
  type        = number
  description = "Port pour health checks"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Path pour health checks"
  default     = "/"
}

variable "enable_cdn" {
  type        = bool
  description = "Active Cloud CDN"
  default     = false
}

variable "enable_armor" {
  type        = bool
  description = "Active Cloud Armor"
  default     = false
}

variable "armor_blocked_ips" {
  type        = list(string)
  description = "Liste d'adresses IP à bloquer"
  default     = []
}

variable "backend_service_account" {
  type        = string
  description = "Service account utilisé pour le backend IAM attachment"
}