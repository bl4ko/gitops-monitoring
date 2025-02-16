output "masters_public_ips" {
  description = "Public IP addresses of master instances"
  value       = module.masters.instance_public_ips
}

output "workers_public_ips" {
  description = "Public IP addresses of worker instances"
  value       = module.workers.instance_public_ips
}

# output "load_balancer_ip" {
#   description = "The external IP of the load balancer"
#   value       = module.load_balancer.lb_ip
# }