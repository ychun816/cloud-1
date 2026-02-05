// ======================================================
// Terraform outputs
// Dev environment
// ======================================================

output "webserver_public_ips" {
  description = "Public IP addresses of the web EC2 instances"
  value       = module.webserver.public_ips
}

output "webserver_public_dns" {
  description = "Public DNS names of the web EC2 instances"
  value       = module.webserver.public_dns
}

output "webserver_instance_ids" {
  description = "IDs of the web EC2 instances"
  value       = module.webserver.instance_ids
}

output "web_security_group_id" {
  description = "Security group ID from the network module"
  value       = module.network.web_sg_id
}
