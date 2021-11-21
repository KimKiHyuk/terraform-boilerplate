resource "aws_cloudwatch_log_group" "simple_workflow_log_group" {
  name = "/aws/workflows/${local.simple_workflow}"
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = local.simple_workflow
  role_arn = aws_iam_role.step_function_role.arn


  definition = <<EOF
  {
    "Comment": "Invoke AWS Lambda from AWS Step Functions",
    "StartAt": "Start workflow",
    "States": {
      "Start workflow": {
        "Type": "Task",
        "Resource": "${var.lambda.lambda_a}",
        "Next": "Choice"
      },
      "Choice": {
        "Type": "Choice",
        "Choices": [
            {
              "Variable": "$.key",
              "StringMatches": "right",
              "Next": "workflow_c"
            }
        ],
        "Default": "workflow_b"
      },
      "workflow_b": {
        "Type": "Task",
       "Resource": "${var.lambda.lambda_b}",
        "End": true
      },
      "workflow_c": {
        "Type": "Task",
        "Resource": "${var.lambda.lambda_c}",
        "End": true
      }
    }
}
EOF

  logging_configuration {
    include_execution_data = true
    level                  = "ALL"
    log_destination        = "${aws_cloudwatch_log_group.simple_workflow_log_group.arn}:*"
  }

  tracing_configuration {
    enabled = false
  }
}


output "workflow_test" {
  value = aws_sfn_state_machine.sfn_state_machine.arn
}
