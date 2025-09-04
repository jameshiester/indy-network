#!/bin/bash

# Exit on any error
set -e

echo "Starting Indy Node Monitor..."

# Get environment variables
GENESIS_URL=${GENESIS_URL}
NETWORK_NAME=${INDY_NETWORK_NAME}
INDY_NAMESPACE=${INDY_NAMESPACE}

echo "Environment variables:"
echo "  GENESIS_URL: $GENESIS_URL"
echo "  NETWORK_NAME: $NETWORK_NAME"
echo "  INDY_NAMESPACE: $INDY_NAMESPACE"

# Update networks.json if all required environment variables are present
if [ -n "$GENESIS_URL" ] && [ -n "$NETWORK_NAME" ] && [ -n "$INDY_NAMESPACE" ]; then
    echo "Updating networks.json with new network configuration..."
    
    # Check if networks.json exists and is valid JSON
    if [ -f "networks.json" ]; then
        echo "Reading existing networks.json..."
        # Create a backup
        cp networks.json networks.json.backup
    else
        echo "Creating new networks.json..."
        echo '{}' > networks.json
    fi
    
    # Use jq to safely update the JSON file
    echo "Updating networks.json with jq..."
    
    # Create new network entry using jq
    jq --arg name "$NETWORK_NAME" \
       --arg genesisUrl "$GENESIS_URL" \
       --arg indyNamespace "$INDY_NAMESPACE" \
       --arg displayName "$NETWORK_NAME" \
       '.[$name] = {
         "name": $displayName,
         "indyNamespace": $indyNamespace,
         "genesisUrl": $genesisUrl
       }' networks.json > networks.json.tmp && mv networks.json.tmp networks.json
    
    if [ $? -eq 0 ]; then
        echo "Successfully updated networks.json with jq"
    else
        echo "Failed to update networks.json with jq, using backup..."
        cp networks.json.backup networks.json
    fi
else
    echo "Warning: Not all required environment variables are set. Using existing networks.json"
fi

# Display the final networks.json content
echo "Final networks.json content:"
cat networks.json

# Start the Python application
echo "Starting Python application..."
exec python main.py --web "$@"
