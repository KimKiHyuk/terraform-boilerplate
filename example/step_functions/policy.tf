resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda-exec-policy"
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

resource "aws_iam_policy" "sfn_exec_policy" {
  name        = "sfn-policy"
  path        = "/"
  description = "IAM policy for sfn"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "states:*"
      ],
      "Resource": "arn:aws:states:*:*:stateMachine:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "logging_policy" {
  name        = "lambda-logging-policy"
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


resource "aws_iam_policy" "step_function_policy" {
  name        = "step-function-policy"
  path        = "/"
  description = "IAM policy for step"

  policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:lambda:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:UpdateLogDelivery",
            "logs:DeleteLogDelivery",
            "logs:ListLogDeliveries",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:DescribeLogGroups"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}