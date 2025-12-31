output "network_name" {
  description = "Nom du VPC"
  value       = google_compute_network.spark_vpc.name
}

output "network_self_link" {
  description = "Self-link du VPC"
  value       = google_compute_network.spark_vpc.self_link
}

output "subnet_name" {
  description = "Nom du subnet"
  value       = google_compute_subnetwork.spark_subnet.name
}

output "subnet_self_link" {
  description = "Self-link du subnet"
  value       = google_compute_subnetwork.spark_subnet.self_link
}