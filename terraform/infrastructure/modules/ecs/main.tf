locals {
  azs = var.azs

  tags = {
    Environment = var.EnvTag
    EnvCode     = var.EnvCode
    Solution    = var.SOLTAG
  }
}

resource "aws_ecs_task_definition" "mswebapp" {
  family                   = var.server_ecr_repo
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  track_latest             = true
  execution_role_arn       = aws_iam_role.ecstaskexec.arn
  task_role_arn            = aws_iam_role.ecstask.arn
  container_definitions = jsonencode([
    {
      name                   = var.SERVER_CONTAINER_NAME
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/${var.server_ecr_repo}:latest"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
          protocol      = "tcp"
        }
      ]
      dependsOn = [
        {
          containerName = var.MONITOR_CONTAINER_NAME
          condition     = "HEALTHY"
        }
      ]
      environment = [
        {
          name  = "INDY_NETWORK_NAME"
          value = var.network_name
        },
        {
          name  = "GENESIS_TXN_PATH"
          value = "/app/genesis.txn"
        },
        {
          name  = "GENESIS_S3_BUCKET"
          value = var.genesis_bucket_name
        },
        {
          name  = "GENESIS_S3_KEY"
          value = var.pool_transactions_key
        },
        {
          name  = "MONITOR_HOST"
          value = "localhost"
        },
        {
          name  = "PORT"
          value = "443"
        },
        {
          name  = "MONITOR_CONTAINER_NAME"
          value = var.MONITOR_CONTAINER_NAME
        },
        {
          name  = "MONITOR_PORT"
          value = tostring(var.MonitorPort)
        },
        {
          name  = "DB_TYPE"
          value = "postgres"
        },
        {
          name  = "DID"
          value = var.steward_did
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_USERNAME"
          value = var.db_master_username
        }
      ]
      secrets = [
        {
          name      = "SEED"
          valueFrom = var.steward_seed_arn
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        },
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.log_group_name,
          awslogs-region        = var.Region,
          awslogs-stream-prefix = "server"
        }
      }
      healthCheck = {
        command         = ["CMD-SHELL", "curl -f http://localhost:443/health || exit 1"]
        intervalSeconds = 30
        timeoutSeconds  = 5
        retries         = 3
        startPeriod     = 30
      }
    },
    {
      name                   = var.MONITOR_CONTAINER_NAME
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/${var.monitor_ecr_repo}:latest"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false
      portMappings = [
        {
          containerPort = var.MonitorPort
          hostPort      = var.MonitorPort
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "INDY_NETWORK_NAME"
          value = var.network_name
        },
        {
          name  = "INDY_NAMESPACE"
          value = var.network_name
        },
        {
          name  = "PORT"
          value = tostring(var.MonitorPort)
        },
        {
          name  = "GENESIS_URL"
          value = "https://${var.genesis_bucket_name}.s3.${var.Region}.amazonaws.com/${var.pool_transactions_key}"
        }
      ]
      # secrets = [
      #   {
      #     name      = "SEED"
      #     valueFrom = var.steward_seed_arn
      #   }
      # ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.log_group_name,
          awslogs-region        = var.Region,
          awslogs-stream-prefix = "monitor"
        }
      }
      healthCheck = {
        command         = ["CMD-SHELL", "curl -f http://localhost:9000/health || exit 1"]
        intervalSeconds = 10
        timeoutSeconds  = 5
        retries         = 3
        startPeriod     = 60
      }
    }
  ])
}


# Create Amazon ECS task service
resource "aws_ecs_service" "mswebapp" {
  name            = var.ecs_service
  cluster         = aws_ecs_cluster.network.id
  task_definition = aws_ecs_task_definition.mswebapp.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  propagate_tags  = "TASK_DEFINITION"


  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.app01.id]
    assign_public_ip = false # Assigns public IPs in public subnet
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mswebapp.arn
    container_name   = var.SERVER_CONTAINER_NAME
    container_port   = 443
  }

  tags = local.tags
}

