terraform {
  required_version = ">= 0.12, < 0.13"

  backend "s3" {
    bucket = "terraform-up-and-running-kirill-amurskiy-state"
    region = "eu-north-1"
    dynamodb_table = "terrafrom-up-and-running-locks"
    encrypt = true
    key = "otus/cloud/14/terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-north-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}


resource "aws_launch_configuration" "socialnetwork_lc" {
  image_id        = "ami-0b2e6fbf8c9364ab6"
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.socialnetwork_instance_sg.id]

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "socialnetwork_asg" {
  launch_configuration = aws_launch_configuration.socialnetwork_lc.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  
  target_group_arns = [aws_lb_target_group.socialnetwork_lb_tg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 2
  
  tag {
    key                 = "Name"
    value               = "socialnetwork-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "socialnetwork_instance_sg" {
  name = var.instance_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    security_groups = [aws_security_group.socialnetwork_lb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "socialnetwork_lb" {

  name               = var.alb_tg_name

  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.socialnetwork_lb_sg.id]
}

resource "aws_lb_listener" "socialnetwork_lb_http_listner" {
  load_balancer_arn = aws_lb.socialnetwork_lb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "socialnetwork_lb_tg" {

  name = var.alb_tg_name

  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "socialnetwork_lb_listener_rule" {
  listener_arn = aws_lb_listener.socialnetwork_lb_http_listner.arn
  priority     = 100

  condition {
    path_pattern{
      values = ["*"]  
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.socialnetwork_lb_tg.arn
  }
}

resource "aws_security_group" "socialnetwork_lb_sg" {

  name = var.alb_security_group_name

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

