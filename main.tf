provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

resource "google_container_cluster" "primary" {
  name   = "my-poor-gke-cluster"

  # zonal cluster
  zone = "${var.zone}"

  # we too poor
  logging_service = "none"
  monitoring_service = "none"

  addons_config {
    # load balancing too expensive
    http_load_balancing {
      disabled = true
    }

    # who needs it
    kubernetes_dashboard {
      disabled = true
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    tags = ["poor-cluster"]
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-poor-node-pool"
  zone    = "${var.zone}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "f1-micro"
    # you get 30gb free so 3 x 10gb 
    disk_size_gb = 10

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster
# by using certificate-based authentication.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}