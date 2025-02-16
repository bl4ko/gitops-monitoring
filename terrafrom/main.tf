# Create a VPC
module "rke2-vpc" {
  source      = "./modules/gcp-vpc"
  name_prefix = var.name_prefix
  region      = var.gcp_region
  project     = var.gcp_project
}

# Create a RKE2 Cluster
module "rke2-cluster" {
  source          = "./modules/rke2-cluster"
  name_prefix     = var.name_prefix
  gcp_zone = var.gcp_zone
  master_machine_type = var.master_machine_type
  agent_machine_type = var.agent_machine_type

  vpc_name        = module.rke2-vpc.vpc_name
  subnetwork_name = module.rke2-vpc.subnetwork_name
  master_count    = var.master_count
  agent_count = var.agent_count
  instance_image = var.instance_image

  username = var.username
  passwd = var.passwd
  passwd_salt = var.passwd_salt
  pubkey_path = var.pubkey_path
  ci_username = var.ci_username
  ci_passwd = var.ci_passwd
  ci_pubkey_path = var.ci_pubkey_path
}


# Allow k8s internal networking
resource "google_compute_firewall" "k8s-internal" {
  name    = "${var.name_prefix}-allow-k8s-internal"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6443", "8443", "9345", "10250", "10251", "10252", "10254"]
  }

  allow {
    protocol = "udp"
    ports    = ["8472"]
  }

  source_ranges = [module.rke2-vpc.subnet_cidr]
}

# Allow firewall access to the master nodes for k8s api (port 6443)
resource "google_compute_firewall" "k8s-api-rules" {
  name    = "${var.name_prefix}-allow-k8s"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = var.allowed_ips
  target_tags = ["rke2-master"]
}

# Allow firewall access to the worker nodes for ingress traffic
resource "google_compute_firewall" "ingress-rules" {
  name    = "${var.name_prefix}-allow-ingress"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.allowed_ips
  target_tags = ["rke2-agent"]
}

# Create a firewall rule to allow SSH connection from the specified source range
resource "google_compute_firewall" "ssh-rules" {
  name    = "${var.name_prefix}-allow-ssh"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = concat(["35.235.240.0/20"], var.allowed_ips)
  target_tags   = ["rke2-node"]
}

// Create a firewall rule to allow DNS
resource "google_compute_firewall" "allow-dns" {
  name    = "${var.name_prefix}-allow-dns"
  network = module.rke2-vpc.vpc_name

  source_ranges = ["0.0.0.0"]

  allow {
    protocol = "tcp"
    ports    = ["53", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
}

// Create a firewall rule to allow health checks
# source_ranges: https://cloud.google.com/load-balancing/docs/health-check-concepts
resource "google_compute_firewall" "allow-health-check" {
  name    = "${var.name_prefix}-allow-health-check"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}