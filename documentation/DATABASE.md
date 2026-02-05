# DATABASE
- S3: Cheap place to put the file.
- DynamoDB: Fast way to ensure only one person edits it at a time.

## the industry best practice, and how we achieve it:

1. The Components (The Holy Trinity)
S3 Bucket: Stores the file.
DynamoDB Table: Locks the file during edits.
S3 Versioning (Crucial): If your state file gets corrupted or you delete the wrong resource, S3 keeps a history of every version of your state file. It gives you an "Undo Button" for your entire infrastructure history.


## S3 
File Cabinet (Storage)

It holds the actual blueprint (the .tfstate file) of your infrastructure.
Why just S3 isn't enough: S3 is great at storing files, but it doesn't strictly prevent two people from grabbing the file at the exact same time. If you and a teammate (or a CI/CD bot) both try to update the infrastructure at once, you might overwrite each other's work or corrupt the file.

## DynamoDB 
the "In Use" Sign (Locking)

It acts as a Lock. When you run terraform apply, Terraform puts a "Do Not Disturb" sign in the DynamoDB table.
Why just DynamoDB isn't enough: DynamoDB is expensive for storing large blobs of data (like your state file), but it is incredibly fast and cheap for checking a tiny "lock" status.

## Deployment Workflow (The Bootstrap Process)

### The "Chicken & Egg" Problem
Terraform is a tool to creating infrastructure.
- To store its memory (`terraform.tfstate`) safely, it needs an **S3 Bucket**.
- But to create that Bucket using Terraform, it needs to store that memory somewhere...
- **Paradox**: We can't use Terraform to store state in a bucket that Terraform hasn't created yet.

### Solution: Bootstrapping
"Bootstrapping" means manually performing the minimum initial setup to let the automation take over.

#### Step 1: Manual Creation (The Bootstrap Script)
We run a script (bash/python) or manual commands to create the "Home" for Terraform.
- **Script**: `./terraform/init_backend.sh`
- **Action**: Creates `tf-state-cloud-1-ychun816` (Bucket) and `tf-lock-cloud-1` (Table).

#### Step 2: Configuration
We tell Terraform to stop using local files and start using the new bucket.
- **File**: `provider.tf`
- **Change**: Replace `backend "local"` with `backend "s3"`.

#### Step 3: Migration
We command Terraform to move the existing data to the new home.
```bash
terraform init -migrate-state
```
- **Action**: Terraform uploads your local `terraform.tfstate` to S3.
- **Result**: Your infrastructure memory is now safe, versioned, and locked in the cloud.

# database admin tools

| Tool                | Type        | Runs on          | Supported databases                         | Primary purpose           | Strengths                            | Typical risks / notes            |
| ------------------- | ----------- | ---------------- | ------------------------------------------- | ------------------------- | ------------------------------------ | -------------------------------- |
| **Adminer**         | Web-based   | Web server (PHP) | MySQL, PostgreSQL, SQLite, others           | Simple DB management      | Lightweight, single file, fast setup | Must be protected (auth + HTTPS) |
| **phpMyAdmin**      | Web-based   | Web server (PHP) | MySQL, MariaDB                              | Full-featured MySQL admin | Rich UI, widely used                 | Large attack surface if exposed  |
| **DBeaver**         | Desktop app | Local machine    | MySQL, PostgreSQL, Oracle, SQL Server, etc. | Professional DB client    | Multi-DB support, ER diagrams        | Local access required            |
| **pgAdmin**         | Web/Desktop | Local or server  | PostgreSQL                                  | PostgreSQL administration | Official Postgres tool               | Heavy for simple tasks           |
| **MySQL Workbench** | Desktop app | Local machine    | MySQL                                       | MySQL design & admin      | Visual modeling, backups             | MySQL-only                       |
| **DataGrip**        | Desktop app | Local machine    | Most SQL DBs                                | Advanced SQL development  | Smart SQL analysis                   | Paid software                    |
| **HeidiSQL**        | Desktop app | Local machine    | MySQL, MariaDB, PostgreSQL                  | Lightweight DB client     | Fast, simple                         | Windows-focused                  |
| **Navicat**         | Desktop app | Local machine    | Multiple DBs                                | Enterprise DB management  | Polished UI, automation              | Paid, commercial                 |

### How to choose (quick guidance)

- Learning / small projects → Adminer, DBeaver
- Production admin → DBeaver, pgAdmin, MySQL Workbench
- Remote servers → Desktop tools + TLS
- Web hosting environments → Adminer or phpMyAdmin (secured)

### Important security reminder
- Database admin tools manage data.
- TLS protects the connection.
- Security depends on configuration, not the tool alone.
- Database admin tools:
    - Do not provide encryption
    - Must rely on TLS/SSL
    - Should never be publicly exposed without strong access controls


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

