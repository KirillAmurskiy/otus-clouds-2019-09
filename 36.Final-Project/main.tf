provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

terraform {
  backend "gcs" {
    bucket  = "state-bucket"
    prefix  = "36-final-project"
  }
}

data "google_compute_network" "default"{
  name = "default"
}

resource "google_sql_database_instance" "otus36_pg12" {
  name             = "otus36-pg12"
  database_version = "POSTGRES_12"
  region           = "europe-north1"
  
  settings {
    tier = "db-g1-small"
    availability_type = "REGIONAL"
    ip_configuration {
      ipv4_enabled = true
      private_network = data.google_compute_network.default.self_link
      authorized_networks {
        value = "0.0.0.0/0"
      }
      
    }
    database_flags {
      name  = "max_connections"
      value = "10000"
    }
    
    location_preference {
      zone = "europe-north1-a"
    }
  }
}

resource "google_sql_user" "user_postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.otus36_pg12.name
  password = var.pg_admin_password
}

resource "google_compute_instance" "otus36_tank_server" {
  name         = "app-server"
  machine_type = "n1-standard-1"

  tags = ["otus36-app-server"]

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

