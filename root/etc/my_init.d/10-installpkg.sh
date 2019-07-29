#!/bin/bash

set -e

if [ -z "$DRIVER_PKGS" ]; then
    echo "No packages to install"
    exit 0
fi

apt-get update

if [ ! -z "$DRIVER_PKGS" ]; then
    for p in $DRIVER_PKGS; do
        echo "Attempting to install $p..."
        apt-get install --no-install-recommends -y $p || echo "Failed, but continuing..."
    done
fi

apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*