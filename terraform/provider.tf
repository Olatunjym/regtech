provider "google" {
  credentials = file("C:/Users/USER/Downloads/toyeglobal-8aaf3bdc5db5.json")
  project     = var.project_id
  region      = var.region
}
