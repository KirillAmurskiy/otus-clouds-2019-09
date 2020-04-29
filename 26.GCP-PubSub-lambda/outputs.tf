output "vm_instance_external_ip" {
  value       = google_compute_instance.otus26_app_server.network_interface.0.access_config.0.nat_ip
  description = "Hostname of vm instance"
}

output "topic_id"{
  value = google_pubsub_topic.otus26_userregistred_topic.id
}