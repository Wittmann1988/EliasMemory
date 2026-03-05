# Elias Memory

Persistentes Wissens-Repository fuer Claude Code (Elias).
Dient als langfristiger Speicher ueber Sessions hinweg -- Architekturentscheidungen, Modell-Evaluierungen, API-Inventar und Pipeline-Ergebnisse bleiben erhalten, auch wenn der Kontext einer Sitzung endet.

## Struktur

| Datei / Verzeichnis | Inhalt |
|----------------------|--------|
| `infrastructure.md` | Infrastruktur-Uebersicht (Termux, Shizuku, SSH, Device Mesh) |
| `modell-inventar.md` | Vollstaendiges Inventar aller 18+ KI-Modelle mit Providern und Endpoints |
| `api-keys.md` | API-Key-Inventar (nur Provider/Status, keine Secrets) |
| `projekte.md` | Projekt-Uebersicht (Agent Forge, DeepResearch, SystemManager, ...) |
| `impl-pipeline.sh` | Multi-Modell Pipeline Script (18 Modelle parallel) |
| `pipeline-run1/` bis `pipeline-run3/` | Konzept-Runs: Jeder Run enthaelt Antworten aller Modelle zu Architektur-Fragen |
| `impl-run1/` bis `impl-run3/` | Implementations-Runs: Code-fokussierte Antworten mit konkreten Loesungen |
| `IMPL-SYNTHESE.md` | Konsens-Analyse ueber alle 3 Implementations-Runs |
| `sessions/` | Session-Logs |

## 18-Modell Pipeline

Die Pipeline befragt 18 KI-Modelle parallel zu einer Fragestellung und fuehrt 3 Iterationszyklen durch.
Jeder Zyklus baut auf den Ergebnissen des vorherigen auf. Ein Orchestrator (Claude Opus) erstellt am Ende eine Synthese mit Konsens-Bewertung.

**Provider:** Ollama Cloud, OpenAI, xAI, Google, Groq, OpenRouter, NVIDIA NIM

**Ergebnisse:** Siehe [IMPL-SYNTHESE.md](IMPL-SYNTHESE.md) fuer die finale Konsens-Analyse ueber alle Runs.
