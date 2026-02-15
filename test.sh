#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

docker run --rm -e CI=true -v "$(pwd):$(pwd)" ubuntu /bin/sh -c "
  apt-get update -qq && apt-get install -y -qq curl git >/dev/null 2>&1
  $(pwd)/install.sh
"
