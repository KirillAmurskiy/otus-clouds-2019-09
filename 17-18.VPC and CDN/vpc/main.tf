terraform {
  required_version = ">= 0.12, < 0.13"

  backend "s3" {
    bucket = "terraform-up-and-running-kirill-amurskiy-state"
    region = "eu-north-1"
    dynamodb_table = "terrafrom-up-and-running-locks"
    encrypt = true
    key = "otus/cloud/17/vpc/terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-north-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

resource "aws_vpc" "otus-17-vpc" {
  cidr_block       = "10.0.0.0/16"
  
  enable_dns_support = true
  
  tags = {
    Name = "otus-17-vpc"
  }
}

# public

resource "aws_subnet" "otus-17-public-subn" {
  vpc_id     = aws_vpc.otus-17-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "otus-17-public-subn"
  }
}

resource "aws_internet_gateway" "otus-17-internet-gw" {
  vpc_id = aws_vpc.otus-17-vpc.id

  tags = {
    Name = "otus-17-internet-gw"
  }
}

resource "aws_route_table" "otus-17-public-route-table" {
  vpc_id = aws_vpc.otus-17-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.otus-17-internet-gw.id
  }

  tags = {
    Name = "otus-17-public-route-table"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.otus-17-vpc.id
  route_table_id = aws_route_table.otus-17-public-route-table.id
}

# private

resource "aws_subnet" "otus-17-private-subn" {
  vpc_id     = aws_vpc.otus-17-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "otus-17-private-subn"
  }
}

resource "aws_eip" "otus-17-nat-gw-eip" {
  vpc      = true
  tags = {
    Name = "otus-17-eip-nat-gw"
  }
}

resource "aws_nat_gateway" "otus-17-nat-gw" {
  allocation_id = aws_eip.otus-17-nat-gw-eip.id
  subnet_id = aws_subnet.otus-17-public-subn.id
  
  depends_on = [aws_internet_gateway.otus-17-internet-gw]
  tags = {
    Name = "otus-17-nat-gw"
  }
}

resource "aws_route_table" "otus-17-private-route-table" {
  vpc_id = aws_vpc.otus-17-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.otus-17-nat-gw.id
  }

  tags = {
    Name = "otus-17-private-route-table"
  }
}

resource "aws_route_table_association" "otus-17-private-rt-association" {
  subnet_id      = aws_subnet.otus-17-private-subn.id
  route_table_id = aws_route_table.otus-17-private-route-table.id
}

resource "aws_ec2_client_vpn_endpoint" "otus-17-vpn-endpoint" {

  client_cidr_block      = "11.0.0.0/22"
  
  server_certificate_arn = "arn:aws:acm:eu-north-1:447890362554:certificate/e05772d5-d43d-43f0-a7c6-d62d5af11bb2"

  authentication_options {
    type                       = "certificate-authentication"
    # the same as server
    root_certificate_chain_arn = "arn:aws:acm:eu-north-1:447890362554:certificate/e05772d5-d43d-43f0-a7c6-d62d5af11bb2"
  }
  
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = "/aws/vpn-endpoints"
    cloudwatch_log_stream = "otus-17"
  }

  tags = {
    Name = "otus-17-vpn-endpoint"
  }
}

resource "aws_ec2_client_vpn_network_association" "otus-17-vpn-network-association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.otus-17-vpn-endpoint.id
  subnet_id              = aws_subnet.otus-17-private-subn.id
}

# allow access only to private subnet
resource "null_resource" "client_vpn_ingress" {
  provisioner "local-exec" {
    when = create
    command = "aws ec2 authorize-client-vpn-ingress --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.otus-17-vpn-endpoint.id} --target-network-cidr ${aws_subnet.otus-17-private-subn.cidr_block} --authorize-all-groups"
  }
}

resource "aws_instance" "otus-17-ec2-in-private" {
  ami                    = "ami-0b2e6fbf8c9364ab6"
  instance_type          = "t3.micro"
  availability_zone      = "eu-north-1a"
  vpc_security_group_ids = [aws_security_group.otus-17-sg.id]
  subnet_id = aws_subnet.otus-17-private-subn.id
    
  # just for trying
  associate_public_ip_address = true

  tags = {
    Name = "otus-17-ec2-in-private"
  }
}

resource "aws_instance" "otus-17-ec2-in-public" {
  ami                    = "ami-0b2e6fbf8c9364ab6"
  instance_type          = "t3.micro"
  availability_zone      = "eu-north-1a"
  vpc_security_group_ids = [aws_security_group.otus-17-sg.id]
  subnet_id = aws_subnet.otus-17-public-subn.id

  associate_public_ip_address = true

  tags = {
    Name = "otus-17-ec2-in-public"
  }
}

resource "aws_security_group" "otus-17-sg" {
  name = "otus-17-sg"
  vpc_id = aws_vpc.otus-17-vpc.id
  
  ingress {
    from_port   = 80
    to_port     = 80
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

  tags = {
    Name = "otus-17-sg"
  }
}