# Generate random DID name
resource "random_string" "did_name" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Generate random wallet name
resource "random_string" "wallet_name" {
  length  = 10
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Create the DID using the script
resource "null_resource" "create_did" {
  triggers = {
    seed        = var.seed
    did_name    = random_string.did_name.result
    wallet_name = random_string.wallet_name.result
    timestamp   = timestamp()
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      docker run --rm -e DID_NAME=${random_string.did_name.result} -e DID_SEED=${var.seed} -e WALLET_NAME=${random_string.wallet_name.result} -v /etc/indy/:/etc/indy/ -v /${path.module}:/home/indy/output genesis /home/indy/create_did.sh
    EOT
  }
}

# Read the generated DID and verkey from JSON file
data "external" "did_info" {
  depends_on = [null_resource.create_did]

  program = ["bash", "-c", <<-EOF
    DID_FILE="/${path.module}/${random_string.did_name.result}_did_info.json"
    if [ -f "$DID_FILE" ]; then
      cat "$DID_FILE"
    else
      echo "ERROR: DID info file $DID_FILE does not exist!" >&2
      exit 1
    fi
  EOF
  ]
}