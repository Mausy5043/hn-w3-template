#!/bin/bash

# This script is used to download the Grav `user/pages/` directory
HERE=$(dirname $0)

pushd $HERE/..
  lftp -f get.lftp
  ls -al
popd
