terraform {
  backend "s3" {
    bucket         = "shared-expenses-api-tfstate"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = false
  }

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

  deletion_protection_enabled = false

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

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "shared-expenses-frontend-test-bucket"

  tags = {
    Name        = "frontend-bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table created"
  value       = aws_dynamodb_table.simple_table.name
}

output "frontend_bucket_website_url" {
  description = "URL del sitio web estático en S3 para el frontend"
  value       = aws_s3_bucket_website_configuration.frontend_bucket_website.website_endpoint
}
