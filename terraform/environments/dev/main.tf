terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

module "network" {
  source = "../../modules/network"

  project_id   = var.project_id
  project_name = var.project_name
  region       = var.region
  subnet_cidr  = var.subnet_cidr
}

module "compute" {
  source = "../../modules/compute"

  project_id          = var.project_id
  project_name        = var.project_name
  region              = var.region
  zone                = var.zone
  subnet_self_link    = module.network.subnet_self_link
  master_machine_type = var.master_machine_type
  worker_machine_type = var.worker_machine_type
  worker_count        = var.worker_count
  ssh_public_key_path = var.ssh_public_key_path

  depends_on = [module.network]
}

# Génération automatique de l'inventaire Ansible
resource "local_file" "ansible_inventory" {
  filename = "../../../ansible/inventory/hosts.ini"

  content = <<-EOF
[spark_master]
${module.compute.master_public_ip} ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster hostname=${module.compute.master_hostname} private_ip=${module.compute.master_private_ip}

[spark_workers]
%{for idx, ip in module.compute.worker_public_ips~}
${ip} ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster hostname=${module.compute.worker_hostnames[idx]} private_ip=${module.compute.worker_private_ips[idx]}
%{endfor~}

[spark_edge]
${module.compute.edge_public_ip} ansible_user=spark-admin ansible_ssh_private_key_file=~/.ssh/spark-cluster

[spark_cluster:children]
spark_master
spark_workers
spark_edge

[spark_cluster:vars]
master_ip=${module.compute.master_private_ip}
  EOF
}