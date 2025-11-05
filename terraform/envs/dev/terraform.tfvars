## Development environment variables (dev)
## Each line sets a Terraform variable used by the root module.

# AWS region where dev resources will be created
aws_region     = "us-east-1"

# (Optional) AWS CLI profile name from ~/.aws/credentials to use for auth
aws_profile    = "default"

# EC2 instance type for dev (small/cost-effective)
instance_type  = "t3a.small"

# If you already have an AWS KeyPair, set its name here so EC2 will use it.
# Leave empty to use the optional `aws_key_pair` resource which uploads your public key.
key_name       = ""

# If creating a key via Terraform, set the local path to your public key (not committed to Git)
# public_key_path = "/home/you/.ssh/cloud1_id_ed25519.pub"

# Notes: dev uses a small instance and defaults suitable for low-cost testing.