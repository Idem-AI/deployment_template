locals {
  tag_base = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.name}-subnet-group"
  description = "Subnet group for ${var.name}" 
  subnet_ids  = var.subnet_ids
  tags        = local.tag_base
}

# Standalone / non-clustered Redis
resource "aws_elasticache_replication_group" "standalone" {
  count                        = var.replication_enabled ? 0 : 1
  replication_group_id         = "${var.name}-standalone"
  node_type                    = var.node_type
  engine                       = "redis"
  engine_version               = var.engine_version
  description                  = "Standalone Redis replication group"
  subnet_group_name            = aws_elasticache_subnet_group.this.name
  security_group_ids           = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  automatic_failover_enabled   = false
  num_node_groups         = 1
  replicas_per_node_group = 0
  parameter_group_name         = var.parameter_group_name != "" ? var.parameter_group_name : null
  tags                         = local.tag_base
}

# Cluster mode Redis
resource "aws_elasticache_replication_group" "clustered" {
  count                        = var.replication_enabled ? 1 : 0
  replication_group_id         = "${var.name}-clustered"
  node_type                    = var.node_type
  engine                       = "redis"
  engine_version               = var.engine_version
  description                  = "Clustered Redis replication group"
  subnet_group_name            = aws_elasticache_subnet_group.this.name
  security_group_ids           = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  automatic_failover_enabled   = var.automatic_failover_enabled
  parameter_group_name         = var.parameter_group_name != "" ? var.parameter_group_name : null
  num_node_groups            = 1                       # Number of shards
  replicas_per_node_group    = var.num_cache_clusters - 1
   # correct usage : cluster_mode block with explicit numbers
  tags = local.tag_base
}
