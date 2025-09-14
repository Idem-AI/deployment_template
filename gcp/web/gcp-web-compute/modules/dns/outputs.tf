

output "record_name" {
  value       = google_dns_record_set.lb_record.name
  description = "Nom de l’enregistrement DNS créé"
}