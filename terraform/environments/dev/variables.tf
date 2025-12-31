variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "credentials_file" {
  description = "Credentials JSON file"
  type        = string
  default     = "~/gcp-key.json"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "spark-automation"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.0.0/24"
}

variable "master_machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "worker_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "worker_count" {
  type    = number
  default = 2
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/spark-cluster.pub"
}