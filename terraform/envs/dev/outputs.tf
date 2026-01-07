// ======================================================
// Terraform outputs
// Dev environment
// ======================================================

output "webserver_public_ip" {
  description = "Public IP address of the web EC2 instance"
  value       = module.webserver.public_ip
}

output "webserver_public_dns" {
  description = "Public DNS name of the web EC2 instance"
  value       = module.webserver.public_dns
}

output "webserver_instance_id" {
  description = "ID of the web EC2 instance"
  value       = module.webserver.instance_id
}

output "web_security_group_id" {
  description = "Security group ID from the network module"
  value       = module.network.web_sg_id
}
