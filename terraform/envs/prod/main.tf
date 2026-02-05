// ======================================================
// Prod Environment entry point
// Calls child modules -> ec2 & network
// ======================================================

// Module: network (security group)
module "network" {

  source = "../../modules/network"

  allowed_ssh_cidr = var.allowed_ssh_cidr
  environment      = var.environment
}

// Module: webserver (EC2 instance)
module "webserver" {
  source = "../../modules/ec2"

  instance_count     = var.instance_count
  instance_type      = var.instance_type
  key_name           = var.key_name
  public_key_path    = var.public_key_path

  environment        = var.environment
  security_group_ids = [module.network.web_sg_id]
}
