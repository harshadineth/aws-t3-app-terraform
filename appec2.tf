resource "aws_instance" "app_instance" {
  ami                    = "ami-0d191299f2822b1fa" 
  instance_type          = "t2.micro"              
  subnet_id              =  aws_subnet.app_AZ-1_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name 
  tags = {
    Name = "App-instance"
  }
  security_groups        = [aws_security_group.appserver_sg.id]
  key_name                = ""  
}

resource "aws_ami_from_instance" "app_instance_ami" {
  name               = "app_instance_ami"
  source_instance_id        = aws_instance.app_instance.id
}

resource "aws_lb_target_group" "app_target_group" {
  name        = "app-target-group"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb" "internal_alb" {
  name               = "app-lb-int"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.app_AZ-1_subnet.id, aws_subnet.app_AZ-2_subnet.id]  
  security_groups    = [aws_security_group.appserver_sg.id]  

  enable_deletion_protection = false  

  tags = {
    Name = "InternalALB" 
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_launch_template" "app_launch_template" {
  name          = "app-launch-template"
  image_id      = aws_ami_from_instance.app_instance_ami.id
  instance_type = "t2.micro"

    tags = {
      Name = "AppLayerInstance"
    }
  

  #security_group_names = [aws_security_group.appserver_sg.name]
  vpc_security_group_ids = [aws_security_group.appserver_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
}


resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-auto-scale-group"
  max_size                  = 2
  min_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.app_AZ-1_subnet.id, aws_subnet.app_AZ-2_subnet.id] 
  target_group_arns         = [aws_lb_target_group.app_target_group.arn]
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "AppLayerInstance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
