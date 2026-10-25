terraform {
  required_version = ">=1.12.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"

    }
  }
  backend "s3" {
    bucket = "shweta-lambda "
    key    = "shweta-lambda/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "dynamodb-table"
  }
}