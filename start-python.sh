#!/bin/bash
BASEDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASEDIR/python-service"
python app.py
