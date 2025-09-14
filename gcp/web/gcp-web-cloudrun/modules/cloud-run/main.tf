
# Récupère le projet et la zone par défaut de l’authentifié
data "google_client_config" "current" {}


##############################################################################
#                                    LOCALS                                  #
##############################################################################
locals {
  # Préfixe unique utilisé dans tous les noms de ressource
  name_prefix = "${var.deployment_name}-${var.environment}"
  
  # Filtre les services nécessitant un LB HTTPS / CDN / domaine
  lb_services = {
    for k, svc in var.services : k => svc
    if svc.expose_lb == true
  }

  # Filtre les services nécessitant WAF
  waf_services = {
    for k, svc in var.services : k => svc
    if svc.enable_waf == true
  }
}

##############################################################################
#                          SERVICE ACCOUNT & IAM                             #
##############################################################################
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${local.name_prefix}-run-sa"
  display_name = "SvcAcc Cloud Run – ${local.name_prefix}"
}

resource "google_project_iam_member" "run_sa_roles" {
  for_each = var.run_roles

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

##############################################################################
#                           CLOUD RUN SERVICES                               #
##############################################################################
resource "google_cloud_run_v2_service" "services" {
  for_each = var.services

  name     = each.value.name
  location = var.region
  deletion_protection = false 
  
  # 0) Labels globaux pour traçabilité et facturation
  labels = merge(
    var.common_labels,
    {
      "env"         = var.environment
      "deployment"  = var.deployment_name
      "service_key" = each.key
    }
  )

  template {
      # 1) Comptes de service & permissions
    service_account = google_service_account.cloud_run_sa.email

    # Container configuration
    containers {
      image = each.value.image

      ports {
        container_port = each.value.port
      }

      # Variables d’environnement dynamiques
      dynamic "env" {
        for_each = each.value.environment
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
      # Ajouter automatiquement les infos DB si needed
      dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "sql" ? [1] : []
  content {
    name  = "DB_HOST"
    value = var.host
  }
}

dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "sql" ? [1] : []
  content {
    name  = "DB_USERNAME"
    value =var.username
  }
}

dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "sql" ? [1] : []
  content {
    name  = "DB_PASSWORD"
    value = var.password
  }
}

dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "sql" ? [1] : []
  content {
    name  = "DB_NAME"
    value = var.db_name
  }
}

dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "sql" ? [1] : []
  content {
    name  = "DB_CONNECTION_NAME"
    value = var.connection_name
  }
}

 dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "spanner" ? [1] : []
  content {
    name  = "SPANNER_INSTANCE"
    value = var.spanner_instance
  }
}

dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "spanner" ? [1] : []
  content {
    name  = "SPANNER_DATABASE"
    value = var.spanner_database
  }
}

dynamic "env" {
  for_each = each.value.needs_database && var.db_engine == "spanner" ? [1] : []
  content {
    name  = "SPANNER_CONNECTION_URI"
    value = var.spanner_connection_uri
  }
}
# ➕ Observabilité : Cloud Trace / Logging / Error Reporting
dynamic "env" {
  for_each = var.enable_observability ? [1] : []
  content {
    name  = "ENABLE_TRACING"
    value = "true"
  }
}

dynamic "env" {
  for_each = var.enable_observability ? [1] : []
  content {
    name  = "ENABLE_LOGGING"
    value = "true"
  }
}

dynamic "env" {
  for_each = var.enable_observability ? [1] : []
  content {
    name  = "ENABLE_ERROR_REPORTING"
    value = "true"
  }
}
# ➕ Redis
dynamic "env" {
  for_each = var.enable_redis ? [1] : []
  content {
    name  = "REDIS_HOST"
    value = var.redis_host
  }
}

dynamic "env" {
  for_each = var.enable_redis ? [1] : []
  content {
    name  = "REDIS_PORT"
    value = tostring(var.redis_port)
  }
}
      # Resources CPU / Mémoire
      resources {
        limits = {
          cpu    = each.value.resources.cpu
          memory = each.value.resources.memory
        }
      }
    }

    ##################################################
    #          AUTOSCALING / MIN/MAX                 #
    ##################################################
    scaling {
      min_instance_count = each.value.scaling.min
      max_instance_count = each.value.scaling.max
    }

    ##################################################
    #           CLOUD SQL / VPC ACCESS               #
    ##################################################
    # Cloud SQL
    dynamic "volumes" {
      for_each = each.value.needs_database && var.db_engine == "sql" ? [1] : []
      content {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [var.connection_name]
        }
      }
    }

    # VPC Access
    dynamic "vpc_access" {
      for_each = each.value.vpc_connector != "" ? [1] : []
      content {
        connector = "projects/${var.project_id}/locations/${var.region}/connectors/${var.vpc_connector}"
        egress    = each.value.vpc_egress   # ex. "ALL_TRAFFIC"
      }
    }
    
  }

  ##################################################
  #             TRAFIC & INGRESS                   #
  ##################################################
  # Dans v2, tout le trafic va par défaut à la dernière révision
  ingress = each.value.ingress  

}

# Autoriser tous à invoquer (ou restreindre via var.invoker_member)
resource "google_cloud_run_service_iam_member" "invoker" {
  for_each = var.services

  service  = google_cloud_run_v2_service.services[each.key].name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
} 

##############################################################################
#                          NEG                                               # 
##############################################################################

resource "google_compute_region_network_endpoint_group" "neg" {
  for_each = var.services
  name                  = "${each.key}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service  = google_cloud_run_v2_service.services[each.key].name
  }
}
##############################################################################
#                      MANAGED SSL CERTIFICATES                              #
##############################################################################
resource "google_compute_managed_ssl_certificate" "ssl" {
  for_each = {
    for k, svc in local.lb_services : k => svc
    if svc.domain_name != ""
  }

  name = "${local.name_prefix}-${each.key}-ssl"

  managed {
    domains = [each.value.domain_name]
  }
}

##############################################################################
#                              BACKEND SERVICES                              #
##############################################################################
resource "google_compute_backend_service" "lb_backend" {
  for_each = local.lb_services

  name                  = "${local.name_prefix}-${each.key}-backend"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"

 backend {
    group = google_compute_region_network_endpoint_group.neg[each.key].id
  }


  enable_cdn = each.value.enable_cdn

  # WAF policy
  security_policy = google_compute_security_policy.waf[each.key].self_link

  depends_on = [google_cloud_run_v2_service.services]
}

##############################################################################
#                             URL MAP & PROXY                                #
##############################################################################
resource "google_compute_url_map" "url_map" {
  for_each = google_compute_backend_service.lb_backend

  name            = "${local.name_prefix}-${each.key}-urlmap"
  default_service = each.value.self_link
 

}

resource "google_compute_target_https_proxy" "https_proxy" {
  for_each = google_compute_url_map.url_map

  name             = "${local.name_prefix}-${each.key}-httpsproxy"
  url_map          = each.value.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl[each.key].self_link]
}

resource "google_compute_global_forwarding_rule" "fwd" {
  for_each = google_compute_target_https_proxy.https_proxy

  name        = "${local.name_prefix}-${each.key}-fwd"
  target      = each.value.self_link
  port_range  = "443"
  ip_protocol = "TCP"
}

##############################################################################
#                             DNS RECORDS                                    #
##############################################################################
resource "google_dns_record_set" "dns" {
  for_each = {
    for k, svc in local.lb_services : k => svc
    if svc.domain_name != ""
  }

  name         = "${each.value.domain_name}."
  type         = "A"
  ttl          = var.dns_ttl
  managed_zone = var.dns_zone
  rrdatas      = [google_compute_global_forwarding_rule.fwd[each.key].ip_address]
}

##############################################################################
#                            CLOUD ARMOR (WAF)                               #
##############################################################################
resource "google_compute_security_policy" "waf" {
  for_each = local.waf_services

  name = "${local.name_prefix}-${each.key}-waf"

  rule {
  priority    = 2147483647
  description = "Default rule to allow all"
  match {
    versioned_expr = "SRC_IPS_V1"
    config {
      src_ip_ranges = ["*"]
    }
  }
  action = "allow" # ou "deny(403)" si tu veux bloquer par défaut
}

  dynamic "rule" {
    for_each = each.value.waf_rules
    content {
      priority       = rule.value.priority
      action         = rule.value.action
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value.source_ranges
        }
      }
    }
  }

 # depends_on = [google_compute_backend_service.lb_backend]
}



