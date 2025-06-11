# Providers specify which cloud you want to deal with, so terraform can download the necessary tools
provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "sahaba-tf-state" # REPLACE WITH YOUR BUCKET NAME
    key            = "state-files/DDB-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sahaba-table"
    encrypt        = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


module "DDB" {
  source = "../DDB/"
  table_name = "My_Web_Visitors"
  hash_key =  "id"
  item_name = "Website_Visitors"
  attr_name = "visitors"
}

