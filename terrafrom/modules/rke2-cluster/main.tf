resource "google_compute_address" "rke2-lb-ip" {
  name = "${var.name_prefix}-loadbalancer-ip"
}

# resource "google_service_account" "rke2-sa" {
#   account_id   = "${var.name_prefix}-service-account"
#   display_name = "Service Account for provisioned RKE2 cluster"
# }
resource "google_compute_target_pool" "rke2-masters" {
  name             = "${var.name_prefix}-masters"
  instances        = google_compute_instance.rke2-master.*.self_link
  health_checks    = [google_compute_http_health_check.rke2-health-check.name]
  session_affinity = "CLIENT_IP"
}

resource "google_compute_target_pool" "rke2-agents" {
  name             = "${var.name_prefix}-agents"
  instances        = google_compute_instance.rke2-agent.*.self_link
  health_checks    = [google_compute_http_health_check.rke2-health-check.name]
  session_affinity = "CLIENT_IP"
}

resource "google_compute_forwarding_rule" "rke2-lb" {
  name        = "${var.name_prefix}-loadbalancer"
  ip_address  = google_compute_address.rke2-lb-ip.address
  target      = google_compute_target_pool.rke2-masters.self_link
  port_range  = "6443"
  ip_protocol = "TCP"
}

resource "google_compute_forwarding_rule" "rke2-http" {
  name        = "${var.name_prefix}-loadbalancer-http"
  ip_address  = google_compute_address.rke2-lb-ip.address
  target      = google_compute_target_pool.rke2-agents.self_link
  port_range  = "80"
  ip_protocol = "TCP"
}

resource "google_compute_forwarding_rule" "rke2-https" {
  name        = "${var.name_prefix}-loadbalancer-https"
  ip_address  = google_compute_address.rke2-lb-ip.address
  target      = google_compute_target_pool.rke2-agents.self_link
  port_range  = "443"
  ip_protocol = "TCP"
}

resource "google_compute_http_health_check" "rke2-health-check" {
  name         = "${var.name_prefix}-kubernetes"
  request_path = "/healthz"
  description  = "The health check for Kubernetes API server"
  host         = "kubernetes.default.svc.cluster.local"
}

# resource "random_uuid" "rke2-token" {
# }

resource "google_compute_instance" "rke2-master" {
  count          = var.master_count
  name           = "${var.name_prefix}-master-${count.index}"
  zone = var.gcp_zone
  machine_type   = var.master_machine_type
  can_ip_forward = true
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  tags = ["rke2-node", "rke2-master"]

  // Workaround, install cloud init if not part of the cloud image
  metadata_startup_script = <<-CLOUD_INIT
    #!/bin/bash
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
  CLOUD_INIT

  metadata = {
    user-data = templatefile("${path.module}/templates/master.yaml", {
      # external_ip = google_compute_address.rke2-lb-ip.address
      # token       = random_uuid.rke2-token.result
      name_prefix = var.name_prefix

      ci_username = var.ci_username
      ci_pubkey = trimspace(data.local_file.pubkey["ci_pubkey"].content)
      ci_hashed_password  = data.external.hasher["ciuser"].result.hashed_password,

      username = var.username
      user_pubkey     = trimspace(data.local_file.pubkey["user_pubkey"].content),
      hashed_password = data.external.hasher["user"].result.hashed_password,
    })
  }

  # service_account {
  #   email = google_service_account.rke2-sa.email
  #   scopes = ["cloud-platform", "compute-rw",
  #     "storage-ro",
  #     "service-management",
  #     "service-control",
  #     "logging-write",
  #     "monitoring",
  #   ]
  # }

  boot_disk {
    initialize_params {
      size  = 50
      image = var.instance_image
    }
  }

  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
}

resource "google_compute_instance" "rke2-agent" {
  count          = var.agent_count
  name           = "${var.name_prefix}-agent-${count.index}"
  machine_type   = var.agent_machine_type
  can_ip_forward = true

  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  // Workaround, install cloud init if not part of the cloud image
  metadata_startup_script = <<-CLOUD_INIT
    #!/bin/bash
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
  CLOUD_INIT
  metadata = {
    user-data = templatefile("${path.module}/templates/agent.yaml", {
      # token       = random_uuid.rke2-token.result
      # server_ip   = google_compute_instance.rke2-master[0].network_interface[0].network_ip
      name_prefix = var.name_prefix

      ci_username = var.ci_username
      ci_pubkey = trimspace(data.local_file.pubkey["ci_pubkey"].content)
      ci_hashed_password  = data.external.hasher["ciuser"].result.hashed_password,

      username = var.username
      user_pubkey     = trimspace(data.local_file.pubkey["user_pubkey"].content),
      hashed_password = data.external.hasher["user"].result.hashed_password,
    })
  }

  # service_account {
  #   email = google_service_account.rke2-sa.email

  #   scopes = ["cloud-platform", "compute-rw",
  #     "storage-ro",
  #     "service-management",
  #     "service-control",
  #     "logging-write",
  #     "monitoring",
  #   ]
  # }

  tags = ["rke2-node", "rke2-agent"]

  boot_disk {
    initialize_params {
      size  = 100
      image = var.instance_image
    }
  }
  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
}