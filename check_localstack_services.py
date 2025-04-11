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
            subprocess.run(["awslocal", "s3", "ls"], check=True)
        elif service == "dynamodb":
            subprocess.run(["awslocal", "dynamodb", "list-tables"], check=True)
        elif service == "sqs":
            subprocess.run(["awslocal", "sqs", "list-queues"], check=True)
        elif service == "sns":
            subprocess.run(["awslocal", "sns", "list-topics"], check=True)
        else:
            print(f"No resource listing implemented for service: {service}")
    except subprocess.CalledProcessError as e:
        print(f"Error listing resources for {service}: {e}")

def main():
    services_status = get_localstack_services_status()
    for service, status in services_status.items():
        if status == "running":
            print(f"Service '{service}' is running. Listing resources...")
            list_resources(service)
        else:
            print(f"Service '{service}' is not running. Skipping...")

if __name__ == "__main__":
    main()