variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "region" {
  type        = string
  description = "Région pour le MIG régional"
}

variable "zones" {
  type        = list(string)
  description = "Liste des zones pour le déploiement multi-zone"
}

variable "single_zone" {
  type        = bool
  description = "True pour MIG single-zone, false pour regional multi-zone"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe de nommage des ressources compute"
}

variable "instance_template" {
  type = object({
    machine_type  = string
    image_family  = string
    image_project = string
    tags          = list(string)
    metadata      = map(string)
  })
  description = "Configuration de l'instance template"
}

variable "network" {
  type        = string
  description = "Self-link de la VPC network"
}

variable "subnet" {
  type        = string
  description = "Self-link du subnetwork à utiliser"
}

variable "target_size" {
  type        = number
  description = "Nombre d'instances dans le MIG"
  default     = 2
}