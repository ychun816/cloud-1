data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "generated" {
  count      = var.key_name == "" && var.public_key_path != "" ? 1 : 0
  key_name   = "cloud1-key-${var.environment}"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : aws_key_pair.generated[0].key_name
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name        = "cloud1-web-${var.environment}"
    Environment = var.environment
  }
}
