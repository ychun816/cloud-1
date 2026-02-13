# Terraform

## Learning resources
- [Get Started: AWS + Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create)
- [Terraform Course – Automate AWS](https://www.youtube.com/watch?v=SLB_c_ayRMo)
- [Complete Terraform Course](https://www.youtube.com/watch?v=7xngnjfIlK4&t=56s)
- [Build a Dev Environment on AWS](https://www.youtube.com/watch?v=iRaai1IBlB0&t=254s)
- [Terraform Tutorial + Labs](https://www.youtube.com/watch?v=YcJ9IeukJL8)
- AWS provider docs: [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

---

## repo brief 
- Each environment now has its own state and provider config for safety.
- Restrict SSH ingress (`allowed_ssh_cidr`), and prefer `user_data` or Ansible to bootstrap.
- Tag resources with `var.environment` for clarity.
- Keep provider config in root; pin versions in `versions.tf`.
- Restrict SSH ingress (`allowed_ssh_cidr`), and prefer `user_data` or Ansible to bootstrap.
- Tag resources with `var.environment` for clarity.
- Once infra grows, then evolve into module-based.

### Environments and state
- Each environment in `envs/` is a **standalone** entry point.
- This creates **Environment Isolation**: a change in `dev` cannot accidentally affect `prod`.
- Run commands inside the specific environment folder.

### Module wiring (concept)
```
root main.tf
  └─ module.network (VPC, subnets, SG)
       outputs: web_sg_id, public_subnet_ids
  └─ module.ec2 (instance)
       inputs: subnet_id=module.network.public_subnet_ids[0]
               security_group_ids=[module.network.web_sg_id]
       outputs: instance_id, public_ip, public_dns
```

### CI/CD (optional)
```
GitHub Actions → cd envs/dev → terraform init/plan/apply → outputs → ansible-playbook
```

---

## repo structure

```bash
/cloud-1/terraform/
├── envs
│   ├── dev
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── prod
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── init_backend.sh
├── modules
│   ├── ec2
│   │   ├── iam.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── tf_outputs.json

```

| File                       | Typical contents                   | Why                                 |
| -------------------------- | ---------------------------------- | ----------------------------------- |
| **main.tf**                | Key resources (EC2, SG, AMI, etc.) | Simple to understand, small project |
| **network.tf** (optional)  | VPC, subnets, routing              | If you manage networking separately |
| **security.tf** (optional) | Security groups                    | If you have multiple SGs            |
| **compute.tf** (optional)  | EC2, autoscaling                   | For scaling / multiple servers      |
| **modules/**               | Reusable sets of resources         | For larger teams/projects           |


---

## workflow
Terraform → Ansible

```bash
AWS credentials ─┬─> terraform init/plan/apply ─┬─> outputs (IP/DNS)
                 │                               │
                 └─> SSH keypair (existing or TF)└─> Ansible inventory
                                                     └─> ansible-playbook
                                                          installs Docker/Compose
                                                          deploys compose services
```

---


## test commands

### workflow
```bash
# To work on Develop
terraform init

# validate config (syntax/type checks)
terraform validate

# binary plan (safer, reproducible)
terraform plan -out=tfplan
# prepare for terrafrom apply with creating a plan file "dev.tfplan" (optional -> safer, reproducible)
# dev.tfplan -> binary plan -> need terraform plan to read it 
terraform plan <terraform.tfvars> -out=<dev.tfplan>


# dry run without saving a file 
terraform plan <terraform.tfvars>

# reprint the saved plan
terraform show <dev.tfplan>


# apply the saved plan
terraform apply tfplan

# Use outputs for Ansible
terraform output public_ip
terraform output public_dns

# To work on Production
cd terraform/envs/prod
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

| Step | Command              | Purpose                                    | Makes Changes |
| ---: | -------------------- | ------------------------------------------ | ------------- |
|    1 | `terraform init`     | Initialize providers, modules, and backend | No            |
|    2 | `terraform validate` | Check syntax and configuration correctness | No            |
|    3 | `terraform plan`     | Preview infrastructure changes             | No            |
|    4 | `terraform apply`    | Create or update infrastructure            | Yes           |
|    5 | `terraform fmt`      | Format Terraform code                      | optional      |
|    6 | `terraform destroy`  | Remove infrastructure                      | optional      |


### first time setup:
```bash
terrafrom init  
terraform validate 
terraform plan 
terraform apply
```

### Post-Apply Terraform & Instance Access Workflow
- ONLY run `terrafrom apply` if:
- change providers
- change modules
- change backend configuration
- Terraform explicitly tells you to

```bash 
terraform validate 
terraform plan 
terraform apply
```

## step-by-step
#### Step 1: Verify Terraform outputs

```bash
# after terrafrom apply is successful:
# 1) print terrafrom output in terminal to verifly (or in json fromat)
# 2) write saving the output into tf_outputs.json 
terraform output -json | tee tf_outputs.json

# terraform output 
# terraform output -json #in json format
# "tee" : a command-line tool that (1)duplicates the output of a command, (2)sends it to both the screen and into the file. #almost always used with pipe | in front
# terraform output -json > tf_outputs.json => won't see anything on terminal
```
#### Step 2: Update Security Group SSH access to your current IP (if needed)
```bash
# Update SSH CIDR to your current IP
NEW_CIDR="$(curl -s https://checkip.amazonaws.com | tr -d '\n')/32"
echo "Updating allowed_ssh_cidr to $NEW_CIDR"

# Apply the change automatically
terraform apply -auto-approve -var "allowed_ssh_cidr=$NEW_CIDR"
```

#### Step 3: Get the instance IP
```bash
# Get instance public IP as a raw string
# need the IP to SSH or test connectivity
# safer than parsing JSON manually!!! 
IP=$(terraform output -raw webserver_public_ip)
echo "IP=$IP"
```
#### Step 4: Check SSH port reachability
```bash
# Probes TCP/22; success means security group + networking is correct -> connection path is open
nc -zv "$IP" 22
```
#### Step 5: SSH into the instance
```bash
# SSH into the instance
# StrictHostKeyChecking=accept-new avoids interactive prompts for new hosts
ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_ed25519 "ubuntu@$IP"
```

(optional) Step 6: One-liner SSH validation 
```bash
# Quick validation of SSH without opening a full session
ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_ed25519 "ubuntu@$IP" "echo 'SSH_OK'; hostname; whoami; uptime"
```

(optional for reference) Step 7: find current public IP && store it in a variable MYIP
```bash
# Keep track of your public IP for future SSH/security updates
MYIP=$(curl -s https://checkip.amazonaws.com | tr -d '\n')
echo "Your current public IP: $MYIP" # for verify

# curl: make HTTP requests # -s means silent
# https://checkip.amazonaws.com : a service that returns your public IP address
# $() syntax executes the command inside and stores the output into a variable

```
(optional) Step 8: Inspect Terraform state 
```bash
# Inspect current resource state in Terraform
# Useful for debugging, seeing actual attributes, or verifying deployed values
terraform state show <resource>
```
