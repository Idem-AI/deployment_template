########################
# Root variables for serverless template
########################

# --- Global settings ---
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "name" {
  description = "Logical deployment name"
  type        = string
  default     = "idem-serverless-app"
}

variable "environment" {
  description = "Environment: dev/staging/prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev","staging","prod"], var.environment)
    error_message = "environment must be one of dev, staging, prod"
  }
}

variable "tags" {
  description = "Tags applied everywhere"
  type        = map(string)
  default     = {}
}

# --- Feature toggles ---
variable "enable_api" {
  description = "Enable API Gateway"
  type        = bool
  default     = true
}

variable "enable_dynamodb" {
  description = "Enable DynamoDB table"
  type        = bool
  default     = true
}

variable "enable_amplify" {
  description = "Enable Amplify app"
  type        = bool
  default     = false
}

# --- IAM roles ---
variable "lambda_role_arn" {
  description = "Existing IAM role ARN for Lambda (leave empty to create one)"
  type        = string
  default     = ""
}

variable "amplify_role_arn" {
  description = "Existing IAM role ARN for Amplify (leave empty to create one)"
  type        = string
  default     = ""
}

variable "create_iam_for_dev" {
  description = "Create IAM roles for dev convenience (not recommended for prod)"
  type        = bool
  default     = false
}

# --- Lambda functions ---


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


# --- API Gateway ---
variable "api_routes" {
  description = <<EOT
List of objects describing API routes:
[
 { path="students", methods=[ { http_method="GET", lambda_name="getStudent" }, { http_method="POST", lambda_name="addStudent" } ] }
]
EOT
  type = list(object({
    path = string
    methods = list(object({
      http_method   = string
      lambda_name   = string    # corresponds to lambda_functions[].name
      authorization = optional(string,"NONE")
      enable_cors   = optional(bool,true)
    }))
  }))
  default = []
}

# --- DynamoDB ---
variable "dynamodb_table_name" {
  description = "Name of DynamoDB table"
  type        = string
  default     = "students"
}

variable "dynamodb_billing_mode" {
  description = "Billing mode: PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  description = "Read capacity (only if PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Write capacity (only if PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_hash_key" {
  description = "Primary hash key name"
  type        = string
  default     = "id"
}

# --- Amplify ---
variable "amplify" {
  description = "Amplify application configuration"
  type = object({
    app_name    = string
    repository  = string
    branch      = optional(string,"master")
    domain_name = optional(string,"")
  })
  default = {
    app_name    = ""
    repository  = ""
    branch      = "master"
    domain_name = ""
  }
}

# --- Observability ---
variable "enable_observability" {
  description = "Enable logging/monitoring (e.g. CloudWatch)"
  type        = bool
  default     = true
}

# --- Backend state ---
variable "tf_state_bucket" {
  description = "S3 bucket for Terraform remote state"
  type        = string
  default     = ""
}

variable "tf_state_dynamodb_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
  default     = ""
}
