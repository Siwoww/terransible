
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = var.region
  profile = "default"
  shared_credentials_files = ["/var/lib/jenkins/aws_creds"]
}