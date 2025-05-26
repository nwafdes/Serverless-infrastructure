
# dynamodDB
variable "table_name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "item_name" {
    type = string
}

variable "attr_name" {
  type = string
}


# Lambda
variable "Lambda_function_Name" {
  type        = string
}

# API GW
variable "resource_name" {
  type = string
}

# IAM 
variable "policy_name" {
    type = string
}

variable "role_name" {
    type = string
}

# Api Gateway
variable api_name {
  type        = string
}

variable myregion {
  type        = string
}

data "aws_caller_identity" "current" {

}
