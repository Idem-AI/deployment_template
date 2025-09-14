output "web_sg_id" {
  description = "ID of the Web Security Group"
  value       = aws_security_group.Web-SG.id
}

output "app_sg_id" {
  description = "ID of the App Security Group"
  value       = aws_security_group.App-SG.id
}

output "web_alb_sg_id" {
  description = "ID of the Web ALB Security Group"
  value       = aws_security_group.web-elb-sg.id
}

output "app_alb_sg_id" {
  description = "ID of the App ALB Security Group"
  value       = aws_security_group.app-elb-sg.id
}

output "database_sg_id" {
  description = "ID of the Database Security Group"
  value       = aws_security_group.Database-SG.id
}

output "redis_sg_id" {
  description = "ID of the Redis Security Group"
  value       = var.enable_redis ? aws_security_group.redis[0].id:null

  
}


# Facultatif : Regrouper tous les SG dans une seule liste
output "all_security_group_ids" {
  description = "List of all Security Group IDs"
  value = [
    aws_security_group.Web-SG.id,
    aws_security_group.App-SG.id,
    aws_security_group.web-elb-sg.id,
    aws_security_group.app-elb-sg.id,
    aws_security_group.Database-SG.id
  ]
}
