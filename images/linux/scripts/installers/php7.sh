#!/bin/bash
################################################################################
##  File:  php7.sh
##  Desc:  Installs php7.1 to 7.4
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

PHP_VERSIONS=('7.1' '7.2' '7.3' '7.4')
DISPLAY_ERRORS=On
PHPMEMORY=512M
MAX_EXECUTION_TIME=300
REALPATH_CACHE_SIZE=4096K
REALPATH_CACHE_TTL=600
TIMEZONE=UTC

echo "==> Add ondrej's PPA..."
apt-add-repository ppa:ondrej/php -y && apt-get update

for i in ${PHP_VERSIONS[@]}; do

PHPINI="/etc/php/$i/fpm/php.ini"
PHPINI_CLI="/etc/php/$i/cli/php.ini"

echo "==> Installing php-$i packages..."
apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages php$i-dev php$i-common php$i-fpm \
    php$i-readline php$i-bcmath php$i-opcache php$i-curl php$i-gd php$i-intl php$i-sqlite3 php$i-pgsql php$i-mbstring php$i-xml php$i-zip php$i-sybase

# Set extra .ini configuration
echo "==> Configuring php.ini..."
sed -i "s/display_errors = .*/display_errors = $DISPLAY_ERRORS/g" $PHPINI
sed -i "s/memory_limit = .*/memory_limit = $PHPMEMORY/g" $PHPINI
sed -i "s/max_execution_time = .*/max_execution_time = $MAX_EXECUTION_TIME/g" $PHPINI
sed -i "s/;date.timezone =/date.timezone = $TIMEZONE/g" $PHPINI
sed -i -r "s/;?realpath_cache_size = .*/realpath_cache_size = $REALPATH_CACHE_SIZE/g" $PHPINI
sed -i -r "s/;?realpath_cache_ttl = .*/realpath_cache_ttl = $REALPATH_CACHE_TTL/g" $PHPINI

echo "==> Updated php-fpm configuration :" && grep -iE 'memory_limit|realpath_cache_size|realpath_cache_ttl|date.timezone =' $PHPINI

echo "==> Configuring php.ini (cli)"
sed -i "s/;date.timezone =/date.timezone = $TIMEZONE/g" $PHPINI_CLI

echo "==> Set opcache configuration"
echo "
zend_extension=opcache.so

opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.validate_timestamps=1
opcache.revalidate_freq=2
" | tee /etc/php/$i/mods-available/opcache.ini

done

echo "==> Install extra packages"
apt-get install -y php-pear php-pecl-http

echo "==> Update PECL channel before finish"
pecl channel-update pecl.php.net

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
for cmd in php php7.1 php7.2 php7.3 php7.4; do
    if ! command -v $cmd; then
        echo "$cmd was not installed"
        exit 1
    fi
done

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "PHP 7.1 ($(php7.1 --version | head -n 1))"
DocumentInstalledItem "PHP 7.2 ($(php7.2 --version | head -n 1))"
DocumentInstalledItem "PHP 7.3 ($(php7.3 --version | head -n 1))"
DocumentInstalledItem "PHP 7.4 ($(php7.4 --version | head -n 1))"
