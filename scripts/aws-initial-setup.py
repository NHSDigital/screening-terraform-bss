import boto3
import os

# Set S3 bucket name
service = "screening-bss"
s3_bucket_name = f"{service}-terraform-state"
region = "eu-west-2"

# Create S3 client
s3 = boto3.client("s3", region_name=region)

# Create S3 bucket
try:
    s3.create_bucket(
        Bucket=s3_bucket_name, CreateBucketConfiguration={"LocationConstraint": region}
    )
    print(f"S3 bucket {s3_bucket_name} created")
except Exception as e:
    if e.response["Error"]["Code"] == "BucketAlreadyOwnedByYou":
        print(f"S3 bucket {s3_bucket_name} already exists")
    else:
        print(f"Error creating S3 bucket: {e}")

# Set the S3 bucket to have server-side encryption
try:
    s3.put_bucket_encryption(
        Bucket=s3_bucket_name,
        ServerSideEncryptionConfiguration={
            "Rules": [
                {"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}
            ]
        },
    )
    print(f"S3 bucket {s3_bucket_name} server-side encryption enabled")
except Exception as e:
    print(f"Error enabling server-side encryption on S3 bucket: {e}")

# Create terraform-state directory and terraform.tfstate file
try:
    s3.put_object(Body="", Bucket=s3_bucket_name, Key="terraform-state/")
    print("terraform-state directory created")
except Exception as e:
    print(f"Error creating terraform-state directory: {e}")

try:
    s3.put_object(
        Body="", Bucket=s3_bucket_name, Key="terraform-state/terraform.tfstate"
    )
    print("terraform.tfstate file created")
except Exception as e:
    print(f"Error creating terraform.tfstate file: {e}")

# Make the S3 bucket versioned
try:
    s3.put_bucket_versioning(
        Bucket=s3_bucket_name, VersioningConfiguration={"Status": "Enabled"}
    )
    print(f"S3 bucket {s3_bucket_name} versioning enabled")
except Exception as e:
    print(f"Error enabling versioning on S3 bucket: {e}")
