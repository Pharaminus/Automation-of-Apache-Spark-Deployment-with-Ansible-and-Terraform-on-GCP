# IP publique statique pour le master
resource "google_compute_address" "master_ip" {
  name    = "${var.project_name}-master-ip"
  region  = var.region
  project = var.project_id
}

# Spark Master
resource "google_compute_instance" "spark_master" {
  name         = "${var.project_name}-master"
  machine_type = var.master_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["spark-cluster", "spark-master"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link

    access_config {
      nat_ip = google_compute_address.master_ip.address
    }
  }

  metadata = {
    ssh-keys = "spark-admin:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    echo "Master node initialized" > /tmp/startup.log
  EOF

  allow_stopping_for_update = true
}

# Spark Workers
resource "google_compute_instance" "spark_workers" {
  count = var.worker_count

  name         = "${var.project_name}-worker-${count.index + 1}"
  machine_type = var.worker_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["spark-cluster", "spark-worker"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    access_config {}
  }

  metadata = {
    ssh-keys = "spark-admin:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    echo "Worker ${count.index + 1} initialized" > /tmp/startup.log
  EOF

  allow_stopping_for_update = true
}

# Edge Node
resource "google_compute_instance" "spark_edge" {
  name         = "${var.project_name}-edge"
  machine_type = "e2-medium"
  zone         = var.zone
  project      = var.project_id

  tags = ["spark-cluster", "spark-edge"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    access_config {}
  }

  metadata = {
    ssh-keys = "spark-admin:${file(var.ssh_public_key_path)}"
  }

  allow_stopping_for_update = true
}