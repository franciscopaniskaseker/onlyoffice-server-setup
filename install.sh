#!/bin/bash

source library.sh

# vars
systemd_services="redis-server nginx rabbitmq-server postgresql"
main

# unknown error
exit 255
