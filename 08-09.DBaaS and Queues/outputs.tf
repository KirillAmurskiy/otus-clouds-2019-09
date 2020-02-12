output "services_public_dns" {
  value = "${aws_instance.otus-services.public_dns}"
}

output "mysql8_address" {
  value = "${aws_db_instance.otus-rds-mysql8.address}"
}