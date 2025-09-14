terraform {
  required_providers {
    google = { source = "hashicorp/google" 
               version = "~> 4.0"
            }
  }
  required_version = ">= 1.1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
   credentials = file("${var.credentials_file}")
}

module "project_services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "18.0.0"
  disable_services_on_destroy = false

  project_id   = var.project_id
  enable_apis  = var.enable_apis

  activate_apis = [
    "compute.googleapis.com",
    "cloudapis.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "redis.googleapis.com",
    "dns.googleapis.com",
    "networkservices.googleapis.com",
    "iap.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  #  "cloudarmor.googleapis.com"
  ]
}

module "iam" {
  source            = "./modules/iam"
  project_id        = var.project_id
  deployment_name   = var.deployment_name

  depends_on = [ module.project_services ]
}

module "network" {
  source       = "./modules/network"
  deployment_name = var.deployment_name
  project_id   = var.project_id
  network_name = var.network_name
  region       = var.region
  subnets      = var.subnets
  depends_on = [module.iam ]
}

module "compute" {
  source            = "./modules/compute"
  project_id        = var.project_id
  region            = var.region
  zones             = var.zones
  single_zone       = var.single_zone
  deployment_name   = var.deployment_name
  instance_template = var.instance_template
  network           = module.network.network_self_link
  subnet            = module.network.subnet_ids[0]
  target_size       = var.target_size

   depends_on = [ module.iam ]
}

module "internal_lb" {
  source          = "./modules/internal_lb"
  project_id      = var.project_id
  deployment_name = var.deployment_name
  network         = module.network.network_self_link
  subnet          = module.network.subnet_ids[0]
  backend_group   = module.compute.instance_group
  region          = var.region

  depends_on = [ module.iam ]
}

module "external_lb" {
  source            = "./modules/external_lb"
  project_id        = var.project_id
  deployment_name   = var.deployment_name
  domains           = var.domains
  backend_group_ids = module.compute.backend_group_ids
  enable_cdn        = var.enable_cdn
  health_check_port = var.health_check_port
  health_check_path = var.health_check_path
  backend_service_account = module.iam.shared_sa_email

  depends_on = [ module.iam ]
}

module "database" {
  source            = "./modules/database"
  project_id        = var.project_id
  deployment_name   = var.deployment_name
  region            = var.region
  db_tier           = var.db_tier
  db_version        = var.db_version
  high_availability = var.high_availability
  backup_start_time = var.backup_start_time
  network_self_link = module.network.network_self_link
  database_name     = var.database_name
  user_name         = var.user_name
  user_password     = var.user_password

  depends_on = [ module.iam ]
}

module "dns" {
  source        = "./modules/dns"
  project_id    = var.project_id
  dns_zone_name = var.dns_zone_name
  domain        = var.domain
  record_name   = var.record_name
  ttl           = var.ttl
  ip_address    = module.external_lb.external_lb_ip

  depends_on = [ module.iam ]
}

module "cdn" {
  source          = "./modules/cdn"
  project_id      = var.project_id
  deployment_name = var.deployment_name
  protocol        = var.cdn_protocol
  timeout_sec     = var.cdn_timeout_sec
  backend_group   = module.compute.instance_group
  cache_mode      = var.cache_mode
  default_ttl     = var.default_ttl
  enable_cdn      = var.enable_cdn

  depends_on = [ module.iam ]
}

/*module "amor" {
  source               = "./modules/amor"
  project_id           = var.project_id
  deployment_name      = var.deployment_name
  enable_armor         = var.enable_armor
  iam_binding_member   = module.iam.shared_sa_email
  custom_rules         = var.custom_rules
  backend_group_ids    =  module.compute.backend_group_ids 
  domains              = var.domains

  depends_on = [ module.iam ]
}
*/