variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "region" {
  type        = string
  description = "Région de l'instance Cloud SQL"
}

variable "db_tier" {
  type        = string
  description = "Machine type (tier) pour Cloud SQL"
}

variable "db_version" {
  type        = string
  description = "Version de la base (ex: MYSQL_8_0)"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe pour nommer les ressources"
}

variable "high_availability" {
  type        = bool
  description = "True pour provisionner en mode REGIONAL HA"
  default     = false
}

variable "backup_start_time" {
  type        = string
  description = "Heure de début de backup (HH:MM)"
  default     = "03:00"
}

variable "network_self_link" {
  type        = string
  description = "Self-link du VPC pour IP privée"
}

variable "database_name" {
  type        = string
  description = "Nom de la base à créer"
}

variable "user_name" {
  type        = string
  description = "Nom de l'utilisateur DB"
}

variable "user_password" {
  type        = string
  description = "Mot de passe de l'utilisateur DB"
}