// ======================================================
// Main Terraform configuration for EC2 instance
// Root module: calls child modules -> ec2 & network
// NOTE: Provider configuration defined in provider.tf.
// ======================================================

// Module: network (security group)
module "network" {
  source = "./modules/network"

  allowed_ssh_cidr = var.allowed_ssh_cidr
  environment      = var.environment
}

// Module: webserver (EC2 instance)
module "webserver" {
  source = "./modules/ec2"

  instance_type      = var.instance_type
  key_name           = var.key_name
  environment        = var.environment
  security_group_ids = [module.network.web_sg_id]
}
