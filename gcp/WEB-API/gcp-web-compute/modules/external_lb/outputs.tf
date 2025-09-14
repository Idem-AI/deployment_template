output "external_lb_ip" {
  value       = google_compute_global_forwarding_rule.external_fr.ip_address
  description = "IP publique de l'External Load Balancer"
}