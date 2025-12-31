output "master_ip" {
  value = module.compute.master_public_ip
}

output "spark_ui_url" {
  value = "http://${module.compute.master_public_ip}:8080"
}

output "worker_ips" {
  value = module.compute.worker_public_ips
}

output "ssh_command_master" {
  value = "ssh -i ~/.ssh/spark-cluster spark-admin@${module.compute.master_public_ip}"
}