provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

terraform {
  backend "gcs" {
    bucket  = "state-bucket"
    prefix  = "23-gcp-cloud-sql"
  }
}

data "google_compute_network" "default"{
  name = "default"
}


resource "google_compute_instance" "otus23_app_server" {
  name         = "otus23-app-server"
  machine_type = "n1-standard-1"
  allow_stopping_for_update = true

  tags = ["otus23-app-server"]
  
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

resource "google_compute_firewall" "otus23_allow_all_needed_ports" {
  name    = "otus23-allow-all-needed-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5011", "5012"]
  }
  
  target_tags = ["otus23-app-server"]
}