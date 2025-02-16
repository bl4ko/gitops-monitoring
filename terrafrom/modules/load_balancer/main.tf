resource "google_compute_health_check" "lb_health_check" {
  name = "${var.lb_name}-hc"

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}

// A Backend Service defines a group of vms that will serve traffic for load balancing.
resource "google_compute_backend_service" "lb_backend" {
  name                  = var.lb_name
  health_checks         = [google_compute_health_check.lb_health_check.self_link]
  protocol              = "HTTP"
  // Use external load balancing scheme
  load_balancing_scheme = "EXTERNAL"

  // Backend service will use the instance group as backend
  backend {
    group = var.instance_group
  }

  timeout_sec = 10
}

resource "google_compute_url_map" "lb_url_map" {
  name            = var.lb_name
  default_service = google_compute_backend_service.lb_backend.self_link
}

resource "google_compute_target_http_proxy" "lb_http_proxy" {
  name    = var.lb_name
  url_map = google_compute_url_map.lb_url_map.self_link
}

// Use global address for load balancer
resource "google_compute_global_address" "lb_address" {
  name = "${var.lb_name}-ip"
}

resource "google_compute_global_forwarding_rule" "lb_forwarding_rule" {
  name       = var.lb_name
  ip_address = google_compute_global_address.lb_address.address
  port_range = var.lb_port
  target     = google_compute_target_http_proxy.lb_http_proxy.self_link
}
