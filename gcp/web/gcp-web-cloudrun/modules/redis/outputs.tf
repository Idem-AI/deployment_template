output "redis_instance_name" {
  description = "Nom de l’instance Redis"
  value       = var.enable_redis ? google_redis_instance.main[0].name : null
}

output "redis_instance_host" {
  description = "Adresse IP de l’instance Redis"
  value       = var.enable_redis ? google_redis_instance.main[0].host : null
}

output "redis_instance_port" {
  description = "Port de l’instance Redis"
  value       = var.enable_redis ? google_redis_instance.main[0].port : null

}

output "redis_instance_region" {
  description = "Région de l’instance Redis"
  value       = var.enable_redis ? google_redis_instance.main[0].region : null
}
