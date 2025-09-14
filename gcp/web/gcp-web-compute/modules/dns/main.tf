locals {
  project = var.project_id
}

// =============== Zone DNS ====================
/*resource "google_dns_managed_zone" "zone" {
  project     = local.project
  name        = var.dns_zone_name
  dns_name    = "${var.domain}."
  description = "Zone DNS pour le domaine ${var.domain}"
}*/

// =============== Enregistrement A ================
resource "google_dns_record_set" "lb_record" {
  project      = local.project
  managed_zone = var.dns_zone_name
  name         = "${var.domain}."  // ex: www.tech.cm.
  type         = "A"
  ttl          = var.ttl
  rrdatas      = [var.ip_address]  // ou output d’un resource global_address
}
