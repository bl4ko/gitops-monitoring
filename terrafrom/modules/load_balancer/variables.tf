variable "lb_name" {
  description = "Name for the load balancer resources"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "instance_group" {
  description = "Self-link of the instance group to use as backend"
  type        = string
}

variable "health_check_port" {
  description = "Port for the health check"
  type        = number
  default     = 6443
}

variable "health_check_path" {
  description = "HTTP request path for the health check"
  type        = string
}

variable "lb_port" {
  description = "Port for the forwarding rule (as string)"
  type        = string
  default     = "6443"
}
