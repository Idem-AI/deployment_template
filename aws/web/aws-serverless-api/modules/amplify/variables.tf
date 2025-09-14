variable "name" { type = string }
variable "app_name" { type = string }
variable "repository" { type = string }
variable "branch" {
    type = string
 default = "master" 
 }
variable "domain_name" {
  type    = string
  default = ""
}

variable "iam_service_role_arn" {
  type    = string
  default = ""
}

variable "create_iam_role" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
