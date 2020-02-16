output "services_public_dns" {
  value = aws_instance.otus-services.public_dns
}

output "sqs_connection" {
  value = aws_sqs_queue.otus_cloud_queue.id
}

output "sqs_deadletter_connection" {
  value = aws_sqs_queue.otus_cloud_deadletter_queue.id
}
