terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    access_key = "ACCESS_KEY"
    secret_key = "SECRET_KEY"
    region = "us-east-1"
}

