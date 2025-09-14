variable "project_id" {
  description = "ID du projet GCP"
  type        = string
  
}

variable "region" {
  description = "Région par défaut pour Cloud Run et ressources associées"
  type        = string
  default     = "europe-west1"
  
}

variable "deployment_name" {
  description = "Préfixe unique pour nommer les ressources"
  type        = string
  
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  
}