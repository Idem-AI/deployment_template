# 5 Creating Security Group for Web Instances Tier With your IP(test purpose) and only access to Web-Tier ALB
resource "aws_security_group" "Web-SG" {
  vpc_id      = var.vpc_id
  description = "Protocol Type HTTP"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["115.110.237.74/32"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-elb-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Web-SG"
  }
}



# Creating Security Group for App Instances Tier With your IP(test purpose) and only access to App-Tier ALB
resource "aws_security_group" "App-SG" {
  vpc_id      = var.vpc_id
  description = "Protocol Type HTTP"

  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.app-elb-sg.id]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "TCP"
    cidr_blocks = ["115.110.237.74/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "App-SG"
  }
}

# Creating Web-Tier ALB Security Group with All traffic for Inbound and Outbound
resource "aws_security_group" "web-elb-sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-elb-sg"
  }
}

# Creating App-Tier ALB Security Group with Web-Security-Group traffic only for Inbound
resource "aws_security_group" "app-elb-sg" {
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = [aws_security_group.Web-SG.id]
  }

  tags = {
    Name = "app-elb-sg"
  }
}


# Creating Security Group for RDS Instances Tier With  only access to App-Tier ALB
resource "aws_security_group" "Database-SG" {
  vpc_id      = var.vpc_id
  description = "Protocol Type MySQL/Aurora"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.App-SG.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Database-SG"
  }
}

# Security Group pour Redis
resource "aws_security_group" "redis" {
  count       = var.enable_redis ? 1 : 0
  description = "Allow access to Redis from ASG instances"
  vpc_id      =var.vpc_id

  ingress {
    description      = "From ASG instances"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    security_groups  = [aws_security_group.App-SG.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   tags = {
    Name = "REDIS-SG"
  }
}
