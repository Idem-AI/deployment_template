variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "dns_zone_name" {
  type        = string
  description = "Nom de la zone DNS"
}

variable "domain" {
  type        = string
  description = "Domaine (sans point final)"
}

variable "record_name" {
  type        = string
  description = "Nom complet de l’enregistrement DNS (avec point final)"
}

variable "ttl" {
  type        = number
  description = "TTL de l’enregistrement DNS"
  default     = 300
}

variable "ip_address" {
  type        = string
  description = "Adresse IP de l’External LB à pointer"
}