output "armor_policy_name" {
  value       = google_compute_security_policy.armor_policy.name
  description = "Nom de la policy Cloud Armor créée"
}

output "armor_attached" {
  value       = var.enable_armor
  description = "Boolean indiquant si la policy a été attachée"
}