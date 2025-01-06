#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

version=('8.1','8.2','8.3','8.4')

if echo ${version[@]} | grep -q -w "$1"; then
    cd ./docker-php-fpm-$1
    docker pull debian:bullseye-slim
    echo "==="
    echo "== make php-fpm image"
    echo "==="
    make build
    echo

    echo "==="
    echo "== rename devilbox/php-fpm-$1 to mrlexx/php-fpm-$1"
    echo "==="
    docker image tag devilbox/php-fpm-$1 mrlexx/php-fpm-$1
    docker image rm devilbox/php-fpm-$1

    php_version=$(docker run --rm mrlexx/php-fpm-$1 php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION . "." . PHP_RELEASE_VERSION . "\n";')
    echo "$php_version"
    docker image tag mrlexx/php-fpm-$1 mrlexx/php-fpm-$1:$php_version
    echo

    echo "==="
    echo "== push mrlexx/php-fpm-$1:latest"
    echo "==="
    docker push mrlexx/php-fpm-$1
    echo
    echo "==="
    echo "== push mrlexx/php-fpm-$1:$php_version"
    echo "==="
    docker push mrlexx/php-fpm-$1:$php_version
    docker image rm mrlexx/php-fpm-$1:$php_version
    echo
    cd $SCRIPTPATH
else
	echo "== make php-fpm image"
	echo " make.sh version "
	echo "  * available version 8.1|8.2|8.3|8.4"
fi
