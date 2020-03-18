#!/bin/bash
################################################################################
##  File:  wkhtmltopdf.sh
##  Desc:  Installs wkhtmltopdf binary
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

wget -qO /tmp/wkhtmltox_0.12.5-1.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -cs)_amd64.deb
dpkg -i /tmp/wkhtmltox_0.12.5-1.deb
apt-get -f install -y

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v wkhtmltopdf; then
    echo "wkhtmltopdf was not installed or found on PATH"
    exit 1
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "wkhtmltopdf ($(wkhtmltopdf --version))"
