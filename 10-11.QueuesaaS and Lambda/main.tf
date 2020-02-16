terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "eu-north-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

resource "aws_iam_role" "iam_role_lambda_sqs_consumer" {
  name = "iam_role_lambda_sqs_consumer"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_consumer_policy_attachment" {
  role       = aws_iam_role.iam_role_lambda_sqs_consumer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  
}


resource "aws_lambda_function" "otus-cloud-lamda-function" {
  function_name = "otus-cloud-lamda-function"
  role          = aws_iam_role.iam_role_lambda_sqs_consumer.arn
  handler       = "SocialNetwork.App.LambdaSqs::SocialNetwork.App.LambdaSqs.Function::FunctionHandler"
  memory_size = 256
  runtime = "dotnetcore2.1"
  s3_bucket = "otus-cloud-lamda-testfunctions"
  s3_key = "function1-637174569685687365.zip"
  
  publish = true
  
}

resource "aws_lambda_alias" "lambda_dev_alias" {
  name             = "lambda-dev-alias"
  description      = "For development environment"
  function_name    = aws_lambda_function.otus-cloud-lamda-function.arn
  function_version = "3"
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_mapping" {
  event_source_arn = aws_sqs_queue.otus_cloud_queue.arn
  function_name    = aws_lambda_alias.lambda_dev_alias.arn
}

resource "aws_s3_bucket" "otus-cloud-lamda-testfunctions" {
  bucket = "otus-cloud-lamda-testfunctions"
  acl    = "private"

  tags = {
    Name        = "otus-cloud-lamda-testfunctions"
  }
}

resource "aws_sqs_queue" "otus_cloud_queue" {
  name                      = "otus-clouds-10-userregistered-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 0
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.otus_cloud_deadletter_queue.arn
    maxReceiveCount     = 4
  })
  
  tags = {
    Name = "otus-clouds-10-userregistered-queue"
  }
}

resource "aws_sqs_queue" "otus_cloud_deadletter_queue" {
  name                      = "otus-clouds-10-deadletter-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 0

  tags = {
    Name = "otus-clouds-10-deadletter-queue"
  }
}

resource "aws_instance" "otus-services" {
  ami                    = "ami-0b2e6fbf8c9364ab6"
  instance_type          = "t3.micro"
  availability_zone      = "eu-north-1a"
  vpc_security_group_ids = [aws_security_group.otus-services-security-group.id]
  iam_instance_profile = aws_iam_instance_profile.otus_services_instance_profile.name
  
  tags = {
    Name = "otus-clouds-10-services"
  }
}

resource "aws_iam_instance_profile" "otus_services_instance_profile" {
  name = "otus_services_instance_profile"
  role = aws_iam_role.otus_services_instance_role.name
}

resource "aws_iam_role" "otus_services_instance_role" {
  name = "otus_services_instance_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "otus_services_policy_attachment" {
  role       = aws_iam_role.otus_services_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"

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
    from_port   = 3306
    to_port     = 3306
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

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-kirill-amurskiy-state"
    region = "eu-north-1"
    dynamodb_table = "terrafrom-up-and-running-locks"
    encrypt = true
    key = "otus/cloud/10/terraform.tfstate"
  }
}
















