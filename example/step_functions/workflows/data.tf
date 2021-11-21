data "aws_iam_policy" "step_function_policy" {
  name = var.step_policy_name
}


locals {
  simple_workflow = "test-sfn-workflow"
}