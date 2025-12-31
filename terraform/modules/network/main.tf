# VPC personnalisé
resource "google_compute_network" "spark_vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Sous-réseau
resource "google_compute_subnetwork" "spark_subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.spark_vpc.id
  project       = var.project_id
}

# Firewall : SSH depuis l'extérieur
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.spark_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["spark-cluster"]
}

# Firewall : Communication interne
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.spark_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = ["spark-cluster"]
}

# Firewall : Spark Web UIs
resource "google_compute_firewall" "allow_spark_ui" {
  name    = "${var.project_name}-allow-spark-ui"
  network = google_compute_network.spark_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["8080", "8081", "4040", "18080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["spark-master"]
}