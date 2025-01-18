#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

versions=('8.1' '8.2' '8.3' '8.4')

REPOSITORY_NAME=devilbox

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            REPOSITORY_NAME)    REPOSITORY_NAME=${VALUE} ;;     
            VERSION)              VERSION=${VALUE} ;;
            *)   
    esac    


done

if echo ${versions[@]} | grep -q -w "$VERSION"; then

    cd ./docker-php-fpm-$VERSION
    docker pull debian:bullseye-slim
    echo "==="
    echo "== make php-fpm image"
    echo "==="
    make rebuild REPOSITORY_NAME=$REPOSITORY_NAME
    echo

    if [[ "${REPOSITORY_NAME,,}" != "devilbox/php-fpm" ]]; then

        echo "==="
        echo "== copy php-fpm image to PHP version"
        echo "==="
        php_version=$(docker run --rm $REPOSITORY_NAME-$VERSION php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION . "." . PHP_RELEASE_VERSION . "\n";')
        docker image tag $REPOSITORY_NAME-$VERSION $REPOSITORY_NAME-$VERSION:$php_version

        echo

        echo "==="
        echo "== push $REPOSITORY_NAME-$VERSION:latest"
        echo "==="
        docker push $REPOSITORY_NAME-$VERSION
        echo

        echo "==="
        echo "== push $REPOSITORY_NAME-$VERSION:$php_version"
        echo "==="
        docker push $REPOSITORY_NAME-$VERSION:$php_version
        docker image rm $REPOSITORY_NAME-$VERSION:$php_version
        echo
    fi

    cd $SCRIPTPATH
else
    delimiter="|"
    joined_versions=$(printf "%s$delimiter" "${versions[@]}")
    joined_versions=${joined_versions%$delimiter}  # Удалить последний разделитель

	echo "== make php-fpm image"
	echo " make-php-fpm.sh REPOSITORY_NAME=your_hub_docker_name VERSION=X.X"
	echo "  * Available versions $joined_versions"
	echo "  * Default REPOSITORY_NAME=devilbox/php-fpm"
	echo "  * When REPOSITORY_NAME=devilbox/php-fpm -> only build, without push to https://hub.docker.com/"
fi
