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
| NVIDIA | NVIDIA_API_KEY | Nemotron, Yi, Llama, +viele | OK |
| HuggingFace | HUGGINGFACE_API_KEY | Inference API | OK |

## Nutzungsregeln
- Tablet: NUR Cloud-APIs, NICHTS lokal
- NVIDIA-Modelle ab Pipeline Durchlauf 2 einbinden
- Groq fuer Speed (Llama-3.3-70B extrem schnell)
- Ollama Cloud fuer grosse Modelle (DeepSeek 671B, Qwen 480B)
- OpenAI fuer Reasoning (o3, GPT-4.1)
- xAI/Grok-4 fuer unzensierte Analyse
- Gemini 2.5 Pro fuer lange Kontexte
