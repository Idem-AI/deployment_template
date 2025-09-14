locals {
  project = var.project_id
}

// =============== SSL Certificate ====================
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  project = local.project
  name    = "${var.deployment_name}-ssl"

  managed {
    domains = var.domains
  }
}

// =============== Backend Service ====================
resource "google_compute_backend_service" "external_backend" {
  project      = local.project
  name         = "${var.deployment_name}-ext-backend"
  protocol     = "HTTP"
  timeout_sec  = 30
  health_checks = [google_compute_health_check.external_hc.id]
  enable_cdn    = var.enable_cdn

  dynamic "backend" {
    for_each = var.backend_group_ids
    content {
      group = backend.value
    }
  }
}

// =============== Health Check ====================
resource "google_compute_health_check" "external_hc" {
  project = local.project
  name    = "${var.deployment_name}-ext-hc"

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}

// =============== URL Map ====================
resource "google_compute_url_map" "external_map" {
  project          = local.project
  name             = "${var.deployment_name}-ext-map"
  default_service  = google_compute_backend_service.external_backend.self_link
}

// =============== Target HTTPS Proxy ====================
resource "google_compute_target_https_proxy" "external_proxy" {
  project          = local.project
  name             = "${var.deployment_name}-ext-proxy"
  url_map          = google_compute_url_map.external_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

// =============== Global Forwarding Rule ====================
resource "google_compute_global_forwarding_rule" "external_fr" {
  project               = local.project
  name                  = "${var.deployment_name}-ext-fr"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.external_proxy.self_link
}

// =============== Cloud Armor Policy ====================
resource "google_compute_security_policy" "armor_policy" {
  count = var.enable_armor ? 1 : 0
  project = local.project
  name    = "${var.deployment_name}-armor"

  rule {
    action = "deny(403)"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.armor_blocked_ips
      }
    }
  }
}

