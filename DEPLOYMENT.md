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

## Next Steps (Day 3/4)

- [ ] Configure real domain (update DNS A record)
- [ ] Install Let's Encrypt for valid TLS certificate
- [ ] Add phpMyAdmin (optional)
- [ ] Test reboot persistence
- [ ] Document deployment in main README
