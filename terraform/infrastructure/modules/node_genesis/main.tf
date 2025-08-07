resource "random_string" "steward_name" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Create the node genesis entry using the script
resource "null_resource" "create_node_genesis" {
  triggers = {
    steward_seed = var.steward_seed
    node_seed    = var.node_seed
    public_ip    = var.public_ip
    private_ip   = var.private_ip
    node_name    = var.node_name
    steward_name = var.steward_name
    timestamp    = timestamp()
  }

  provisioner "local-exec" {
    command = "docker run --rm -v /${path.module}:/home/indy/output -v /etc/indy/:/etc/indy/ genesis /home/indy/create_node_genesis.sh --steward-seed=${var.steward_seed} --node-seed=${var.node_seed} --public-ip=${var.public_ip} --private-ip=${var.private_ip} --node-port=${var.node_port} --client-port=${var.client_port} --network-name=${var.network_name} --steward-name=${var.steward_name} --node-name=${var.node_name}"
  }
}

# Read the generated genesis entry from JSON file, panic if file doesn't exist
data "external" "genesis_info" {
  depends_on = [null_resource.create_node_genesis]

  program = ["bash", "-c", <<-EOF
    GENESIS_FILE="/${path.module}/${var.network_name}_${var.node_name}_genesis.json"
    if [ -f "$GENESIS_FILE" ]; then
      cat "$GENESIS_FILE"
    else
      echo "ERROR: Genesis file $GENESIS_FILE does not exist!" >&2
      exit 1
    fi
  EOF
  ]
} 