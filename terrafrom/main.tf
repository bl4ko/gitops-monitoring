terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "masters" {
  source         = "./modules/instance"
  instance_names = [for i in range(var.masters_count) : "master-${i}"]
  machine_type   = var.master_machine_type
  zone           = var.zone
  image          = var.image
  network        = var.network
  tags           = ["master"]
  passwd_salt = var.passwd_salt
  username = var.username
  passwd = var.passwd
  user_extra_groups = var.user_extra_groups
  pubkey_path = var.pubkey_path
  ci_username = var.ci_username
  ci_passwd = var.ci_passwd
  ci_pubkey_path = var.ci_pubkey_path
  ci_user_extra_groups = var.ci_user_extra_groups
}

module "workers" {
  source         = "./modules/instance"
  instance_names = [for i in range(var.workers_count) : "worker-${i}"]
  machine_type   = var.worker_machine_type
  zone           = var.zone
  image          = var.image
  network        = var.network
  tags           = ["worker"]
  passwd_salt = var.passwd_salt
  username = var.username
  passwd = var.passwd
  user_extra_groups = var.user_extra_groups
  pubkey_path = var.pubkey_path
  ci_username = var.ci_username
  ci_passwd = var.ci_passwd
  ci_pubkey_path = var.ci_pubkey_path
  ci_user_extra_groups = var.ci_user_extra_groups
}

# resource "google_compute_instance_group" "master_nodes" {
#   name = "master-instances-group"
#   description = "Instance group for master nodes"
#   instances = module.masters.instance_self_links
#   zone = var.zone
# }

# module "load_balancer" {
#   source            = "./modules/load_balancer"
#   lb_name           = "k8s-lb"
#   zone              = var.zone
#   instance_group    = google_compute_instance_group.master_nodes.self_link
#   health_check_port = 80
#   health_check_path = "/"
#   lb_port           = "80"
# }

# Allow firewall access to the master nodes (port 6443)
resource "google_compute_firewall" "master_nodes" {
  name    = "allow-k8s-api"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["master"]
}
