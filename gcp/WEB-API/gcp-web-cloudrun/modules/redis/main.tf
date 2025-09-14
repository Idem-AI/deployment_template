locals {
  computed_primary_zone   = coalesce(var.redis_primary_zone, "${var.region}-b")
  computed_secondary_zone = coalesce(var.redis_secondary_zone, "${var.region}-c")
}

resource "google_redis_instance" "main" {
  count = var.enable_redis ? 1 : 0
  name                    = "${var.deployment_name}-cache"
  display_name            = "${var.deployment_name}-cache"
  project                 = var.project_id
  tier                    = var.redis_tier
  memory_size_gb          = var.redis_memory_size_gb
  redis_version           = var.redis_version
  authorized_network      = var.authorized_network
  connect_mode            = "DIRECT_PEERING"
  transit_encryption_mode = "DISABLED"
  labels                  = var.labels
  location_id             = local.computed_primary_zone
  #location_id = var.redis_tier == "STANDARD_HA" ? local.computed_primary_zone : var.region

  alternative_location_id =  var.redis_tier == "STANDARD_HA" ? local.computed_secondary_zone : null
}
