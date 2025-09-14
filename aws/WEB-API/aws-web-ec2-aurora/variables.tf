# VPC
variable "VPC-NAME" {}
variable "VPC-CIDR" {}
variable "IGW-NAME" {}
variable "PUBLIC-CIDR1" {}
variable "PUBLIC-SUBNET1" {}
variable "PUBLIC-CIDR2" {}
variable "PUBLIC-SUBNET2" {}
variable "PRIVATE-CIDR1" {}
variable "PRIVATE-SUBNET1" {}
variable "PRIVATE-CIDR2" {}
variable "PRIVATE-SUBNET2" {}
variable "EIP-NAME1" {}
variable "EIP-NAME2" {}
variable "NGW-NAME1" {}
variable "NGW-NAME2" {}
variable "PUBLIC-RT-NAME1" {}
variable "PUBLIC-RT-NAME2" {}
variable "PRIVATE-RT-NAME1" {}
variable "PRIVATE-RT-NAME2" {}

# SECURITY GROUP
variable "ALB-SG-NAME" {}
variable "WEB-SG-NAME" {}
variable "DB-SG-NAME" {}

# RDS
variable "db_engine_type" {
  description = "Type of database: aurora or rds"
  type        = string
  default     = "aurora"
}

variable "engine" {
  description = "Engine type (mysql or postgres)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = ""
}

variable "rds_name" {
  description = "Base name for resources"
  type        = string
}

variable "db_username" {
  description = "Master DB username"
  type        = string
}

variable "db_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "allocated_storage" {
  description = "Storage for RDS instances (ignored for Aurora)"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "Instance class for DB"
  type        = string
  default     = "db.t3.medium"
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 2
}

variable "multi_az" {
  description = "Enable Multi-AZ (RDS only)"
  type        = bool
  default     = true
}

variable "enable_read_replica" {
  description = "Enable read replica (RDS only)"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Should the DB be publicly accessible?"
  type        = bool
  default     = false
}

variable "backup_retention" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}


variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

# REDIS

variable "name" {
  type    = string
  default = "idem-redis"
}

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "num_cache_clusters" {
  type    = number
  default = 1
}

variable "redis_engine_version" {
  type    = string
  default = "6.x"
}

variable "parameter_group_name" {
  type    = string
  default = ""
}

variable "replication_enabled" {
  type    = bool
  default = false
}

variable "automatic_failover_enabled" {
  type    = bool
  default = true
}

variable "enable_redis" { 
  type = bool
  default = false 
 } # optional ElastiCache Redis





# ALB
variable "TG-NAME" {}
variable "ALB-NAME" {}

# IAM
variable "IAM-ROLE" {}
variable "IAM-POLICY" {}
variable "INSTANCE-PROFILE-NAME" {}

# AUTOSCALING
variable "AMI-NAME" {}
variable "LAUNCH-TEMPLATE-NAME" {}
variable "ASG-NAME" {}

# CLOUDFFRONT
variable "DOMAIN-NAME" {}
variable "CDN-NAME" {}

# WAF
variable "WEB-ACL-NAME" {}

#REGION
variable "AWS-REGION" {
  default = "us-east-1"
}
