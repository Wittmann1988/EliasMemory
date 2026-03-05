# Infrastruktur-Protokoll

## Stand: 2026-03-05

### Verfuegbare APIs & Modelle

| Modell | Provider | API | Status | Latenz |
|--------|----------|-----|--------|--------|
| Claude Opus 4.6 | Anthropic | Abo (ich selbst) | OK | - |
| GPT-4.1 | OpenAI | API Key | OK | schnell |
| o3 | OpenAI | API Key | OK | schnell |
| o1-pro | OpenAI | API Key | verfuegbar | - |
| Nemotron-3-Nano 30B | NVIDIA/Ollama Cloud | OLLAMA_API_KEY | OK | schnell |
| DeepSeek-V3.2 671B | DeepSeek/Ollama Cloud | OLLAMA_API_KEY | OK | mittel |
| Qwen3-Coder 480B | Qwen/Ollama Cloud | OLLAMA_API_KEY | OK | schnell |

### Weitere verfuegbare Ollama Cloud Modelle (nicht aktiv genutzt)
- Kimi-K2.5 (1T), Kimi-K2-Thinking (1T)
- Qwen3.5:397B, Qwen3-Next:80B
- Mistral-Large-3:675B, Devstral-2:123B
- Cogito-2.1:671B, DeepSeek-V3.1:671B
- GLM-5, GLM-4.7
- GPT-OSS:120B, GPT-OSS:20B
- MiniMax-M2.5, MiniMax-M2.1

### Maschinen

| Geraet | IP | Status | Ollama | SSH |
|--------|-----|--------|--------|-----|
| Tablet (Samsung) | lokal | OK | 3 Modelle (NICHT nutzen) | - |
| Desktop PC | 192.168.50.250 | online | laeuft (localhost-only) | Port zu |
| Laptop (WSL2/Kali) | 192.168.50.99 | ping OK | ? | Port zu |
| NVIDIA Jetson AGX Orin 64GB | ? | wird geflasht | noch nicht | noch nicht |

### PC Ports offen
- 80 (HTTP), 135 (MSRPC), 139/445 (SMB), 2179 (VMRDP)
- 3240, 7680, 27036 (Steam), 49668
- KEIN SSH (22), KEIN Ollama (11434)

### PC freischalten (PowerShell Admin)
```powershell
# Ollama fuer Netzwerk
[System.Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0", "User")
taskkill /f /im ollama.exe; Start-Sleep 2; Start-Process ollama
New-NetFirewallRule -DisplayName "Ollama API" -Direction Inbound -Port 11434 -Protocol TCP -Action Allow

# SSH aktivieren
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
New-NetFirewallRule -DisplayName "SSH" -Direction Inbound -Port 22 -Protocol TCP -Action Allow
```

### MCP Server
- `sequential-thinking`: node ~/downloads/mcp-sequential-thinking/dist/index.js
- `ollama-sidekick`: node ~/ollama-sidekick/index.js (Nemotron Cloud)

### API Keys
- OLLAMA_API_KEY: in ~/.bashrc (e8428dd33e...)
- OPENAI_API_KEY: in ~/.bashrc (sk-wwD...)
- Anthropic: via Abo (kein expliziter Key noetig)

### Tablet-Regel
- Auf Android-Tablet NUR Cloud-Modelle, NICHTS lokal laufen lassen
- Genuegend Hardware vorhanden (PC, Laptop, AGX Orin)
