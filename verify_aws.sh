#!/bin/bash
export AWS_PROFILE=cloud-1-dev

echo "---------------------------------------------------"
echo "🔍 CHECKING TERRAFORM REMOTE BACKEND RESOURCES"
echo "---------------------------------------------------"

echo ""
echo "📦 1. S3 BUCKET (Storage for State File)"
echo "   Command: aws s3 ls | grep tf-state"
echo "   Result :"
aws s3 ls | grep tf-state

echo ""
echo "   --> Checking inside the bucket:"
aws s3 ls s3://tf-state-cloud-1-ychun816/dev/

echo ""
echo "---------------------------------------------------"
echo "🔐 2. DYNAMODB TABLE (Locking Mechanism)"
echo "   Command: aws dynamodb list-tables"
echo "   Result :"
aws dynamodb list-tables --query "TableNames[]" --output text | grep tf-lock

echo ""
echo "---------------------------------------------------"
echo "✅ VERIFICATION COMPLETE"
