#!/bin/bash
BASEDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASEDIR/backend"
node server.js
