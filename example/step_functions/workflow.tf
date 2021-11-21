module "workflow" {
    source = "./workflows"
    iam_role_name = "step-function-role"
    step_policy_name = local.step_function_policy_name
    sfn_policy_name = local.sfn_policy_name
    lambda = {
        "lambda_a" = module.workflow_a.lambda_arn
        "lambda_b" = module.workflow_b.lambda_arn
        "lambda_c" = module.workflow_c.lambda_arn
    }

    depends_on = [
        aws_iam_policy.lambda_exec_policy,
        aws_iam_policy.logging_policy,
        aws_iam_policy.step_function_policy
    ]
}

output "workflow_test" {
  value = module.workflow.workflow_test
}