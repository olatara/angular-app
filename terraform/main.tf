terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Configure Cluster
resource "aws_ecs_cluster" "convertr_cluster" {
  name = "convertr_cluster" 
}

# Configure Task Definition
resource "aws_ecs_task_definition" "convertr-task" {
  family = "convertr-task"
  container_definitions = <<DEFINITION
  [
    {
      "name": "convertr-task",
      "image": "${aws_ecr_repository.convertr-app.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "hostPort": 80,
          "protocol": "tcp",
          "containerPort": 80
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory = 1024
  cpu = 512 
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

# Configure ECS Service
resource "aws_ecs_service" "angular-app" {
  name            = "angular-app"
  cluster         = aws_ecs_cluster.convertr_cluster.id
  task_definition = aws_ecs_task_definition.convertr-task.arn
  launch_type     = "FARGATE"
  desired_count   = 3
  depends_on = [aws_lb_listener.lb_listener]

#link load balancer tg to service
  load_balancer {
    target_group_arn = aws_lb_target_group.convertr-tg.arn
    container_name   = aws_ecs_task_definition.convertr-task.family
    container_port   = var.port
  }

  network_configuration {
    subnets = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.service_sg.id]
  }
}

#Network Configuration must be provided when networkMode 'awsvpc'
# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}


