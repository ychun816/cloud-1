## Production environment variables (prod)
## IMPORTANT: keep secrets out of Git; supply credentials via environment/CI secrets.

# AWS region for production resources
aws_region     = "eu-west-3"

# AWS CLI profile (leave blank to use environment credentials provided by your CI or runner)
aws_profile    = "cloud-1-dev"

# EC2 instance type for production (larger for real traffic)
instance_type  = "t3.micro"

# Name of an existing AWS KeyPair to attach to the instance (strongly recommended for prod)
key_name       = ""

# If you want Terraform to create the key pair from a local public key, set the path here
public_key_path = "/home/yilin/GITHUB/cloud-1/deploy_key.pub"

# Notes: production uses larger instance; use a secure credential strategy (separate AWS account, CI secrets).