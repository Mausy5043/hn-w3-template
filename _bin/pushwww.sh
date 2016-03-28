#!/bin/bash

#if [ -z $1 ]; then
#  echo "Syntax: pushwww.sh <dir>"
#  exit 1
#fi

pushd .
  make
popd

pushd ./_build
  lftp -f ../_bin/mirrorto.lftp
popd
