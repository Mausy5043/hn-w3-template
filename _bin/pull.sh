#!/bin/bash

HERE=$(dirname $0)

pushd $HERE/..
  lftp -f pull.lftp
  ls -al
popd
