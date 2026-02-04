
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
[ ] Local dev tools setup `tools.yml` implemented (Terraform, AWS CLI on macOS)
[ ] Roles created (`docker`, `terraform`, `awscli`)
[ ] Systemd service integration for auto-start/stop of Compose stack
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
[ ] Add HTTP→HTTPS redirect in nginx (port 80 → 443)
[ ] Add PHP-MyAdmin service (or document alternative like adminer)
[ ] Verify `.env` file with all required variables
[ ] Test multi-server parallel deployment scenario
[ ] Confirm domain DNS setup for `yilin.42.fr`

### Next Session TODO (CloudWatch & CI/CD)
[ ] **Implement Monitoring (AWS CloudWatch)**
    -> [ ] Create IAM Role for EC2 (Terraform)
    -> [ ] Install CloudWatch Agent (Ansible)
    -> [ ] Verify Metrics in AWS Console
[ ] Add CI/CD pipeline
[ ] Complete staging and prod environment configs
