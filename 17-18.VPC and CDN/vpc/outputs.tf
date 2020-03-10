output "ec2-in-private-subnet-public-ip" {
  value       = aws_instance.otus-17-ec2-in-private.public_ip
  description = "Public ip of ec2 instance in private subnet"
}

output "ec2-in-public-subnet-public-ip" {
  value       = aws_instance.otus-17-ec2-in-public.public_ip
  description = "Public ip of ec2 instance in public subnet"
}

output "nat-gw-eip-public-ip" {
  value       = aws_eip.otus-17-nat-gw-eip.public_ip
  description = "Public ip of Elastic IP for NatGateway"
}

output "vpn-endpoint-dns-name" {
  value       = aws_ec2_client_vpn_endpoint.otus-17-vpn-endpoint.dns_name
  description = "Dns name of vpn endpoint"
}

