#!/bin/bash

# This script is used to download the Grav `user/pages/` directory

lftp -f get.lftp
ls -al
