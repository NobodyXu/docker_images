#!/usr/bin/env sh

exec docker run --name dev --mount type=bind,source=$PWD,target=/root/dev -it build-env-base
