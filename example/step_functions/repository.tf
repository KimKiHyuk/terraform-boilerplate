resource "aws_ecr_repository" "workflow_init" {
  name                 = "lambda/workflow-init"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "workflow_a" {
  name                 = "lambda/workflow-a"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "workflow_b" {
  name                 = "lambda/workflow-b"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "workflow_c" {
  name                 = "lambda/workflow-c"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}