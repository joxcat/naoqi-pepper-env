#!/usr/bin/env bash
xhost +local:docker
docker exec -it pepper /bin/bash
