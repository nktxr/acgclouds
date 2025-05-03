#!/bin/bash

# Create the .aws directory - won't fair if it already exists
mkdir -p .aws

# Create the AWS credentials file with default profile from GHA secrets
cat > .aws/credentials <<EOL
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOL

# Create the AWS config file to set the default region
cat > .aws/config <<EOL
[default]
region=us-east-1
EOL

echo "AWS credentials have been set up successfully."