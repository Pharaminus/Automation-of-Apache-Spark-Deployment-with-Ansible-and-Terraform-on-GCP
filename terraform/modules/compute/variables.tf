variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
}

variable "zone" {
  description = "Zone GCP"
  type        = string
  default     = "europe-west1-b"
}

variable "subnet_self_link" {
  description = "Self-link du subnet"
  type        = string
}

variable "master_machine_type" {
  description = "Type machine master"
  type        = string
  default     = "e2-standard-4"
}

variable "worker_machine_type" {
  description = "Type machine workers"
  type        = string
  default     = "e2-standard-2"
}

variable "worker_count" {
  description = "Nombre de workers"
  type        = number
  default     = 3
}

variable "ssh_public_key_path" {
  description = "Chemin clé SSH publique"
  type        = string
}