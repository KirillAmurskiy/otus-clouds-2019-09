provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

terraform {
  backend "gcs" {
    bucket  = "state-bucket"
    prefix  = "26-gcp-pubsub-lambda"
  }
}

data "google_compute_network" "default"{
  name = "default"
}

resource "google_cloudfunctions_function" "otus26_userregistred_handler" {
  name        = "otus26-userregistred-handler"
  runtime     = "python37"
  entry_point = "userregistred_handle"
  region = "europe-west2"
  available_memory_mb   = 128
  
  source_repository{
    url = "https://source.developers.google.com/projects/otus-cloud-2019-09-274812/repos/cloud-functions/moveable-aliases/master/paths/userregistred-handler"
  }
  
  event_trigger{
    event_type = "google.pubsub.topic.publish"
    resource = google_pubsub_topic.otus26_userregistred_topic.name
  }
}

resource "google_pubsub_topic" "otus26_userregistred_topic" {
  name = "otus26-userregistred-topic"
}

resource "google_pubsub_topic" "otus26_dead_letter" {
  name = "otus26-dead-letter"
}

resource "google_pubsub_subscription" "otus26_userregistred_subscription" {
  name  = "otus26-userregistred-subscription"
  topic = google_pubsub_topic.otus26_userregistred_topic.name

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  
  dead_letter_policy {
    dead_letter_topic = google_pubsub_topic.otus26_dead_letter.id
    max_delivery_attempts = 10
  }
}

resource "google_compute_instance" "otus26_app_server" {
  name         = "otus26-app-server"
  machine_type = "n1-standard-1"
  allow_stopping_for_update = true

  tags = ["otus26-app-server"]
  
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  service_account {
    scopes = ["pubsub"]
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

resource "google_compute_firewall" "otus26_allow_all_needed_ports" {
  name    = "otus26-allow-all-needed-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "5011", "5020", "3306" ]
  }
  
  target_tags = ["otus26-app-server"]
}