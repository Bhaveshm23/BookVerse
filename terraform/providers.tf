terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  ### For local testing ###3

#  region = "us-east-1"
#  shared_credentials_files = ["~/.aws/credentials"]
#  profile = "terraform_user"

}