provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


module "cluster_vpc" {
  source     = "../../modules/aws/vpc"
  cidr_block = "10.10.0.0/16"
  tag_name   = "ecs-vpc"
}

data "aws_availability_zones" "available" {

}

resource "aws_subnet" "cluster" {
  vpc_id                  = module.cluster_vpc.vpc_id
  count                   = "${length(data.aws_availability_zones.available.names)}"
  cidr_block              = "10.10.${10 + count.index}.0/24"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  tags = {
    Name = "ecs-subnet"
  }
}

# create route53

module "route53" {
  source = "../../modules/aws/domain"
  name   = "front_domain"
  lb = {
    dns_name = aws_lb.staging.dns_name
    zone_id  = aws_lb.staging.zone_id
  }
}


# ----






module "cluster_igw" {
  source   = "../../modules/aws/network/igw"
  vpc_id   = module.cluster_vpc.vpc_id
  tag_name = "ecs-igw"
}

resource "aws_route_table" "public_route" {
  vpc_id = module.cluster_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.cluster_igw.igw_id
  }

  tags = {
    Name = "ecs-route-table"
  }
}

resource "aws_route_table_association" "to-public" {
  count          = "${length(aws_subnet.cluster)}"
  subnet_id      = aws_subnet.cluster[count.index].id
  route_table_id = aws_route_table.public_route.id
}



# --- sg


resource "aws_security_group" "lb" {
  vpc_id = module.cluster_vpc.vpc_id
  name   = "lb-sg"
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  vpc_id = module.cluster_vpc.vpc_id
  name   = "ecs-tasks-sg"

  ingress {
    protocol        = "tcp"
    from_port       = 9000
    to_port         = 9000
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ----- load blancer

resource "aws_lb" "staging" {
  name               = "alb"
  subnets            = aws_subnet.cluster[*].id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  tags = {
    Environment = "staging"
    Application = "cloud-computing"
  }
}

# resource "aws_lb_listener" "https_forward" {
#   load_balancer_arn = aws_lb.staging.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.staging.arn
#   }
# }

resource "aws_lb_target_group" "staging" {
  name        = "cloud-computing-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.cluster_vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}


# -- make ecr

resource "aws_ecr_repository" "repo" {
  name = "keykim/cloud-computing"
}


resource "aws_ecr_lifecycle_policy" "repo-policy" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep image deployed with tag latest",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["latest"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 2 any images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}




data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-staging-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data "template_file" "cloud-computing" {
  template = file("/home/key/repository/Fargate-terraform-githubactions/terraform-boilerplate/terraform/arch/ecs_fargate/cloud-computing.json.tpl")
  vars = {
    aws_ecr_repository = aws_ecr_repository.repo.repository_url
    tag                = "latest"
    app_port           = 80
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "cloud-computing-staging"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.cloud-computing.rendered
  tags = {
    Environment = "staging"
    Application = "cloud-computing"
  }
}

resource "aws_ecs_cluster" "staging" {
  name = "cloud-computing-ecs-cluster"
}

resource "aws_ecs_service" "staging" {
  name            = "staging"
  cluster         = aws_ecs_cluster.staging.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.cluster[*].id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = "cloud-computing"
    container_port   = 9000
  }

  depends_on = [aws_lb.staging, aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Environment = "staging"
    Application = "cloud-computing"
  }
}


resource "aws_cloudwatch_log_group" "cloud-computing" {
  name = "awslogs-cloud-computing-staging"

  tags = {
    Environment = "staging"
    Application = "cloud-computing"
  }
}