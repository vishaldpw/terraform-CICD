terraform {
  backend "s3" {
    bucket = "terraform-statefile-2710"
    key    = "production/ec2"
    dynamodb_table = "tadap-table"
    region = "us-east-2"
  }
}
