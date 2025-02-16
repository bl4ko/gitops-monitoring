variable "instance_names" {
  description = "List of instance names to create"
  type        = list(string)
}

variable "machine_type" {
  description = "Compute machine type"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "image" {
  description = "Boot disk image"
  type        = string
}

variable "network" {
  description = "Network to attach the instance to"
  type        = string
}

variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}

# Cloud-Init specific variables
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
