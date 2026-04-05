#!/bin/bash
MODEL="qwen/qwen3.6-plus:free"
RESPONSE=$(curl -s --max-time 10 "https://openrouter.ai/api/v1/models/$MODEL" 2>/dev/null)

STATUS=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin).get('data', {})
    pricing = data.get('pricing', {})
    p = float(pricing.get('prompt', 0))
    c = float(pricing.get('completion', 0))
    if p > 0 or c > 0:
        print(f'PAID|Prompt: \${p}, Completion: \${c}')
    else:
        print('FREE')
except:
    print('ERROR')
")

if echo "$STATUS" | grep -q "PAID"; then
  echo "🚨 ALERT: Model $MODEL berubah jadi BERBAYAR! ($STATUS)"
elif echo "$STATUS" | grep -q "FREE"; then
  echo "✅ OK: Model $MODEL masih GRATIS."
else
  echo "⚠️  Gagal cek status: $STATUS"
fi