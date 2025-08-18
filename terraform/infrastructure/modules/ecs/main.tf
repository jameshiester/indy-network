locals {
  azs = var.azs

  tags = {
    Environment = var.EnvTag
    EnvCode     = var.EnvCode
    Solution    = var.SolTag
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
      name                   = "node1"
      image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.Region}.amazonaws.com/${var.server_ecr_repo}:latest"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = false
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "INDY_NETWORK_NAME"
          value = var.network_name
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
          name  = "DB_TYPE"
          value = "postgres"
        },
        {
          name  = "VALIDATOR_DID"
          value = var.steward_did
        },
        {
          name  = "DB_PORT"
          value = var.db_port
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
          name      = "VALIDATOR_SEED"
          valueFrom = var.steward_seed_arn
        },
        {
          name      = "DB_HOST"
          valueFrom = var.db_secret_arn
        },
      ]
      logconfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.log_group_name,
          awslogs-region        = "${var.Region}",
          awslogs-stream-prefix = "awslogs-"
        }
      }
      healthCheck = {
        command         = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
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

  load_balancer {
    target_group_arn = aws_lb_target_group.mswebapp.arn
    container_name   = "indy-api"
    container_port   = 8080
  }

  tags = local.tags
}

