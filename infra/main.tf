terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region in which to create resources"
  type        = string
  default     = "us-east-1"
}

resource "aws_dynamodb_table" "simple_table" {
  name         = "shared-expenses"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Name        = "simple-table"
    Environment = "dev"
  }
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table created"
  value       = aws_dynamodb_table.simple_table.name
}
