#!/bin/bash

if [ $1 == "" ]; then
  echo "Syntax: pushwww.sh <dir>"
  exit 1
fi

pushd $1
  make
popd

pushd $1/_build
  lftp -f ../_bin/mirrorto.lftp
popd
