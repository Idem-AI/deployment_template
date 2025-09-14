variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe pour nommer le backend CDN"
}

variable "protocol" {
  type        = string
  description = "Protocole du backend (HTTP ou HTTPS)"
  default     = "HTTP"
}

variable "timeout_sec" {
  type        = number
  description = "Timeout pour le backend en secondes"
  default     = 30
}

variable "backend_group" {
  type        = string
  description = "Self-link du groupe d'instances ou NEG"
}

variable "cache_mode" {
  type        = string
  description = "Mode de cache CDN (e.g. \"CACHE_ALL_STATIC\")"
  default     = "CACHE_ALL_STATIC"
}

variable "default_ttl" {
  type        = number
  description = "TTL par défaut pour le contenu cache"
  default     = 3600
}

variable "enable_cdn" {
  type = bool
}

variable "health_check_port" {
  type        = number
  description = "Port pour les health checks"
  default     = 80  
  
}

variable "health_check_path" {
  type        = string
  description = "Chemin pour les health checks"
  default     = "/"
}