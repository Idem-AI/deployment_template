############################
# main.tf
############################


resource "google_sql_database_instance" "db" {
  count              = var.engine == "sql" ? 1 : 0

  name               = "${var.name}-sql"
  project            = var.project_id
  database_version   = var.db_version
  region             = var.region
  deletion_protection = var.enable_deletion_protection

  settings {
    tier              = var.db_tier
    availability_type = var.enable_ha ? "REGIONAL" : "ZONAL"
    disk_autoresize   = true
    disk_size         = var.disk_size_gb
    disk_type         = var.disk_type

    backup_configuration {
      enabled             = true
      start_time          = var.backup_start_time
      binary_log_enabled  = var.enable_binlog
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }

    dynamic "database_flags" {
      for_each = var.engine == "mysql" && (var.enable_ha || var.enable_replication) ? [1] : []
      content {
        name  = "log_bin"
        value = "on"
      }
    }
  }

 
}

resource "google_sql_user" "default" {
  count      = var.engine == "sql" ? 1 : 0
  name       = var.db_user
  instance   = google_sql_database_instance.db[0].name
  password   = var.db_password
}

resource "google_sql_database" "default" {
  count      = var.engine == "sql" ? 1 : 0
  name       = var.db_name
  instance   = google_sql_database_instance.db[0].name
}

# Read replica si activé
resource "google_sql_database_instance" "replica" {
  count                   = var.engine == "sql" && var.enable_replication ? 1 : 0

  name                    = "${var.name}-replica"
  project                 = var.project_id
  region                  = var.region
  database_version        = var.db_version
  master_instance_name    = google_sql_database_instance.db[0].name

  replica_configuration {
    failover_target = true
  }

  settings {
    tier              = var.db_tier
    availability_type = var.enable_ha ? "REGIONAL" : "ZONAL"
    disk_autoresize   = true
    disk_size         = var.disk_size_gb
    disk_type         = var.disk_type
  }
}

# Cloud Spanner Instance
resource "google_spanner_instance" "default" {
  count               = var.engine == "spanner" ? 1 : 0

  name                = "${var.name}-spanner"
  project             = var.project_id
  config              = var.spanner_multi_region ? "regional-${var.region}" : "regional-${var.region}"
  display_name        = "${var.name}-spanner"
  num_nodes           = var.spanner_nodes
  processing_units    = var.spanner_processing_units
}

resource "google_spanner_database" "default" {
  count               = var.engine == "spanner" ? 1 : 0

  name                = var.db_name
  instance            = google_spanner_instance.default[0].name
  ddl                 = var.spanner_ddl
}
