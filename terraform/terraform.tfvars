# Use the SSH key you already imported into AWS
key_name = "sophia_mac"


// ======================================================
// OPTIONAL 
// ======================================================
# override instance type (otherwise default t3a.small)
instance_type = "t2.micro" # t3a.small

# set environment name
environment = "dev"


# set allowed SSH CIDR (use /32 to lock to a single IP)
# Note: env-specific tfvars (e.g., envs/dev/terraform.tfvars) override these values when passed via -var-file
allowed_ssh_cidr = "37.174.160.154/32"

# optional: set if using a named AWS CLI profile
# aws_profile      = ""  