# Cloud 1 

## Daily Plan

---

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
