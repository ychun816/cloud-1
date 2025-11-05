// Main Terraform root module - main resources for Cloud-1
// This file defines the core infrastructure resources: data sources (AMI lookup),
// a security group for web access, an EC2 instance, and an optional key-pair resource.
// Comments here explain each block and the purpose of important attributes.


// ====== Data source: Find latest Ubuntu 20.04 AMI ======
// We use a data source to look up the most recent Canonical Ubuntu Focal AMI.
// This keeps the AMI selection dynamic while still using the official owner.
data "aws_ami" "ubuntu_focal" {
  // If true, returns the most recent AMI matching the filters
  most_recent = true

  // Canonical's AWS account ID — restricts the search to official Ubuntu images
  owners = ["099720109477"]

  // Filter by AMI name pattern (matches Ubuntu 20.04 server images)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


// ====== Security group: allow SSH, HTTP, HTTPS ======
// Create a security group that allows inbound SSH (22), HTTP (80), and HTTPS (443).
// Be careful: the example opens these ports to 0.0.0.0/0 which is acceptable for dev
// but you should restrict CIDR ranges for production for better security.
resource "aws_security_group" "web_sg" {
  // Human-readable name for the SG
  name        = "cloud1-web-sg"

  // Short description to explain the purpose of the group
  description = "Allow SSH, HTTP, HTTPS"

  // Ingress rule: SSH access (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    // CIDR block of allowed remote IPs; consider narrowing this in prod
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Ingress rule: HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Ingress rule: HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress rule: allow all outbound traffic (default behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // -1 indicates all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// ====== EC2 instance: web server ======
// This resource creates a single Ubuntu EC2 instance and attaches the security group.
// The instance uses the AMI ID returned by the data source above and the instance
// type provided by `var.instance_type`.
resource "aws_instance" "web" {
  // Which AMI to boot — from the canonical lookup
  ami = data.aws_ami.ubuntu_focal.id

  // Instance type (e.g., t3a.small) from variables
  instance_type = var.instance_type

  // Attach the security group created earlier. This accepts a list of SG IDs.
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  // Attach a key pair if provided. The ternary expression returns `null` when
  // `var.key_name` is empty so the instance won't try to use a non-existent key.
  key_name = var.key_name != "" ? var.key_name : null

  // Tags help identify resources in the AWS console
  tags = {
    Name = "cloud1-web"
  }
}


// ====== Optional: create an AWS KeyPair from a local public key ======
// If you prefer Terraform to upload your public key to AWS (so you don't manually
// create a KeyPair in the console), uncomment this resource and ensure
// `var.public_key_path` points to your local public key file.
# resource "aws_key_pair" "deployer" {
#   // Key name in AWS
#   key_name   = "cloud1-deploy"
#
#   // Read the public key contents from a local file path provided by a variable
#   public_key = file(var.public_key_path)
# }

