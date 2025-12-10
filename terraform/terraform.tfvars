# Use the SSH key you already imported into AWS
key_name = "sophia_mac"


// ======================================================
// OPTIONAL 
// ======================================================
# override instance type (otherwise default t3a.small)
instance_type = "t2.micro" # t3a.small

# set environment name
environment = "dev"


# set allowed SSH CIDR
allowed_ssh_cidr = "78.242.104.196"

# optional: set if using a named AWS CLI profile
# aws_profile      = ""  