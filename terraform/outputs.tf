output "public_ip" {                       # Define an output named "public_ip"
  description = "Public IP address of the web instance"
  value       = aws_instance.web.public_ip # Reference EC2 instance resource attribute
}

output "public_dns" {                      # Another output for DNS name
  description = "Public DNS name of the web instance"
  value       = aws_instance.web.public_dns
}
