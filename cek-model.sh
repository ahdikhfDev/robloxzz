#!/bin/bash
# Cek status model OpenRouter (Free/Paid)
# Usage: ./cek-model.sh [model_id]

MODEL_ID=${1:-"qwen/qwen3.6-plus:free"}

echo "🔍 Cek Model: $MODEL_ID"
echo "--------------------------------"

# Fetch data via Python (more reliable than jq if not installed)
python3 -c "
import requests, sys

model_id = '$MODEL_ID'
try:
    res = requests.get('https://openrouter.ai/api/v1/models', timeout=10)
    res.raise_for_status()
    models = res.json().get('data', [])
    
    found = False
    for m in models:
        if m['id'] == model_id:
            found = True
            pricing = m.get('pricing', {})
            prompt_cost = float(pricing.get('prompt', 0))
            completion_cost = float(pricing.get('completion', 0))
            
            is_free = (prompt_cost == 0 and completion_cost == 0)
            status = '✅ FREE' if is_free else '⚠️ BERBAYAR'
            
            print(f'Status: {status}')
            print(f'Prompt: ${prompt_cost}/1K tokens')
            print(f'Completion: ${completion_cost}/1K tokens')
            print(f'Context: {m.get("context_length", "N/A")} tokens')
            break
    
    if not found:
        print('❌ Model tidak ditemukan atau ID salah.')
except Exception as e:
    print(f'❌ Error: {e}')
"

echo "--------------------------------"
