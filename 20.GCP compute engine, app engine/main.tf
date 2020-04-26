provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

terraform {
  backend "gcs" {
    bucket  = "state-bucket"
    prefix  = "20-compute-engine"
  }
}

resource "google_compute_instance" "app_server" {
  name         = "app-server"
  machine_type = "g1-small"

  tags = ["app-server"]
  
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

resource "google_compute_firewall" "otus20_allow_all_needed_ports" {
  name    = "otus20-allow-all-needed-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5011", "5012", "5433"]
  }
  
  target_tags = ["app-server"]
}