
# Create Security Groups
resource "aws_security_group" "web01" {
  name        = format("%s%s%s%s", var.Prefix, "scg", var.EnvCode, "web01")
  description = "Web Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Web Inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Http Inbound"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Web Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = format("%s%s%s%s", var.Prefix, "scg", var.EnvCode, "web01")
    resourcetype = "security"
    codeblock    = "network-3tier"
  }
}

resource "aws_security_group" "app01" {
  name        = format("%s%s%s%s", var.Prefix, "scg", var.EnvCode, "app01")
  description = " Application Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Application Inbound"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.web01.id]
    self            = true
  }

  egress {
    description = "Application Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = format("%s%s%s%s", var.Prefix, "scg", var.EnvCode, "app01")
    resourcetype = "security"
    codeblock    = "network-3tier"
  }
}


# Create Application Load Balancer
# WARNING: Consider implementing AWS WAFv2 in front of an Application Load Balancer for production environments
resource "aws_lb" "mswebapp" {
  name                       = format("%s%s%s%s", var.Prefix, "alb", var.EnvCode, "mswebapp")
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.web01.id]
  subnets                    = var.public_subnets
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alblogs.id
    prefix  = "albaccesslogs"
    enabled = true
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "alb", var.EnvCode, "mswebapp")
    rtype = "network"
  }
}



# Create ALB listener
# WARNING: Consider changing port to 443 and protocol to HTTPS for production environments 
resource "aws_lb_listener" "mswebapp" {
  load_balancer_arn = aws_lb.mswebapp.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mswebapp.arn
  }

  tags = {
    Name  = format("%s%s%s%s", var.Region, "lbl", var.EnvCode, "mswebapp")
    rtype = "network"
  }
}

# Define ALB Target Group
# WARNING: Lifecyle and name_prefix added for testing. Issue discussed here https://github.com/hashicorp/terraform-provider-aws/issues/16889
resource "aws_lb_target_group" "mswebapp" {
  name_prefix                   = "msweb-"
  port                          = 80
  protocol                      = "HTTP"
  target_type                   = "ip"
  vpc_id                        = var.vpc_id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    path    = "/healthz"
    matcher = "200"
  }

  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name  = format("%s-%s-%s-%s", var.Region, "lbt", var.EnvCode, "mswebapp")
    rtype = "network"
  }
}