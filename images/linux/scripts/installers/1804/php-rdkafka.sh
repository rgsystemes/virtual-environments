#!/bin/bash
################################################################################
##  File:  php-rdkafka.sh
##  Desc:  Installs Rdkafka PHP driver
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh
LIBRDKAFKA_VERSION=1.3.0
PHP_RDKAFKA_VERSION=4.0.3
PHP_VERSIONS=('7.1' '7.2' '7.3' '7.4')

mkdir -p /tmp/lib
wget -qO /tmp/lib/librdkafka.tar.gz https://github.com/edenhill/librdkafka/archive/v${LIBRDKAFKA_VERSION}.tar.gz
tar -C /tmp/lib -xzf /tmp/lib/librdkafka.tar.gz
pushd /tmp/lib/librdkafka-${LIBRDKAFKA_VERSION}
./configure --install-deps
make -j$(nproc) >/dev/null 2>&1
make install
popd

for i in ${PHP_VERSIONS[@]}; do
    # here we first need to unregister the extension from PECL list to allow the following install command work for another php version
    pecl uninstall -r rdkafka
    # install rdkafka via PECL
    pecl -d php_suffix=$i install -f rdkafka-$PHP_RDKAFKA_VERSION
    echo "extension=rdkafka.so" | tee /etc/php/$i/mods-available/rdkafka.ini
done

phpenmod -v ALL rdkafka

# Document what was added to the image
echo "Lastly, document the installed versions"
# git version 2.20.1
DocumentInstalledItem "PHP Rdkafka v${PHP_RDKAFKA_VERSION}"
# git-lfs/2.6.1 (GitHub; linux amd64; go 1.11.1)
DocumentInstalledItem "Librdkafka v${LIBRDKAFKA_VERSION}"
