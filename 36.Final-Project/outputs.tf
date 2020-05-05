output "pg12_external_ip" {
  value       = google_sql_database_instance.otus36_pg12.ip_address.0.ip_address
  description = "Pg12 external ip address"
}

output "tank_server_external_ip" {
  value       = google_compute_instance.otus36_tank_server.network_interface.0.access_config.0.nat_ip
  description = "Tank server external ip address"
}