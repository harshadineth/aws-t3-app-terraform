resource "aws_instance" "web_instance" {
  ami           = "ami-0d191299f2822b1fa"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_AZ-1_subnet.id
  associate_public_ip_address = true 
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "Web-instance"
  }
  vpc_security_group_ids = [aws_security_group.webtier_sg.id]
}

resource "aws_ami_from_instance" "web_instance_ami" {
  name               = "web_instance_ami"
  source_instance_id        = aws_instance.web_instance.id
}

resource "aws_lb_target_group" "web_tier_tg" {
  name     = "web-tier-tg"  
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    protocol            = "HTTP"
    port                = "80"
  }

  tags = {
    Name = "WebTierTG"
  }
}

# ALB
resource "aws_lb" "external_lb" {
  name               = "webtier-external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webtier_sg.id]
  subnets            = [aws_subnet.web_AZ-1_subnet.id, aws_subnet.web_AZ-2_subnet.id]  
  tags = {
    Name = "external-alb"
  }
}

# Listener for the ALB
resource "aws_lb_listener" "http_listener_external" {
  load_balancer_arn = aws_lb.external_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tier_tg.arn
  }
}

resource "aws_launch_template" "web_tier_launch_template" {
  name          = "web-tier-launch-template"
  image_id      = aws_ami_from_instance.web_instance_ami.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.webtier_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  tags = {
    Name = "Web-Tier-LaunchTemplate"
  }
}

resource "aws_autoscaling_group" "web_tier_asg" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.web_AZ-1_subnet.id, aws_subnet.web_AZ-2_subnet.id]
  target_group_arns = [aws_lb_target_group.web_tier_tg.arn]
  launch_template {
    id      = aws_launch_template.web_tier_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "WebTierASG"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
  health_check_type         = "ELB"
  health_check_grace_period = 300
 }
