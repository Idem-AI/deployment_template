locals {
  project = var.project_id
}


##############################################################################
#                          COMPUTE RESOURCES                                 #
##############################################################################

// =============== Instance Template ====================
resource "google_compute_instance_template" "template" {
  project      = local.project
  name         = "${var.deployment_name}-tmpl"
  machine_type = var.instance_template.machine_type
  tags         = var.instance_template.tags

  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/${var.instance_template.image_project}/global/images/family/${var.instance_template.image_family}"
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  metadata = var.instance_template.metadata
}

// =============== Managed Instance Group ====================
resource "google_compute_region_instance_group_manager" "mig_regional" {
  count                      = var.single_zone ? 0 : 1
  project                    = local.project
  name                       = "${var.deployment_name}-mig-regional"
  region                     = var.region
  base_instance_name         = "${var.deployment_name}-inst"

  version {
    instance_template = google_compute_instance_template.template.self_link
  }

  target_size               = var.target_size
  distribution_policy_zones = var.zones
}

resource "google_compute_instance_group_manager" "mig_single" {
  count              = var.single_zone ? 1 : 0
  project            = local.project
  name               = "${var.deployment_name}-mig-single"
  zone               = var.zones[0]
  base_instance_name = "${var.deployment_name}-inst"

  version {
    instance_template = google_compute_instance_template.template.self_link
  }

  target_size        = var.target_size
}

// =============== Backend Service ====================
resource "google_compute_backend_service" "backend" {
  project     = local.project
  name        = "${var.deployment_name}-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10
  enable_cdn  = false

  // Health check must be defined for backend service
  health_checks = [google_compute_health_check.default.id]

  // Backend group: choisissez le groupe d'instances selon le mode
  backend {
    group = var.single_zone ? google_compute_instance_group_manager.mig_single[0].instance_group : google_compute_region_instance_group_manager.mig_regional[0].instance_group
  }
}

// Health check par défaut pour le backend
resource "google_compute_health_check" "default" {
  project = local.project
  name    = "${var.deployment_name}-hc"
  http_health_check {
    request_path = "/"
    port         = 80
  }
}