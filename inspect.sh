#!/bin/bash

#inspect a crash docker containers logs

docker inspect $1 | grep 'LogPath' | sed -n "s/^.*\(\/var.*\)\",$/\1/p" | xargs sudo less +G