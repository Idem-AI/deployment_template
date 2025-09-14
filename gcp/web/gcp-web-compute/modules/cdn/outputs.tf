output "cdn_backend_service_name" {
  value       =  var.enable_cdn ? google_compute_backend_service.cdn_enabled.name : null
  description = "Nom du Backend Service avec CDN activé"
}