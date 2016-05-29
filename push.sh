#!/bin/bash

# This script is used to upload the Grav `user/pages/` directory to the hosting site.
HERE=$(dirname $0)

pushd $HERE/..
  lftp -f put.lftp
popd
