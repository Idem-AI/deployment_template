variable "deployment_name" {
  description = "Nom de déploiement utilisé comme préfixe pour les ressources"
  type        = string
}

variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région où déployer les ressources (ex: us-central1)"
  type        = string
}

variable "redis_memory_size_gb" {
  description = "Taille mémoire Redis en Go (doit être une valeur valide selon le type de l’instance, ex: 1, 2, 4, 5, 10...)"
  type        = number
}

variable "labels" {
  description = "Labels à appliquer à l’instance Redis"
  type        = map(string)
  default     = {}
}

variable "authorized_network" {
  description = "Réseau autorisé pour l’instance Redis"
  type        = string
}

variable "enable_redis" {
  description = "Activer ou non le déploiement de l'instance Redis"
  type        = bool
  default     = false
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