# main.tf
##############################################################################
#                         REQUIRED PROVIDERS & VERSIONS                      #
##############################################################################
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0"
    }
  }
}

##############################################################################
#                                    PROVIDER                                #
##############################################################################
provider "google" {
  project = var.project_id
  region  = var.region
#  credentials = file("terraform-sa.json")
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
#  credentials = file("terraform-sa.json")
}


##############################################################################
#                                    ACTIVATE APIS                           #
##############################################################################

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "18.0.0"
  disable_services_on_destroy = false

  project_id  = var.project_id
  enable_apis = true

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
  ]
}

 
##############################################################################
#                              NETWORKING MODULE                              #
##############################################################################

module "networking" {
  source = "./modules/networking"

  project_id        = var.project_id
  region            = var.region
  deployment_name   = var.deployment_name
  environment       = var.environment

  depends_on = [ module.project-services ]
}

module "database" {
  source = "./modules/cloud-sql"

  project_id                = var.project_id
  region                    = var.region
  name                      = var.name
  db_name                   = var.db_name
  engine                    = var.db_engine
  db_version                = var.db_version
  db_tier                   = var.db_tier
  disk_size_gb              = var.disk_size_gb
  disk_type                 = var.disk_type
  enable_ha                 = var.enable_ha
  enable_replication        = var.enable_replication
  enable_binlog             = var.enable_binlog
  backup_start_time         = var.backup_start_time
  network_self_link         =    module.networking.vpc_network_self_link
  db_user                   = var.db_user
  db_password               = var.db_password
  enable_deletion_protection= var.enable_deletion_protection
  spanner_nodes             = var.spanner_nodes
  spanner_processing_units  = var.spanner_processing_units
  spanner_multi_region      = var.spanner_multi_region
  spanner_ddl               = var.spanner_ddl

  depends_on = [ module.networking ]
  
}

module "cloud_run" {
  source = "./modules/cloud-run"

  project_id        = var.project_id
  region            = var.region
  connection_name   = try(module.database.sql_instance_connection_name, "")
  spanner_instance  = try(module.database.spanner_instance_name, "")
  spanner_database  = try(module.database.spanner_database_name, "")
  spanner_connection_uri = try(module.database.spanner_connection_uri, "") 
    db_engine         = var.db_engine
    host             = try(module.database.sql_credentials.host, "")
    username         = try(module.database.sql_credentials.username, "")
    password        = try(module.database.sql_credentials.password, "")
  deployment_name   = var.deployment_name
  environment       = var.environment
  services          = var.services
  enable_observability = var.enable_observability
  vpc_connector     = module.networking.vpc_access_connector_name
  dns_zone          = var.dns_zone
  common_labels     = var.common_labels
  enable_redis      = var.enable_redis
  redis_host        = try(module.redis.redis_instance_name, "")
  redis_port        = try(module.redis.redis_instance_port, "")
  run_roles         = var.run_roles

  depends_on = [
    module.networking,
    module.database
  ]
}

module "redis" {
  source               = "./modules/redis"
  enable_redis         = var.enable_redis
  deployment_name      = var.deployment_name
  project_id           = var.project_id
  region               = var.region
  redis_memory_size_gb = var.redis_memory_size_gb
  labels               = var.labels
  authorized_network   = module.networking.vpc_network_self_link
  redis_tier           = var.redis_tier

}
