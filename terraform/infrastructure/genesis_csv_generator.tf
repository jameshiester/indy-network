# Generate 4 random passwords for trustee seeds
resource "random_password" "trustee_seed_1" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "trustee_seed_2" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "trustee_seed_3" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "trustee_seed_4" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Create 4 trustee DID instances
module "trustee_did_1" {
  source = "./modules/did_generator"
  seed   = random_password.trustee_seed_1.result
}

module "trustee_did_2" {
  source = "./modules/did_generator"
  seed   = random_password.trustee_seed_2.result
}

module "trustee_did_3" {
  source = "./modules/did_generator"
  seed   = random_password.trustee_seed_3.result
}

module "trustee_did_4" {
  source = "./modules/did_generator"
  seed   = random_password.trustee_seed_4.result
}

# Create trustee CSV content
locals {
  trustee_csv_content = <<-EOF
Trustee name,Trustee DID,Trustee verkey
Trustee_1,${module.trustee_did_1.did},${module.trustee_did_1.verkey}
Trustee_2,${module.trustee_did_2.did},${module.trustee_did_2.verkey}
Trustee_3,${module.trustee_did_3.did},${module.trustee_did_3.verkey}
Trustee_4,${module.trustee_did_4.did},${module.trustee_did_4.verkey}
EOF
}

# Create the trustee CSV file locally
resource "local_file" "trustee_csv" {
  filename = "${path.module}/input/trustee_file.csv"
  content  = local.trustee_csv_content

  depends_on = [
    module.trustee_did_1,
    module.trustee_did_2,
    module.trustee_did_3,
    module.trustee_did_4
  ]
}

# Create the steward CSV file (nodes_genesis_file.csv format)
locals {
  steward_csv_content = <<-EOF
Steward name,Validator alias,Node IP address,Node port,Client IP address,Client port,Validator verkey,Validator BLS key,Validator BLS POP,Steward DID,Steward verkey
${module.node_genesis_1.steward_name},${module.node_genesis_1.validator_alias},${module.node_genesis_1.node_ip_address},${module.node_genesis_1.node_port},${module.node_genesis_1.client_ip_address},${module.node_genesis_1.client_port},${module.node_genesis_1.validator_verkey},${module.node_genesis_1.validator_bls_key},${module.node_genesis_1.validator_bls_pop},${module.node_genesis_1.steward_did},${module.node_genesis_1.steward_verkey}
${module.node_genesis_2.steward_name},${module.node_genesis_2.validator_alias},${module.node_genesis_2.node_ip_address},${module.node_genesis_2.node_port},${module.node_genesis_2.client_ip_address},${module.node_genesis_2.client_port},${module.node_genesis_2.validator_verkey},${module.node_genesis_2.validator_bls_key},${module.node_genesis_2.validator_bls_pop},${module.node_genesis_2.steward_did},${module.node_genesis_2.steward_verkey}
${module.node_genesis_3.steward_name},${module.node_genesis_3.validator_alias},${module.node_genesis_3.node_ip_address},${module.node_genesis_3.node_port},${module.node_genesis_3.client_ip_address},${module.node_genesis_3.client_port},${module.node_genesis_3.validator_verkey},${module.node_genesis_3.validator_bls_key},${module.node_genesis_3.validator_bls_pop},${module.node_genesis_3.steward_did},${module.node_genesis_3.steward_verkey}
${module.node_genesis_4.steward_name},${module.node_genesis_4.validator_alias},${module.node_genesis_4.node_ip_address},${module.node_genesis_4.node_port},${module.node_genesis_4.client_ip_address},${module.node_genesis_4.client_port},${module.node_genesis_4.validator_verkey},${module.node_genesis_4.validator_bls_key},${module.node_genesis_4.validator_bls_pop},${module.node_genesis_4.steward_did},${module.node_genesis_4.steward_verkey}
EOF
}

# Create the steward CSV file locally
resource "local_file" "steward_csv" {
  filename = "${path.module}/input/steward_file.csv"
  content  = local.steward_csv_content

  depends_on = [
    module.node_genesis_1,
    module.node_genesis_2,
    module.node_genesis_3,
    module.node_genesis_4
  ]
}

# Execute the genesis_from_files.py script
resource "null_resource" "genesis_executor" {
  triggers = {
    trustee_csv_content = local.trustee_csv_content
    steward_csv_content = local.steward_csv_content
    timestamp           = timestamp()
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      docker run --rm -v ${path.module}:/var/output -v /etc/indy/:/etc/indy/ -v ${path.module}/input:/var/input genesis 
    EOT
  }

  depends_on = [
    local_file.trustee_csv,
    local_file.steward_csv
  ]
}

# Upload the generated genesis files to S3
resource "aws_s3_object" "pool_transactions" {
  bucket = aws_s3_bucket.genesis_bucket.bucket
  key    = "pool_transactions"
  source = "${path.module}/pool_transactions_genesis"

  depends_on = [
    null_resource.genesis_executor,
    aws_s3_bucket.genesis_bucket
  ]

  tags = local.tags
}

resource "aws_s3_object" "domain_transactions" {
  bucket = aws_s3_bucket.genesis_bucket.bucket
  key    = "domain_transactions"
  source = "${path.module}/domain_transactions_genesis"

  depends_on = [
    null_resource.genesis_executor,
    aws_s3_bucket.genesis_bucket
  ]

  tags = local.tags
}

# S3 Bucket for storing genesis files
resource "aws_s3_bucket" "genesis_bucket" {
  bucket_prefix = format("%s-%s-%s", var.Prefix, "genesis", var.EnvCode)
  force_destroy = true

  tags = local.tags
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "genesis_bucket" {
  bucket                  = aws_s3_bucket.genesis_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "genesis_bucket" {
  bucket = aws_s3_bucket.genesis_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Policy to enforce TLS 1.2 on S3 bucket
data "aws_iam_policy_document" "genesis_bucket_tls" {
  statement {
    sid    = "Allow HTTPS only"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3*"
    ]
    resources = [
      "${aws_s3_bucket.genesis_bucket.arn}",
      "${aws_s3_bucket.genesis_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
  statement {
    sid    = "Allow TLS 1.2 and above"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3*"
    ]
    resources = [
      "${aws_s3_bucket.genesis_bucket.arn}",
      "${aws_s3_bucket.genesis_bucket.arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

# Apply policy to enforce TLS 1.2 on S3 bucket
resource "aws_s3_bucket_policy" "genesis_bucket" {
  bucket = aws_s3_bucket.genesis_bucket.id
  policy = data.aws_iam_policy_document.genesis_bucket_tls.json
}


# Outputs
output "genesis_bucket_name" {
  description = "Name of the S3 bucket containing genesis files"
  value       = aws_s3_bucket.genesis_bucket.bucket
}

output "genesis_bucket_arn" {
  description = "ARN of the S3 bucket containing genesis files"
  value       = aws_s3_bucket.genesis_bucket.arn
}

