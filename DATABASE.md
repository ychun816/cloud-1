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