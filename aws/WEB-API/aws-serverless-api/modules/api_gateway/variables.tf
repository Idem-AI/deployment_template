variable "name" { type = string }
variable "rest_api_name" { type = string }
variable "rest_api_description" { type = string }
variable "api_routes" {
  type = list(object({
    path = string
    methods = list(object({
      http_method = string
      lambda_name = string
      authorization = optional(string,"NONE")
      enable_cors = optional(bool,true)
    }))
  }))
  default = []
}
variable "stage_name" { 
    type = string
 default = "prod"
  }
variable "tags" { 
    type = map(string)
  default = {} 
 }
