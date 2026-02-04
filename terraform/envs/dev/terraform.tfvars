## Development environment variables (dev)
## Each line sets a Terraform variable used by the root module.

# AWS region where dev resources will be created
aws_region     = "eu-west-3"

# (Optional) AWS CLI profile name from ~/.aws/credentials to use for auth
aws_profile    = "cloud-1-dev"

# EC2 instance type for dev (small/cost-effective)
instance_type  = "t3.micro"

# If you already have an AWS KeyPair, set its name here so EC2 will use it.
# Leave empty to use the optional `aws_key_pair` resource which uploads your public key.
# Use existing AWS KeyPair name if present; else leave empty to let Terraform create one from your local public key
key_name       = ""
# If you don't have an AWS KeyPair named above, set key_name = "" and provide a local public key path below to let Terraform create one for you.
public_key_path = "/home/yilin/.ssh/id_rsa.pub"

# Temporary: allow SSH from anywhere (adjust to your IP/32 for better security)
#  SSH locked to my IP
allowed_ssh_cidr = "37.174.160.154/32"
# allowed_ssh_cidr = "0.0.0.0/0"


# If creating a key via Terraform, set the local path to your public key (not committed to Git)
# public_key_path = "/home/you/.ssh/cloud1_id_ed25519.pub"

# Notes: dev uses a small instance and defaults suitable for low-cost testing.