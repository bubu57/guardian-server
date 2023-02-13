#!/bin/bash

echo "Installation of guardian..."

echo -e "copy guardian in /sbin"
sudo cp -fr src/guadrian.sh /sbin/guardian
if [ -f "/sbin/guardian"]; then
    echo "DONE"
else
    echo "FAIL"
    exit 1
fi

echo "copy files of guardian in /usr/share/guardian"
sudo cp -fr src /usr/share/guardian-server
if [ -d "/usr/share/guardian"]; then
    echo "DONE"
else
    echo "FAIL"
    exit 1
fi

echo "Installation completed successfully, guardian -h"