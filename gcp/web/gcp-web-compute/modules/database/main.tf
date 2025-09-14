locals {
  project = var.project_id
}

## =============== Private VPC Connection ====================
// Pour connecter Cloud SQL en IP privée, on crée une connexion de réseau privé
// et une plage d’adresses IP réservée pour le peering.

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_self_link  # ou var.network, si c’est un nom et pas un self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.deployment_name}-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       =  var.network_self_link  # même VPC que Cloud SQL
}

// =============== Cloud SQL Instance ====================
resource "google_sql_database_instance" "db" {
  project           = local.project
  name              = "${var.deployment_name}-sql"
  database_version  = var.db_version
  region            = var.region

  settings {
    tier             = var.db_tier
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"
    backup_configuration {
      enabled = true
      binary_log_enabled      = true
      start_time = var.backup_start_time
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }
   
  }

  // Standby dans une autre zone pour HA
  deletion_protection = var.high_availability

depends_on = [google_service_networking_connection.private_vpc_connection]
}


// =============== Database and User ====================
resource "google_sql_database" "app_db" {
  project    = local.project
  instance   = google_sql_database_instance.db.name
  name       = var.database_name
}

resource "google_sql_user" "app_user" {
  project    = local.project
  instance   = google_sql_database_instance.db.name
  name       = var.user_name
  password   = var.user_password
}