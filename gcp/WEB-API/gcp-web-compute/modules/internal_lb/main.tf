locals {
  project = var.project_id
}

// =============== Health Check ====================
resource "google_compute_health_check" "internal_hc" {
  project = local.project
  name    = "${var.deployment_name}-int-hc"

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}

// =============== Backend Service ====================
resource "google_compute_region_backend_service" "internal_backend" {
  name                  = "${var.deployment_name}-int-backend"
  region                = var.region
  project               = local.project
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"
  health_checks         = [google_compute_health_check.internal_hc.id]
  backend {
    group = var.backend_group
    balancing_mode  = "UTILIZATION"  
    capacity_scaler = 1.0
  }
}

// =============== URL Map ====================
resource "google_compute_region_url_map" "internal_map" {
  name    = "${var.deployment_name}-int-map"
  region  = var.region
  default_service = google_compute_region_backend_service.internal_backend.id
  project = local.project
}

// =============== Target HTTP Proxy ====================
resource "google_compute_region_target_http_proxy" "internal_proxy" {
  name    = "${var.deployment_name}-int-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.internal_map.id
  project = local.project
}

// =============== Forwarding Rule ====================
resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "${var.deployment_name}-proxy-subnet"
  ip_cidr_range = "10.129.0.0/23"  # Choisis une plage CIDR libre
  region        = var.region
  network       = var.network
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  project       = local.project
}
