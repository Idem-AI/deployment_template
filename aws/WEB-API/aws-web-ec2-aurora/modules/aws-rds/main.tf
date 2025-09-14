locals {
  tag_base = merge({ "Name" = var.name }, var.tags)
}

# --- Subnet group (commun à Aurora et RDS) ---
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = local.tag_base
}

##############################
# Aurora Cluster
##############################
resource "aws_rds_cluster" "aurora" {
  count                   = var.db_engine_type == "aurora" ? 1 : 0
  cluster_identifier      = "${var.name}-aurora-cluster"
  engine                  = var.engine == "mysql" ? "aurora-mysql" : "aurora-postgresql"
  engine_version          = var.engine_version
  master_username         = var.username
  master_password         = var.password
  backup_retention_period = var.backup_retention
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  database_name           = var.db_name
  port                    = var.engine == "mysql" ? 3306 : 5432
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  tags                    = local.tag_base
}

# Aurora cluster instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.db_engine_type == "aurora" ? var.aurora_instance_count : 0
  cluster_identifier = aws_rds_cluster.aurora[0].id
  identifier         = "${var.name}-aurora-${count.index}"
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora[0].engine
  engine_version     = aws_rds_cluster.aurora[0].engine_version
  publicly_accessible = var.publicly_accessible
  tags               = local.tag_base
}

##############################
# Classic RDS (MySQL/Postgres)
##############################
resource "aws_db_parameter_group" "this" {
  count       = var.db_engine_type == "rds" ? 1 : 0
  name        = "${var.name}-params"
  family      = var.engine == "mysql" ? "mysql8.0" : "postgres13"
  description = "Parameter group for ${var.name}"
  tags        = local.tag_base
}

resource "aws_db_instance" "primary" {
  count                  = var.db_engine_type == "rds" ? 1 : 0
  identifier             = "${var.name}-primary"
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = true
  backup_retention_period = var.backup_retention
  parameter_group_name   = try(aws_db_parameter_group.this[0].name, null)
  storage_encrypted      = true
  tags                   = local.tag_base
  lifecycle { ignore_changes = [password] }
}

resource "aws_db_instance" "replica" {
  count                  = var.db_engine_type == "rds" && var.enable_read_replica ? 1 : 0
  identifier             = "${var.name}-rr"
  replicate_source_db    = aws_db_instance.primary[0].id
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = false
  tags                   = merge(local.tag_base, { "Role" = "replica" })
}
