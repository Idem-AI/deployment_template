output "network_self_link" {
  value       = google_compute_network.vpc.self_link
  description = "Lien complet de la VPC créée"
}

output "subnet_ids" {
  value       = [for s in google_compute_subnetwork.subnets : s.id]
  description = "Liste des IDs des subnets créés"
}

output "nat_router_name" {
  value       = google_compute_router.nat_router.name
  description = "Nom du routeur Cloud NAT configuré"
}