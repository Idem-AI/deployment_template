output "instance_template_self_link" {
  value       = google_compute_instance_template.template.self_link
  description = "Self-link de l'instance template"
}

output "instance_group" {
  value       = var.single_zone ? google_compute_instance_group_manager.mig_single[0].instance_group : google_compute_region_instance_group_manager.mig_regional[0].instance_group
  description = "Groupe d'instances pour les backends"
}

output "backend_group" {
  value       = google_compute_backend_service.backend.id
  description = "ID du Backend Service à utiliser par les LB"
}

output "backend_service_name" {
  value       = google_compute_backend_service.backend.name
  description = "Nom du backend service (à utiliser dans l'External LB)"
}

output "backend_group_ids" {
  value = [
    for mig in (
      var.single_zone ?
      [google_compute_instance_group_manager.mig_single[0].instance_group] :
      [for k, v in google_compute_region_instance_group_manager.mig_regional : v.instance_group]
    ) : mig
  ]
  description = "Liste des self_links des groupes d’instances"
}