provider "google" {
  credentials = var.gcp_sa_key  # Use the variable for the service account key
  project     = var.project_id
  region      = var.region
}