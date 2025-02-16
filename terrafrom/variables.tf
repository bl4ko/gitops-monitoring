variable "project" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "credentials_file" {
  description = "Path to GCP credentials JSON file"
  type        = string
}

variable "masters_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "workers_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "master_machine_type" {
  description = "Machine type for master nodes"
  type        = string
  default     = "e2-medium"
}

variable "worker_machine_type" {
  description = "Machine type for worker nodes"
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "AlmaLinux image for VMs"
  type        = string
}

variable "network" {
  description = "GCP network to use"
  type        = string
  default     = "k8s-network"
}

variable "ci_username" {
  description = "CI username for CI tasks"
  type        = string
}

variable "ci_passwd" {
  description = "CI user password"
  type        = string
}

variable "ci_user_extra_groups" {
  description = "List of groups for the CI user"
  type        = list(string)
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


variable "user_extra_groups" {
  description = "List of groups for the main user"
  type        = list(string)
}

variable "pubkey_path" {
  description = "Path to the public key for the main user"
  type        = string
}
