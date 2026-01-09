# Cloud 1 

---
## Index Table (to be added)
---

## [updating] Project Status & TODOs

### Completed
[V] Git repository cleanup (removed large Terraform artifacts from history)
[V] `.gitignore` hardened (Terraform state, plans, logs, cache)
[V] `make terraform-clean` target created
[V] Terraform modules created (network, ec2)
[V] Environment-specific tfvars structure (`dev`, `staging`, `prod`)
[V] Ansible directory structure and inventory templates
**1/6**
[V] recheck terrafrom structure (init/plan/apply)
[V] Configure AWS credentials (SSH /access keys pair/SG_ID/instance)
[V] Run `terraform apply` to provision infrastructure -> provisioning -> get instance running to get crendentials
[V] Update and save IP in `ansible/inventories/dev/hosts.ini`
**1/9**
**ansible**
[V] Main playbook `playbook.yml` implemented (Docker, UFW, Systemd, Repo clone)
[ ] Local dev tools setup `tools.yml` implemented (Terraform, AWS CLI on macOS)
[ ] Roles created (`docker`, `terraform`, `awscli`)
[ ] Systemd service integration for auto-start/stop of Compose stack
[ ] Dynamic inventory setup with correct IP

**TODO list**
[ ] rerun terrafrom setup
[ ] Configure server with Ansible (In Progress)
> Provisioning gave you the server; Ansible will give you the application.
> *Current Block:* Ansible requires Python 3.9+, but Ubuntu 20.04 defaults to 3.8. Creating a bootstrap fix.

**Action Plan**
1. [V] **Provision (Terraform)**:
   - `make tf-deploy ENV=dev` 
   - (Optional) `make tf-plan ENV=dev` before deploy

2. [V] **Connect (SSH Check)**:
   - `make check-ssh-env ENV=dev`
   - Automatically updates Security Group with your current IP
   - Verifies SSH connectivity

3. [ ] **Configure (Ansible)**:
   - [V] Ensure `ansible/inventories/dev/hosts.ini` has the correct IP (from step 1 output).
   - [ ] **Fix Python Version**: Verify `pre_tasks` in playbook to install Python 3.9 on target.
   - [ ] Run: `ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbook.yml`
     > *Deploys: Docker Engine, UFW Security, Systemd Service, App Code*

4. [ ] **Verify Application**:
   - Open Browser: `https://51.44.19.78`
   - Setup WordPress. 


### extra improvements
[ ] Add remote Terraform state backend (S3 + DynamoDB)
[ ] Create helper script: `terraform output -json` → Ansible inventory
[ ] Add TLS/HTTPS with Let's Encrypt
[ ] Implement monitoring and logging
[ ] Add CI/CD pipeline
[ ] Complete staging and prod environment configs

---

## Quick Start: AWS auth → Terraform plan

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

## After Terraform apply (dev)

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

## 📋 Infrastructure & Deployment Workflow

This project follows a standard 3-step automation pipeline: **Provision → Configure → Deploy**.

> NOTES: 
> * **Terraform files (`.tf`)** are the blueprints for the *building* (walls, floor, address).
> * **Ansible Playbooks (`.yml`)** are the blueprints for the *interior* (furniture, appliances, electricity, software).


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


> **Terraform** gives us the computer.
> **Ansible** prepares the computer and installs Docker.
> **Docker** runs the actual application.

--- 



## porject brief 
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

## general setup
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


#### docker
- 

 / terraform / ansible / AWS CLI


---
## project repo structure (consolidated)
- `terraform/` → infrastructure (VPC, SG, EC2) with reusable modules and env tfvars
- `ansible/` → server configuration and app deployment (uses Terraform outputs)
- `compose/` → container definitions and configs used by Ansible

```bash
cloud-1/
├── README.md
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
│   └── roles/
│       └── webserver/
│           ├── tasks/
│           │   └── main.yml
│           ├── templates/
│           └── files/
└── compose/
  ├── docker-compose.yml
  └── conf/
    ├── nginx/
    │   └── nginx.conf
    ├── wordpress/
    │   └── www.conf
    └── mariadb/
      └── init_mariadb.sh
```

## Notes
- Terraform provisions infrastructure (VPC, subnets, security groups, EC2) using reusable modules.
- Ansible configures the EC2 instance(s) after Terraform apply (install packages, configure services, deploy app).
- Use `terraform outputs` to feed IP/DNS into `ansible/inventory.ini`.


## project structure (ASCII GRAPHIC)

“big picture” of your Automated Inception project (Terraform + Ansible):
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
```


```bash
                    ┌──────────────────────────────────────┐
                    │   Local Dev Workflow                 │
                    │──────────────────────────────────────│
                    │  - Edit terraform/ & ansible/        │
                    │  - Test compose/ locally (optional)  │
                    │  - Push to Git repository            │
                    └──────────────┬───────────────┬──────┘
                                   │               │
                                   │ terraform     │ ansible
                                   ▼               ▼
        ┌────────────────────────────────────────────────────┐
        │        Remote Ubuntu 20.04 EC2 (Provisioned)       │
        │────────────────────────────────────────────────────│
        │  Ansible runs:                                     │
        │   • Updates packages                                │
        │   • Installs Docker & Compose                       │
        │   • Renders compose templates (roles/webserver)     │
        │   • Runs `docker compose up -d`                     │
        │   • Configures firewall & TLS (HTTPS)               │
        │────────────────────────────────────────────────────│
        │  Services:                                          │
        │   • NGINX (TLS)  • WordPress  • MariaDB  • phpMyAdmin│
        └────────────────────────────────────────────────────┘
                                   │
                                   │ HTTPS
                                   ▼
                ┌────────────────────────────────┐
                │     Your WordPress Website     │
                │  - NGINX + TLS                 │
                │  - Persistent volumes          │
                │  - Deployable via automation   │
                └────────────────────────────────┘
```

## Notes for newbs

# Inception Automated Deployment – Key Concepts and Tools

This section explains important concepts, tools, and technologies used in the "Automated Deployment of Inception" project.  
All explanations are provided in **English** and **Traditional Chinese** for reference.

---

## 1️⃣ What is Automation?

**English:**  
Automation is using tools or scripts to make computers perform repetitive tasks automatically, without manual intervention.  
In DevOps and cloud environments, automation means deploying servers, installing software, configuring services, and running applications automatically using scripts or playbooks.

**中文（繁體）：**  
自動化（Automation）是指利用工具或程式，使電腦能自動執行重複性任務，而不需要人工操作。  
在 DevOps 或雲端環境中，自動化通常指自動部署伺服器、安裝軟體、設定服務、以及啟動應用程式。

**Learning Resources:**  
- [Red Hat: What is Automation?](https://www.redhat.com/en/topics/automation/what-is-automation)  
- [Automation in DevOps (YouTube – Simplilearn)](https://www.youtube.com/watch?v=JfYt0U2aJ1E)

---

## 2️⃣ What is Ansible?

**English:**  
Ansible is an **open-source IT automation tool**. You define server configurations and tasks using **YAML playbooks**, which describe what to install, configure, or run. It uses **SSH** to connect to remote machines and does not require agents.

**中文（繁體）：**  
Ansible 是一個開源的 **IT 自動化工具**，透過 **YAML 格式的 playbook** 描述伺服器該如何設定、安裝軟體或執行指令。  
它使用 **SSH** 連線至遠端主機，不需要安裝代理程式。

**Learning Resources:**  
- [Ansible Official Documentation](https://docs.ansible.com/)  
- [Ansible Getting Started Guide](https://docs.ansible.com/ansible/latest/getting_started/index.html)  
- [Ansible for Beginners (YouTube – TechWorld with Nana)](https://www.youtube.com/watch?v=1id6ERvfozo)

---

## 3️⃣ What are phpMyAdmin and MySQL?

**English:**  
- **MySQL:** A database management system that stores data like users, posts, and comments for your WordPress site.  
- **phpMyAdmin:** A web-based interface to manage MySQL visually, without typing SQL commands.  

**中文（繁體）：**  
- **MySQL:** 一個資料庫管理系統，用來儲存網站資料（使用者、文章、留言等）。  
- **phpMyAdmin:** 網頁介面工具，可圖形化管理 MySQL，查看、修改或備份資料，而不必輸入 SQL 指令。

**Learning Resources:**  
- [MySQL Official Documentation](https://dev.mysql.com/doc/)  
- [phpMyAdmin Official Documentation](https://www.phpmyadmin.net/docs/)  
- [MySQL Crash Course (YouTube – FreeCodeCamp)](https://www.youtube.com/watch?v=HXV3zeQKqGY)  
- [phpMyAdmin Tutorial (YouTube – ProgrammingKnowledge)](https://www.youtube.com/watch?v=1uFY60CESlM)

---

## 4️⃣ Explanation of Target Script Requirements

**English:**  
> "The script must be able to function in an automated way with for only assumption an Ubuntu 20.04 LTS-like OS of the target instance running an SSH daemon and with Python installed."

- Your deployment script (e.g., Ansible playbook) must **run automatically** on a fresh Ubuntu 20.04 server.  
- **Only assumptions:** the server has **SSH** and **Python** installed.  
- Everything else (Docker, Compose, WordPress, MySQL) must be installed/configured by the script.  

**中文（繁體）：**  
你的部署腳本必須能在「全新」Ubuntu 20.04 伺服器上自動執行。  
唯一的前提是：伺服器啟用了 **SSH** 並且安裝了 **Python**。  
其餘所有軟體（Docker、Docker Compose、WordPress、MySQL 等）必須由自動化腳本處理。

**Learning Resources:**  
- [Ubuntu 20.04 Server Documentation](https://ubuntu.com/server/docs)  
- [Ansible Prerequisites & SSH Connection](https://docs.ansible.com/ansible/latest/inventory_guide/connection_details.html)

---

## 5️⃣ Server Using TLS

**English:**  
TLS (Transport Layer Security) encrypts communication between users and your server. A server using TLS means your website runs on **HTTPS**, securing all traffic. Certificates are issued by authorities like Let’s Encrypt.

**中文（繁體）：**  
TLS（傳輸層安全協定）用來 **加密使用者與伺服器之間的通訊**。  
伺服器使用 TLS 表示網站運行在 **HTTPS** 上，保護資料安全。憑證由認證機構（例如 Let’s Encrypt）簽發。

**Learning Resources:**  
- [Let’s Encrypt Official Guide](https://letsencrypt.org/getting-started/)  
- [Nginx + Let’s Encrypt Guide](https://www.nginx.com/blog/using-free-ssl-tls-certificates-with-nginx/)  
- [How HTTPS Works (YouTube – Computerphile)](https://www.youtube.com/watch?v=T4Df5_cojAs)  

---

## 6️⃣ Other Automation & Deployment Tools

Here is a **full table** of alternative and complementary tools for server provisioning, configuration, and container orchestration:

| Tool | Purpose | Pros | Cons | Use Case in Inception Project | Learning Resources |
|------|--------|------|------|-------------------------------|------------------|
| **Ansible** | Configuration management & automation | Agentless, simple YAML syntax, widely used | Slower for very large deployments | Install Docker, Docker Compose, deploy containers automatically | [Docs](https://docs.ansible.com/), [YouTube](https://www.youtube.com/watch?v=1id6ERvfozo) |
| **Terraform** | Cloud infrastructure provisioning | Declarative, multi-cloud support, idempotent | Only provisions resources; no configuration | Provision Ubuntu VM on Scaleway/AWS | [Docs](https://developer.hashicorp.com/terraform/docs), [YouTube](https://www.youtube.com/watch?v=SLauY6PpjW4) |
| **Puppet** | Configuration management | Good for large-scale enterprise, rich ecosystem | Requires master-agent setup, more complex | Alternative to Ansible for config automation | [Docs](https://puppet.com/docs/puppet/latest/puppet_index.html), [YouTube](https://www.youtube.com/watch?v=0yKg1n2tZp0) |
| **Chef** | Configuration automation | Ruby-based recipes, powerful | Requires learning Ruby DSL, agent setup | Alternative config tool | [Docs](https://docs.chef.io/), [YouTube](https://www.youtube.com/watch?v=8X-1JXyFijE) |
| **SaltStack** | Automation & orchestration | Scalable, real-time management, agentless option | Learning curve can be steep | Config management + monitoring | [Docs](https://docs.saltproject.io/en/latest/), [YouTube](https://www.youtube.com/watch?v=6v8X_1GGN70) |
| **Docker Compose** | Single-host container orchestration | Simple YAML, perfect for local and single server | Not multi-host | Orchestrate WordPress + MySQL + phpMyAdmin locally or on server | [Docs](https://docs.docker.com/compose/) |
| **Kubernetes** | Multi-host container orchestration | Highly scalable, production-ready | Complex, steep learning curve | Optional: deploy Inception on multiple servers | [Docs](https://kubernetes.io/docs/), [YouTube](https://www.youtube.com/watch?v=X48VuDVv0do) |

**Recommended Combo for Inception Project:**  
- **Terraform** (optional) for VM provisioning  
- **Ansible** for automated setup and deployment  
- **Docker Compose** to orchestrate containers  

---

## Ansible Implementation

> other notes in /anible/README.md

### Ansible files & workflow:
1. `inventory.ini` tells Ansible where to connect.
2. `playbook.yml` defines what to do.
3. `variables.yml` defines values used by the playbook.
4. `.j2` templates are rendered with those variables and written to the target server.
5. The result → Docker app deployed on your EC2. 
```
TEMPLATE (.j2)
↓ + VARIABLES
-------------------
= RENDERED FILE (.yml)
↓
→ COPIED TO SERVER
↓
→ USED IN DEPLOYMENT
```

```bash
┌──────────────────────────────┐
│        YOU (the user)        │
│ Run: ansible-playbook playbook.yml
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ inventory.ini                │
│ - Defines target hosts, SSH  │
│   keys, interpreter, etc.    │
│ Example: 1.2.3.4 ansible_user=ubuntu
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ playbook.yml                 │
│ - Calls "roles/docker"       │
│ - Includes "variables.yml"   │
│ - Tells Ansible to apply     │
│   the template task          │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ variables.yml                │
│ - Defines values used inside │
│   the Jinja2 template        │
│ e.g. app_dir=/opt/cloud-1    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ roles/docker/tasks/main.yml  │
│ - Has a task like:           │
│   template:                  │
│     src: docker-compose.yml.j2
│     dest: "{{ compose_dir }}/docker-compose.yml"
└──────────────┬───────────────┘
               │
               ▼
────────────────────────────────────────────
   Inside the `template:` task (Ansible magic)
────────────────────────────────────────────
               │
               ▼
┌──────────────────────────────┐
│ 1️⃣ Read Source Template (.j2) │
│ e.g., roles/docker/templates/ │
│      docker-compose.yml.j2    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 2️⃣ Parse with Jinja2 Engine  │
│ - Finds {{ variables }} and  │
│   {% logic %} blocks         │
│ - Replaces using vars.yml or │
│   playbook vars              │
│ Example:                     │
│   "{{ app_dir }}" → "/opt/cloud-1"
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 3️⃣ Render Final Text File    │
│ - The template now becomes a │
│   plain YAML file (no braces)│
│ Example output:              │
│   volumes:                   │
│     - /opt/cloud-1/html:/usr/share/nginx/html
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 4️⃣ Copy Rendered File to     │
│   Remote Host via SSH        │
│ - Saved at path in 'dest:'   │
│   e.g. /opt/cloud-1/compose/ │
│        docker-compose.yml    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 5️⃣ Next Task Executes Docker │
│   - "docker compose up -d"   │
│   - Containers start running │
│     using the rendered file  │
└──────────────────────────────┘

```

### files brief
```bash
| Path                                           | Type            | Purpose                                                                                                | Example Usage                                           |
| ---------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| `inventory.ini`                                | File            | Lists your **target servers** (where Ansible will deploy). Defines host groups (`[web]`, `[db]`, etc.) | Defines EC2 instance IP, SSH key path                   |
| `inventory.ini.example`                        | Template        | Example version of `inventory.ini` for reference or new users                                          | Shows how to structure connection settings              |
| `playbook.yml`                                 | File            | The **main Ansible script** — defines what tasks or roles to run on which host groups                  | Calls the `docker` role to deploy your app              |
| `roles/docker/`                                | Folder          | Self-contained logic for configuring Docker                                                            | Reusable building block                                 |
| `roles/docker/tasks/main.yml`                  | File            | Contains a **sequence of tasks** (Ansible actions)                                                     | Install Docker, copy compose template, start containers |
| `roles/docker/templates/docker-compose.yml.j2` | Jinja2 template | Template for Docker Compose file                                                                       | Variables in `{{ brackets }}` get replaced              |
| `variables.yml`                                | File            | Stores global **variables** used in playbook and templates                                             | Defines repo URL, app directory, etc.                   |
```

---

## Terraform
### repo structure
```
terraform/
├── main.tf
├── outputs.tf
├── provider.tf
└── variables.tf
```
- `main.tf` → core logic: resources, data sources, infra setup.
- `variables.tf` → input definitions, reusable.
- `provider.tf` → provider configuration, version pinning.
- `outputs.tf` → export info for Ansible, CI/CD, etc.

> next step structure
```
terraform/
├── backend.tf          # Remote state management (S3 + DynamoDB)
├── provider.tf         # AWS provider configuration
├── variables.tf        # Variable definitions
├── locals.tf           # Common tags, names, reusable logic
├── main.tf             # Resources (EC2, SG, Key Pair)
├── outputs.tf          # Outputs (IP, DNS, etc.)
├── terraform.tfvars    # Default values for variables
├── env/
│   ├── dev/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
└── ansible/
    └── playbook.yml #etc
    └── ...    
```

> modern day organization 

| File                       | Typical contents                   | Why                                 |
| -------------------------- | ---------------------------------- | ----------------------------------- |
| **main.tf**                | Key resources (EC2, SG, AMI, etc.) | Simple to understand, small project |
| **network.tf** (optional)  | VPC, subnets, routing              | If you manage networking separately |
| **security.tf** (optional) | Security groups                    | If you have multiple SGs            |
| **compute.tf** (optional)  | EC2, autoscaling                   | For scaling / multiple servers      |
| **modules/**               | Reusable sets of resources         | For larger teams/projects           |
> For Cloud 1 Project → keeping AMI, SG, and EC2 all in main.tf is perfect.

🔵 Optional next improvements:
ext-step files: `backend.tf`, `locals.tf`, `terraform.tfvars` , etc.
- [] Add a `backend.tf` for remote state (e.g., S3 + DynamoDB).
- [] Split resources into modules if project grows (e.g., /modules/ec2).
- [] Add `terraform.tfvars` for runtime variable overrides.


### workflow
```
                            ┌──────────────────────────────┐
                            │        GitHub / Codespace    │
                            │ (Your Terraform repository)  │
                            └─────────────┬────────────────┘
                                          │
                                          ▼
        ┌────────────────────────────────────────────────────────────────┐
        │                    TERRAFORM PROJECT STRUCTURE                  │
        ├────────────────────────────────────────────────────────────────┤
        │                                                                │
        │  backend.tf        → Configure remote state backend (S3, lock) │
        │  provider.tf       → Set up AWS provider + version constraints │
        │  variables.tf      → Define all configurable inputs            │
        │  locals.tf         → Define reusable tags & naming conventions │
        │  main.tf           → Main logic: EC2, SG, Key Pair, AMI data   │
        │  outputs.tf        → Export useful info (IP, DNS)              │
        │  terraform.tfvars  → Actual values (region, key name, etc.)    │
        │  env/dev, env/prod → Environment overrides                     │
        │                                                                │
        └────────────────────────────────────────────────────────────────┘
                                          │
                                          ▼
                         ┌─────────────────────────────────┐
                         │ terraform init                  │
                         │  ↳ Reads backend.tf             │
                         │  ↳ Downloads AWS provider       │
                         │  ↳ Initializes state mgmt (S3)  │
                         └─────────────────────────────────┘
                                          │
                                          ▼
                         ┌─────────────────────────────────┐
                         │ terraform plan                  │
                         │  ↳ Reads variables.tf + tfvars  │
                         │  ↳ Evaluates main.tf resources  │
                         │  ↳ Shows changes preview         │
                         └─────────────────────────────────┘
                                          │
                                          ▼
                         ┌─────────────────────────────────┐
                         │ terraform apply                 │
                         │  ↳ Creates resources in AWS     │
                         │  ↳ Writes state to S3 backend   │
                         │  ↳ Outputs IP + DNS info        │
                         └─────────────────────────────────┘
                                          │
                                          ▼
                       ┌──────────────────────────────────────┐
                       │  AWS Cloud Infrastructure            │
                       │  - EC2 instance (Ubuntu)             │
                       │  - Security group                    │
                       │  - SSH key pair                      │
                       │  - Tags from locals.tf               │
                       │  - State stored in S3 backend        │
                       └──────────────────────────────────────┘
                                          │
                                          ▼
                     ┌────────────────────────────────────────────┐
                     │  Ansible Provisioning Layer (optional)     │
                     │  - SSHs into EC2                           │
                     │  - Installs Docker / Nginx / WordPress     │
                     │  - Configures environment                  │
                     └────────────────────────────────────────────┘
                                          │
                                          ▼
                      ┌──────────────────────────────────────────┐
                      │  Running Cloud Service                   │
                      │  🌍 https://<public_dns>                 │
                      │  Managed via IaC + Ansible               │
                      └──────────────────────────────────────────┘

```
| File                       | Purpose                                                           | When Used                 | Key Workflow Role                          |
| -------------------------- | ----------------------------------------------------------------- | ------------------------- | ------------------------------------------ |
| **`backend.tf`**           | Defines where Terraform stores state (S3 bucket + DynamoDB lock). | During `terraform init`   | Enables team collaboration & persistence   |
| **`provider.tf`**          | Configures AWS provider + version pinning.                        | During all Terraform runs | Connects Terraform → AWS                   |
| **`variables.tf`**         | Declares variable names, types, defaults.                         | During `plan/apply`       | Defines flexible, reusable inputs          |
| **`terraform.tfvars`**     | Contains actual variable values (region, key_name, etc).          | During `plan/apply`       | Supplies environment-specific config       |
| **`locals.tf`**            | Holds reusable naming conventions & tagging maps.                 | During resource creation  | Keeps naming/tagging consistent            |
| **`main.tf`**              | Core file — declares resources: EC2, SG, AMI, keypair.            | During `plan/apply`       | Builds your AWS infrastructure             |
| **`outputs.tf`**           | Defines outputs: IP, DNS, etc.                                    | After `apply`             | Returns resource info for Ansible or CI/CD |
| **`env/dev` / `env/prod`** | Contains tfvars overrides for each environment.                   | Manual or automated       | Separates dev/staging/prod                 |
| **`ansible/playbook.yml`** | (Optional) Configures app after instance is created.              | After Terraform apply     | Automates provisioning of software         |


### files brief

`main.tf`

* In Terraform, `main.tf` is typically used to **declare core resources** — the things you are actually creating (EC2, S3, SG, etc).
* It acts as the “entry point” or the **main blueprint** of your infrastructure.

👉 However, as a project grows, teams often split it into **multiple files** or even **modules** for organization:

```
main.tf            → high-level composition (calls modules)
modules/
 ├── network/
 ├── compute/
 └── storage/
```

### 🟩 “Lookup the latest Ubuntu 20.04 AMI from Canonical”

```hcl
data "aws_ami" "ubuntu_focal" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
```

#### 🧩 What’s an **AMI**?

* **AMI = Amazon Machine Image**
* It’s like a **template or base image** for your EC2 instance.
* It includes:

  * Operating system (Ubuntu, Amazon Linux, Windows, etc.)
  * Optional pre-installed software
  * Boot configuration

So, when you launch an EC2, you’re saying “create a new virtual machine **based on this AMI**”.

#### 🧩 What’s “Canonical”?

* **Canonical** is the company that develops **Ubuntu**.
* AWS lists many AMIs from different publishers, but each publisher has a unique **account ID**.
* The ID `099720109477` = Canonical’s official AWS account.

  > ✅ This ensures you’re pulling **authentic Ubuntu images**, not random community ones.

---

### 🟩 2. “Define a security group for web traffic”

```hcl
resource "aws_security_group" "web_sg" {
  name        = "cloud1-web-sg"
  description = "Allow SSH, HTTP, HTTPS"
  ...
}
```

#### 🧩 What’s a **security group**?

A **security group** is a **virtual firewall** attached to your EC2 instance.

It defines:

* ✅ **Ingress rules** → what traffic is allowed **into** your instance.
* ✅ **Egress rules** → what traffic is allowed **out** of your instance.

In your example:

* Port 22 → SSH (so you can log in)
* Port 80 → HTTP (for web traffic)
* Port 443 → HTTPS (for secure web)
* Egress → all traffic allowed outbound

💡 Without a security group, your EC2 would be **isolated — you couldn’t access it at all.**

---

### 🟩 3. “Create an EC2 instance”

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu_focal.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name != "" ? var.key_name : null
  tags = { Name = "cloud1-web" }
}
```

#### 🧩 Can I create multiple EC2 instances here?

✅ Yes, absolutely.

There are two common ways:

**A. Manually duplicate**

```hcl
resource "aws_instance" "web2" { ... }
resource "aws_instance" "db" { ... }
```

**B. Dynamically create multiple instances**

```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = data.aws_ami.ubuntu_focal.id
  instance_type = var.instance_type
  tags = { Name = "cloud1-web-${count.index}" }
}
```

This would create:

```
cloud1-web-0
cloud1-web-1
cloud1-web-2
```

💡 **Common practice:**

* For small projects → put EC2 resources in `main.tf`
* For larger ones → move them to `compute.tf` or a `/modules/ec2` folder

---

### 🟩 4. “Why create key pair from local public key?”

```hcl
# resource "aws_key_pair" "deployer" {
#   key_name   = "cloud1-deploy"
#   public_key = file(var.public_key_path)
# }
```

#### 🧩 What this does:

It uploads your **local SSH public key** to AWS as a **key pair**.

Then AWS uses it to let you SSH into the EC2 instance securely:

* You connect using your **private key**
* AWS verifies it against the **public key** stored in your EC2

So instead of manually adding your key in AWS Console, Terraform automates it.

#### 🧠 When to use it:

| Scenario                                            | Should you use `aws_key_pair`?            |
| --------------------------------------------------- | ----------------------------------------- |
| You already have a key pair created in AWS          | ❌ No (just reference it using `key_name`) |
| You want Terraform to create & manage it for you    | ✅ Yes (uncomment the resource)            |
| You deploy from GitHub Codespaces (no pre-made key) | ✅ Very helpful!                           |

---

## 📊 Summary Table

| Section            | Purpose                     | Common Practice                                     |
| ------------------ | --------------------------- | --------------------------------------------------- |
| **AMI data block** | Get the latest Ubuntu image | Yes, always use a data source instead of hardcoding |
| **Security Group** | Allow web + SSH traffic     | Always define your own SG per instance/app          |
| **EC2 instance**   | Create the actual VM        | Often stays in `main.tf` unless large project       |
| **Key Pair**       | Allow secure SSH login      | Use if you don’t already have a key in AWS          |

---

### 🧩 ASCII overview — how `main.tf` flows

```
[ data.aws_ami.ubuntu_focal ]   -> finds the latest Ubuntu AMI
             │
             ▼
[ aws_security_group.web_sg ]   -> defines firewall rules
             │
             ▼
[ aws_instance.web ]            -> creates EC2 using the above AMI + SG
             │
             ▼
[ aws_key_pair.deployer ] (opt) -> uploads local public key to AWS
```

---

✅ **Final takeaways**

* Yes, your `main.tf` is well structured and standard.
* Keeping AMI + SG + EC2 here is fine for small projects.
* You can expand later into modules if your infra grows.
* The key pair helps automate SSH setup.
* Each section serves a critical part of the EC2 lifecycle.

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


---
## test commands 
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
---

## extra tools installed : 

### git-filter-repo
- A powerful tool for rewriting Git history.
- Remove files or directories from all past commits
- Rewrite commit messages
- Delete large files from history to shrink repo size
- Replace text or secrets across the entire commit history
- Split or reorganize a repository
> It is the modern replacement for git filter-branch and the BFG tool—faster, safer, and more flexible.
### gitleaks
A security scanning tool that searches your Git repositories for:
- Hard-coded passwords
- API keys
- Tokens
- Private keys
- Other sensitive data

> It scans commit history, branches, and even PRs to detect accidental secret exposure. > It’s often used in CI pipelines to prevent leaking credentials.

### git-filter-repo — Common Commands


| Task                                     | Command                                                        | Notes                                         |
| ---------------------------------------- | -------------------------------------------------------------- | --------------------------------------------- |
| Remove a file from entire history        | `git filter-repo --path filename --invert-paths`               | Deletes the file in all commits               |
| Remove a folder from history             | `git filter-repo --path foldername --invert-paths`             | Useful for cleaning large or unwanted folders |
| Replace text across all commits          | `git filter-repo --replace-text replacements.txt`              | `replacements.txt` defines text substitutions |
| Remove large files by size               | `git filter-repo --strip-blobs-bigger-than 10M`                | Removes blobs larger than the given size      |
| Rewrite author info                      | `git filter-repo --email-callback 'return new_email'`          | Used to fix author/committer emails           |
| Keep only a specific subdirectory        | `git filter-repo --subdirectory-filter path/to/dir`            | Turns a folder into the root of the repo      |
| Remove all history except last N commits | `git filter-repo --refs HEAD~N..HEAD`                          | Keeps only recent history                     |
| Clean commit messages                    | `git filter-repo --message-callback '...python code...'`       | Fully customizable rewriting                  |
| Rename a file historically               | `git filter-repo --path oldname --path-rename oldname:newname` | Rewrites past commits with new name           |

### gitleaks — Common Commands
| Task                                     | Command                                                     | Notes                                |
| ---------------------------------------- | ----------------------------------------------------------- | ------------------------------------ |
| Run a scan on current repo               | `gitleaks detect`                                           | Uses default configuration           |
| Scan with verbose output                 | `gitleaks detect -v`                                        | Shows detailed findings              |
| Provide a custom config file             | `gitleaks detect -c path/to/config.toml`                    | Allows custom rules                  |
| Scan and output report to file           | `gitleaks detect -r report.json`                            | Exports results                      |
| Scan a specific path                     | `gitleaks detect -s path/to/dir`                            | Useful outside Git repos             |
| Scan a remote repository                 | `gitleaks detect --source=https://github.com/user/repo.git` | Clones and scans                     |
| Run in CI mode (exit 1 if secrets found) | `gitleaks protect`                                          | Used to prevent commits with secrets |
| Allowlist a file or pattern              | (in config TOML)                                            | Rules added via configuration        |
| Redact secrets in output                 | `gitleaks detect --redact`                                  | Hides actual secret values           |



---

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⡀⣀⠀⠀⠀⠀⠀⢀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⣢⠀⠀⠉⠀⠉⠉⡆⠀⠀⢀⡔⣧⠀⠀⠉⠀⠀⢷⠀⠀⠀⠀⠈⣆⣇⣠⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠓⠒⠚⠦⠼⠤⠼⠋⠁⠀⠀⠈⠢⠤⠴⣄⣀⡶⠤⠞⠀⠀⠀⠉⠉⡽⣿⣿⠒⠒⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠞⠁⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠴⠒⠒⠦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⠶⠀⢷⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠇⠀⠀⠀⠀⡼⢀⣩⠗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠀⠀⠀⠀⠀⡗⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣄⡀⠀⠀⠀⠀⣀⣠⠇⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡍⠉⠉⠉⠉⢁⡀⠀⣀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠓⡄⠀⠀⠀⠯⠤⠖⠁⠀⠀⢀⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠲⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠆⠈⠓⢄⣀⣀⣀⣀⣀⡤⠖⠋⠈⠒⢦⠀⠀⠀⠀⠀⢠⣆⠀⠀⠀⣇⠋⠙⡝⡲⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⠁⢠⡋⠀⣖⣀⣀⣀⣀⣀⣀⣈⡇⠐⡆⠀⡇⠀⠀⠀⠀⠸⡌⠓⡒⠚⠉⠀⢠⠟⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⣄⡀⠉⠓⠦⠤⠄⠀⠀⠤⠤⠤⠤⠖⢁⡴⠃⠀⠀⠀⢀⠀⣳⣌⣓⠋⣁⡤⠋⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠒⠒⠦⠤⠤⠤⠴⠒⠒⠒⠚⠉⠀⠀⠀⣠⠀⣇⠀⠧⣄⣈⣉⣁⡬⠗⣦⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⣄⠈⠉⠓⠒⠀⠀⠒⠒⠚⠁⢦⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠒⠒⠢⠤⠤⠤⠒⠋⠉⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀

GIT COMMAND SHEET
- https://education.github.com/git-cheat-sheet-education.pdf
- https://git-scm.com/cheat-sheet
- https://about.gitlab.com/images/press/git-cheat-sheet.pdf


