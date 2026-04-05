#!/bin/bash
# Ultra Scraper - Telegram Ready
# Usage: s.sh <URL> [links|images|text|all]

URL="$1"
MODE="${2:-all}"

if [ -z "$URL" ]; then
    echo "Usage: s.sh <URL> [links|images|text|all]"
    exit 1
fi

python3 /root/.nullclaw/workspace/scrapers/ultra-scrape.py "$URL" "$MODE"
