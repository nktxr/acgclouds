#!/bin/bash
set -e

ROLE_ARN="$1"
SESSION_NAME="$2"
AWS_REGION="${3:-us-east-1}"

if [[ -z "$ROLE_ARN" || -z "$SESSION_NAME" ]]; then
  echo "Usage: $0 <role-arn> <session-name> [region]"
  exit 1
fi

CREDS=$(aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name "$SESSION_NAME" \
  --region "$AWS_REGION" \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text)

ACCESS_KEY=$(echo "$CREDS" | awk '{print $1}')
SECRET_KEY=$(echo "$CREDS" | awk '{print $2}')
SESSION_TOKEN=$(echo "$CREDS" | awk '{print $3}')

mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $ACCESS_KEY
aws_secret_access_key = $SECRET_KEY
aws_session_token = $SESSION_TOKEN
EOF

echo "AWS credentials written to ~/.aws/credentials"