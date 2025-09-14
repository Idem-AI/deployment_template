output "vpc_network_name" {
  description = "Nom du réseau VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_network_self_link" {
  description = "Lien complet du réseau VPC"
  value       = google_compute_network.vpc.self_link
}

output "vpc_access_connector_name" {
  description = "Nom du VPC Access Connector"
  value       = google_vpc_access_connector.main.name
}

output "vpc_access_connector_id" {
  description = "ID complet du VPC Access Connector"
  value       = google_vpc_access_connector.main.id
}

output "vpc_access_connector_self_link" {
  description = "Self link du VPC Access Connector"
  value       = google_vpc_access_connector.main.self_link
}
output "vpc_peering_range_name" {
  description = "Nom de la plage d'adresses pour le peering VPC"
  value       = google_compute_global_address.vpc_peering_range.name
}