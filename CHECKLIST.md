
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
[V] Local dev tools setup `tools.yml` implemented (Terraform, AWS CLI on macOS)
[V] Roles created (`docker`, `terraform`, `awscli`)
[V] Systemd service integration for auto-start/stop of Compose stack
[ ] Dynamic inventory setup with correct IP

**Ansible Fixes & Deployment**
[V] Resolved Python 3.8/3.9 conflict on Ubuntu 20.04 (Bridge fix)
[V] Fixed `pip` and `docker-compose` installation dependencies
[V] Successful `ansible-playbook` run (failed=0)
[V] Systemd service `cloud-1` created for auto-start
[V] Security hardening applied (UFW, SSH)

* notes
after anisble set up , check server:
- SSH into server to verify the containers are running: 
```bash
ssh ubuntu@51.44.255.51
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
```bash


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
[ ] Test multi-server parallel deployment scenario

### Next Session TODO (CloudWatch & CI/CD)
[ ] **Implement Monitoring (AWS CloudWatch)**
    -> [ ] Create IAM Role for EC2 (Terraform)
    -> [ ] Install CloudWatch Agent (Ansible)
    -> [ ] Verify Metrics in AWS Console
[ ] Add CI/CD pipeline
[ ] Complete staging and prod environment configs

---

> Only run Terraform when you verify or change infrastructure (Firewall rules, EC2 size, SSH key).

> Only run Ansible when you change configuration files (Nginx config, scripts, Docker setup).

---
## tests commands

🔧 STEP 0: Pre-Deployment Setup

```
cd /home/yilin/GITHUB/cloud-1/compose
cp ../.env.example .env
nano .env  # Edit with your actual credentials
```

📦 STEP 1: Deploy to Your Server

Option A: Full automated deployment (if Terraform + Ansible ready)

```
cd /home/yilin/GITHUB/cloud-1
make check-ssh-env ENV=dev

# 1. Deploy infrastructure
make tf-deploy ENV=dev

# 2. Get the public IP from output (save it)
make check-ssh-env ENV=dev

# 3. Update Ansible inventory with that IP
nano ansible/inventories/dev/hosts.ini

# 4. Run Ansible to configure server
ansible-playbook -i ansible/inventories/dev/hosts.ini ansible/playbook.yml
```

Option B: Manual deployment (if server already exists)
```
# SSH into your server
ssh ubuntu@[SERVER_IP] 
ssh ubuntu@35.180.100.72

# check IP address viewed by external 
curl ifconfig.me

# restart container if update changes
cd /home/ubuntu/cloud-1/compose
sudo docker compose down -v
sudo docker compose up -d --build 
#-d (detached, run in background) / #--build (Force Rebuild)

# check if containers are running 
sudo docker ps

# Check if the site answers locally (curl)
curl -k https://localhost | grep "wordpress"

# Check if database is ready
sudo docker exec mariadb mysql -u root -p[ROOT_PASSWORD] -e "SHOW DATABASES;"
sudo docker exec mariadb mysql -u root -piwantstage -e "SHOW DATABASES;" # OR: -piwillfindstageapril




# Exit and test from browser
https://[SERVER_IP] #35.180.100.72 (Accept warning)
http://[SERVER_IP] #35.180.100.72  (Should redirect to HTTPS)
https://[SERVER_IP]/adminer/  # 35.180.100.72 (Should see Adminer login)


# if there's prob -> check if the server listen on port 80 and 443
ss -tulpn | grep -E '80|443'

# Clone/update your repo
cd /home/ubuntu
git clone https://github.com/your-repo/cloud-1.git
# OR: cd cloud-1 && git pull

# Copy your .env file to the server
exit  # back to local
scp compose/.env ubuntu@YOUR_SERVER_IP:/home/ubuntu/cloud-1/compose/

# SSH back in
ssh ubuntu@YOUR_SERVER_IP

# Build and start containers
cd /home/ubuntu/cloud-1/compose
sudo docker-compose up -d --build
```

✅ STEP 2: Verify Containers are Running

```
# Check all 4 containers are up
sudo docker ps

# Should see:
# - nginx
# - wordpress
# - mariadb
# - adminer
```

🌐 STEP 3: Test HTTP → HTTPS Redirect

```
# From your local machine (replace with YOUR_SERVER_IP)
curl -v http://YOUR_SERVER_IP

# Should see:
# HTTP/1.1 301 Moved Permanently
# Location: https://yilin.42.fr/
```

🔒 STEP 4: Test HTTPS Access

```bash
# Test HTTPS (ignore self-signed cert warning)
curl -k -I https://YOUR_SERVER_IP

# Should see:
# HTTP/2 200 
# server: nginx
```

📝 STEP 5: Test WordPress Setup

```
https://YOUR_SERVER_IP
```

Test login:
```
https://YOUR_SERVER_IP/wp-admin
```

🗄️ STEP 6: Test Adminer (Database Access)

```
https://YOUR_SERVER_IP/adminer/
```
Login with:
- System: MySQL
- Server: mariadb
- Username: wpuser (from .env MYSQL_USER)
- Password: SecureDbPass456! (from .env MYSQL_PASSWORD)
- Database: wordpress

🔄 STEP 7: Test Auto-Restart (Data Persistence)

```
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

🖥️ STEP 8: Test Server Reboot
```
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

📊 STEP 9: Complete Checklist
```
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

SUCCESS Criteria:
[x] HTTP (80) redirects to HTTPS (443)
[ ] HTTPS serves WordPress with TLS
[ ] WordPress accessible and working
[ ] Adminer accessible at /adminer/
[ ] All 4 containers running
[ ] Data persists after restart
[ ] Auto-starts after server reboot


## aws CLI commands

```
aws sts get-caller-identity

# configure as default
aws configure 

# creates a separate named profile & stores another copy under a different profile name
aws configure --profile cloud-1-dev

```

```
cp = Copy locally (File A → File B)
ssh = Login remotely
scp = ssh + cp (Copy File A → Remote Computer File B)
```