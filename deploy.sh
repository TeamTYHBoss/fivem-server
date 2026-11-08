#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f .env ]]; then
    echo "Missing .env file. Copy .env.example to .env and fill in the values."
    exit 1
fi

source .env

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "Missing DATABASE_URL in .env."
    exit 1
fi

if [[ -z "${FIVEM_LICENSE_KEY:-}" ]]; then
    echo "Missing FIVEM_LICENSE_KEY in .env."
    exit 1
fi

echo "Deployment checks passed."
echo "Start the FiveM server with: ./run.sh or use your server control panel."
