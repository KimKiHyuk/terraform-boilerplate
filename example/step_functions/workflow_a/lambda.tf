data "archive_file" "env" {
  type        = "zip"
  source_dir = "${path.module}/env"
  output_path = "${path.module}/env.zip"
}

locals {
  image_tag = "latest"
}

data "aws_ecr_repository" "repo" {
  name                 = var.ecr_repo_name
}

data "aws_ecr_image" "image" {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = data.aws_ecr_repository.repo.name
  image_tag       = local.image_tag
}

data "aws_iam_policy" "logging_policy" {
  name = var.logging_policy_name
}

data "aws_iam_policy" "lambda_exec_policy" {
  name = var.lambda_policy_name
}



resource "null_resource" "ecr_image" {
  triggers = {
    python_file  = md5(file("${path.module}/index.py"))
    docker_file  = md5(file("${path.module}/Dockerfile"))
    requirements = md5(file("${path.module}/requirements.txt"))
    env_hash = data.archive_file.env.output_sha
  }

  provisioner "local-exec" {
    command = <<EOF
      sh build.sh \
        -r "${data.aws_ecr_repository.repo.repository_url}:${local.image_tag}" \
        -f "${path.module}/Dockerfile" \
        -c "${path.module}"
    EOF
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  timeout       = var.timeout
  memory_size   = var.memory_size
  image_uri     = "${data.aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.image.id}"
  package_type  = "Image"
  depends_on = [
    null_resource.ecr_image
  ]
}



resource "aws_iam_role" "lambda_role" {
  name =  var.iam_role_name

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

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.lambda_exec_policy.arn
}



output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}
