
## [updating] Project Status & TODOs


✅ MET Requirements:
1. Fully automated deployment - Ansible playbooks configured ✓
2. Separate containers - nginx, mariadb, wordpress in docker-compose ✓
3. Data persistence - Named volumes for mariadb_data and wordpress_data ✓
4. Auto-restart on reboot - restart: unless-stopped in compose ✓
5. Systemd integration - Ansible creates systemd service ✓
6. Ubuntu 20.04 LTS support - Bootstrap Python fix implemented ✓
7. Docker containers - docker-compose.yml present with 3 services ✓
8. Network security - Internal network inception_network, database not exposed to internet ✓
9. TLS/HTTPS - nginx configured with SSL certificates (port 443) ✓
10. Database + WordPress + PHP - MariaDB, WordPress, nginx setup ✓


### Completed

[V] Git repository cleanup (removed large Terraform artifacts from history)
[V] `.gitignore` hardened (Terraform state, plans, logs, cache)
[V] `make terraform-clean` target created
[V] Terraform modules created (network, ec2)
[V] Environment-specific tfvars structure (`dev`, `staging`, `prod`)
[V] Ansible directory structure and inventory templates
[V] recheck terrafrom structure (init/plan/apply)
[V] Configure AWS credentials (SSH /access keys pair/SG_ID/instance)
[V] Run `terraform apply` to provision infrastructure -> provisioning -> get instance running to get crendentials
[V] Update and save IP in `ansible/inventories/dev/hosts.ini`

**ansible**
[V] Main playbook `playbook.yml` implemented (Docker, UFW, Systemd, Repo clone)
[V] Roles created (`docker`, `terraform`, `awscli`, `cloudwatch`)
[V] Systemd service integration for auto-start/stop of Compose stack
[V] Dynamic inventory setup with correct IP (generate_inventory.py)

**Ansible Fixes & Deployment**
[V] Resolved Python 3.8/3.9 conflict on Ubuntu 20.04 (Bridge fix)
[V] Fixed `pip` and `docker-compose` installation dependencies
[V] Successful `ansible-playbook` run (failed=0)
[V] Systemd service `cloud-1` created for auto-start
[V] Security hardening applied (UFW, SSH)

**New Features (Cloud & Monitoring)**
[V] Parallel Deployment: Terraform supports `instance_count` and Ansible handles multiple IPs
[V] Monitoring Infrastructure: Terraform creates IAM Role for CloudWatch
[V] Monitoring Agent: Ansible installs and configures CloudWatch Agent (Memory/Disk metrics)
[V] CI/CD Pipeline: GitHub Actions workflow (`deploy.yml`) created for automated deployment
[V] Production Environment: Configured independently with cost-optimized settings (`t3.micro`)


### TODO (if to launch prod)
- [ ] Run `terraform init` in `terraform/envs/prod` to generate .terraform.lock.hcl and initialize provider/modules for production environment.

### feb6-feb7 (Verification)
 These are the final steps to prove your project meets all requirements:

1.  **Deployment Verification (CI/CD)**
    *   [V] Commit and push all changes to GitHub.
    *   [V] Go to the **Actions** tab in your GitHub repository.
    *   [V] Confirm the "Deploy to AWS" workflow runs successfully (green checkmark).
    *   [V] **TODO Next:** Fix `.env` missing in CI/CD (add secrets).

- check status in summary
```bash
git status -sb
```
- Generate a stable key (Locally) for deployment key
> if not specific keys, the workflow generates a random one every tim
```bash
ssh-keygen -t rsa -b 4096 -f deploy_key -N ""
```
- terminate aws instance ot let terrafrom run fresh instance
```bash
# CLI commands
export AWS_PROFILE=cloud-1-dev
aws ec2 terminate-instances --instance-ids [(#ur-instanceID)i-054711dbdbb95e108] --region [(#your-region)eu-west-3]
```
- allow gitpush when theres no new changes
```
git commit --allow-empty -m "...."
```

2.  **Monitoring Verification (AWS CloudWatch)**
    *   [V] Log in to the AWS Console.
    *   [V] Go to **CloudWatch** -> **Metrics**.
    *   [V] Look for the **CWAgent** namespace.
    *   [V] Confirm `mem_used_percent` and `disk_used_percent` are visible.

- restrat and ssh into container
```bash
ssh -v -i deploy_key ubuntu@51.44.17.77
```
- Check CloudWatch Agent Status
- Check the logs are actually sending data with 
```bash
sudo systemctl status amazon-cloudwatch-agent
tail -n 20 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

3.  **Application Verification**
    *   [x] Access the site via HTTPS (accept the self-signed certificate).
    *   [x] Reboot the server: `ssh ubuntu@<IP> 'sudo reboot'`
    *   [x] Wait 2 minutes.
    *   [x] Access the site again and verify the post is still there (Persistence & Auto-start).

4.  **Multi-Server Proof**
    *   [x] Edit `terraform/envs/dev/terraform.tfvars` and set `instance_count = 2`.
    *   [x] Push to master.
    *   [x] Verify **two** servers are created and configured in AWS.


---

* notes
after anisble set up , check server:
- SSH into server to verify the containers are running:

```bash
ssh ubuntu@51.44.255.51 #ubuntu@51.44.17.77
sudo docker ps
exit #quit 
```

**rerun terrafrom, Ansible, check docker setup for wordpress,ngnix,mariadb**
[V] Verify WordPress setup in browser
[V] Configure TLS/HTTPS (Encrypt)
[V] Add remote Terraform state backend (S3 + DynamoDB)
[V] Automate dynamic inventory (Terraform JSON -> Ansible)

**Action Plan**
1. [V] **Provision (Terraform)**:
   - `make tf-deploy ENV=dev` 
   - (Optional) `make tf-plan ENV=dev` before deploy

2. [V] **Connect (SSH Check)**:
   - `make check-ssh-env ENV=dev`
   - Automatically updates Security Group with your current IP
   - Verifies SSH connectivity

3. [V] **Configure (Ansible)**:
   - [V] Ensure `ansible/inventories/dev/hosts.ini` has the correct IP (from step 1 output).
   - [V] **Fix Python Version**: Implemented bootstrap fix for Ubuntu 20.04.
   - [V] Run: `ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbook.yml`
     > *Deploys: Docker Engine, UFW Security, Systemd Service, App Code*

4. [V] **Verify Application**:
   - Open Browser: `https://35.180.118.164` (Accept the security warning)
   - Setup WordPress 

### 1/16 TODO : Completed

[V] Automate dynamic inventory (Terraform JSON -> Ansible)
[V] Add remote Terraform state backend (S3 + DynamoDB)
[V] Add TLS/HTTPS (Self-Signed)
```
-> Traffic encrypted @ port 443
-> Port 80 handled
```

### Mandatory Requirements Compliance Checklist
[V] Add HTTP→HTTPS redirect in nginx (port 80 → 443)
[V] Add Adminer database manage tools
[V] Verify `.env` file with all required variables
[V] Confirm domain DNS setup for `yilin.42.fr` (Verified via hosts/redirects)
[V] Test multi-server parallel deployment scenario

### Next Session TODO (CloudWatch & CI/CD)
[x] **Implement Monitoring (AWS CloudWatch)**
    -> [x] Create IAM Role for EC2 (Terraform)
    -> [x] Install CloudWatch Agent (Ansible)
    -> [x] Verify Metrics in AWS Console
[x] Add CI/CD pipeline
[x] Complete staging and prod environment configs (Prod configured, Staging skipped)

---

## Criteria:
[x] HTTP (80) redirects to HTTPS (443)
[x] HTTPS serves WordPress with TLS
[x] WordPress accessible and working
[x] Adminer accessible at /adminer/
[x] All 4 containers running
[x] Data persists after restart
[x] Auto-starts after server reboot

---

> Only run Terraform when you verify or change infrastructure (Firewall rules, EC2 size, SSH key).

> Only run Ansible when you change configuration files (Nginx config, scripts, Docker setup).

---

## tests commands

### STEP 0: Pre-Deployment Setup
1. make sure ssh key pairs and .env in repo:
- `.env` in `cloud1/compose`
- `deploy_key.pub` in `terraform/envs/dev`
- `deploy_key` in root repo

2. check if all tools are installed (ansible/terraform/aws cli)
```bash
make check-tools
```

### STEP 1: Deploy to Your Server

#### NORMAL SETUP 
```bash
# 1 terraform deploy the initate EC2 instance
make tf-deploy ENV=dev

# 2 updates the security group with your current IP, saves outputs, and tests SSH access
make init-ssh-ec2 ENV=dev

# 3 Check if EC2 instance is running and reachable (port 22)
make check-aws-ec2 ENV=dev

# 4 Ensure your current IP is allowed for SSH and test SSH access
# run terraform init & terraform apply -> update the security group with current public IP for SSH access (port 220) with deploy_key
#make init-ssh-ec2 ENV=dev

# 5  Run Ansible to configure/setup everything
make run-ansible ENV=dev
```

### STEP 2: Verify Containers are Running

```bash
# Check all 4 containers are up
make check-containers ENV=dev

# Should see:
# - nginx
# - wordpress
# - mariadb
# - adminer
```

### STEP 3: Test HTTP → HTTPS Redirect

```bash
# From your local machine (replace with YOUR_SERVER_IP)
curl -v http://[SERVER_IP] 


# Should see:
# HTTP/1.1 301 Moved Permanently
# Location: https://yilin.42.fr/
```

### STEP 4: Test HTTPS Access

```bash
# Test HTTPS (ignore self-signed cert warning)
curl -k -I https://YOUR_SERVER_IP

# Should see:
# HTTP/2 200 
# server: nginx
# ...
```

### STEP 5: Test WordPress Setup / WordPress login / Adminer (Database Access)

```bash
# Wordpress
https://[SERVER_IP]

# Test Wordpress login:
https://[SERVER_IP]/wp-admin

# adminer 
https://[SERVER_IP]/adminer/

# Login with:
# - System: MySQL
# - Server: mariadb
# - Username: wpuser (from .env MYSQL_USER)
# - Password: SecureDbPass456! (from .env MYSQL_PASSWORD)
# - Database: wordpress
```

### STEP 6 : check cloudwatch
```bash
# SSH into running EC2 instance
ssh -i deploy_key ubuntu@<EC2_PUBLIC_IP>
# ssh -i deploy_key ubuntu@13.38.93.240

# once inside EC2, manually start the CloudWatch
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

# check if the CloudWatch agent process is running on ec2
ps aux | grep amazon-cloudwatch-agent

# check CloudWatch running
sudo systemctl status amazon-cloudwatch-agent

# check CloudWatch logs
tail -n 20 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

# close/leave EC2
exit

```


### STEP 7 (final): destroy EC2 
```bash
# destory EC2 instance
make tf-destroy ENV=dev

#  remove temporary Terraform files (plans, cache), keep your state files
make tf-clean-cache ENV=dev

# confirm there are no running EC2 instances and no leftover temp files
make tf-clean-check ENV=dev

# check if EC2 still running
make check-aws-ec2 ENV=dev

```

---


## Other notes & checking process

### aws CLI commands

```bash
aws sts get-caller-identity

aws-cli --version

# configure as default -> show aws ID
aws configure 

# creates a separate named profile & stores another copy under a different profile name
aws configure --profile cloud-1-dev

curl -s https://checkip.amazonaws.com

```

```bash
cp = Copy locally (File A → File B)
ssh = Login remotely
scp = ssh + cp (Copy File A → Remote Computer File B)
```

---

### ec2 setup
#### Option A: Full automated deployment (if Terraform + Ansible ready)

```bash
# SSH requires private keys to be readable only by the owner (should be 0600)
# First time: Allow IP for SSH access
make check-ssh-env ENV=dev  

# (optional) if Infrastructure change (servers, networks, firewalls, etc.)
make tf-deploy ENV=dev

# Get the public IP from output (save it)
# (optional) Second time: Get the new server IP(s) after infrastructure changes.
# make check-ssh-env ENV=dev

# Update Ansible inventory with that IP
# (OPTIONAL) if IP changes -> nano ansible/inventories/dev/hosts.ini 
ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbook.yml
```

#### Option B: Manual deployment (if server already exists)

```bash
# SSH into your server
ssh -i deploy_key ubuntu@[SERVER_IP]
# check IP address viewed by external
curl ifconfig.me
# Restart containers if you made updates
make compose-up ENV=dev
# Check if containers are running
sudo docker ps
# Check if the site answers locally
curl -k https://localhost | grep "wordpress"
# Check if database is ready
sudo docker exec mariadb mysql -u root -p[ROOT_PASSWORD] -e "SHOW DATABASES;"
# Exit and test from browser
https://[SERVER_IP] (Accept warning)
http://[SERVER_IP]  (Should redirect to HTTPS)
https://[SERVER_IP]/adminer/  (Should see Adminer login)
# If there's a problem, check if the server listens on port 80 and 443
ss -tulpn | grep -E '80|443'
# Clone/update your repo if needed
cd /home/ubuntu
git clone https://github.com/your-repo/cloud-1.git || (cd cloud-1 && git pull)
# Copy your .env file to the server
exit  # back to local
scp compose/.env ubuntu@YOUR_SERVER_IP:/home/ubuntu/cloud-1/compose/
# SSH back in
ssh ubuntu@YOUR_SERVER_IP
# Build and start containers
cd /home/ubuntu/cloud-1/compose
sudo docker-compose up -d --build
```
---


### Test Auto-Restart (Data Persistence)

```bash
# SSH into server
ssh ubuntu@YOUR_SERVER_IP

# Stop all containers
cd /home/ubuntu/cloud-1/compose
sudo docker-compose down

# Start them again
sudo docker-compose up -d

# Check containers are back
sudo docker ps

# In browser, visit again
https://YOUR_SERVER_IP
```

### Test Server Reboot
```bash
# SSH into server
ssh ubuntu@YOUR_SERVER_IP

# Reboot the server
sudo reboot

# Wait 1 minute, then SSH back in
ssh ubuntu@YOUR_SERVER_IP

# Check if systemd started containers automatically
sudo systemctl status cloud-1

# Check containers
sudo docker ps
```

### Complete Checklist
```bash
# 1. HTTP redirect works?
curl -I http://YOUR_SERVER_IP | grep "301"

# 2. HTTPS works?
curl -k -I https://YOUR_SERVER_IP | grep "200"

# 3. WordPress accessible?
curl -k https://YOUR_SERVER_IP | grep "wordpress"

# 4. All containers running?
sudo docker ps | wc -l  # Should be 5 (4 containers + header)

# 5. Database connection?
sudo docker exec mariadb mysql -u wpuser -pSecureDbPass456! -e "SHOW DATABASES;"    
```

### Multi-Server Verification (Scaling)

```bash
# 1. Verify 2 IPs in Terraform Output
cd terraform/envs/dev && terraform output webserver_public_ips

# 2. Verify Ansible Inventory
cat ../../../ansible/inventories/dev/hosts.ini

# 3. Check Docker status on BOTH servers simultaneously
cd ../../..
ansible -i ansible/inventories/dev/hosts.ini web -m shell -a "sudo docker ps" --become

# 4. CURL both endpoints (Replace with your specific IPs)
curl -k -I https://51.44.220.17
curl -k -I https://13.39.162.182
```

### Verify .env Requirements

```bash
# Verify .env exists and has content (ssh into one instance)
# Note: Ansible installs to /opt/cloud-1 by default
ssh -i deploy_key ubuntu@51.44.220.17 "ls -l /opt/cloud-1/compose/.env"

# Check for required keys (without revealing passwords) @cloud -1 
ssh -i deploy_key ubuntu@51.44.220.17 "sudo grep -E 'DOMAIN_NAME|MYSQL_USER|MYSQL_DATABASE' /opt/cloud-1/compose/.env"

```

### DNS Verification

```bash
# Option A: Check Real DNS (if configured)
dig +short yilin.42.fr

# Option B: Verify Nginx Response to Domain (Simulate DNS)
# This sends the domain name in the header directly to the IP
curl -k -I -H "Host: yilin.42.fr" https://51.44.220.17

# Verify it matches your Terraform output
cd terraform/envs/dev && terraform output webserver_public_ips

```