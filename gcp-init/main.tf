provider "google" {
  project = "otus-cloud-2019-09-274812"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

resource "google_storage_bucket" "state-bucket" {
  name          = "state-bucket"
  location      = "EUROPE-NORTH1"
  force_destroy = true
  storage_class = "STANDARD"
  bucket_policy_only = true

  versioning{
    enabled = true
  }
}