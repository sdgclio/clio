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

# Function to install a package if not already installed
install_if_missing() {
  if ! dpkg -s "$1" >/dev/null 2>&1; then
    echo "Installing $1..."
    sudo apt-get update -y
    sudo apt-get install -y "$1"
  else
    echo "$1 is already installed."
  fi
}

# Ensure necessary packages are installed
install_if_missing curl
install_if_missing tar
install_if_missing sudo  # Ensure sudo is present for script running without root
install_if_missing apt-transport-https  # Useful for adding repos securely

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
sudo ./svc.sh install
sudo ./svc.sh start

# Wait for the agent process to exit
tail -f /dev/null
