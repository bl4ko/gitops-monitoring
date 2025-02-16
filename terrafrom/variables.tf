variable "name_prefix" {
  description = "Name prefix for the resources"
  type        = string
  default = "cg-rke2"
}

variable "allowed_ips" {
  description = "Home IP address"
  type        = list(string)
  default = ["0.0.0.0/0"]
}

variable "gcp_project" {
  description = "GCP project id"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default = "europe-central2"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default    = "europe-central2a"
}

variable "gcp_credentials_file" {
  description = "Path to GCP credentials JSON file"
  type        = string
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "agent_count" {
  description = "Number of agent/worker nodes"
  type        = number
  default     = 1
}

variable "master_machine_type" {
  description = "Machine type for master nodes"
  type        = string
  default     = "n2-standard-2"
}

variable "agent_machine_type" {
  description = "Machine type for worker nodes"
  type        = string
  default     = "n2-standard-4"
}

variable "instance_image" {
  description = "Image for the vm instance"
  type        = string
  default = "almalinux-cloud/almalinux-9-v20250212"
}

variable "ci_username" {
  description = "CI username for CI tasks"
  type        = string
}

variable "ci_passwd" {
  description = "CI user password"
  type        = string
}

variable "ci_pubkey_path" {
  description = "Path to the public key for the CI user"
  type        = string
}

variable "username" {
  description = "Main username"
  type        = string
}

variable "passwd" {
  description = "Main user password"
  type        = string
}

variable "passwd_salt" {
  description = "Salt used for hashing the password"
  type        = string
}

variable "pubkey_path" {
  description = "Path to the public key for the main user"
  type        = string
}
