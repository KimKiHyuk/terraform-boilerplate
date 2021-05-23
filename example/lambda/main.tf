terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "terraform/remote-state"
    region         = "ap-northeast-2"
    dynamodb_table = "lambda-state-locking"
    encrypt        = true
    profile        = "default"
  }
}


provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_s3_bucket" "bucket" {
  bucket = var.bucket
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "iam-lambda-exec-policy"
  path        = "/"
  description = "IAM policy for lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "iam:CreateRole",
            "iam:GetRole",
            "iam:AttachRolePolicy",
            "iam:PassRole",
            "lambda:AddPermission",
            "lambda:CreateFunction",
            "lambda:GetFunction",
            "lambda:UpdateFunctionCode",
            "lambda:UpdateFunctionConfiguration",
            "lambda:InvokeFunction",
            "lambda:ListFunctions",
            "logs:FilterLogEvents",
            "logs:getLogEvents",
            "logs:describeLogStreams"
      ],
      "Resource": "arn:aws:lambda:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "logging_policy" {
  name        = "iam-lambda-logging-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "s3_policy" {
  name        = "iam-s3-policy"
  path        = "/"
  description = "IAM policy for access to s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${data.aws_s3_bucket.bucket.arn}/*",
        "${data.aws_s3_bucket.bucket.arn}"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}


module "your_app" {
  source = "./your-app"
  bucket = var.bucket
  env    = var.env

  depends_on = [
    aws_iam_policy.lambda_exec_policy,
    aws_iam_policy.s3_policy,
    aws_iam_policy.logging_policy
  ]
}
