#!/bin/bash

# Usage: ./restore-tfstate.sh <bucket> <key> <versionID>

set -euo pipefail

tmpfile="$(mktemp)"

function _main {
  local bucket="$1"
  local key="$2"
  local versionID="$3"

  aws s3api get-object --bucket "$bucket" --key "$key" --version-id "$versionID" "$tmpfile"
  aws s3api put-object --bucket "$bucket" --key "$key" --body "$tmpfile"

  STATE="${bucket}/${key}"
  dynamodb_key="{ \"LockID\": { \"S\": \"${STATE}-md5\" } }"
  aws dynamodb delete-item --table terraform-locks --key "${dynamodb_key}" | jq -r '.'
}

echo "using $tmpfile"
_main "$@"
