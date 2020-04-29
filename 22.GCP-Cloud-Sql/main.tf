provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

terraform {
  backend "gcs" {
    bucket  = "state-bucket"
    prefix  = "22-gcp-cloud-sql"
  }
}

data "google_compute_network" "default"{
  name = "default"
}

resource "google_sql_database_instance" "otus22_pg12-from-tf" {
  name             = "otus22-pg12-from-tf"
  database_version = "POSTGRES_12"
  region           = "europe-north1"
  
  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled = true
      private_network = data.google_compute_network.default.self_link
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
    
    location_preference {
      zone = "europe-north1-a"
    }
  }
}

resource "google_sql_user" "user_postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.otus22_pg12-from-tf.name
  password = var.pg_admin_password
}

resource "google_compute_instance" "otus22_app_server" {
  name         = "otus22-app-server"
  machine_type = "n1-standard-1"
  allow_stopping_for_update = true

  tags = ["otus22-app-server"]
  
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
  
  boot_disk {
    initialize_params {
      image = "ubuntu1804-docker-logged-to-github"
    }
  }
  
  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config {
    }
  }
}

resource "google_compute_firewall" "otus22_allow_all_needed_ports" {
  name    = "otus22-allow-all-needed-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5011", "5012"]
  }
  
  target_tags = ["otus22-app-server"]
}