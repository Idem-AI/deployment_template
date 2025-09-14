variable "project_id"         { type = string }
variable "region"             { type = string }
variable "zones"              { type = list(string) }
variable "single_zone"        { type = bool }
variable "deployment_name"    { type = string }

variable "network_name"       { type = string }
variable "subnets"            { type = list(object({ zone=string, cidr=string })) }

variable "instance_template" {
  type = object({
    machine_type  = string
    image_family  = string
    image_project = string
    tags          = list(string)
    metadata      = map(string)
  })
}
variable "target_size" {
  type = number
}

variable "domains" {
  type = list(string)
}

variable "enable_cdn" {
  type = bool
}

variable "health_check_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}
variable "credentials_file" {
  type        = string
  description = "Chemin vers le fichier de credentials GCP" 
  
}
variable "db_tier" {
  type = string
}

variable "db_version" {
  type = string
}

variable "high_availability" {
  type    = bool
  default = false
}

variable "backup_start_time" {
  type    = string
  default = "03:00"
}

variable "database_name" {
  type = string
}

variable "user_name" {
  type = string
}

variable "user_password" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "record_name" {
  type = string
}

variable "ttl" {
  type    = number
  default = 300
}

variable "cdn_protocol" {
  type    = string
  default = "HTTP"
}

variable "cdn_timeout_sec" {
  type    = number
  default = 30
}

variable "cache_mode" {
  type    = string
  default = "CACHE_ALL_STATIC"
}

variable "default_ttl" {
  type    = number
  default = 3600
}


variable "enable_apis" {
  description = "Active la création des services GCP nécessaires (APIs)"
  type        = bool
  default     = true
}


variable "enable_armor" {
  type    = bool
  default = false
}
variable "custom_rules"       { type = map(object({ priority=number, action=string, description=string, versioned_expr=string, src_ip_ranges=list(string), custom_expr=string })) }