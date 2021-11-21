resource "aws_iam_role" "step_function_role" {
  name               = var.iam_role_name
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  }
  EOF
}




resource "aws_iam_role_policy_attachment" "step_function_policy" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = data.aws_iam_policy.step_function_policy.arn
}



