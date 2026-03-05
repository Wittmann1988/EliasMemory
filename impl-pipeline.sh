#!/bin/bash
source ~/.bashrc 2>/dev/null

PROMPT="$1"
OUTDIR="$2"
MAX_TOKENS="${3:-6000}"

# Reasoning models need more tokens for thinking+content
REASON_TOKENS=8000

echo "Starting pipeline with $MAX_TOKENS tokens (reasoning: $REASON_TOKENS)..."
echo "Output dir: $OUTDIR"

# Helper: extract content from various API formats  
extract() {
  python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    # OpenAI/Groq/Ollama/OpenRouter format
    if 'choices' in d:
        c=d['choices'][0]['message']
        reasoning=c.get('reasoning','') or c.get('reasoning_content','') or ''
        content=c.get('content','') or ''
        if reasoning and not content:
            print(reasoning)
        elif reasoning:
            print('<reasoning>\n'+reasoning+'\n</reasoning>\n\n'+content)
        else:
            print(content)
    # Gemini format
    elif 'candidates' in d:
        parts=d['candidates'][0]['content']['parts']
        for p in parts:
            if 'text' in p: print(p['text'])
    # NVIDIA format
    elif 'message' in d:
        print(d['message'].get('content',''))
    else:
        print('ERROR: '+json.dumps(d)[:500])
except Exception as e:
    print('PARSE_ERROR: '+str(e)+' RAW: '+sys.stdin.read()[:500])
" 2>/dev/null
}

run_model() {
  local name="$1" outfile="$2"
  shift 2
  echo "  [$name] starting..."
  local start=$(date +%s)
  "$@" | extract > "$outfile"
  local end=$(date +%s)
  local size=$(wc -c < "$outfile")
  echo "  [$name] done in $((end-start))s, ${size} bytes"
}

# === TIER 1: Flagships ===

# 1. GPT-4.1
run_model "GPT-4.1" "$OUTDIR/gpt41.txt" \
  curl -s --max-time 120 https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"gpt-4.1\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# 2. Grok-4
run_model "Grok-4" "$OUTDIR/grok4.txt" \
  curl -s --max-time 120 https://api.x.ai/v1/chat/completions \
  -H "Authorization: Bearer $XAI_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"grok-4-0709\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# 3. Gemini 3.1 Pro
run_model "Gemini-3.1-Pro" "$OUTDIR/gemini31pro.txt" \
  curl -s --max-time 120 "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"contents\":[{\"parts\":[{\"text\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}]}],\"generationConfig\":{\"maxOutputTokens\":$MAX_TOKENS,\"temperature\":0.7}}" &

# 4. DeepSeek-V3.2 (Ollama Cloud)
run_model "DeepSeek-V3.2" "$OUTDIR/deepseek.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"deepseek-v3.2\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 5. Qwen3-Coder 480B
run_model "Qwen3-Coder" "$OUTDIR/qwen_coder.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"qwen3-coder:480b\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 6. Devstral-2 123B (NEU)
run_model "Devstral-2" "$OUTDIR/devstral2.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"devstral-2:123b\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# === TIER 2: Starke Spezialisten ===

# 7. Nemotron 30B
run_model "Nemotron" "$OUTDIR/nemotron.txt" \
  curl -s --max-time 120 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"nemotron-3-nano:30b\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# 8. Step-3.5-Flash (OpenRouter)
run_model "Step-3.5-Flash" "$OUTDIR/step35flash.txt" \
  curl -s --max-time 120 https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"stepfun/step-3.5-flash:free\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 9. Kimi-K2.5
run_model "Kimi-K2.5" "$OUTDIR/kimi_k25.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"kimi-k2.5\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 10. Mistral-Large-3 675B
run_model "Mistral-Large-3" "$OUTDIR/mistral_large3.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"mistral-large-3:675b\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# 11. Qwen3.5 397B
run_model "Qwen3.5" "$OUTDIR/qwen35.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"qwen3.5:397b\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 12. Grok-Code-Fast-1
run_model "Grok-Code" "$OUTDIR/grok_code.txt" \
  curl -s --max-time 120 https://api.x.ai/v1/chat/completions \
  -H "Authorization: Bearer $XAI_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"grok-code-fast-1\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# === TIER 3: Speed + Kostenlos ===

# 13. Groq Llama-3.3-70B
run_model "Groq-Llama" "$OUTDIR/groq_llama.txt" \
  curl -s --max-time 60 https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $GROQ_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"llama-3.3-70b-versatile\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# 14. Groq Kimi-K2
run_model "Groq-Kimi-K2" "$OUTDIR/groq_kimi.txt" \
  curl -s --max-time 60 https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $GROQ_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"moonshotai/kimi-k2-instruct\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$MAX_TOKENS,\"temperature\":0.7}" &

# 15. GPT-OSS-120B (Groq)
run_model "GPT-OSS-120B" "$OUTDIR/gpt_oss.txt" \
  curl -s --max-time 60 https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $GROQ_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"openai/gpt-oss-120b\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 16. Qwen3-235B Thinking (OpenRouter)
run_model "Qwen3-235B" "$OUTDIR/qwen3_235b.txt" \
  curl -s --max-time 120 https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"qwen/qwen3-235b-a22b-thinking-2507\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 17. NVIDIA DeepSeek-V3.2
run_model "NVIDIA-DeepSeek" "$OUTDIR/nvidia_deepseek.txt" \
  curl -s --max-time 120 https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Authorization: Bearer $NVIDIA_DEEPSEEK_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"deepseek-ai/deepseek-v3.2\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

# 18. GLM-5
run_model "GLM-5" "$OUTDIR/glm5.txt" \
  curl -s --max-time 180 https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" -H "Content-Type: application/json" \
  -d "{\"model\":\"glm-5\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}],\"max_tokens\":$REASON_TOKENS,\"temperature\":0.7}" &

echo "All 18 models launched. Waiting..."
wait
echo "=== ALL DONE ==="
echo ""
echo "Results:"
for f in "$OUTDIR"/*.txt; do
  name=$(basename "$f" .txt)
  size=$(wc -c < "$f")
  lines=$(wc -l < "$f")
  printf "  %-20s %6d bytes  %4d lines\n" "$name" "$size" "$lines"
done
