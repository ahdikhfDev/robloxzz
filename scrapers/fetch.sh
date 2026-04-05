#!/bin/bash
# Universal URL Fetcher - Simple wrapper
# Usage: fetch.sh <URL> [lines]

URL="$1"
LINES="${2:-50}"

if [ -z "$URL" ]; then
    echo "Usage: fetch.sh <URL> [lines]"
    exit 1
fi

curl -s -L -A "Mozilla/5.0" "$URL" 2>/dev/null | head -$LINES
