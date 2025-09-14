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
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.external_proxy.self_link
}

// =============== Cloud Armor Policy ====================
resource "google_compute_security_policy" "armor_policy" {
  project     = local.project
  name        = "${var.deployment_name}-armor-policy"
  description = "Policy Cloud Armor pour protéger le LB externe"

  dynamic "rule" {
    for_each = var.custom_rules
    content {
      priority    = rule.value.priority
      action      = rule.value.action
      description = rule.value.description

      match {
        versioned_expr = rule.value.versioned_expr
        config {
          src_ip_ranges = rule.value.src_ip_ranges
        }
      }

      # Si une expression CEL personnalisée est fournie, on la place après le match
      # (Terraform provider GCP supporte un bloc `expression` pour filtrer via CEL)
     /* dynamic "expression" {
        for_each = rule.value.custom_expr != "" ? [rule.value.custom_expr] : []
        content {
          expression = expression.value
        }
      }
      */
    }
  }
}

