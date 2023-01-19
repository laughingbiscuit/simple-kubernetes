#!/bin/sh
set -xe

echo "Lets check that docker is installed, this is our only dependency to run this demo!" > /dev/null
docker version
read EnterToContinue
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

