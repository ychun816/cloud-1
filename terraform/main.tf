// ======================================================
// Main Terraform configuration for EC2 instance
// ======================================================

// 1️⃣ Provider: AWS
provider "aws" {
  region = var.aws_region
  # Optional: use aws_profile if specified
  profile = var.aws_profile != "" ? var.aws_profile : null
}

// 2️⃣ Data source: Latest Ubuntu 22.04 AMI
// Dynamically finds the most recent Canonical Ubuntu Jammy AMI in the region
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] // Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

// 3️⃣ Security group: allow SSH (22) and HTTP (80) access
resource "aws_security_group" "web_sg" {
  name        = "cloud1-web-sg"
  description = "Allow SSH and HTTP"

  // Ingress: SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr] // Use variable to limit access
  }

  // Ingress: HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Open to public for demo/dev
  }

  // Egress: allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// 4️⃣ EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "${var.environment}-web"
  }
}

// 5️⃣ Optional: Terraform-managed keypair
// If you want Terraform to upload your public key automatically, uncomment and configure
# resource "aws_key_pair" "deployer" {
#   key_name   = "cloud1-deploy"
#   public_key = file(var.public_key_path)
# }
