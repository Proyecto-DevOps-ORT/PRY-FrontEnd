# Terraform Settings Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 3.21" # Optional but recommended in production
    }
  }
}

# Provider Block
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# S3 Creation with Static Website Hosting and Policies
resource "aws_s3_bucket" "dev_bucket" {
  bucket = "dev-desde-terraform"
  acl    = "private"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "stg_bucket" {
  bucket = "stg-desde-terraform"
  acl    = "private"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "prod_bucket" {
  bucket = "prod-desde-terraform"
  acl    = "private"

  website {
    index_document = "index.html"
  }
}

# Block Public Access Disabled for Each Bucket
resource "aws_s3_bucket_public_access_block" "dev_block" {
  bucket = aws_s3_bucket.dev_bucket.bucket

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "stg_block" {
  bucket = aws_s3_bucket.stg_bucket.bucket

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "prod_block" {
  bucket = aws_s3_bucket.prod_bucket.bucket

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

# Bucket Policies
data "aws_iam_policy_document" "dev_bucket_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.dev_bucket.bucket}"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.dev_bucket.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "dev_policy" {
  bucket = aws_s3_bucket.dev_bucket.id
  policy = data.aws_iam_policy_document.dev_bucket_policy.json
}

data "aws_iam_policy_document" "stg_bucket_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.stg_bucket.bucket}"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.stg_bucket.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "stg_policy" {
  bucket = aws_s3_bucket.stg_bucket.id
  policy = data.aws_iam_policy_document.stg_bucket_policy.json
}

data "aws_iam_policy_document" "prod_bucket_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.prod_bucket.bucket}"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.prod_bucket.bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "prod_policy" {
  bucket = aws_s3_bucket.prod_bucket.id
  policy = data.aws_iam_policy_document.prod_bucket_policy.json
}

# Lambda Function
resource "aws_lambda_function" "email_alert_lambda" {
  function_name = "Email-Alert-Desde-Terraform"
  filename      = "${path.module}/lambda_function.zip"  # Path to your .zip file
  handler       = "index.handler"  # Assuming your Lambda function's entry point is in index.js with exports.handler
  runtime       = "nodejs20.x"
  role          = "arn:aws:iam::753480294298:role/LabRole"  # Replace your_account_id with your AWS account ID

  # Environment variables can be defined here if necessary
  environment {
    variables = {
      LOG_LEVEL = "info"
    }
  }
}

# Lambda Permission to Allow S3 to Invoke Lambda
resource "aws_lambda_permission" "allow_s3_invocation_dev" {
  statement_id  = "AllowExecutionFromS3Dev"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_alert_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dev_bucket.arn
}

resource "aws_lambda_permission" "allow_s3_invocation_stg" {
  statement_id  = "AllowExecutionFromS3Stg"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_alert_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.stg_bucket.arn
}

resource "aws_lambda_permission" "allow_s3_invocation_prod" {
  statement_id  = "AllowExecutionFromS3Prod"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_alert_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.prod_bucket.arn
}

# S3 Event Notifications for Lambda Trigger
resource "aws_s3_bucket_notification" "dev_notification" {
  bucket = aws_s3_bucket.dev_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_alert_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "index.html"
  }

  depends_on = [aws_lambda_permission.allow_s3_invocation_dev]
}

resource "aws_s3_bucket_notification" "stg_notification" {
  bucket = aws_s3_bucket.stg_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_alert_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "index.html"
  }

  depends_on = [aws_lambda_permission.allow_s3_invocation_stg]
}

resource "aws_s3_bucket_notification" "prod_notification" {
  bucket = aws_s3_bucket.prod_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_alert_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "index.html"
  }

  depends_on = [aws_lambda_permission.allow_s3_invocation_prod]
}
