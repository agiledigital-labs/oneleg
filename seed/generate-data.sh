#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

python tools/datafiller.py --size=100000 postgresql/01-schema.sql > postgresql/02-data.sql