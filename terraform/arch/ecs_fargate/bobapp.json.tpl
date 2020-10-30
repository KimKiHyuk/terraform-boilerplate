[
  {
    "name": "bobapp",
    "image": "${aws_ecr_repository}:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-2",
        "awslogs-stream-prefix": "bobapp-staging-service",
        "awslogs-group": "awslogs-bobapp-staging"
      }
    },
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp"
      }
    ],
    "cpu": 1,
    "environment": [
      {
        "name": "NODE_ENV",
        "value": "staging"
      },
      {
        "name": "PORT",
        "value": "3000"
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