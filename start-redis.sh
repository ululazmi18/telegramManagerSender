#!/bin/bash
BASEDIR="$(cd "$(dirname "$0")" && pwd)"
redis-server "$BASEDIR/redis.conf"
