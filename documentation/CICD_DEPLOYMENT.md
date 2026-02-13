# CI/CD Automazation Deployment

## `deploy.yml`
- enables **automation** 
- tells GitHub how to build, test, and deploy infrastructure and application every time push code. 
> Without it -> have to run all deployment steps manually on local machine => error-prone & not scalable!!

**Key reasons:**
- **Automation:** Every deployment step (Terraform, Ansible, Docker, etc.) runs automatically in the cloud, not just on local computer
- **Reliability:** Ensures the same process runs every time, reducing human error and "works on my machine" problems.
- **Security:** Secrets (like AWS keys) are managed securely by GitHub, not stored on local computer
- **Auditability:** Every change and deployment is tracked in Git history
- **Modern DevOps:** industry standard for managing infrastructure and application deployments (CI/CD, GitOps)

> `deploy.yml` is the recipe for GitHub to build and deploy project automatically, reliably, and securely

---


## 1. why `deploy.yml` in .github

- This file is the "brain" of your automation. It tells GitHub exactly how to build, test, and deploy your application whenever you change your code.
- It lives in a special hidden folder (`.github/workflows`) because GitHub looks there specifically for **Actions** (instructions).

## 2. The Concepts

### CI (Continuous Integration)
*   **Definition:** Automatically checking your code every time you save it.
*   **In this project:** It ensures that your code "integrates" correctly. If you were running tests (like checking if your Python script runs), they would happen here. It prevents broken code from getting into the main project.

### CD (Continuous Deployment / Delivery)
*   **Definition:** Automatically pushing your code to the real world (production servers) without human intervention.
*   **In this project:** This is the main job of `deploy.yml`. It takes your Terraform and Ansible code and **updates your AWS servers automatically** as soon as you push to GitHub.

### GitOps
*   **Definition:** Using Git as the "single source of truth" for your infrastructure.
*   **Why it matters:**
    *   If you want to change the server size, you don't go to the AWS Console. You edit `variables.tf` in Git.
    *   If you want to add a new monitoring tool, you don't SSH into the server. You add an Ansible Role in Git.
    *   **The Result:** Your entire infrastructure is versioned, auditable, and reproducible.

## 3. How It Works (The Pipeline Flow)

When you run `git push origin master`:

1.  **Trigger:** GitHub notices the push and wakes up a "Runner" (a temporary Ubuntu server provided by GitHub).
2.  **Checkout:** The runner downloads your code.
3.  **Setup:** It installs the tools you need (Terraform, Python, Ansible).
4.  **Infrastructure (Terraform):**
    *   It logs into AWS using your secret keys.
    *   It runs `terraform apply` to ensure your EC2 servers exist and are configured correctly.
5.  **Configuration (Ansible):**
    *   It generates the inventory file (list of IP addresses).
    *   It runs the playbook to install Docker, Nginx, WordPress, and the CloudWatch Agent.

## 4. Manual vs. Modern Approach (Difference between Scripts & CI/CD)

Think of it like the difference between **a Chef** (GitHub Actions) and **a Recipe** (Bash/Python).

| | Bash / Python Scripts | GitHub Actions Workflow (`deploy.yml`) |
| :--- | :--- | :--- |
| **What is it?** | A list of actual commands to execute. | A configuration file for a **Server**. |
| **Who runs it?** | **You** (on your laptop) or a specific server. | **GitHub** (automatically). |
| **The Job** | "Connect to AWS", "Install Docker", "Print Hello". | "Get a computer ready", "Install Python", "Download the code", "Then **run the bash script**". |
| **Environment** | Relies on *your* laptop having Terraform/Python installed. | Creates a **brand new** clean environment (Virtual Machine) every time. |
| **Role** | The **Tool** (The Hammer). | The **Manager** (The Person holding the hammer). |

## 5. Why "Necessary"?

While you *technically* can run scripts manually for a school project, in the professional world:

*   **Reliability:** CI/CD eliminates "it works on my machine" bugs.
*   **Auditability:** Every change to the infrastructure is recorded in Git commit history.
*   **Scale:** You can manage 100 servers as easily as 1.

By including `deploy.yml`, you are demonstrating that you understand how modern cloud engineering works: **Automate everything.**

## 6. Common Pitfalls: Manual vs Automated

| Problem | Manual (Working) | Automated (Failing) | Explanation |
| :--- | :--- | :--- | :--- |
| **Missing .env** | File exists in folder (ignored by git). | Runner starts fresh from git (file is missing). | **Fix:** Inject secrets via GitHub Secrets & generate .env on fly. |
| **Volumes** | Docker creates internal volume automagically. | Ansible creates host folder, Docker ignores it. | **Fix:** Bind mount explicit host paths `device: ${DATA_DIR}/data`. |
| **Permissions** | You are `yilin`, specific shell env is loaded. | Systemd is `root`, non-interactive, no env vars. | **Fix:** Explicitly pass `Environment=` in systemd unit file. |
| **Paths** | You `cd` into folder and run. | Systemd runs from `/` or specified working dir. | **Fix:** Always use absolute paths in automation configs. |

---

# Cloud-1 Deployment Guide

## Quick Start: Deploy to Cloud Server

### Prerequisites
- Cloud server with Ubuntu 20.04/22.04 LTS
- SSH access configured
- Your SSH public key added to the server

### Step 1: Provision Server

**Recommended Provider: DigitalOcean**
- Plan: Basic Droplet ($6/month)
- Specs: 1 vCPU, 1 GB RAM, 25 GB SSD
- Image: Ubuntu 20.04 LTS
- Add your SSH key during creation

**Alternative: Scaleway**
- Plan: DEV1-S (€0.01/hour)
- Specs: 2 vCPU, 2 GB RAM, 20 GB SSD
- Image: Ubuntu Focal 20.04

### Step 2: Connect to Server

```bash
ssh root@YOUR_SERVER_IP
# or
ssh ubuntu@YOUR_SERVER_IP
```

### Step 3: Install Ansible on Server

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible git
ansible --version
```

### Step 4: Clone Repository

```bash
cd ~
git clone https://github.com/ychun816/cloud-1.git
cd cloud-1
```

### Step 5: Configure Environment

Create `.env` file:
```bash
nano .env
```

Paste and customize:
```env
DOMAIN_NAME=yilin.42.fr

# MariaDB Configuration
MYSQL_HOSTNAME=mariadb
MYSQL_DATABASE=wordpress
MYSQL_USER=yilin
MYSQL_ROOT_PASSWORD=your_secure_password_here
MYSQL_PASSWORD=your_secure_password_here

# WordPress Configuration  
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=your_wp_admin_password
WP_ADMIN_EMAIL=admin@example.com

WP_URL=https://yilin.42.fr
WP_TITLE=Cloud-1 Inception
WP_USER=editor
WP_USER_PASSWORD=editor_password
WP_USER_EMAIL=editor@example.com

# Data directories - SERVER PATH
DATA_DIR=/opt/cloud-1-data
```

Save: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 6: Create Data Directories

```bash
sudo mkdir -p /opt/cloud-1-data/mariadb_data
sudo mkdir -p /opt/cloud-1-data/wordpress_data
sudo chown -R $USER:$USER /opt/cloud-1-data
```

### Step 7: Run Ansible Playbook

```bash
cd ~/cloud-1/ansible
ansible-playbook -i hosts.ini playbook.yml --ask-become-pass
```

Enter your sudo password when prompted.

This will:
- Install Docker & Docker Compose
- Configure UFW firewall
- Disable root SSH password login
- Create systemd service for auto-start
- Clone repo to `/opt/cloud-1`
- Start all containers

### Step 8: Verify Deployment

Check containers:
```bash
cd ~/cloud-1/compose
docker compose ps
docker ps
```

Expected output:
```
nginx       Up    0.0.0.0:443->443/tcp
wordpress   Up
mariadb     Up
```

### Step 9: Access WordPress

Open browser:
```
https://YOUR_SERVER_IP
```

**Note:** You'll see a certificate warning (self-signed cert). Click "Advanced" → "Proceed anyway".

You should see WordPress installation screen!

### Step 10: Complete WordPress Setup

1. Select language
2. Enter site details
3. Create admin account
4. Log in and test:
   - Create a test post
   - Upload an image
   - Restart containers: `docker compose restart`
   - Verify post + image persist

## Troubleshooting

### Containers not starting
```bash
docker compose logs -f
```

### Firewall blocking access
```bash
sudo ufw status
sudo ufw allow 443/tcp
```

### Reset deployment
```bash
cd ~/cloud-1/compose
docker compose down -v
sudo rm -rf /opt/cloud-1-data/*
# Then re-run ansible playbook
```

## Clean Up (When Done)

Destroy cloud server to stop billing:
- DigitalOcean: Dashboard → Droplets → More → Destroy
- Scaleway: Console → Instances → Delete
