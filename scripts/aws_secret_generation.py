import boto3
from botocore.exceptions import ClientError
import getpass
import json

def create_secret(secret_name, password):
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')

    # The secret key-value pairs
    secret_string = json.dumps({"username": "bss", "password": password})

    try:
        # Create the secret
        response = client.create_secret(
            Name=secret_name,
            SecretString=secret_string
        )
        print(f"Secret created: {response['Name']}")
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceExistsException':
            print(f"A secret with the name {secret_name} already exists.")
            update_response = input("Do you want to update the existing secret? (yes/no): ")
            if update_response.lower() == 'yes':
                response = client.update_secret(
                    SecretId=secret_name,
                    SecretString=secret_string
                )
                print(f"Secret updated: {secret_name}")
            else:
                print("Exiting without updating the secret.")
        else:
            print(f"An error occurred: {e}")

def main():
    print("AWS Secrets Manager Secret Creator")
    print("-----------------------------------")

    secret_name = input("Enter the name for the secret: ")
    password = getpass.getpass("Enter the password for the secret: ")
    confirm_password = getpass.getpass("Confirm the password: ")

    if password != confirm_password:
        print("Passwords do not match. Exiting.")
        return

    create_secret(secret_name, password)

if __name__ == "__main__":
    main()

