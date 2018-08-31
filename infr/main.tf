####################
### Terraform Setup

# AWS Provider
provider "aws" {
  version = "~> 1.34"
  access_key = "${var.skipp_access_key}"
  secret_key = "${var.skipp_secret_key}"
  region = "us-east-1"
}

//# Terraform S3 Backend (for state storage)
//terraform {
//  backend "s3" {
//    bucket = "skipp-terraform"
//    key = "state"
//    region = "us-east-1"
//    encrypt = true
//    dynamodb_table = "terraform-lock"
//  }
//}

# AWS password policy

# A very liberal policy ...
resource "aws_iam_account_password_policy" "strict" {
  max_password_age = 90
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_uppercase_characters   = false
  require_numbers                = false
  allow_users_to_change_password = true
}

####################
### Base resources

# S3

resource "aws_s3_bucket" "skipp-terraform" {
  bucket = "skipp-terraform"
  force_destroy = false
}

resource "aws_s3_bucket" "skipp-data" {
  bucket = "skipp-data"
  force_destroy = false
}
