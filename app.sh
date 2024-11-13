#!/bin/bash

# Constants - Change these as needed
AGENT_VERSION="2.213.2" # Ensure this is the latest stable version
AGENT_DIR="/azp/agent"

# Environment Variables - Assumed to be provided
# AZP_URL - Azure DevOps organization URL, e.g., https://dev.azure.com/your-organization
# AZP_TOKEN - Personal Access Token for authentication, with agent permissions
# AZP_AGENT_NAME - Desired name for the agent
# AZP_POOL - Agent pool to register with

# Exit on any failure
set -e

# Create a directory for the agent
mkdir -p $AGENT_DIR
cd $AGENT_DIR

echo "Downloading Azure Pipelines agent..."
curl -LsS https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz -o agent.tar.gz

echo "Extracting Azure Pipelines agent..."
tar zxvf agent.tar.gz

echo "Configuring Azure Pipelines agent..."
./config.sh --unattended \
    --url "$AZP_URL" \
    --auth pat \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "$AZP_AGENT_NAME" \
    --acceptTeeEula \
    --replace \
    --work "_work" \
    --runAsService

echo "Cleaning up..."
rm -f agent.tar.gz

echo "Running Azure Pipelines agent..."
# Start the agent
./svc.sh install
./svc.sh start

# Wait for the agent process to exit
tail -f /dev/null
