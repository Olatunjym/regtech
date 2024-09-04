resource "google_container_cluster" "primary" {
  name     = "youverify"
  location = var.region
  initial_node_count = 2

  node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = 50
    disk_type = "pd-standard"
  }

  # Disable deletion protection
  deletion_protection = false
}
