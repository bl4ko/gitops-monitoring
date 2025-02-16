output "master_addresses" {
  description = "The public IP addresses of the master nodes."
  value       = module.rke2-cluster.master_addresses
}

output "worker_addresses" {
  description = "The public IP addresses of the worker nodes."
  value       = module.rke2-cluster.worker_addresses
}

output "loadbalancer_ip" {
  description = "The public IP address of the load balancer."
  value       = module.rke2-cluster.loadbalancer_ip
}
