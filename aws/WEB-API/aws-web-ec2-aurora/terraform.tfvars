# -------------------
# VPC
# -------------------
VPC-NAME         = "idem-vpc"
VPC-CIDR         = "10.0.0.0/16"
IGW-NAME         = "idem-igw"

PUBLIC-CIDR1     = "10.0.1.0/24"
PUBLIC-SUBNET1   = "idem-public-subnet1"
PUBLIC-CIDR2     = "10.0.2.0/24"
PUBLIC-SUBNET2   = "idem-public-subnet2"

PRIVATE-CIDR1    = "10.0.11.0/24"
PRIVATE-SUBNET1  = "idem-private-subnet1"
PRIVATE-CIDR2    = "10.0.12.0/24"
PRIVATE-SUBNET2  = "idem-private-subnet2"

EIP-NAME1        = "idem-eip1"
EIP-NAME2        = "idem-eip2"

NGW-NAME1        = "idem-ngw1"
NGW-NAME2        = "idem-ngw2"

PUBLIC-RT-NAME1  = "idem-public-rt1"
PUBLIC-RT-NAME2  = "idem-public-rt2"

PRIVATE-RT-NAME1 = "idem-private-rt1"
PRIVATE-RT-NAME2 = "idem-private-rt2"

# -------------------
# SECURITY GROUPS
# -------------------
ALB-SG-NAME = "idem-alb-sg"
WEB-SG-NAME = "idem-web-sg"
DB-SG-NAME  = "idem-db-sg"

# -------------------
# RDS (Aurora MySQL)
# -------------------
db_engine_type        = "rds"
engine                = "postgres"
engine_version        = "13.15"
rds_name              = "idem-dev-db"
db_username           = "idemadmin"
db_password           = "DevSecretPwd123!"
db_name               = "idemdevdb"
allocated_storage     = 20
instance_class        = "db.t3.small"
aurora_instance_count = 0
multi_az              = false
enable_read_replica   = false
publicly_accessible   = false
backup_retention      = 3
tags = {
  Env     = "dev"
  Project = "idem-saas"
}

# REDIS (ElastiCache)
#-------------  ------

# Redis configuration
name                  = "idem-redis"
node_type             = "cache.t3.small"
num_cache_clusters    = 2
redis_engine_version        = "6.x"
parameter_group_name  = "default.redis6.x"


# Replication and failover
replication_enabled         = true
automatic_failover_enabled  = true

# Tags

# Feature toggle
enable_redis = true


# -------------------
# ALB
# -------------------
TG-NAME   = "idem-tg"
ALB-NAME  = "idem-alb"

# -------------------
# IAM
# -------------------
IAM-ROLE              = "idem-ec2-role"
IAM-POLICY            = "idem-ec2-policy"
INSTANCE-PROFILE-NAME = "idem-ec2-instance-profile"

# -------------------
# AUTOSCALING
# -------------------
AMI-NAME              = "amzn2-ami-hvm"
LAUNCH-TEMPLATE-NAME  = "idem-launch-template"
ASG-NAME              = "idem-asg"

# -------------------
# CLOUDFRONT
# -------------------
DOMAIN-NAME = "azopat.cm"
CDN-NAME    = "idem-cdn"

# -------------------
# WAF
# -------------------
WEB-ACL-NAME = "idem-web-acl"
