
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
  profile = "default"
  shared_credentials_files = ["/var/lib/jenkins/aws_creds"]
}