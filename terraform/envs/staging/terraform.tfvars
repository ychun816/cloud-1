## Staging environment variables (staging)
## Use these to provision a staging server that mirrors production more closely.

# AWS region for staging resources
aws_region     = "us-east-1"

# (Optional) AWS CLI profile to use for auth in staging
aws_profile    = "default"

# EC2 instance type for staging (medium to emulate prod load)
instance_type  = "t3a.medium"

# Name of an existing AWS KeyPair to attach to the instance (optional)
key_name       = ""

# If using Terraform to create the keypair, provide the path to your public key here
# public_key_path = "/home/you/.ssh/cloud1_id_ed25519.pub"

# Notes: staging uses a medium instance to better emulate production performance.