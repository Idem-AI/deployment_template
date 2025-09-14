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

variable "engine_version" {
  type    = string
  default = "6.x"
}

variable "parameter_group_name" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "replication_enabled" {
  type    = bool
  default = false
}

variable "automatic_failover_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
