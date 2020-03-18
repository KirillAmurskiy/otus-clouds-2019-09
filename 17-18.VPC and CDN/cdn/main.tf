terraform {
  required_version = ">= 0.12, < 0.13"

  backend "s3" {
    bucket = "terraform-up-and-running-kirill-amurskiy-state"
    region = "eu-north-1"
    dynamodb_table = "terrafrom-up-and-running-locks"
    encrypt = true
    key = "otus/cloud/17/cdn/terraform.tfstate"
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


resource "aws_launch_configuration" "otus-17-launch-config" {
  image_id        = "ami-0b2e6fbf8c9364ab6"
  instance_type   = "t3.medium"
  security_groups = [aws_security_group.otus-17-instance-sg.id]

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "otus-17-asg" {
  launch_configuration = aws_launch_configuration.otus-17-launch-config.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  
  target_group_arns = [aws_lb_target_group.otus-17-lb-target-group.arn]
  health_check_type = "ELB"

  suspended_processes = ["ReplaceUnhealthy"]

  min_size = 1
  max_size = 1

}

resource "aws_security_group" "otus-17-instance-sg" {
  name = var.instance_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    security_groups = [aws_security_group.otus-17-lb-sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ping
  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "otus-17-instance-sg"
  }
}


resource "aws_lb" "otus-17-lb" {

  name               = var.alb_tg_name

  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.otus-17-lb-sg.id]

  tags = {
    Name = "otus-17-lb"
  }
}

resource "aws_lb_listener" "otus-17-lb-http-listener" {
  load_balancer_arn = aws_lb.otus-17-lb.arn
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

resource "aws_lb_target_group" "otus-17-lb-target-group" {

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

resource "aws_lb_listener_rule" "otus-17-lb-listener-rule" {
  listener_arn = aws_lb_listener.otus-17-lb-http-listener.arn
  priority     = 100

  condition {
    path_pattern{
      values = ["*"]  
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.otus-17-lb-target-group.arn
  }
}

resource "aws_security_group" "otus-17-lb-sg" {

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

resource "aws_cloudfront_distribution" "otus-17-cf-distribution" {
  origin {
    domain_name = aws_lb.otus-17-lb.dns_name
    origin_id   = aws_lb.otus-17-lb.id
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1"]
      origin_read_timeout = 10
    }
  }

  enabled             = true
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.otus-17-lb.id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    
    viewer_protocol_policy = "allow-all"
     
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  
  ordered_cache_behavior {
    path_pattern     = "/_next/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_lb.otus-17-lb.id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }


  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "otus-17-cf-distribution"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

