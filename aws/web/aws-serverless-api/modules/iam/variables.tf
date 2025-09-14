variable "name" {
  type = string
}

variable "create_lambda_role" {
  type    = bool
  default = false
}

variable "create_amplify_role" {
  type    = bool
  default = false
}

variable "dynamodb_table_arn" {
  type    = string
  default = "" # for policy scoping
}

variable "tags" {
  type    = map(string)
  default = {}
}
