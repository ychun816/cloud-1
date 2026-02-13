# Notes for newbs

> some silly questions here are explained


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

## Other Automation & Deployment Tools


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


### 🟩 1. “Lookup the latest Ubuntu 20.04 AMI from Canonical”

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

#### 🧩 When to use it:

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

---

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


## HTTP / HTTPS / SSL / TLS

- HTTPS  → HTTP + TLS encryption
- HTTP   → plain web traffic
- SSL    → old, replaced by TLS
- TLS    → current encryption layer

> HTTP moves data.
> TLS protects it.
> HTTPS combines both.
> SSL is obsolete.(OLD!)

### concepts clarify 
- HTTP can never be secure by itself.
- HTTPS ≠ SSL
- HTTPS uses TLS, not SSL.
- “SSL certificate” is a legacy term ->  It actually means a `TLS certificate`


| Term      | Type                       | What it is                       | Purpose                      | Encrypts data? | Used today? | Key notes                  |
| --------- | -------------------------- | -------------------------------- | ---------------------------- | -------------- | ----------- | -------------------------- |
| **HTTP**  | Application protocol       | Basic web communication protocol | Transfer web pages and data  | ❌ No           | ⚠ Limited   | Data sent in plain text    |
| **HTTPS** | Application protocol       | HTTP over TLS                    | Secure web communication     | ✅ Yes          | ✅ Yes       | Uses TLS for encryption    |
| **SSL**   | Security protocol (legacy) | Old encryption protocol          | Secure network communication | ❌ No (broken)  | ❌ No        | Deprecated and insecure    |
| **TLS**   | Security protocol          | Modern replacement for SSL       | Encrypt data in transit      | ✅ Yes          | ✅ Yes       | Industry security standard |

---

## application protocol vs security protocol

How they work together:
- An application protocol does not provide security by default.
- A security protocol wraps around it.

> Application protocol → The language and rules of a conversation
> Security protocol → A sealed, locked envelope protecting the message

```
HTTP  → sends web requests
TLS   → encrypts HTTP
HTTPS → HTTP + TLS
```


| Aspect                    | Application protocol                       | Security protocol                          |
| ------------------------- | ------------------------------------------ | ------------------------------------------ |
| Purpose                   | Defines **what data is exchanged**         | Defines **how data is protected**          |
| Main role                 | Enables communication between applications | Secures communication channels             |
| Data handling             | Specifies message format and actions       | Encrypts, authenticates, ensures integrity |
| Operates at               | Application layer                          | Transport / security layer                 |
| Can work alone            | ✅ Yes                                      | ❌ No (wraps another protocol)              |
| Examples                  | HTTP, FTP, SMTP, DNS                       | TLS, SSL, IPsec                            |
| Typical question answered | “What is being sent?”                      | “Is it safe to send?”                      |

---

## OSI model vs TCP/IP model

A browser sends HTTP instructions, TLS protects them, and TCP/IP delivers them.
> OSI helps you understand and troubleshoot networking concepts
> TCP/IP explains how the Internet actually works
> Modern protocols map concepts from OSI into TCP/IP layers

### High-level flow
```pgsql
Browser
  ↓
DNS lookup (get server IP)
  ↓
TCP connection
  ↓
TLS handshake
  ↓
HTTP request/response (encrypted)
```

### Layer-by-layer view (OSI + TCP/IP)
| Step | OSI Layer        | TCP/IP Layer   | What happens                                      |
| ---- | ---------------- | -------------- | ------------------------------------------------- |
| 1    | Application (7)  | Application    | Browser prepares HTTP request (GET/POST, headers) |
| 2    | Presentation (6) | Application    | **TLS handshake starts** (certificates, keys)     |
| 3    | Session (5)      | Application    | Secure session established                        |
| 4    | Transport (4)    | Transport      | TCP connection (ports 443 ↔ ephemeral port)       |
| 5    | Network (3)      | Internet       | IP routing across the Internet                    |
| 6    | Data Link (2)    | Network Access | Ethernet / Wi-Fi framing                          |
| 7    | Physical (1)     | Network Access | Bits transmitted over cable / radio               |

| Aspect                | OSI model                   | TCP/IP model                     |
| --------------------- | --------------------------- | -------------------------------- |
| Purpose               | Conceptual / teaching model | Practical / implementation model |
| Number of layers      | 7                           | 4                                |
| Used in real networks | ❌ No (reference only)       | ✅ Yes                            |
| Designed by           | ISO                         | DARPA / DoD                      |
| Security placement    | Layer 6 (Presentation)      | Application layer                |

