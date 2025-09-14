variable "service_account_roles" {
  description = "Liste des rôles IAM à attribuer au service account unique utilisé par tous les modules"
  type        = list(string)
  default     = [
    "roles/compute.admin",                   # Pour les ressources compute et load balancer
    "roles/iam.serviceAccountUser",         # Pour exécuter avec le SA
    "roles/servicenetworking.networksAdmin",# Pour les réseaux partagés et SQL
    "roles/compute.securityAdmin",          # Pour Cloud Armor
    "roles/cloudsql.admin",                      # Pour gérer Cloud SQL
    "roles/dns.admin",                      # Pour Cloud DNS
    "roles/storage.admin",                  # Pour gérer les buckets (optionnel)
    "roles/cloudsql.client",                # Pour que les instances accèdent à SQL
    "roles/redis.admin",                    # Si tu ajoutes Memorystore plus tard
    "roles/run.admin",                      # Si tu ajoutes Cloud Run plus tard
    "roles/compute.loadBalancerAdmin",      # Pour attacher les backends
  ]
}

variable "deployment_name" {
  type        = string
  description = "Préfixe de nommage des ressources compute"
}

variable "project_id" {
  type        = string
  description = "ID du projet GCP"
  
}