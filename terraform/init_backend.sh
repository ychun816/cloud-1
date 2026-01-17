#!/bin/bash
set -e

# Configuration
REGION="eu-west-3"
PROJECT_NAME="cloud-1"
# S3 Buckets must be globally unique. adjusting connection to user specific handle if possible, 
# otherwise using a random suffix is valid. Here we use a likely unique pattern.
BUCKET_NAME="tf-state-${PROJECT_NAME}-ychun816"
TABLE_NAME="tf-lock-${PROJECT_NAME}"

echo ">> Bootstrapping Terraform Backend Resources..."
echo "   Region: $REGION"
echo "   Bucket: $BUCKET_NAME"
echo "   Table:  $TABLE_NAME"

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

echo ">> Success! Backend resources are ready."
echo "   BUCKET_NAME=$BUCKET_NAME"
echo "   TABLE_NAME=$TABLE_NAME"
