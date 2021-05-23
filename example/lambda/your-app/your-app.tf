data "aws_s3_bucket" "bucket" {
  bucket = var.bucket
}

data "aws_ecr_image" "your_app" {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = aws_ecr_repository.your_app.name
  image_tag       = "latest"
}


resource "null_resource" "ecr_image" {
  triggers = {
    python_file  = md5(file("${path.module}/index.py"))
    docker_file  = md5(file("${path.module}/Dockerfile"))
    requirements = md5(file("${path.module}/requirements.txt"))
  }

  provisioner "local-exec" {
    command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
           docker build --build-arg DOT_ENV=development -t ${aws_ecr_repository.your_app.repository_url}:latest -f ${path.module}/Dockerfile ${path.module}
           docker push ${aws_ecr_repository.your_app.repository_url}:latest
       EOF
  }
}

resource "aws_ecr_repository" "your_app" {
  name                 = "your_app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "your_app" {
  name = "iam-your_app"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.your_app.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.bucket.arn
}



resource "aws_lambda_function" "your_app" {
  function_name = "${var.env}-your_app-s3"
  role          = aws_iam_role.your_app.arn
  timeout       = 900
  memory_size   = 10240
  image_uri     = "${aws_ecr_repository.your_app.repository_url}@${data.aws_ecr_image.your_app.id}"
  package_type  = "Image"
  depends_on = [
    null_resource.ecr_image
  ]

}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.your_app.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_suffix       = ".zip"
  }

  depends_on = [aws_lambda_permission.allow_bucket, aws_cloudwatch_log_group.your_app, aws_iam_role_policy_attachment.logging, aws_iam_role_policy_attachment.lambda_exec_policy, aws_iam_role_policy_attachment.s3]
}




resource "aws_cloudwatch_log_group" "your_app" {
  name              = "/aws/lambda/${var.env}-your-app"
  retention_in_days = 14
}

data "aws_iam_policy" "lambda_exec_policy" {
  name = "iam-lambda-exec-policy"
}

data "aws_iam_policy" "logging_policy" {
  name = "iam-lambda-logging-policy"
}

data "aws_iam_policy" "s3_policy" {
  name = "iam-s3-policy"
}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.your_app.name
  policy_arn = data.aws_iam_policy.logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.your_app.name
  policy_arn = data.aws_iam_policy.lambda_exec_policy.arn
}


resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.your_app.name
  policy_arn = data.aws_iam_policy.s3_policy.arn
}
