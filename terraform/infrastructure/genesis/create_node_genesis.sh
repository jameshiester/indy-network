#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --steward-seed=SEED    Steward seed for DID generation (required)"
    echo "  --node-seed=SEED       Node seed for indy keys (required)"
    echo "  --public-ip=IP         Public IP address (required)"
    echo "  --private-ip=IP        Private IP address (required)"
    echo "  --node-port=PORT       Node port (default: 9701)"
    echo "  --client-port=PORT     Client port (default: 9702)"
    echo "  --network-name=NAME    Network name (default: sandbox)"
    echo "  --steward-name=NAME    Steward name (default: steward)"
    echo "  --node-name=NAME       Node name (default: node)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --steward-seed=SEED1 --node-seed=SEED2 --public-ip=1.2.3.4 --private-ip=10.0.0.1"
    echo "  $0 --steward-seed=SEED1 --node-seed=SEED2 --public-ip=1.2.3.4 --private-ip=10.0.0.1 --network-name=testnet"
    exit 1
}

# Default values
STEWARD_SEED=""
NODE_SEED=""
PUBLIC_IP=""
PRIVATE_IP=""
NODE_PORT="9701"
CLIENT_PORT="9702"
NETWORK_NAME="sandbox"
STEWARD_NAME="steward"
NODE_NAME="node"

# Parse named arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --steward-seed=*)
            STEWARD_SEED="${1#*=}"
            shift
            ;;
        --node-seed=*)
            NODE_SEED="${1#*=}"
            shift
            ;;
        --public-ip=*)
            PUBLIC_IP="${1#*=}"
            shift
            ;;
        --private-ip=*)
            PRIVATE_IP="${1#*=}"
            shift
            ;;
        --node-port=*)
            NODE_PORT="${1#*=}"
            shift
            ;;
        --client-port=*)
            CLIENT_PORT="${1#*=}"
            shift
            ;;
        --network-name=*)
            NETWORK_NAME="${1#*=}"
            shift
            ;;
        --steward-name=*)
            STEWARD_NAME="${1#*=}"
            shift
            ;;
        --node-name=*)
            NODE_NAME="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required inputs
if [[ -z "$STEWARD_SEED" ]]; then
    echo "Error: steward-seed is required"
    usage
fi

if [[ -z "$NODE_SEED" ]]; then
    echo "Error: node-seed is required"
    usage
fi

if [[ -z "$PUBLIC_IP" ]]; then
    echo "Error: public-ip is required"
    usage
fi

if [[ -z "$PRIVATE_IP" ]]; then
    echo "Error: private-ip is required"
    usage
fi

echo "Creating node genesis entry with:"
echo "  Steward seed: $STEWARD_SEED"
echo "  Node seed: $NODE_SEED"
echo "  Public IP: $PUBLIC_IP"
echo "  Private IP: $PRIVATE_IP"
echo "  Network name: $NETWORK_NAME"
echo "----------------------------------------"

# Set up working directory for indy-cli-rs
WORKING_DIR="/tmp/indy-cli-rs"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

# Set environment variables for indy-cli-rs
export INDY_HOME="$WORKING_DIR"

# Step 1: Create steward DID
echo "Step 1: Creating steward DID..."
STEWARD_WALLET_NAME="steward_wallet_$(date +%s)"
TEMP_CMD_FILE=$(mktemp)
TEMP_OUTPUT_FILE=$(mktemp)

# Build steward DID creation commands
cat > "$TEMP_CMD_FILE" << EOF
wallet create $STEWARD_WALLET_NAME key=password
wallet open $STEWARD_WALLET_NAME key=password
did new seed=$STEWARD_SEED
wallet delete $STEWARD_WALLET_NAME key=password
exit
EOF

# Execute steward DID creation
indy-cli-rs < "$TEMP_CMD_FILE" > "$TEMP_OUTPUT_FILE" 2>&1
STEWARD_EXIT_CODE=$?

if [[ $STEWARD_EXIT_CODE -eq 0 ]]; then
    # Extract steward DID and verkey
    STEWARD_DID=$(grep -o 'Did "[^"]*"' "$TEMP_OUTPUT_FILE" | head -n1 | sed 's/Did "//' | sed 's/"//')
    STEWARD_VERKEY=$(grep -o 'with "[^"]*" verkey' "$TEMP_OUTPUT_FILE" | head -n1 | sed 's/with "//' | sed 's/" verkey//')
    
    if [[ -n "$STEWARD_DID" && -n "$STEWARD_VERKEY" ]]; then
        echo "Steward DID created: $STEWARD_DID"
        echo "Steward verkey: $STEWARD_VERKEY"
    else
        echo "Error: Failed to extract steward DID or verkey"
        cat "$TEMP_OUTPUT_FILE"
        exit 1
    fi
else
    echo "Error: Failed to create steward DID"
    cat "$TEMP_OUTPUT_FILE"
    exit 1
fi

# Clean up steward files
rm -f "$TEMP_CMD_FILE" "$TEMP_OUTPUT_FILE"

# Step 2: Create node indy keys
echo "Step 2: Creating node indy keys..."


output=$(init_indy_keys --name=${NODE_NAME} --seed=$NODE_SEED)
NODE_PUBLIC_KEY=$(echo "$output" | grep "Public key is" | tail -n1 | awk '{print $4}')
NODE_VERIFICATION_KEY=$(echo "$output" | grep "Verification key is" | tail -n1 | awk '{print $4}')
NODE_BLS_PUBLIC_KEY=$(echo "$output" | grep "BLS Public key is" | awk '{print $5}')
NODE_BLS_PROOF_OF_POSSESSION=$(echo "$output" | grep "Proof of possession for BLS key is" | awk '{print $8}')

# Step 3: Create JSON output
echo "Step 3: Creating JSON output..."
OUTPUT_FILE="/home/indy/output/${NETWORK_NAME}_${NODE_NAME}_genesis.json"

cat > "$OUTPUT_FILE" << EOF
{
  "steward_name": "$STEWARD_NAME",
  "validator_alias": "${NODE_NAME}",
  "node_ip_address": "$PUBLIC_IP",
  "node_port": "$NODE_PORT",
  "client_ip_address": "$PRIVATE_IP",
  "client_port": "$CLIENT_PORT",
  "validator_verkey": "$NODE_VERIFICATION_KEY",
  "validator_bls_key": "$NODE_BLS_PUBLIC_KEY",
  "validator_bls_pop": "$NODE_BLS_PROOF_OF_POSSESSION",
  "steward_did": "$STEWARD_DID",
  "steward_verkey": "$STEWARD_VERKEY",
  "network_name": "$NETWORK_NAME",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "Genesis entry created successfully!"
echo "Output file: $OUTPUT_FILE"
echo ""
echo "=== Genesis Entry Summary ==="
echo "Steward DID: $STEWARD_DID"
echo "Steward Verkey: $STEWARD_VERKEY"
echo "Node Verkey: $NODE_VERIFICATION_KEY"
echo "Node BLS Key: $NODE_BLS_PUBLIC_KEY"
echo "Node BLS POP: $NODE_BLS_PROOF_OF_POSSESSION"
echo "Public IP: $PUBLIC_IP"
echo "Private IP: $PRIVATE_IP"
echo "============================"

 