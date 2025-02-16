resource "google_compute_address" "static_ip" {
  for_each     = toset(var.instance_names)
  name         = each.value
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}


resource "google_compute_instance" "vm" {
  for_each     = toset(var.instance_names)
  name         = each.value
  zone         = var.zone
  machine_type = var.machine_type

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = var.network
    access_config {
      nat_ip = google_compute_address.static_ip[each.value].address
    }
  }

  // Workaround, install cloud init if not available
  metadata_startup_script = <<-CLOUD_INIT
    #!/bin/bash
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
  CLOUD_INIT

  metadata = {
    user-data = templatefile("files/cloud-init.yaml.tmpl", {
      hostname        = each.value,  # The VM name becomes its hostname.
      ci_username     = var.ci_username,
      ci_user_extra_groups  = var.ci_user_extra_groups,
      ci_pubkey       = trimspace(data.local_file.pubkey["ci_pubkey"].content),

      username        = var.username,
      user_pubkey     = trimspace(data.local_file.pubkey["user_pubkey"].content),
      hashed_password = data.external.hasher["user"].result.hashed_password,
      ci_hashed_pass  = data.external.hasher["ciuser"].result.hashed_password,
      user_extra_groups     = var.user_extra_groups,
    })
  }

  tags = var.tags
}
