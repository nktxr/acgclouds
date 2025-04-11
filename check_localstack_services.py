#!/usr/bin/env python3
import subprocess
import json

def get_localstack_services_status():
    """Get the status of LocalStack services."""
    try:
        result = subprocess.run(
            ["localstack", "status", "services", "--format", "json"],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running 'localstack status services': {e}")
        return {}

def list_resources(service):
    """List resources for a given service using awslocal."""
    try:
        if service == "s3":
            print("Listing S3 buckets:")
            subprocess.run(["awslocal", "s3", "ls"], check=True)
        elif service == "dynamodb":
            print("Listing DynamoDB tables:")
            subprocess.run(["awslocal", "dynamodb", "list-tables"], check=True)
        elif service == "sqs":
            print("Listing SQS queues:")
            subprocess.run(["awslocal", "sqs", "list-queues"], check=True)
        elif service == "sns":
            print("Listing SNS topics:")
            subprocess.run(["awslocal", "sns", "list-topics"], check=True)
        elif service == "ec2":
            print("Listing EC2 instances:")
            subprocess.run(["awslocal", "ec2", "describe-instances", "--query", "Reservations[].Instances[]"], check=True)
        elif service == "secretsmanager":
            print("Listing SecretsManager secrets:")
            subprocess.run(["awslocal", "secretsmanager", "list-secrets"], check=True)
        elif service == "iam":
            print("No resource listing implemented for service: iam")
        elif service == "sts":
            print("No resource listing implemented for service: sts")
        else:
            print(f"No resource listing implemented for service: {service}")
    except subprocess.CalledProcessError as e:
        print(f"Error listing resources for {service}: {e}")

def main():
    services_status = get_localstack_services_status()
    if not services_status:
        print("No services found or failed to retrieve services.")
        return

    for service, status in services_status.items():
        if status == "running":
            print(f"Service '{service}' is running. Listing resources...")
            list_resources(service)
        elif status == "available":
            print(f"Service '{service}' is available but not running. Skipping...")
        else:
            print(f"Service '{service}' is not running or available. Skipping...")

if __name__ == "__main__":
    main()