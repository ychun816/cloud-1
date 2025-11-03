# Cloud 1 

## Daily Plan

---

# Steps for implement

## ✅ Step-by-Step Plan

### **1️⃣ Prepare Environment (Local + Remote)**

**Goal:** Prepare both your local workspace and your target cloud server.

**Steps:**

* Choose a cloud provider (Scaleway, AWS Lightsail, DigitalOcean, etc.)
* Create a VM running **Ubuntu 20.04 LTS**
* Add your **SSH public key** for secure access
* On your local machine (or Codespaces), make sure:

  * You can SSH into the remote server
  * You have **Ansible**, **Docker**, and **Git** installed locally
  * Your `ansible/playbook.yml` can connect to the remote host

💡 *At this stage, don’t deploy anything yet — just ensure access and compatibility.*

---

### **2️⃣ Build and Test the Containers (Inception Core — Locally)**

**Goal:** Make sure your core stack (MariaDB + WordPress + Nginx) works perfectly **in isolation** before automation.

**Steps:**

* Use your `compose/docker-compose.yml` to:

  * Start MariaDB, WordPress, Nginx
  * Test locally using `docker compose up -d`
* Validate:

  * WordPress can connect to MariaDB
  * Nginx serves your site correctly
  * Data is persistent (volumes work)
* Fix all configuration issues here first.

💡 *This ensures that when you automate later, you’re deploying a known-good setup.*

---

### **3️⃣ Automate Deployment (Ansible)**

**Goal:** Create a **fully automated deployment process** that can set up your environment from scratch.

**Steps:**

* Write your `ansible/playbook.yml` to:

  * Update Ubuntu packages
  * Install Docker and Docker Compose
  * Clone your Git repo on the server
  * Run `docker compose up -d`
  * Configure firewall (`ufw`) and security (disable root login, open ports 22, 80, 443)
* Test automation:

  ```bash
  ansible-playbook -i ansible/hosts.ini ansible/playbook.yml
  ```
* Re-run to confirm it’s **idempotent** (can be run multiple times without breaking anything).

💡 *At the end of this step, one command should recreate your whole deployment.*

---

### **4️⃣ Deploy to Cloud and Secure**

**Goal:** Run your automation on your cloud VM and expose it safely to the internet.

**Steps:**

* Run your playbook targeting the cloud instance
* Access your site via your domain or IP
* Configure **TLS/HTTPS** (using Let’s Encrypt or self-signed cert)
* Verify:

  * The website is accessible over HTTPS
  * Database is **not** publicly exposed
  * Site data persists after reboot (`docker restart`, `reboot` test)
* Document your setup in `README.md`

💡 *This is your “production” deployment — ready for evaluation or real use.*

---

### **📦 5️⃣ (Optional but Highly Recommended): Version Control & CI/CD**

Once the above steps are stable:

* Push everything to GitHub
* Optionally, integrate GitHub Actions to test playbooks or build images automatically
* Tag a stable release (e.g., `v1.0.0`)

---

## 🧭 Summary

| Step         | Name                | Purpose                        | Where it Runs           |
| ------------ | ------------------- | ------------------------------ | ----------------------- |
| 1            | Prepare Environment | Ensure server access and setup | Local + Cloud           |
| 2            | Inception Setup     | Build/test containers          | Local                   |
| 3            | Automation          | Write and test Ansible scripts | Local controlling Cloud |
| 4            | Cloud Deployment    | Deploy and secure              | Cloud                   |
| 5 (optional) | CI/CD + Git         | Automate updates               | GitHub                  |


> Do NOT start directly on the cloud — first, test locally (Step 2), then automate and deploy (Step 3–4).


---

Would you like me to make this into a **Notion-style checklist** (like “Day 1 → Prepare Environment”, “Day 2 → Local Containers”, etc.) so you can track your progress easily?




# **4-Day Intensive Plan**

## **Day 1 — Environment & Local Prototype (Full Setup)**

**Goal:** Set up tools and create a working local WordPress + DB + phpMyAdmin + reverse proxy prototype.

* [ ] Create Git repository for project.
* [ ] Install Docker, Docker Compose, and Ansible locally.
* [ ] Test SSH access to a local VM or test server.
* [ ] Write `docker-compose.yml` for:

  * WordPress container
  * MySQL/MariaDB container
  * phpMyAdmin container (optional)
  * Nginx reverse proxy for HTTP
* [ ] Map persistent volumes for database and WordPress uploads.
* [ ] Test containers: create posts, upload files, stop/restart → verify persistence.
* [ ] Commit `docker-compose.yml` to Git.

---

## **Day 2 — Automation (Ansible) & Local Testing**

**Goal:** Automate deployment with Ansible and test locally.

* [ ] Write Ansible playbook(s) to:

  * Update Ubuntu 20.04 packages
  * Install Docker & Docker Compose
  * Clone Git repo
  * Configure firewall (allow SSH, HTTP, HTTPS)
  * Disable root password login
  * Start Docker Compose setup as a service (auto-start)
* [ ] Test playbook on a local VM/test server.
* [ ] Debug any issues and ensure idempotency.
* [ ] Test container networking and persistence after running playbook locally.
* [ ] Commit playbooks to Git.

---

## **Day 3 — Remote Server Deployment & Basic Security**

**Goal:** Deploy project to cloud server and make it functional.

* [ ] Provision Ubuntu 20.04 server (Scaleway, AWS, etc.)
* [ ] Add SSH public key.
* [ ] Run Ansible playbook on remote server.
* [ ] Verify deployment:

  * WordPress site accessible
  * phpMyAdmin works internally
  * Containers restart after reboot → persistence works
* [ ] Configure firewall, secure DB access (DB not exposed externally).
* [ ] Optional: minimal TLS setup for HTTPS (basic Let’s Encrypt)

---

## **Day 4 — Security, TLS, Documentation & Submission**

**Goal:** Finalize security, TLS, documentation, and submission.

* [ ] Complete TLS/HTTPS with Let’s Encrypt on reverse proxy.
* [ ] Test full deployment from scratch on fresh server (full teardown → redeploy).
* [ ] Ensure persistent storage works correctly (posts/images survive).
* [ ] Write README.md detailing:

  * How to provision server
  * How to run Ansible playbook
  * How to deploy/update containers
  * How to clean up resources
* [ ] Commit all files (playbooks, `docker-compose.yml`, README).
* [ ] Submit Git repository.

---

### ⚡ Notes for a 4-Day Schedule:

1. **No time for extended experimentation** — stick strictly to functional setup.
2. **Use a local VM** for testing Ansible before deploying to remote server — saves hours troubleshooting.
3. **TLS can be partial on Day 3**; finalize full HTTPS on Day 4.
4. **Have all configurations pre-tested** locally, including Docker volumes and container communication.

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

## porject Stack Overview

| Layer                                     | Tool                        | Purpose                                                                                                          | Notes                                                                                     |
| ----------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **Cloud Provider**                        | **AWS EC2**                 | Provides the virtual server (Ubuntu VM) that will host everything                                                | You’ll create this instance using **Terraform** (instead of manually from AWS console)    |
| **Infrastructure as Code (IaC)**          | **Terraform**               | Automates the creation of AWS EC2, network, and security groups                                                  | Your `.tf` files describe the cloud resources declaratively                               |
| **Configuration Management / Automation** | **Ansible**                 | Runs *inside or against* the created EC2 VM to install Docker, copy your project files, and start the containers | You’ll use a `playbook.yml` for tasks like “install Docker,” “start docker-compose,” etc. |
| **Containerization**                      | **Docker + Docker Compose** | Packages your Inception stack (Nginx + MariaDB + WordPress) into containers                                      | Keeps the setup portable, reproducible, and cloud-ready                                   |


## project repo structure
- `ansible/` → automation logic
- `compose/` → service definitions
```bash
cloud-1/
├── ansible/
│   ├── playbook.yml
│   ├── hosts.ini
│   └── roles/
│       └── docker/
│           └── tasks/main.yml
├── compose/
│   ├── docker-compose.yml
│   └── conf/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
└── README.md

```

1. Terraform → Provision
- Use Terraform to create your AWS EC2 instance automatically.
- Output: a running Ubuntu VM + SSH access.

2. Ansible → Configure
- Use Ansible to connect to that EC2 instance.
- Install Docker, Docker Compose, copy your compose/ folder.

3. Docker → Deploy
- Run docker compose up -d via Ansible to deploy your Nginx, WordPress, MariaDB containers.

4. (Optional) Add domain name + SSL later for public access.

```bash
cloud-inception/
├── README.md
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       └── docker/
│           ├── tasks/
│           │   └── main.yml
│           └── templates/
│               └── docker-compose.yml.j2
└── compose/
    ├── mariadb/
    │   ├── Dockerfile
    │   └── conf/
    │       └── init_mariadb.sh
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/
    │       └── nginx.conf
    ├── wordpress/
    │   ├── Dockerfile
    │   └── conf/
    │       └── www.conf
    └── .env

```


## project structure (ASCII GRAPHIC)

“big picture” of your Automated Inception project:
```bash
                        ┌────────────────────────────┐
                        │  Your Laptop (Local)       │
                        │────────────────────────────│
                        │ - Git repository (code)    │
                        │ - Ansible playbooks        │
                        │ - docker-compose.yml       │
                        │ - SSH key                  │
                        └──────────────┬─────────────┘
                                       │ SSH (port 22)
                                       ▼
                   ┌──────────────────────────────────────────────┐
                   │  Remote Server (Ubuntu 20.04)                │
                   │──────────────────────────────────────────────│
                   │  Ansible installs & configures:              │
                   │    1. Docker & Docker Compose                │
                   │    2. Firewall & TLS certificates            │
                   │    3. Starts containers automatically        │
                   │----------------------------------------------│
                   │  Containers (each service isolated):         │
                   │                                              │
                   │  ┌───────────┐   ┌────────────┐              │
                   │  │ WordPress │◄──│  MySQL DB  │              │
                   │  └───────────┘   └────────────┘              │
                   │        ▲              ▲                      │
                   │        │              │                      │
                   │  ┌─────────────┐      │                      │
                   │  │ phpMyAdmin  │──────┘                      │
                   │  └─────────────┘                             │
                   │        │                                     │
                   │  ┌─────────────┐                             │
                   │  │ Nginx Proxy │──▶ HTTPS (TLS) ─▶ Internet  │
                   │  └─────────────┘                             │
                   └──────────────────────────────────────────────┘

```


```bash
                    ┌─────────────────────────────-─┐
                    │   Your Local Machine          │
                    │────────────────────────────-──│
                    │  - Write docker-compose.yml   │
                    │  - Write Ansible playbooks    │
                    │  - Test containers locally    │
                    │  - Push to Git repository     │
                    └──────────────┬───────────────-┘
                                   │
                                   │ SSH + Git Clone
                                   ▼
        ┌─────────────────────────────────────-──────-──┐
        │        Remote Ubuntu 20.04 Server             │
        │──────────────────────────────────-────────-───│
        │  Ansible Automation runs here:                │
        │   • Updates system packages                   │
        │   • Installs Docker & Compose                 │
        │   • Pulls your Git repo                       │
        │   • Runs `docker-compose up -d`               │
        │   • Configures firewall & TLS (HTTPS)         │
        │─────────────────────────────────────────--────│
        │         Docker Compose Orchestrator           │
        │────────────────────────────-────────────────-─│
        │   ┌───────────────────────-──────┐            │
        │   │ NGINX (Reverse Proxy)        │◄───TLS───┐ │
        │   │ - Routes requests            │            │
        │   │ - HTTPS via Let's Encrypt    │            │
        │   └──────────────┬───────────────┘            │
        │                  │                            │
        │                  ▼                            │
        │   ┌──────────────────────────-───┐            │
        │   │ WordPress Container          │            │
        │   │ - Runs PHP + WP engine       │            │
        │   │ - Stores uploads in volume   │            │
        │   └──────────────┬───────────────┘            │
        │                  │                            │
        │                  ▼                            │
        │   ┌─────────────────────────────┐             │
        │   │ MySQL/MariaDB Container     │             │
        │   │ - Stores posts, users       │             │
        │   │ - Persistent DB volume      │             │
        │   └─────────────────────────────┘             │
        │                                               │
        │   (optional)                                  │
        │   ┌─────────────────────────────┐             │
        │   │ phpMyAdmin Container        │             │
        │   │ - Internal DB management UI │             │
        │   │ - Accessible via NGINX proxy│             │
        │   └─────────────────────────────┘             │
        └───────────────────────────────────────────────┘
                                   │
                                   │
                        Browser Access (HTTPS)
                                   │
                                   ▼
                ┌────────────────────────────────┐
                │     Your WordPress Website     │
                │  - Secure via NGINX + TLS      │
                │  - Data persistent in volumes  │
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
| Tool / Provider    | Purpose                                      | Pros                                        | Cons                                        | Use Case in Inception Project                                              | Learning Resources                                                                                                      | Sign-In / Start Link                                           |
| ------------------ | -------------------------------------------- | ------------------------------------------- | ------------------------------------------- | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **Ansible**        | Configuration management & automation        | Agentless, uses simple YAML, widely adopted | Slightly slower for massive infrastructures | Automate setup of Docker, firewall, and deploy containers to your cloud VM | [Docs](https://docs.ansible.com/), [YouTube](https://www.youtube.com/watch?v=1id6ERvfozo)                               | —                                                              |
| **Terraform**      | Cloud infrastructure provisioning            | Declarative IaC, supports all major clouds  | Doesn’t handle OS-level configuration       | Automate creation of the VM (e.g., on DigitalOcean or Scaleway)            | [Docs](https://developer.hashicorp.com/terraform/docs), [YouTube](https://www.youtube.com/watch?v=SLauY6PpjW4)          | —                                                              |
| **Puppet**         | Config management (enterprise-grade)         | Strong ecosystem, scalable                  | Requires agent/master setup                 | Alternative to Ansible for config management                               | [Docs](https://puppet.com/docs/puppet/latest/puppet_index.html), [YouTube](https://www.youtube.com/watch?v=0yKg1n2tZp0) | —                                                              |
| **Chef**           | Configuration automation via Ruby DSL        | Flexible, powerful                          | Requires Ruby knowledge, agent setup        | Another configuration alternative                                          | [Docs](https://docs.chef.io/), [YouTube](https://www.youtube.com/watch?v=8X-1JXyFijE)                                   | —                                                              |
| **SaltStack**      | Real-time automation & orchestration         | Scalable, agentless mode possible           | Higher learning curve                       | Advanced orchestration or monitoring                                       | [Docs](https://docs.saltproject.io/en/latest/), [YouTube](https://www.youtube.com/watch?v=6v8X_1GGN70)                  | —                                                              |
| **Docker Compose** | Orchestrates multiple containers on one host | Simple YAML syntax, lightweight             | Single-host only                            | Orchestrate WordPress, Nginx, MariaDB setup                                | [Docs](https://docs.docker.com/compose/)                                                                                | —                                                              |
| **Kubernetes**     | Multi-host container orchestration           | Scalable, used in production                | Complex setup, overkill for small projects  | For future scaling to multiple servers                                     | [Docs](https://kubernetes.io/docs/), [YouTube](https://www.youtube.com/watch?v=X48VuDVv0do)                             | —                                                              |
| **DigitalOcean**   | Cloud VM provider (beginner friendly)        | Easy UI, clear pricing, excellent docs      | Slightly limited advanced networking        | Host your full stack on a $5/month droplet                                 | [Tutorials](https://docs.digitalocean.com/), [YouTube](https://www.youtube.com/watch?v=l5s7LRkQwjE)                     | [Start Here](https://cloud.digitalocean.com/registrations/new) |
| **Scaleway**       | EU-based cloud, project-friendly             | Cheap, GDPR compliant, used in 42 projects  | Slightly slower UI than DO                  | Deploy Ubuntu 20.04 VM for Ansible deployment                              | [Docs](https://www.scaleway.com/en/docs/), [YouTube](https://www.youtube.com/watch?v=vQhYDMQ-ymI)                       | [Start Here](https://console.scaleway.com/)                    |
| **AWS Lightsail**  | Simplified AWS hosting                       | Stable, predictable cost                    | Limited customization                       | Host small deployments inside AWS                                          | [Docs](https://lightsail.aws.amazon.com/ls/docs/), [YouTube](https://www.youtube.com/watch?v=_bUIKbbhZbQ)               | [Start Here](https://lightsail.aws.amazon.com/)                |
| **Hetzner Cloud**  | High-performance EU cloud                    | Great performance/price ratio               | KYC verification required                   | Cheap, fast Ubuntu server for automation                                   | [Docs](https://docs.hetzner.com/cloud/), [YouTube](https://www.youtube.com/watch?v=3kngzWLeK_g)                         | [Start Here](https://accounts.hetzner.com/signUp)              |


**Recommended Combo for Inception Project:**  
- **Terraform** (optional) for VM provisioning  
- **Ansible** for automated setup and deployment  
- **Docker Compose** to orchestrate containers  

---

## Learning Resources on server/data services

- [ Learn Terraform (and AWS) by Building a Dev Environment – Full Course for Beginners ](https://www.youtube.com/watch?v=iRaai1IBlB0)

- Server (with more built-in services) : [AWS lightsail](https://aws.amazon.com/free/compute/lightsail/?trk=efe0b52e-4f28-4f2b-8db8-31bec4d48cd6&sc_channel=ps&ef_id=Cj0KCQjwvJHIBhCgARIsAEQnWlDhr-h7p2MK-BRy3htdnbmFS4qra8OIOrwe3E925sIaZ-2DiNy5J2caArO5EALw_wcB:G:s&s_kwcid=AL!4422!3!536451983681!e!!g!!amazon%20lightsail!12260821599!116187150926&gad_campaignid=12260821599&gclid=Cj0KCQjwvJHIBhCgARIsAEQnWlDhr-h7p2MK-BRy3htdnbmFS4qra8OIOrwe3E925sIaZ-2DiNy5J2caArO5EALw_wcB)
- Server : [Amazon EC2](https://aws.amazon.com/ec2/?nc2=type_a)
- Online Database : [RDS](https://aws.amazon.com/rds/?nc2=h_prod_db_rds)


| **Topic**                            | **Resource / Link**                                                                                                                                            | **Type**             | **Difficulty**             | **Summary / Why it’s Good**                                                                   |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | -------------------------- | --------------------------------------------------------------------------------------------- |
| 🌥️ **Cloud Basics**                 | [AWS Cloud Practitioner Essentials (Free Course)](https://explore.skillbuilder.aws/learn/course/external/view/elearning/134/aws-cloud-practitioner-essentials) | Free AWS Course      | ⭐ Beginner                 | AWS’s official beginner course – teaches what cloud computing and AWS are, step by step.      |
| 🌍 **AWS Basics**                    | [AWS Getting Started Resource Center](https://aws.amazon.com/getting-started/)                                                                                 | Tutorials & Docs     | ⭐ Beginner                 | Central hub with beginner-friendly projects (create a website, launch EC2, store data, etc.). |
| 💻 **EC2 Basics (Official Docs)**    | [Getting Started with Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)                                                     | AWS Docs             | ⭐ Beginner                 | Official step-by-step guide to launch your first EC2 instance from the AWS console.           |
| 🎥 **EC2 Video Tutorial**            | [FreeCodeCamp – AWS EC2 Crash Course](https://www.youtube.com/watch?v=Uhi3ikKzK0s)                                                                             | YouTube Video        | ⭐ Beginner                 | Visual, practical walkthrough on EC2 concepts, setup, and SSH access.                         |
| ⚙️ **Terraform Basics**              | [Terraform Getting Started Guide (AWS)](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)                                                   | Official Tutorial    | ⭐ Beginner                 | Hands-on tutorial to deploy EC2 with Terraform – excellent intro to Infrastructure as Code.   |
| 🎬 **Terraform Explained (YouTube)** | [TechWorld with Nana – Terraform Explained Simply](https://www.youtube.com/watch?v=YcJ9IeukJL8)                                                                | YouTube Video        | ⭐ Beginner                 | Super clear visual explanation of Terraform, infrastructure as code, and workflows.           |
| 📘 **Book (Optional)**               | [Terraform Up & Running (O’Reilly)](https://www.oreilly.com/library/view/terraform-up-and/9781098116743/)                                                      | Book                 | ⭐⭐ Beginner → Intermediate | Best book to deepen understanding once you’ve done a few basic projects.                      |
| 🧪 **Hands-on Labs**                 | [AWS Skill Builder Labs](https://explore.skillbuilder.aws/learn/labs)                                                                                          | Interactive Labs     | ⭐ Beginner                 | Practice EC2 and IAM tasks in a free sandbox without needing your own AWS account.            |
| 🧰 **Browser Practice**              | [Katacoda Terraform Scenarios](https://www.katacoda.com/hashicorp)                                                                                             | Interactive Tutorial | ⭐ Beginner                 | Learn Terraform right in the browser – no install required.                                   |



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
