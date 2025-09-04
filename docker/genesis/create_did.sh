#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0"
    echo ""
    echo "Environment Variables:"
    echo "  DID_NAME          Name for the DID (default: test_did)"
    echo "  DID_SEED          Seed for deterministic DID generation (optional)"
    echo "  WALLET_NAME       Wallet name (default: test_wallet)"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  DID_NAME=my_did $0                    # Custom DID name"
    echo "  DID_SEED=SEED123 $0                   # Use specific seed"
    echo "  DID_NAME=my_did DID_SEED=SEED123 $0  # Custom name and seed"
    echo ""
    echo "Current Environment:"
    echo "  DID_NAME: ${DID_NAME:-test_did}"
    echo "  DID_SEED: ${DID_SEED:-not set}"
    echo "  WALLET_NAME: ${WALLET_NAME:-test_wallet}"
    exit 1
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Get values from environment variables with defaults
DID_NAME="${DID_NAME:-test_did}"
WALLET_NAME="${WALLET_NAME:-test_wallet}"
SEED="${DID_SEED:-}"

# Validate inputs
if [[ -z "$DID_NAME" ]]; then
    echo "Error: DID_NAME environment variable cannot be empty"
    usage
fi

echo "Creating DID with name: $DID_NAME"
if [[ -n "$SEED" ]]; then
    echo "Using seed"
else
    echo "No seed provided, using random generation"
fi

# Set up working directory for indy-cli-rs
WORKING_DIR="/tmp/indy"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

# Set environment variables for indy-cli-rs
export INDY_HOME="$WORKING_DIR"

# Create a temporary command file
TEMP_CMD_FILE=$(mktemp)
TEMP_OUTPUT_FILE=$(mktemp)

# Build the command sequence
cat > "$TEMP_CMD_FILE" << EOF
wallet create $WALLET_NAME key=password
wallet open $WALLET_NAME key=password
EOF

# Add DID creation command based on whether seed is provided
if [[ -n "$SEED" ]]; then
    echo "did new seed=$SEED" >> "$TEMP_CMD_FILE"
else
    echo "did new" >> "$TEMP_CMD_FILE"
fi

echo "wallet delete $WALLET_NAME key=password" >> "$TEMP_CMD_FILE"
# Add exit command
echo "exit" >> "$TEMP_CMD_FILE"

# Execute indy-cli-rs with the command file
cat "$TEMP_CMD_FILE"
echo "----------------------------------------"

indy-cli-rs < "$TEMP_CMD_FILE" > "$TEMP_OUTPUT_FILE" 2>&1
EXIT_CODE=$?

echo "Exit code: $EXIT_CODE"
echo "Output file size: $(wc -l < "$TEMP_OUTPUT_FILE") lines"
echo "First 10 lines of output:"
head -10 "$TEMP_OUTPUT_FILE"
echo "----------------------------------------"

# Check if execution was successful
if [[ $EXIT_CODE -eq 0 ]]; then
    # Extract DID and verkey from output
    DID=$(grep -o 'Did "[^"]*"' "$TEMP_OUTPUT_FILE" | head -n1 | sed 's/Did "//' | sed 's/"//')
    VERKEY=$(grep -o 'with "[^"]*" verkey' "$TEMP_OUTPUT_FILE" | head -n1 | sed 's/with "//' | sed 's/" verkey//')
    OUTPUT_FILE="/home/indy/output/${DID_NAME}_did_info.json"
    if [[ -n "$DID" && -n "$VERKEY" ]]; then
        echo ""
        echo "=== DID Creation Results ==="
        echo "Name: $DID_NAME"
        echo "DID: $DID"
        echo "Verkey: $VERKEY"
        echo "Output file: $OUTPUT_FILE"
        echo "============================"
        echo ""
        # Save to JSON file
        
        cat > "$OUTPUT_FILE" << EOF
{
  "did": "$DID",
  "verkey": "$VERKEY",
  "name": "$DID_NAME"
}
EOF
    else
        echo "Warning: Could not extract DID or verkey from output"
        echo "Raw output:"
        cat "$TEMP_OUTPUT_FILE"
    fi
else
    echo "Failed to execute commands (exit code: $EXIT_CODE)"
    echo "Full error output:"
    cat "$TEMP_OUTPUT_FILE"
fi
# Clean up temporary files
rm -f "$TEMP_CMD_FILE" "$TEMP_OUTPUT_FILE"