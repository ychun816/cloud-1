# AWS CLI


## AWS CLI to reset credentails (key-pair, SG_ID, instance)
```bash
# Set your profile/region
export AWS_PROFILE=cloud-1-dev
export AWS_REGION=eu-west-3

# 1) (If any) find instances using the SG name
aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --filters "Name=instance.group-name,Values=cloud1-web-sg-dev" \
  --query "Reservations[*].Instances[*].InstanceId" --output text

# If any instance IDs are shown, terminate them first:
# aws ec2 terminate-instances --instance-ids i-xxxxxxxx --region "$AWS_REGION"
aws ec2 terminate-instances --instance-ids

# 2) Delete the key pair (safe even if unused)
# aws ec2 delete-key-pair --key-name XXXX(<-key pair name) --region "$AWS_REGION"
aws ec2 delete-key-pair --key-name cloud1-key-dev --region "$AWS_REGION"

# 3) Get the SG id by name
SG_ID=$(aws ec2 describe-security-groups \
  --region "$AWS_REGION" \
  --filters Name=group-name,Values=cloud1-web-sg-dev \
  --query "SecurityGroups[0].GroupId" --output text)

# 4) Delete the SG (only works if not attached to any ENIs)
[ "$SG_ID" != "None" ] && aws ec2 delete-security-group --group-id "$SG_ID" --region "$AWS_REGION"

# 5) Re-run Terraform inside envs/dev
cd /Users/chun/Desktop/🇫🇷❹❷\ /cloud-1/terraform/envs/dev
terraform apply
```
---

## Manage access keys for IAM users
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#securing_access-keys

