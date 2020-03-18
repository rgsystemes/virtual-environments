#!/bin/bash
################################################################################
##  File:  composer.sh
##  Desc:  Installs Composer
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
composer global require hirak/prestissimo

DocumentInstalledItem "Composer ($(composer --version))"
