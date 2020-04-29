output "vm_instance_external_ip" {
  value       = google_compute_instance.otus22_app_server.network_interface.0.access_config.0.nat_ip
  description = "Hostname of vm instance"
}

