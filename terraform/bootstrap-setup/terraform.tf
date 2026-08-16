terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }
 backend "s3"{
   bucket="taskpilot-tf-state-891377312206-us-east-1"
   key="terraform.tfstate"
   region="us-east-1"
   use_lockfile= true
   encrypt=true
 }
}



provider "aws" {
  region = "us-east-1"
}
