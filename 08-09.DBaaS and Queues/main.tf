terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "eu-north-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

resource "aws_db_instance" "otus-rds-mysql8" {
  identifier           = "otus-rds-mysql8"
  
  allocated_storage    = 20
  storage_type         = "gp2"

  instance_class       = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  
  availability_zone    = "eu-north-1a"
  publicly_accessible  = true
  port                 = 3306
  username             = "root"
  password             = "adminadmin"
  vpc_security_group_ids = [aws_security_group.otus-rds-mysql8-security-group.id]
  
}

resource "aws_instance" "otus-services" {
  ami                    = "ami-0b2e6fbf8c9364ab6"
  instance_type          = "t3.micro"
  availability_zone      = "eu-north-1a"
  vpc_security_group_ids = [aws_security_group.otus-services-security-group.id]
  
  tags = {
    Name = "otus-clouds-08-services"
  }
}

resource "aws_security_group" "otus-services-security-group" {
  name = "otus-services-security-group"

  ingress {
    from_port   = 5010
    to_port     = 5010
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5011
    to_port     = 5011
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 5020
    to_port     = 5020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "otus-rds-mysql8-security-group" {
  name = "otus-rds-mysql8"
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
















