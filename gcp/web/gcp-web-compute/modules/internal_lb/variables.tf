variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe nommage des ressources internal LB"
}

variable "network" {
  type        = string
  description = "Self-link de la VPC network"
}

variable "subnet" {
  type        = string
  description = "Self-link du subnetwork pour le forwarding rule"
}

variable "backend_group" {
  type        = string
  description = "Self-link du Backend Service du module compute"
}

variable "health_check_port" {
  type        = number
  description = "Port utilisé pour les health checks"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Chemin HTTP pour les health checks"
  default     = "/"
}

variable "listener_port" {
  type        = number
  description = "Port d’écoute du forwarding rule"
  default     = 8080
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Région pour le load balancer"
  
}