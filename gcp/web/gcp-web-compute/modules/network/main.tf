// =============== VPC ====================
resource "google_compute_network" "vpc" {
  name                    = var.network_name                     // Nom du réseau
  auto_create_subnetworks = false                                  // On gère manuellement les subnets
  description             = "VPC network for SaaS deployment"
}

// =============== Subnets ====================
resource "google_compute_subnetwork" "subnets" {
  for_each      = { for s in var.subnets : s.zone => s }           // Création dynamique par zone
  name           = "${var.network_name}-${each.key}"            // Ex: "saas-net-europe-west3-a"
  ip_cidr_range  = each.value.cidr                                // Plage CIDR fournie en variable
  region         = var.region                                     // Région du sous-réseau
  network        = google_compute_network.vpc.id                  // Référence à la VPC créée
  description    = "Subnet in zone ${each.key}"                  // Tag de la zone
}

// =============== Cloud NAT ====================
resource "google_compute_router" "nat_router" {
  name    = "${var.network_name}-nat-router"                    // Routeur pour NAT
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "${var.network_name}-nat"     
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"                   
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" 
}

