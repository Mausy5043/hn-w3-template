#!/bin/bash

HERE=$(dirname $0)

pushd $HERE/..
  #lftp -f push.lftp
  ls -al
popd
