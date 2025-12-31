variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Nom du projet (préfixe)"
  type        = string
  default     = "spark-automation"
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west1"
}

variable "subnet_cidr" {
  description = "CIDR du sous-réseau"
  type        = string
  default     = "10.0.0.0/24"
}