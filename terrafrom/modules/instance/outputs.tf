output "instance_self_links" {
  description = "List of instance self-links"
  value       = values(google_compute_instance.vm)[*].self_link
}

output "instance_public_ips" {
  description = "Public IP addresses for the instances"
  value = [
    for instance in google_compute_instance.vm : instance.network_interface[0].access_config[0].nat_ip
  ]
}