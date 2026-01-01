output "master_public_ip" {
  value = google_compute_address.master_ip.address
}

output "master_private_ip" {
  value = google_compute_instance.spark_master.network_interface[0].network_ip
}

output "worker_public_ips" {
  value = google_compute_instance.spark_workers[*].network_interface[0].access_config[0].nat_ip
}

output "worker_private_ips" {
  value = google_compute_instance.spark_workers[*].network_interface[0].network_ip
}

output "edge_public_ip" {
  value = google_compute_instance.spark_edge.network_interface[0].access_config[0].nat_ip
}

output "master_hostname" {
  value = google_compute_instance.spark_master.name
}

output "worker_hostnames" {
  value = google_compute_instance.spark_workers[*].name
}