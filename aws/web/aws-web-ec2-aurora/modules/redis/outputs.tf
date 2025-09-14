# Replication group ID (works for standalone or clustered)
output "redis_replication_group_id" {
  description = "The ID of the Redis replication group"
  value = coalesce(
    try(aws_elasticache_replication_group.standalone[0].id, null),
    try(aws_elasticache_replication_group.clustered[0].id, null)
  )
}

# Redis primary endpoint (hostname:port)
output "redis_primary_endpoint" {
  description = "The primary endpoint of the Redis cluster"
  value = coalesce(
    try(aws_elasticache_replication_group.standalone[0].primary_endpoint_address, null),
    try(aws_elasticache_replication_group.clustered[0].primary_endpoint_address, null)
  )
}

# Redis reader endpoint (clustered mode only, returns null for standalone)
output "redis_reader_endpoint" {
  description = "The reader endpoint of the Redis cluster (null if standalone)"
  value = try(aws_elasticache_replication_group.clustered[0].reader_endpoint_address, null)
}