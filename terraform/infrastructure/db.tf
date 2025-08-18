data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "17.5"
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.15.0"

  name              = format("%s-%s-%s", var.Prefix, "indy", var.EnvCode)
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true
  master_username   = local.master_username

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }
  }
  manage_master_user_password          = true

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  enable_http_endpoint = true

  serverlessv2_scaling_configuration = {
    min_capacity             = 0
    max_capacity             = 10
    seconds_until_auto_pause = 3600
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }

  tags = local.tags
}