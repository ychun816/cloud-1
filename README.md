# Cloud 1 

---

## Index Table 
- Project brief
- Project overview
- Project workflow
- Quick Start
- Local test procedures (Ansible & Terraform)


- documentations
  - [Deployment & Devops Tools Comparison](documentation/DEPLOYMENT.md)
  - [terraform](documentation/TERRAFORM.md)
  - [ansible](documentation/ANSIBLE.md)
  - [automization](documentation/automization.md)
  - [database](documentation/DATABASE.md)
  - [(AWS service) Cloudwatch](documentation/CLOUDWATCH.md)
  - [notes for newbs](documentation/NEWBS_NOTES.md)
---


## project brief 
Previous Inception project + automation + cloud infrastructure, 
Extending the old Inception project by:
1. Moving it from local to cloud-based deployment.
2. Automating the whole process using Ansible (or similar tools).
3. Adding security, persistence, and reliability — like a real-world production environment.

| Component       | Original Inception                           | Automated Deployment of Inception                        |
| --------------- | -------------------------------------------- | -------------------------------------------------------- |
| **Environment** | Local only (Docker on your machine)          | Remote Ubuntu 20.04 server                               |
| **Setup**       | Manual (you build and run locally)           | Automated (Ansible or script builds everything remotely) |
| **Containers**  | Nginx, WordPress, MariaDB (maybe phpMyAdmin) | Same services, same isolation concept                    |
| **Persistence** | Local Docker volumes                         | Remote persistent volumes on the server                  |
| **Networking**  | Local Docker bridge network                  | Server-level Docker network, secure routing              |
| **Security**    | Local access only                            | Public access secured by firewall + HTTPS                |
| **Objective**   | Learn containerization & orchestration       | Learn DevOps automation & infrastructure-as-code         |
---

### general setup
* **Bash script:** Procedural environment setup (install Docker, build images, verify credentials).
* **Makefile:** Project task automation (run Terraform commands inside Docker).
> This combination is portable, maintainable, and readable, which aligns with industry DevOps workflows.
* **Docker:** Isolated, portable environment for Terraform + AWS CLI
* **Terraform:** Infrastructure as Code for provisioning EC2 and AWS resources.
* **Ansible:** (Optional) Configure and manage software/settings on provisioned EC2 instances
* **AWS CLI:** Manage and verify AWS resources, debug deployments, and test credentials.
> [AWS CLI setup](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
> [Installing or updating to the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)


| Task                                           | Where to put it                         |
| ---------------------------------------------- | --------------------------------------- |
| Install Docker/Terraform on host               | Bash script (`init_project.sh`)         |
| Install Terraform/AWS CLI **inside container** | Dockerfile                              |
| Run Terraform commands                         | Makefile (calls script or `docker run`) |
| Multi-container orchestration                  | docker-compose.yml                      |


---

## Project Structure Overview

- `terraform/` → infrastructure (VPC, SG, EC2) with reusable modules and env tfvars
- `ansible/` → server configuration and app deployment (uses Terraform outputs)
- `compose/` → container definitions and configs used by Ansible

```bash
cloud-1/
├── README.md
├── ansible
│   ├── ansible.cfg
│   ├── group_vars
│   │   └── all.yml
│   ├── inventories
│   │   ├── dev
│   │   │   └── hosts.ini
│   │   ├── local
│   │   │   └── hosts.ini
│   │   └── prod
│   │       └── hosts.ini
│   ├── playbook.yml
│   ├── playbooks
│   │   ├── docker_deploy.yml
│   │   └── setup_tools.yml
│   ├── roles
│   │   ├── awscli
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── cloudwatch
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   │       └── amazon-cloudwatch-agent.json.j2
│   │   ├── docker
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── terraform
│   │       └── tasks
│   │           └── main.yml
│   ├── scripts
│   │   └── generate_inventory.py
│   ├── tools.yml
│   └── variables.yml
├── compose
│   ├── conf
│   │   ├── adminer
│   │   │   └── Dockerfile
│   │   ├── mariadb
│   │   │   ├── Dockerfile
│   │   │   └── conf
│   │   │       └── init_mariadb.sh
│   │   ├── nginx
│   │   │   ├── Dockerfile
│   │   │   └── conf
│   │   │       └── nginx.conf
│   │   └── wordpress
│   │       ├── Dockerfile
│   │       └── conf
│   │           ├── init_wordpress.sh
│   │           └── www.conf
│   └── docker-compose.yml
├── documentation
│   ├── ANSIBLE.md
│   ├── CHECKLIST.md
│   ├── CICD_DEPLOYMENT.md
│   ├── CLOUDWATCH.md
│   ├── Cloud 1 Subject (EN).pdf
│   ├── DATABASE.md
│   ├── DEPLOYMENT.md
│   ├── NEWBS_NOTES.md
│   └── TERRAFORM.md
├── makefile
└── terraform
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

---

## project workflow 


## 📋 Infrastructure & Deployment Workflow

This project follows a standard 3-step automation pipeline: **Provision → Configure → Deploy**:
- **Terraform** gives us the computer.
- **Ansible** prepares the computer and installs Docker.
- **Docker** runs the actual application.

#### 1. Provisioning (Terraform)

* **Action:** Run `terraform apply`
* **Role:** The "Builder"
* **What it does:** Creates the raw infrastructure (Virtual Machines/EC2 instances, VPCs, Security Groups).
* **Result:** We have an "empty room" (a running server) with an IP address, but it has no software installed yet.

#### 2. Configuration (Ansible)

* **Action:** Run `ansible-playbook`
* **Role:** The "Organizer"
* **What it does:** Connects to the empty server created by Terraform. It follows the **Playbook** (instruction list) to install necessary facilities:
* System updates & Security patches.
* **Dependencies:** Installs the Docker Engine (the "shelves").
* **Result:** The server is fully furnished and ready to run applications.

#### 3. Application Deployment (Docker)

* **Action:** Triggered by Ansible tasks
* **Role:** The "Package"
* **What it does:** Ansible instructs the Docker Engine to pull and start the specific Docker containers (the actual application code).
* **Result:** The application is live and serving traffic.


### workflow diagram

```bash
                        ┌──────────────────────────────────────┐
                        │  Your Laptop (Local)                 │
                        │──────────────────────────────────────│
                        │ - Git repo (terraform/ ansible/      │
                        │   compose/)                          │
                        │ - SSH key                            │
                        │ - AWS CLI credentials                │
                        └──────────────┬─────────────┬─────────┘
                                       │             │
                                       │             │
                                       ▼             ▼
                     ┌─────────────────────┐   ┌───────────────────────┐
                     │  Terraform (IaC)    │   │  Ansible (Config)     │
                     │─────────────────────│   │───────────────────────│
                     │ - terraform/        │   │ - ansible/            │
                     │   - main.tf         │   │   - inventory.ini      │
                     │   - variables.tf    │   │   - playbook.yml       │
                     │   - outputs.tf      │   │   - roles/webserver    │
                     │   - modules/{vpc,   │   │     (tasks/templates)  │
                     │     ec2}            │   │                       │
                     └──────────┬──────────┘   └──────────┬────────────┘
                                │                         │
                                │ terraform apply         │
                                │ emits outputs (IP/DNS)  │
                                │                         │ consumes outputs
                                ▼                         │ (inventory)
                   ┌──────────────────────────────────────────────────┐
                   │  AWS Cloud (Ubuntu 20.04 EC2)                    │
                   │──────────────────────────────────────────────────│
                   │  Provisioned by Terraform:                       │
                   │   • VPC, subnets, internet gateway               │
                   │   • Security Group (SSH/HTTP/HTTPS)              │
                   │   • EC2 Instance (Ubuntu AMI)                    │
                   │                                                  │
                   │  Configured by Ansible:                          │
                   │   • Installs Docker & Docker Compose             │
                   │   • Deploys compose/ services                    │
                   │     - NGINX (Reverse Proxy + TLS)                │
                   │     - WordPress (PHP/APP)                        │
                   │     - MariaDB (DB)                               │
                   │     - (optional) phpMyAdmin                      │
                   │                                                  │
                   │  Access: HTTPS via NGINX → Internet              │
                   └──────────────────────────────────────────────────┘
                                          │
                                          ▼
                    ┌────────────────────────────────┐
                    │     Your WordPress Website     │
                    │  - NGINX + TLS                 │
                    │  - Persistent volumes          │
                    │  - Deployable via automation   │
                    └────────────────────────────────┘
```


---


## Quick Start

# fetch a webpage from your server using HTTP (Port 80)
# -v (verbose): Shows the complete "conversation" (handshake)
curl -v  [address]

# connect to server securely to run two specific checks, then immediately disconnect.
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@51.44.255.51 "sudo docker ps && sudo ufw status"

aws ec2 describe-instances --filters "Name=tag:Name,Values=cloud1-web-dev" "Name=instance-state-name,Values=running" --region eu-west-3 --query "Reservations[*].Instances[*].PublicIpAddress" --output text

# Checks if your server is reachable via HTTPS (Port 443)
# -k (insecure): Crucial
# -I (Head): Fetches only the headers (server info, status code 200/404) without downloading the whole HTML page
curl -k -I -v [address]
```

* modify wordpress
```bash
# tell Docker to run a command inside the container named wordpress
sudo docker exec wordpress

# WP-CLI command to change a database setting
wp option update [option_name] [new_value]

# Required because Docker runs as root, and WP-CLI normally blocks root for security (but it's fine inside a container)
--allow-root

```

---

### Quick Start: AWS auth → Terraform plan

Use this concise checklist to go from tools-installed to a verified Terraform plan:

1. Choose AWS auth method
  - Prefer SSO: `aws configure sso` (name a profile, e.g., `cloud-1-dev`).
  - Or access keys: `aws configure --profile cloud-1-dev`.
2. Log in and verify credentials
  - SSO login: `aws sso login --profile cloud-1-dev`.
  - Verify: `AWS_PROFILE=cloud-1-dev aws sts get-caller-identity`.
3. Pick environment
  - Select one: `dev`, `staging`, or `prod` (see `terraform/envs/<env>/terraform.tfvars`).
4. Initialize Terraform
  - `cd terraform && export AWS_PROFILE=cloud-1-dev && terraform init`.
5. Run plan
  - `terraform plan -var-file envs/dev/terraform.tfvars` (swap `dev` for your env).
6. Apply (optional)
  - `terraform apply -var-file envs/dev/terraform.tfvars`.

### After Terraform apply (dev)

Follow these steps to verify access and configure the server:

1) SSH into the EC2 instance

- Use the outputs printed by Terraform (example):
  - Public IP: `15.237.127.174`
  - Public DNS: `ec2-15-237-127-174.eu-west-3.compute.amazonaws.com`
- Default user for Ubuntu AMI: `ubuntu`
- Command:
  - `ssh -i ~/.ssh/id_ed25519 ubuntu@<webserver_public_ip>`

2) Save Terraform outputs (optional)

- From the `terraform/` directory:
  - `terraform output`
  - `terraform output -json > tf_outputs.json`
- You can parse this JSON to generate an Ansible inventory.

3) Run Ansible to configure the server (Docker, Compose, app)

- Create/update an inventory that points to the new EC2 public IP:
  - `ansible/inventories/dev/hosts.ini` (example):
    ```
    [web]
    15.237.127.174 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519
    ```
- Run the playbook:
  - `ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbook.yml`

Notes
- If your public IP changes, update `allowed_ssh_cidr` in `terraform/envs/dev/terraform.tfvars` and re-apply.
- If you don’t have an existing AWS key pair, leave `key_name = ""` and set `public_key_path` in `envs/dev/terraform.tfvars` to let Terraform create one.
- For Free Tier, prefer `t3.micro` (region-dependent) or adjust instance type as needed.

Optional local stack: `make compose-up`.

---

## Local test procedures (Ansible & Terraform)

Follow these steps to validate your automation locally before provisioning cloud resources.

Ansible — quick local checks and full VM test
- Purpose: Validate playbook syntax, role tasks, Docker install, UFW, and systemd unit creation.
- Quick commands (syntax/lint/check mode):

```bash
# Syntax check
ansible-playbook --syntax-check ansible/playbook.yml

# Lint (optional)
ansible-lint ansible/playbook.yml || true

# Dry-run (simulate changes) using an inventory file
ansible-playbook -i ansible/inventory_test.ini ansible/playbook.yml --check
```

- Recommended local run using Multipass (Ubuntu 20.04):

```bash
# 1) Launch disposable VM
multipass launch -n cloud1-test 20.04

# 2) Get VM IP (replace below)
multipass info cloud1-test | grep IPv4

# 3) Create `ansible/inventory_test.ini` with the returned IP, e.g.:
# [web]
# 10.1.2.3 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

# 4) Run the playbook against the VM (no --check to apply changes)
ansible-playbook -i ansible/inventory_test.ini ansible/playbook.yml
```

Notes:
- Using Multipass gives a near-production Ubuntu environment and avoids changing your workstation.
- Running with `--check` is useful but not all modules are check-mode safe.

Terraform — validate & plan locally
- Purpose: verify Terraform syntax and see intended resource changes without creating resources.
- Commands:

```bash
cd terraform
terraform fmt -check
terraform init
terraform validate

# Plan for dev environment
terraform plan -var-file=envs/dev/terraform.tfvars -out=tfplan
```

Notes:
- The `data "aws_ami"` lookup queries AWS. Without AWS credentials `terraform plan` may fail.
- Options if you don't have AWS creds locally:
  * Provide AWS creds via env vars or `aws_profile` in the tfvars.
  * Temporarily replace the AMI lookup with a fixed AMI id in `main.tf` for local planning.

End-to-end (real cloud)
- After local validation, run `terraform apply` (requires AWS credentials) and then run Ansible using an inventory generated from `terraform output`.

```bash
cd terraform
terraform apply -var-file=envs/dev/terraform.tfvars
terraform output -json > ../terraform/tf_outputs.json

# Convert outputs to inventory (example helper not included yet)
# ./tools/tf-to-inventory.sh ../terraform/tf_outputs.json > ../ansible/inventory_generated.ini

# Run Ansible against real instance
ansible-playbook -i ansible/inventory_generated.ini ansible/playbook.yml
```

```bash
# repo and commit
git status --porcelain
git rev-parse --show-toplevel
git log --oneline -n 5

# docker & compose
docker --version
docker compose version || docker-compose --version

# docker-compose file & run state
ls -l compose/docker-compose.yml
docker compose -f compose/docker-compose.yml ps || docker-compose -f compose/docker-compose.yml ps
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

# volumes & persistent data
docker volume ls
# show volumes referenced by your compose file
grep -n "volumes:" -n compose/docker-compose.yml -A5 || true

# basic manual test steps (you must do these in a browser / WordPress UI)
# 1) Start compose locally (if not running)
docker compose -f compose/docker-compose.yml up -d
# 2) Create a WP post and upload a media file, then:
docker compose -f compose/docker-compose.yml down
docker compose -f compose/docker-compose.yml up -d
# Confirm post + file persist in the site UI
```
