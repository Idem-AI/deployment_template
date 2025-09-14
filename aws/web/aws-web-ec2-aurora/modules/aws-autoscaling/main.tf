# 6 Creating Launch Configuration for Web-Tier, Make sure to add your custom AMI or AWS Ubuntu AMI. I have used Ubuntu 22.04 AMI. So, do accordingly
resource "aws_launch_template" "WEB-LC" {
  name_prefix   = "Web-LC"
  image_id      = "ami-0360c520857e3138f"
  instance_type = var.instance_type
  iam_instance_profile {
    name = var.instance-profile-name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.aws_security_group-Web-SG]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web-LC"
    }
  }
}


# Creating Launch Configuration for App-Tier, Make sure to add your custom AMI or AWS Ubuntu AMI. I have used Ubuntu 22.04 AMI. So, do accordingly
resource "aws_launch_template" "App-LC" {
  name         = "App-LC"
  image_id      = "ami-0360c520857e3138f"
  instance_type = var.instance_type
  iam_instance_profile {
    name = var.instance-profile-name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.aws_security_group-App-SG]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web-LC"
    }
  }

   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App-LC"
    }
  }
}


# 7 Creating AutoScaling Group for Web Tier 

resource "aws_autoscaling_group" "Web-ASG" {
  vpc_zone_identifier  = var.public-subnet-ids
  launch_template {
    id      = aws_launch_template.WEB-LC.id
    version = "$Latest"
  }
  min_size             = 2
  max_size             = 4
  health_check_type    = "EC2"
  target_group_arns    = [var.web-tg-arn]
  force_delete         = true
  tag {
    key                 = "Name"
    value               = "Web-ASG"
    propagate_at_launch = true
  }

}

# Creating AutoScaling Group for Application Tier 
resource "aws_autoscaling_group" "App-ASG" {
  vpc_zone_identifier  = var.private-subnet-ids
  launch_template {
    id      = aws_launch_template.App-LC.id
    version = "$Latest"
  }
  min_size             = 2
  max_size             = 4
  health_check_type    = "EC2"
  target_group_arns    = [var.app-tg-arn]
  force_delete         = true
  tag {
    key                 = "Name"
    value               = "App-ASG"
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_policy" "web-custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.Web-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "web-custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm when cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Web-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.web-custom-cpu-policy.arn]
}


resource "aws_autoscaling_policy" "web-custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.Web-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "web-custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm when cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Web-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.web-custom-cpu-policy-scaledown.arn]
}



resource "aws_autoscaling_policy" "app-custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.App-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "app-custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm when cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.App-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.app-custom-cpu-policy.arn]
}


resource "aws_autoscaling_policy" "app-custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.App-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app-custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm when cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.App-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.app-custom-cpu-policy-scaledown.arn]
}
