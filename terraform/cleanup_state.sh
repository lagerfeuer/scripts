#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo 'Usage: terraform/cleanup_state.sh <S3_KEY>'
  echo 'Example: terraform/cleanup_state.sh ${BUCKET_NAME}/us-east-1/dev/services/static_site/terraform.tfstate'
fi

set -euo pipefail

STATE="$1"

echo "Cleaning up Terraform state file and lock..."

aws s3 ls "s3://${STATE}"
KEY="{ \"LockID\": { \"S\": \"${STATE}-md5\" } }"
aws dynamodb get-item --table terraform-locks --key "${KEY}"  | jq -r '.'


read -p "Are you sure? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  aws s3 rm "s3://${STATE}"
  aws dynamodb delete-item --table terraform-locks --key "${KEY}" | jq -r '.'
fi


