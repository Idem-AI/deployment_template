output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [
    aws_subnet.public-subnet1.id,
    aws_subnet.public-subnet2.id
  ]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.private-subnet1.id,
    aws_subnet.private-subnet2.id
  ]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [
    aws_nat_gateway.ngw1.id,
    aws_nat_gateway.ngw2.id
  ]
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = [
    aws_route_table.public-rt1.id,
    aws_route_table.public-rt2.id
  ]
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = [
    aws_route_table.private-rt1.id,
    aws_route_table.private-rt2.id
  ]
}

output "elastic_ip_ids" {
  description = "List of Elastic IPs used for NAT Gateways"
  value       = [
    aws_eip.eip1.id,
    aws_eip.eip2.id
  ]
}
