provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

terraform {
  backend "gcs" {
    bucket  = "state-bucket"
    prefix  = "24-gcp-message-queues"
  }
}

data "google_compute_network" "default"{
  name = "default"
}

resource "google_compute_instance" "otus24_app_server" {
  name         = "otus24-app-server"
  machine_type = "n1-standard-1"
  allow_stopping_for_update = true

  tags = ["otus24-app-server"]
  
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

resource "google_compute_firewall" "otus24_allow_all_needed_ports" {
  name    = "otus24-allow-all-needed-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "5011", "5020", "3306", "5672", "15672" ]
  }
  
  target_tags = ["otus24-app-server"]
}