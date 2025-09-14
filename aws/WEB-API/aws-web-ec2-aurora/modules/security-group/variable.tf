variable "vpc_id" {}
variable "alb-sg-name" {}
variable "web-sg-name" {}
variable "db-sg-name" {}
variable "enable_redis" {
  description = "Enable Redis and create related resources"
  type        = bool
  default     = false
}