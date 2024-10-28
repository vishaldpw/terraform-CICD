
# backend.tf
terraform {
  backend "s3" {
    bucket         = "terraform-statefile-2710" # Your S3 bucket name
    key            = "development/backend.tf"   # Unique key for the state file
    dynamodb_table = "tadak-table"              # DynamoDB table for state locking
    region         = "us-east-2"                # Region for S3 and DynamoDB
  }
}
