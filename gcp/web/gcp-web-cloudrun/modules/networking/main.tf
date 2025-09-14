locals {
  # Préfixe unique utilisé dans tous les noms de ressource
  name_prefix = "${var.deployment_name}-${var.environment}"
}
##############################################################################
#                              VPC & NETWORK                                 #
##############################################################################
# 1) Création du VPC principal
resource "google_compute_network" "vpc" {
  provider                = google-beta
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = true
}

# 2) Réservation d’une plage d’adresses internes destinée au peering
resource "google_compute_global_address" "vpc_peering_range" {
  provider       = google-beta
  name           = "${local.name_prefix}-peering-range"
  purpose        = "VPC_PEERING"
  address_type   = "INTERNAL"
  prefix_length  = 16
  network        = google_compute_network.vpc.self_link
  project        = var.project_id
}

# 3) Établissement du peering entre votre VPC et le service Service Networking
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                 = google-beta
  network                  = google_compute_network.vpc.self_link
  service                  = "servicenetworking.googleapis.com"
  reserved_peering_ranges  = [google_compute_global_address.vpc_peering_range.name]

  # Définit le comportement à la suppression : on abandonne la connexion
  deletion_policy          = "ABANDON" 
  depends_on               = [google_compute_global_address.vpc_peering_range]
}

# 4) Pause avant destruction du VPC (évite les suppressions trop rapides)
resource "time_sleep" "wait_before_destroy" {
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  destroy_duration = "60s"
}


##############################################################################
#                              VPC ACCESS CONNECTOR                          #
##############################################################################

resource "google_vpc_access_connector" "main" {
  provider       = google-beta
  project        = var.project_id
  name           = "${var.deployment_name}-connector"
  ip_cidr_range  = "10.8.0.0/28"
  network        = google_compute_network.vpc.name
  region         = var.region
  max_throughput = 300
  min_throughput = 200
  depends_on     = [time_sleep.wait_before_destroy]
}
