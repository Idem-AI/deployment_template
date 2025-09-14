locals {
  project = var.project_id
}

// =============== Backend Service avec CDN ====================
resource "google_compute_health_check" "cdn_hc" {
  project = local.project
  name    = "${var.deployment_name}-cdn-hc"

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}

resource "google_compute_backend_service" "cdn_enabled" {

  project      = local.project
  name         = "${var.deployment_name}-cdn-backend"
  protocol     = var.protocol
  timeout_sec  = var.timeout_sec
  enable_cdn   = true
  health_checks = [google_compute_health_check.cdn_hc.id]

  backend {
    group = var.backend_group
  }

  cdn_policy {
    cache_mode  = var.cache_mode
    default_ttl = var.default_ttl
    cache_key_policy {
    include_host          = true
    include_protocol      = true
    include_query_string  = true
  
    }
  }
}