provider "aws" {
  region = var.AWS-REGION
}

# Alias spécifique pour CloudFront (global)
provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/aws-vpc"

  vpc-name        = var.VPC-NAME
  vpc-cidr        = var.VPC-CIDR
  igw-name        = var.IGW-NAME
  public-cidr1    = var.PUBLIC-CIDR1
  public-subnet1  = var.PUBLIC-SUBNET1
  public-cidr2    = var.PUBLIC-CIDR2
  public-subnet2  = var.PUBLIC-SUBNET2
  private-cidr1   = var.PRIVATE-CIDR1
  private-subnet1 = var.PRIVATE-SUBNET1
  private-cidr2   = var.PRIVATE-CIDR2
  private-subnet2 = var.PRIVATE-SUBNET2
  eip-name1       = var.EIP-NAME1
  eip-name2       = var.EIP-NAME2

  ngw-name1        = var.NGW-NAME1
  ngw-name2        = var.NGW-NAME2
  public-rt-name1  = var.PUBLIC-RT-NAME1
  public-rt-name2  = var.PUBLIC-RT-NAME2
  private-rt-name1 = var.PRIVATE-RT-NAME1
  private-rt-name2 = var.PRIVATE-RT-NAME2
}

module "security-group" {
  source = "./modules/security-group"

  alb-sg-name = var.ALB-SG-NAME
  web-sg-name = var.WEB-SG-NAME
  db-sg-name  = var.DB-SG-NAME
  vpc_id      = module.vpc.vpc_id
  enable_redis = var.enable_redis

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/aws-rds"

  db_engine_type       = var.db_engine_type
  engine               = var.engine
  engine_version       = var.engine_version
  name                 = var.rds_name
  username             = var.db_username
  password             = var.db_password
  db_name              = var.db_name
  allocated_storage    = var.allocated_storage
  instance_class       = var.instance_class
  aurora_instance_count = var.aurora_instance_count
  multi_az             = var.multi_az
  enable_read_replica  = var.enable_read_replica
  publicly_accessible  = var.publicly_accessible
  backup_retention     = var.backup_retention
  private_subnet_ids   = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.security-group.database_sg_id]
  tags                 = var.tags
  depends_on = [module.security-group]
}


module "alb" {
  source = "./modules/alb-tg"

  public-subnet-name1 = var.PUBLIC-SUBNET1
  public-subnet-name2 = var.PUBLIC-SUBNET2
  web-alb-sg-name     = var.ALB-SG-NAME
  tg-name             = var.TG-NAME
  vpc-name            = var.VPC-NAME
  vpc_id              = module.vpc.vpc_id
  web-elb-sg          = module.security-group.web_alb_sg_id
  private-subnet-ids  = module.vpc.private_subnet_ids
  public-subnet-ids   = module.vpc.public_subnet_ids
  app-elb-sg-id       = module.security-group.app_alb_sg_id
  web-sg-id           = module.security-group.web_sg_id
  app-sg-id           = module.security-group.app_sg_id
  web-alb-name        =  "${var.ALB-NAME}-web"
  app-alb-name        = "${var.ALB-NAME}-app"

  depends_on = [module.rds]
}

module "iam" {
  source = "./modules/aws-iam"

  iam-role              = var.IAM-ROLE
  iam-policy            = var.IAM-POLICY
  instance-profile-name = var.INSTANCE-PROFILE-NAME

  depends_on = [module.alb]
}

module "autoscaling" {
  source = "./modules/aws-autoscaling"

  ami_name              = var.AMI-NAME
  launch-template-name  = var.LAUNCH-TEMPLATE-NAME
  instance-profile-name = var.INSTANCE-PROFILE-NAME
  web-sg-name           = var.WEB-SG-NAME
  tg-name               = var.TG-NAME
  iam-role              = var.IAM-ROLE
  public-subnet-name1   = var.PUBLIC-SUBNET1
  public-subnet-name2   = var.PUBLIC-SUBNET2
  asg-name              = var.ASG-NAME
  public-subnet-ids     = module.vpc.public_subnet_ids
  private-subnet-ids    = module.vpc.private_subnet_ids
  web-tg-arn            = module.alb.web_alb_target_group_arn
  app-tg-arn            = module.alb.app_alb_target_group_arn
  aws_security_group-App-SG = module.security-group.app_sg_id
  aws_security_group-Web-SG = module.security-group.web_sg_id

  depends_on = [module.iam]
}

module "redis" {
  source                = "./modules/redis"
  count                 = var.enable_redis ? 1 : 0
  name                  = "${var.name}-redis"
  subnet_ids            = module.vpc.private_subnet_ids
  security_group_ids    = [module.security-group.redis_sg_id]
  replication_enabled   = var.replication_enabled
  tags                  = var.tags
  node_type             = var.node_type
  num_cache_clusters    = var.num_cache_clusters
  engine_version        = var.redis_engine_version
  depends_on            = [ module.autoscaling ]
}

module "route53" {
  source = "./modules/aws-waf-cdn-acm-route53"

  domain-name  = var.DOMAIN-NAME
  cdn-name     = var.CDN-NAME
  alb-name     = "${var.ALB-NAME}-web"
  web_acl_name = var.WEB-ACL-NAME

  depends_on = [ module.autoscaling ]
}