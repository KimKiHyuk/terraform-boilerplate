# if you have s3 backend
# terraform {
#   backend "s3" {
#     bucket = "terraform-state"
#     key            = "lambda/terraform.tfstate"
#     region         = "ap-northeast-2"
#     dynamodb_table = "lambda-state-locking"
#     encrypt        = true
#     profile        = "default"
#   }
# }

locals {
  logging_policy_name       = "lambda-logging-policy"
  lambda_policy_name        = "lambda-exec-policy"
  sfn_policy_name           = "sfn-policy"
  step_function_policy_name = "step-function-policy"
}


provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}



module "workflow_init" {
  source              = "./workflow-init"
  account_id          = var.account_id
  region              = var.region
  memory_size         = 1024
  timeout             = 900
  ecr_repo_name       = "lambda/workflow-init"
  iam_role_name       = "iam-workflow-init-role"
  function_name       = "workflow-init"
  lambda_policy_name  = local.lambda_policy_name
  logging_policy_name = local.logging_policy_name
  sfn_policy_name     = local.sfn_policy_name

  depends_on = [
    aws_iam_policy.lambda_exec_policy,
    aws_iam_policy.logging_policy,
    aws_iam_policy.sfn_exec_policy,
    aws_ecr_repository.workflow_init
  ]
}

module "workflow_a" {
  source              = "./workflow_a"
  account_id          = var.account_id
  region              = var.region
  memory_size         = 4096
  timeout             = 900
  ecr_repo_name       = "lambda/workflow-a"
  iam_role_name       = "iam-workflow-a-role"
  function_name       = "workflow-a"
  lambda_policy_name  = local.lambda_policy_name
  logging_policy_name = local.logging_policy_name

  depends_on = [
    aws_iam_policy.lambda_exec_policy,
    aws_iam_policy.logging_policy,
    aws_ecr_repository.workflow_a
  ]
}
module "workflow_b" {
  source              = "./workflow_b"
  account_id          = var.account_id
  region              = var.region
  memory_size         = 4096
  timeout             = 900
  ecr_repo_name       = "lambda/workflow-b"
  iam_role_name       = "iam-workflow-b-role"
  function_name       = "workflow-b"
  lambda_policy_name  = local.lambda_policy_name
  logging_policy_name = local.logging_policy_name

  depends_on = [
    aws_iam_policy.lambda_exec_policy,
    aws_iam_policy.logging_policy,
    aws_ecr_repository.workflow_b
  ]
}
module "workflow_c" {
  source              = "./workflow_c"
  account_id          = var.account_id
  region              = var.region
  memory_size         = 4096
  timeout             = 900
  ecr_repo_name       = "lambda/workflow-c"
  iam_role_name       = "iam-workflow-c-role"
  function_name       = "workflow-c"
  lambda_policy_name  = local.lambda_policy_name
  logging_policy_name = local.logging_policy_name

  depends_on = [
    aws_iam_policy.lambda_exec_policy,
    aws_iam_policy.logging_policy,
    aws_ecr_repository.workflow_c
  ]
}