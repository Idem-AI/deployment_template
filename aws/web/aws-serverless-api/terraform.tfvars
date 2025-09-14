########################
# terraform.tfvars
# Values for serverless template
########################

# --- Global settings ---
aws_region  = "eu-west-1"
name        = "idem-serverless-app"
environment = "dev"

tags = {
  Project     = "ServerlessTemplate"
  Environment = "dev"
}

# --- Feature toggles ---
enable_api       = true
enable_dynamodb  = true
enable_amplify   = false

# --- IAM roles ---
lambda_role_arn  = ""  # If empty, module will create a new Lambda role
amplify_role_arn = ""  # If empty, module will create a new Amplify role
create_iam_for_dev = true

# --- Lambda functions ---
functions = [
    {
      name       = "hello"
      handler    = "index.handler"
      runtime    = "nodejs18.x"
      memory     = 128
      timeout    = 10
      publish    = true
      git_repo   = "https://github.com/Idem-IA/idem-api.git"
      git_branch = "main"
      env        = { ENV = "dev" }
      role_arn   = ""
      vpc_config = {
        subnet_ids        = []
        security_group_ids = []
      }
    },
    {
      name       = "process"
      handler    = "app.lambda_handler"
      runtime    = "nodejs18.x"
      memory     = 256
      timeout    = 15
      publish    = true
      git_repo   = "https://github.com/Idem-IA/idem-api.git"
      git_branch = "dev"
      env        = { STAGE = "dev" }
      role_arn   = ""
      vpc_config = {
        subnet_ids        = []
        security_group_ids = []
      }
    }
  ]

# --- API Gateway ---
api_routes = [
  {
    path = "students"
    methods = [
      { http_method = "GET",  lambda_name = "hello",  authorization = "NONE", enable_cors = true },
      { http_method = "POST", lambda_name = "process", authorization = "NONE", enable_cors = true }
    ]
  }
]

# --- DynamoDB ---
dynamodb_table_name   = "students"
dynamodb_billing_mode = "PAY_PER_REQUEST"
dynamodb_read_capacity  = 5
dynamodb_write_capacity = 5
dynamodb_hash_key     = "id"

# --- Amplify ---
amplify = {
  app_name    = "my-app"
  repository  = "https://github.com/Idem-IA/idem.git"
  branch      = "main"
  domain_name = "azopat.cm"
}

# --- Observability ---
enable_observability = true

# --- Backend state ---
tf_state_bucket          = "my-terraform-state-bucket"
tf_state_dynamodb_table  = "terraform-locks"
