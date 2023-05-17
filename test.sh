#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

docker run --rm -e CI=true -v $(pwd):$(pwd) ubuntu /bin/sh -c "$(pwd)/install.sh"
