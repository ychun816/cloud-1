# Cloud‑1 Terraform guide (concise)

## Learning resources
- [Get Started: AWS + Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create)
- [Terraform Course – Automate AWS](https://www.youtube.com/watch?v=SLB_c_ayRMo)
- [Complete Terraform Course](https://www.youtube.com/watch?v=7xngnjfIlK4&t=56s)
- [Build a Dev Environment on AWS](https://www.youtube.com/watch?v=iRaai1IBlB0&t=254s)
- [Terraform Tutorial + Labs](https://www.youtube.com/watch?v=YcJ9IeukJL8)
- AWS provider docs: [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

## Big picture: Terraform → Ansible
```
AWS credentials ─┬─> terraform init/plan/apply ─┬─> outputs (IP/DNS)
                 │                               │
                 └─> SSH keypair (existing or TF)└─> Ansible inventory
                                                     └─> ansible-playbook
                                                          installs Docker/Compose
                                                          deploys compose services
```

## Repository structure (aligned with README)
```
cloud-1/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── network/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── ec2/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/webserver/
│       ├── tasks/main.yml
│       ├── templates/
│       └── files/
└── compose/
    ├── docker-compose.yml
    └── conf/{nginx,wordpress,mariadb}
```

## Module wiring (concept)
```
root main.tf
  └─ module.network (VPC, subnets, SG)
       outputs: web_sg_id, public_subnet_ids
  └─ module.ec2 (instance)
       inputs: subnet_id=module.network.public_subnet_ids[0]
               security_group_ids=[module.network.web_sg_id]
       outputs: instance_id, public_ip, public_dns
```

## Environments and state
- Use `terraform.tfvars` or `-var-file=envs/dev/terraform.tfvars` for per-env config.
- Start local; switch to remote state (S3 + DynamoDB) when collaborating.

## Minimal workflow
```bash
cd terraform
terraform init
terraform plan -var-file=envs/dev/terraform.tfvars -out=tfplan
terraform apply tfplan

# Use outputs for Ansible
terraform output public_ip
terraform output public_dns
```

## CI/CD (optional)
```
GitHub Actions → terraform init/plan/apply → outputs → ansible-playbook
```

## Notes
- Keep provider config in root; pin versions in `versions.tf`.
- Restrict SSH ingress (`allowed_ssh_cidr`), and prefer `user_data` or Ansible to bootstrap.
- Tag resources with `var.environment` for clarity.
Once your infra grows, then evolve into module-based.
