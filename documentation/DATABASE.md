# DATABASE

## Two Layers of Databases : one for infrastructure; one for applications

### 1. **Infrastructure Database (for Terraform):**
  - **S3** and **DynamoDB** are used by Terraform to store and lock the infrastructure state file. They are not used for application data.

### 2. **Application Database:**
  - **MariaDB** is used by your applications (like WordPress) to store user data, posts, configs, etc.
  - **Adminer** is a web-based visual tool to manage MariaDB (and other databases). It lets you view, edit, and manage your application data in MariaDB through a browser.


> S3/DynamoDB = infrastructure state management
> MariaDB = application data
> Adminer = visual handler for MariaDB

---

## Use S3 and DynamoDB for Terraform State

- **S3** : store Terraform state file in the cloud, making it durable, backed up, and versioned. 
> infrastructure’s “memory” is always safe and recoverable.

- **DynamoDB** lock the state file during edits. 
DynamoDB is a NoSQL (key-value) database service provided by AWS. In Terraform workflows, it’s often used together with S3: S3 stores the state file, and DynamoDB provides locking to prevent concurrent edits
> prevents multiple people or processes from making changes at the same time, which could corrupt your infrastructure state.

> **S3 Versioning** is crucial: If state file gets corrupted or delete the wrong resource, S3 keeps a history of every version of your state file. => It gives "Undo Button" for entire infrastructure history!!!

---

## Database intro 

### S3 
File Cabinet (Storage)

It holds the actual blueprint (the .tfstate file) of your infrastructure.
Why just S3 isn't enough: S3 is great at storing files, but it doesn't strictly prevent two people from grabbing the file at the exact same time. If you and a teammate (or a CI/CD bot) both try to update the infrastructure at once, you might overwrite each other's work or corrupt the file.

### DynamoDB 
the "In Use" Sign (Locking)

It acts as a Lock. When you run terraform apply, Terraform puts a "Do Not Disturb" sign in the DynamoDB table.
Why just DynamoDB isn't enough: DynamoDB is expensive for storing large blobs of data (like your state file), but it is incredibly fast and cheap for checking a tiny "lock" status.


### mariadb
- Stores all application data (not infrastructure state)
- Runs in a Docker container
- Accessed by WordPress and other services
- Can be managed directly using Adminer or other DB tools

### adminer
- lightweight
- Web UI, general-purpose database management tool that supports multiple database systems, including MySQL, MariaDB, PostgreSQL, SQLite
- Runs in its own Docker container
- Access via browser (typically http://localhost:8080 or similar)
- Use for inspecting, editing, or troubleshooting application data
- Should be secured and not exposed to the public internet


---

## S3 vs DynamoDB vs MariaDB

> S3 and DynamoDB are for infrastructure management (Terraform state and locking)
> MariaDB is for application’s data (WordPress, etc.)

| Service   | What it is used for in this project                | Type/Purpose                        | Why you need it here                          |
|-----------|---------------------------------------------------|-------------------------------------|-----------------------------------------------|
| S3        | Stores Terraform state file (infrastructure info) | Object storage (cloud file cabinet) | Safe, versioned, durable state storage        |
| DynamoDB  | Locks Terraform state during changes              | NoSQL key-value DB (locking table)  | Prevents simultaneous edits/corruption        |
| MariaDB   | Application database for WordPress & services     | Relational database (SQL)           | Stores app data (users, posts, configs, etc.) |


---

# Note on Bootstrapping S3 and DynamoDB

- S3 and DynamoDB must be created (bootstrapped) before Terraform can use them for remote state management!!  
- should be done at the very beginning—before running `terraform init` with the S3 backend. 
- 2 ways to create S3 + DynamoDB:   
  - (A) create them manually in the AWS Console
  - (B) use a bootstrap script `terraform/init_backend.sh` -> automate their creation
  > Once they exist, configure Terraform to use them for state storage and locking.

```bash
# 1. Create S3 Bucket
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "   [Skip] Bucket $BUCKET_NAME already exists"
else
    echo "   [Create] Creating S3 Bucket: $BUCKET_NAME..."
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION"
    
    echo "   [Config] Enabling Versioning on $BUCKET_NAME..."
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
fi

# 2. Create DynamoDB Table
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
    echo "   [Skip] DynamoDB Table $TABLE_NAME already exists"
else
    echo "   [Create] Creating DynamoDB Table: $TABLE_NAME..."
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --region "$REGION"
fi
```

---



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

---

# database admin tools

| Tool                | Type        | Runs on          | Supported databases                         | Primary purpose           | Strengths                            | Typical risks / notes            |
| ------------------- | ----------- | ---------------- | ------------------------------------------- | ------------------------- | ------------------------------------ | -------------------------------- |
| **Adminer**         | Web-based   | Web server (PHP) | MySQL, PostgreSQL, SQLite, others           | Simple DB management      | Lightweight, single file, fast setup | Must be protected (auth + HTTPS) |
| **phpMyAdmin**      | Web-based   | Web server (PHP) | MySQL, MariaDB                              | Full-featured MySQL admin | Rich UI, widely used                 | Large attack surface if exposed  |
| **DBeaver**         | Desktop app | Local machine    | MySQL, PostgreSQL, Oracle, SQL Server, etc. | Professional DB client    | Multi-DB support, ER diagrams        | Local access required            |
| **pgAdmin**         | Web/Desktop | Local or server  | Postg--reSQL                                  | PostgreSQL administration | Official Postgres tool               | Heavy for simple tasks           |
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

