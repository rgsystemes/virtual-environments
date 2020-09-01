#!/bin/bash
################################################################################
##  File:  php-cassandra.sh
##  Desc:  Installs Datastax PHP driver
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

OS_RELEASE=18.04
LIBUV_VERSION=1.29.1
CASSANDRA_VERSION=2.13.0
PHP_VERSIONS=('7.1' '7.2' '7.3' '7.4')

apt-get install -y libgmp-dev

mkdir -p /tmp/lib
pushd /tmp/lib
echo "==> Download and install libuv1..."
wget -qO libuv.deb https://downloads.datastax.com/cpp-driver/ubuntu/${OS_RELEASE}/dependencies/libuv/v${LIBUV_VERSION}/libuv1_${LIBUV_VERSION}-1_amd64.deb && dpkg -i libuv.deb
wget -qO libuv-dev.deb https://downloads.datastax.com/cpp-driver/ubuntu/${OS_RELEASE}/dependencies/libuv/v${LIBUV_VERSION}/libuv1-dev_${LIBUV_VERSION}-1_amd64.deb && dpkg -i libuv-dev.deb
echo "==> Download and install cassandra c++ drivers..."
wget -qO cass-cpp.deb https://downloads.datastax.com/cpp-driver/ubuntu/${OS_RELEASE}/cassandra/v${CASSANDRA_VERSION}/cassandra-cpp-driver_${CASSANDRA_VERSION}-1_amd64.deb && dpkg -i cass-cpp.deb
wget -qO cass-cpp-dev.deb https://downloads.datastax.com/cpp-driver/ubuntu/${OS_RELEASE}/cassandra/v${CASSANDRA_VERSION}/cassandra-cpp-driver-dev_${CASSANDRA_VERSION}-1_amd64.deb && dpkg -i cass-cpp-dev.deb
popd

# Install PHP Extension
cd /usr/src
git clone https://github.com/datastax/php-driver.git

cd /usr/src/php-driver/ext

for i in ${PHP_VERSIONS[@]}; do
    phpize$i
    mkdir -p /usr/src/php-driver/build
    cd /usr/src/php-driver/build
    ../ext/configure --with-php-config=/usr/bin/php-config$i > /dev/null
    make clean >/dev/null
    make -j$(nproc) >/dev/null 2>&1
    make install
    echo "extension=cassandra.so" | tee /etc/php/$i/mods-available/cassandra.ini
done

find /usr/lib/php -type f -name 'cassandra.so' | xargs chmod 644

phpenmod -v ALL cassandra

# clean Up
rm -R /usr/src/php-driver


# Document what was added to the image
echo "Lastly, document the installed versions"
DocumentInstalledItem "Datastax PHP driver v1.3.2"
DocumentInstalledItem "Cassandra CPP driver v${CASSANDRA_VERSION}"
