output "shared_sa_email" {
  value = google_service_account.shared_sa.email
}
output "shared_sa_name" {
  value       = google_service_account.shared_sa.display_name
  description = "Nom du Service Account partagé pour les services GCP"
}