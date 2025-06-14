# Providers specify which cloud you want to deal with, so terraform can download the necessary tools
provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "sahaba-tf-state" # REPLACE WITH YOUR BUCKET NAME
    key            = "state-files/serverless-infra/terraform.tfstate"
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


module "Cloud_Resume" {
  source = "../Infastructure/"
  Lambda_function_Name = "differnt_function"
  policy_name = "allow_edit_DDB_Table"
  role_name = "allow_lambda_assume"
  api_name = "FirstTerraformAPI"
  myregion = "us-east-1"
  resource_name = "visitors"
}