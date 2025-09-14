variable "name" {
  type = string
}

variable "functions" {
  type = list(object({
    name       = string
    handler    = string
    runtime    = string
    memory     = number
    timeout    = number
    publish    = bool
    git_repo   = string
    git_branch = string
    env        = map(string)
    role_arn   = string
    vpc_config = object({
      subnet_ids        = optional(list(string), [])
      security_group_ids = optional(list(string), [])
    })
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
