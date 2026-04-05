#!/bin/bash
export PATH="$HOME/.opencode/bin:$PATH"
cd /root/.nullclaw/workspace

# Run opencode in non-interactive mode with the prompt
PROMPT="$*"

if [ -z "$PROMPT" ]; then
    echo "Usage: opencode.sh <prompt>"
    exit 1
fi

opencode run "$PROMPT"
