#!/bin/bash
################################################################################
##  File:  docker-compose.sh
##  Desc:  Installs Docker Compose
################################################################################

source $HELPER_SCRIPTS/document.sh

URL=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("docker-compose-Linux-x86_64"))' | head -1)

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt-get update
apt-get install -y docker-ce

# Install latest docker-compose from releases
curl -L $URL -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v docker-compose; then
    echo "docker-compose was not installed"
    exit 1
fi

## Add version information to the metadata file
echo "Documenting Docker & Docker Compose versions"
DocumentInstalledItem "Docker Compose ($(docker-compose -v))"
DocumentInstalledItem "Docker CE ($(docker --version))"
