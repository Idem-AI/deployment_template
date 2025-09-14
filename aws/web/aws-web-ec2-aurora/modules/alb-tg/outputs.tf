output "web_alb_dns_name" {
  description = "DNS name of the Web ALB"
  value       = aws_lb.web-elb.dns_name
}

output "web_alb_target_group_arn" {
  description = "ARN of the Web ALB Target Group"
  value       = aws_lb_target_group.web-tg.arn
}

output "web_alb_listener_arn" {
  description = "ARN of the Web ALB Listener"
  value       = aws_lb_listener.web-alb-listener.arn
}

output "app_alb_dns_name" {
  description = "DNS name of the App ALB"
  value       = aws_lb.app-elb.dns_name
}

output "app_alb_target_group_arn" {
  description = "ARN of the App ALB Target Group"
  value       = aws_lb_target_group.app-tg.arn
}

output "app_alb_listener_arn" {
  description = "ARN of the App ALB Listener"
  value       = aws_lb_listener.app-elb-listener.arn
}
