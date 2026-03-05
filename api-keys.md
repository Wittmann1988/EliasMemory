# API Keys Inventar

## Stand: 2026-03-05

WICHTIG: Keys sind in ~/.bashrc gespeichert, NICHT hier.
Diese Datei dokumentiert nur welche Keys existieren.

| Provider | Env Variable | Modelle | Status |
|----------|-------------|---------|--------|
| Anthropic | (Abo) | Claude Opus 4.6, Sonnet 4.6, Haiku 4.5 | OK |
| OpenAI | OPENAI_API_KEY | GPT-4.1, o3, o1-pro, GPT-4o | OK |
| Ollama Cloud | OLLAMA_API_KEY | Nemotron 30B, DeepSeek-V3.2, Qwen3-Coder 480B, +28 weitere | OK |
| Google | GEMINI_API_KEY | Gemini 2.5 Pro, 2.5 Flash, 2.0 Flash | OK |
| xAI | XAI_API_KEY | Grok-4, Grok-3, Grok-3-mini | OK |
| OpenRouter | OPENROUTER_API_KEY | 343 Modelle (Aggregator) | OK |
| Groq | GROQ_API_KEY | Llama-3.3-70B, Qwen3-32B, Kimi-K2 | OK |
| NVIDIA Chat | NVIDIA_API_KEY | Chat-Modelle (generisch, 403 bei den meisten) | Teilweise |
| NVIDIA DeepSeek | NVIDIA_DEEPSEEK_API_KEY | deepseek-ai/deepseek-v3.2 (Chat+Reasoning) | **OK** |
| NVIDIA Embed | NVIDIA_EMBED_API_KEY | llama-nemotron-embed-1b-v2 (2048-dim) | OK |
| NVIDIA Retriever | NVIDIA_RETRIEVER_API_KEY | llama-3.2-nemoretriever-300m-embed-v2 | Endpoint unklar |
| HuggingFace | HUGGINGFACE_API_KEY | Inference API | OK |

## NVIDIA: Ein Key pro Modell!
Bei NVIDIA NIM gehoert JEDER API Key zu einem spezifischen Modell.
- NVIDIA_DEEPSEEK_API_KEY -> deepseek-ai/deepseek-v3.2 (Chat, Reasoning, Thinking-Mode)
  - Endpoint: https://integrate.api.nvidia.com/v1/chat/completions
  - Supports: stream, thinking, temperature, top_p, max_tokens 8192, seed
- NVIDIA_EMBED_API_KEY -> llama-nemotron-embed-1b-v2 (Embeddings, 2048-dim, 0.67s/5 Texte)
- NVIDIA_RETRIEVER_API_KEY -> llama-3.2-nemoretriever-300m-embed-v2 (Embeddings, kleiner/schneller)
- NVIDIA_API_KEY -> Generischer Key (funktioniert nicht bei allen Modellen)

## Embedding-Modell fuer MemoryFramework
- **nvidia/llama-nemotron-embed-1b-v2**: 2048-dim, schnell, gratis Tier
- Perfekt fuer sqlite-vec Integration im MemoryFramework
- Benchmark: 5 Texte in 0.67s, 83 Tokens

## Nutzungsregeln
- Tablet: NUR Cloud-APIs, NICHTS lokal
- Groq fuer Speed (Llama-3.3-70B extrem schnell)
- Ollama Cloud fuer grosse Modelle (DeepSeek 671B, Qwen 480B)
- OpenAI fuer Reasoning (o3, GPT-4.1)
- xAI/Grok-4 fuer unzensierte Analyse
- Gemini 2.5 Pro fuer lange Kontexte
- OpenRouter fuer kostenlose Modelle (Step-3.5-Flash)
- NVIDIA Embed fuer Vektor-Embeddings im Memory System
