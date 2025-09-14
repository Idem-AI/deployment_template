
output "internal_health_check_name" {
  description = "Nom du health check interne"
  value       = google_compute_health_check.internal_hc.name
}
output "internal_health_check_self_link" {
  description = "Self-link du health check interne"
  value       = google_compute_health_check.internal_hc.self_link
}

