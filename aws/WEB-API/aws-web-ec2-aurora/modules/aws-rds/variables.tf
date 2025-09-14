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

variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "username" {
  description = "Master DB username"
  type        = string
}

variable "password" {
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

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "VPC security group IDs"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
