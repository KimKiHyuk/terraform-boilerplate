[
  {
    "name": "cloud-computing",
    "image": "${aws_ecr_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-2",
        "awslogs-stream-prefix": "cloud-computing-staging-service",
        "awslogs-group": "awslogs-cloud-computing-staging"
      }
    },
    "portMappings": [
      {
        "containerPort": 9000,
        "hostPort": 9000,
        "protocol": "tcp"
      }
    ],
    "cpu": 2,
    "environment": [
      {
        "name": "PORT",
        "value": "9000"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "mountPoints": [],
    "memory": 2048,
    "volumesFrom": []
  }
]