locals {
  azs = var.azs

  tags = {
    Environment = var.EnvTag
    EnvCode     = var.EnvCode
    Solution    = var.SolTag
  }
}

resource "aws_ecs_task_definition" "mswebapp" {
  family                   = var.node_ecr_repo
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  track_latest             = true
  execution_role_arn       = aws_iam_role.ecstaskexec.arn
  task_role_arn            = aws_iam_role.ecstask.arn
  container_definitions = jsonencode([
    {
      name                   = "node1"
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/${var.node_ecr_repo}:latest"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "INDY_NETWORK_NAME"
          value = var.network_name
        },
        {
          name  = "INDY_NODE_NAME"
          value = var.node_name_1
        }
      ]
      secrets = [
        {
          name      = "INDY_NODE_SEED"
          valueFrom = var.node_seed_arn_1
        }
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.mswebapp.name}",
          awslogs-region        = "${var.Region}",
          awslogs-stream-prefix = "awslogs-"
        }
      }
      healthCheck = {
        command         = ["CMD-SHELL", "curl -f http://localhost:80/healthz || exit 1"]
        intervalSeconds = 30
        timeoutSeconds  = 5
        retries         = 3
        startPeriod     = 30
      }
    }
  ])
}


# Create Amazon ECS task service
resource "aws_ecs_service" "mswebapp" {
  name            = var.ecs_service
  cluster         = aws_ecs_cluster.mswebapp.id
  task_definition = aws_ecs_task_definition.mswebapp.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  propagate_tags  = "TASK_DEFINITION"


  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [aws_security_group.app01.id]
    assign_public_ip = false # Assigns public IPs in public subnet
  }

  # Alternative: Use specific network interfaces for each task
  # This requires creating individual services for each task
  # network_configuration {
  #   subnets         = [var.public_subnets[0]]
  #   security_groups = [aws_security_group.app01.id]
  #   assign_public_ip = true
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.mswebapp.arn
    container_name   = "go-api"
    container_port   = 80
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "iar", var.EnvCode, "api")
    rtype = "ecsservice"
  }
}

