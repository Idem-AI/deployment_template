# 4 Creating Application Load Balancers, Target Group and Listeners for Web Tier and Application Tier


# Creating ALB for Web Tier
resource "aws_lb" "web-elb" {
  name               = var.web-alb-name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public-subnet-ids
  security_groups    = [var.web-elb-sg]
  ip_address_type    = "ipv4"
  tags = {
    Name = "Web-elb"
  }
}

# Creating Target Group for Web-Tier 
resource "aws_lb_target_group" "web-tg" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "Web-TG"
  }
}


# Creating ALB listener with port 80 and attaching it to Web-Tier Target Group
resource "aws_lb_listener" "web-alb-listener" {
  load_balancer_arn = aws_lb.web-elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}




# Creating ALB for App Tier
resource "aws_lb" "app-elb" {
  name               =  var.app-alb-name
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private-subnet-ids
  security_groups    = [var.app-elb-sg-id]
  ip_address_type    = "ipv4"
  tags = {
    Name = "App-elb"
  }
}

# Creating Target Group for App-Tier
resource "aws_lb_target_group" "app-tg" {
  health_check {
    interval            = 10
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "App-TG"
  }
}

# Creating ALB listener with port 80 and attaching it to App-Tier Target Group
resource "aws_lb_listener" "app-elb-listener" {
  load_balancer_arn = aws_lb.app-elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
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
    security_groups = [var.web-sg-id]
  }

  tags = {
    Name = "app-elb-sg"
  }
}
