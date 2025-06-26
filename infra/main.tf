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

variable "ecr_image_name" {
  description = "Name of the ECR image"
  type        = string
  default     = "shared-expenses-backend"
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

resource "aws_ecr_repository" "backend_repo" {
  name = "shared-expenses-backend"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "backend-repo"
    Environment = "dev"
  }
}

resource "aws_iam_role" "apprunner_ecr_access_role" {
  name = "apprunner-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "apprunner-ecr-access-role"
    Environment = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_access_attachment" {
  role       = aws_iam_role.apprunner_ecr_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role" "apprunner_dynamo_access_role" {
  name = "apprunner-dynamo-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "apprunner-dynamo-access-role"
    Environment = "dev"
  }
}

resource "aws_iam_policy" "dynamodb_table_policy" {
  name        = "dynamodb-table-access-policy"
  description = "Allow runtime access to the shared-expenses DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [
          aws_dynamodb_table.simple_table.arn,
          "${aws_dynamodb_table.simple_table.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_dynamo_access_attachment" {
  role       = aws_iam_role.apprunner_dynamo_access_role.name
  policy_arn = aws_iam_policy.dynamodb_table_policy.arn
}

resource "aws_apprunner_service" "backend_service" {
  service_name = "shared-expenses-backend"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access_role.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      image_repository_type = "ECR"

      image_configuration {
        port = "8000" # Cambia este puerto si tu contenedor expone uno distinto
      }
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1 vCPU"
    memory = "2 GB"
    instance_role_arn = aws_iam_role.apprunner_dynamo_access_role.arn
  }

  tags = {
    Name        = "backend-apprunner-service"
    Environment = "dev"
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

output "ecr_repository_url" {
  description = "URI del repositorio ECR"
  value       = aws_ecr_repository.backend_repo.repository_url
}

output "apprunner_service_url" {
  description = "Public URL App Runner"
  value       = aws_apprunner_service.backend_service.service_url
}
