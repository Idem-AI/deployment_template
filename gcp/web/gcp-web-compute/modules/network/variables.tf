variable "project_id" {
  type        = string
  description = "GCP Project ID où le réseau sera créé"
}

variable "network_name" {
  type        = string
  description = "Nom de la VPC network"
}

variable "region" {
  type        = string
  description = "Région où seront créés les subnets et le routeur"
}

variable "subnets" {
  type = list(object({
    zone = string  // Zone GCP (ex: "europe-west3-a")
    cidr = string  // Plage CIDR (ex: "10.0.1.0/24")
  }))
  description = "Liste des subnets à créer avec leur zone et CIDR"
}

variable "deployment_name" {
  type        = string
  description = "Préfixe pour nommer les ressources réseau"
  
}