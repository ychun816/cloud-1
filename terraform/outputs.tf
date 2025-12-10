
// ======================================================
// Terraform outputs (multi-module)

// EC2 outputs → module.webserver.instance_public_ip / module.webserver.instance_id
// Security group outputs → module.network.web_sg_id

// Note: In a multi-module setup, EC2 and network resources live inside their respective modules. Root module can only access them via module outputs.
// Root module can only reference resources or outputs that exist in the root module or outputs exposed by child modules.

// ======================================================

// ----------------------
// EC2 module outputs
// ----------------------

// Public IP of the web EC2 instance
// aws_instance.web now lives inside the ec2 module.
// From the root module, Terraform cannot see aws_instance.web directly — you must reference it via the module output (module.webserver.instance_public_ip).
// The root module doesn’t have aws_instance directly.
// It references the output declared inside the ec2 module.
output "webserver_public_ip" {
  description = "Public IP address of the web EC2 instance from the EC2 module"
  // Access the EC2 module output
  value       = module.webserver.public_ip
}

// Public DNS of the web EC2 instance
output "webserver_public_dns" {
  description = "Public DNS name of the web EC2 instance from the EC2 module"
  value       = module.webserver.public_dns
}

// EC2 instance ID
output "webserver_instance_id" {
  description = "ID of the web EC2 instance from the EC2 module"
  value       = module.webserver.instance_id
}

// ----------------------
// Network module outputs
// ----------------------

// Security group ID
// The root module cannot access aws_security_group directly; it must use the output from the network module
output "web_security_group_id" {
  description = "Security group ID from the network module"
  value       = module.network.web_sg_id
}