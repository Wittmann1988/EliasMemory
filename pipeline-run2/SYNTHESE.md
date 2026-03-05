# Pipeline Durchlauf 2/3 — SYNTHESE

## Datum: 2026-03-05
## Modelle: GPT-4.1, Grok-4, Gemini 2.5 Pro, Groq Llama-3.3-70B, DeepSeek-V3.2 671B, Qwen3-Coder 480B, Nemotron 30B, Step-3.5-Flash (NEU)
## Fehlgeschlagen: NVIDIA NIM (403 Auth Error - braucht Account-Setup)

## Verbesserungen gegenueber Durchlauf 1
1. max_tokens erhoeht (4000 statt 2000) -> DeepSeek vollstaendig (17KB statt 1.6KB!)
2. Gemini Pro statt Flash -> bessere Tiefe
3. Step-3.5-Flash hinzugefuegt (Reasoning-Modell, kostenlos)
4. Prompt fokussiert auf IMPLEMENTATION statt Konzepte
5. Cross-Feature-Interaktion abgefragt

## KONSENS: Empfohlene Open-Source Repos

| Feature | Repo | Konsens |
|---------|------|---------|
| Graph Orchestration | **LangGraph** (github.com/langchain-ai/langgraph) | 8/8 |
| Graph Memory | **Mem0** (github.com/mem0ai/mem0) | 8/8 |
| Zettelkasten Memory | **A-MEM** (github.com/agiresearch/A-mem) | 6/8 |
| Self-Improving | **DSPy** (github.com/stanfordnlp/dspy) | 8/8 |
| Agent Teams | **CrewAI** (github.com/crewAIInc/crewAI) | 7/8 |
| Memory Paging | **Letta/MemGPT** (github.com/letta-ai/letta) | 7/8 |
| RL Memory | **AgentFly** (github.com/papers/AgentFly) | 5/8 |

## KONSENS: Architektur-Design (alle 8 Modelle konvergiert)

```
                    +------------------+
                    |   USER/TABLET    |  (Android/Termux - Thin Client)
                    +--------+---------+
                             |
                    +--------v---------+
                    |   ORCHESTRATOR   |  (LangGraph StateGraph)
                    |  - AgentState    |
                    |  - Routing       |
                    |  - Checkpoints   |
                    +--+----+----+---+-+
                       |    |    |   |
            +----------+  +-+  ++  ++---------+
            v             v    v              v
    +-------+---+  +------+--+ +---+------+ +-+--------+
    | TEAM MGR  |  | DSPy    | | MEMORY   | | RL CTRL  |
    | CrewAI    |  | Pipeline| | PAGING   | | PPO/DQN  |
    | Hierarchy |  | Optimize| | MemGPT   | | Rewards  |
    +-----+-----+  +----+----+ +----+-----+ +----+-----+
          |              |           |             |
          |              |     +-----v------+      |
          |              |     | DUAL MEM   |      |
          |              |     | Working:   |      |
          |              |     |  deque     |      |
          |              |     | LTM:       |      |
          |              |     |  Graph DB  |<-----+
          |              |     | (Mem0+FAISS|  RL updates
          +--------------+---->|  +sqlite)  |  graph structure
             read context      +------------+
```

## KONSENS: Datenstrukturen

### MemoryNode (Zettelkasten-inspiriert)
```python
@dataclass
class MemoryNode:
    id: UUID
    content: str
    embedding: List[float]  # 384-dim (MiniLM-L6-v2)
    type: str  # observation|reflection|plan|action|result
    confidence: float  # 0.0-1.0
    tags: Dict[str, Any]  # intent-tags (DSPy Thought-Conditioning)
    connections: List[Edge]
    created_at: datetime
    last_accessed: datetime
    access_count: int
```

### AgentState (LangGraph)
```python
class AgentState(TypedDict):
    messages: List[BaseMessage]
    memory_facts: List[MemoryNode]
    current_plan: str
    task_queue: List[str]
    team_assignments: Dict[str, List[str]]
```

### RL Memory Action Space
```python
actions = ["store_node", "link_edge", "consolidate_cluster",
           "forget_node", "update_weight", "replay_episode"]
reward = task_accuracy * 0.5 + retrieval_hit_rate * 0.3 - redundancy * 0.2
```

## KONSENS: Tech Stack pro Plattform

| Plattform | Rolle | Stack |
|-----------|-------|-------|
| **Android/Termux** | Thin Client + API Gateway | Node.js CLI, ssh tunnels, SQLite (read-only cache) |
| **NVIDIA Jetson AGX 64GB** | Primary Inference + RL | TensorRT-LLM, FAISS-GPU, PyTorch, LangGraph, Mem0 |
| **Desktop PC (GPU)** | Heavy Models + Graph DB | vLLM, Neo4j/Postgres+pgvector, Redis, DSPy, CrewAI |

## MODELL-BEWERTUNG Run 2

| Modell | Tiefe | Praezision | Repos | Code | Architektur | Score |
|--------|-------|------------|-------|------|-------------|-------|
| **Qwen3-Coder** | Sehr hoch | Sehr hoch | Ja | Umfangreich | Detailliert | **10/10** |
| **Grok-4** | Sehr hoch | Sehr hoch | Ja | Detailliert | Blueprint-Level | **10/10** |
| **Step-3.5-Flash** | Sehr hoch | Hoch | Ja | Gut | Vollstaendig | **9/10** |
| **GPT-4.1** | Hoch | Hoch | Ja | Gut | Klar | 8/10 |
| **DeepSeek-V3.2** | Hoch | Hoch | Ja | Umfangreich | Gut (17KB!) | **9/10** |
| **Nemotron** | Hoch | Hoch | Teilw. | Gut | Innovativ | 8/10 |
| **Gemini 2.5 Pro** | Mittel-Hoch | Mittel | Ja | Wenig | Kompakt | 7/10 |
| **Groq Llama** | Mittel | Mittel | Wenig | Mittel | OK | 6/10 |

## Verbesserung Run 1 -> Run 2

| Metrik | Run 1 | Run 2 | Verbesserung |
|--------|-------|-------|-------------|
| Modelle | 7 | 8 (+Step-3.5) | +14% |
| Avg Output (bytes) | ~4700 | ~13000 | **+177%** |
| Repo-URLs genannt | 0 | 7+ pro Modell | Neu |
| Code-Beispiele | 2 Modelle | 6 Modelle | +200% |
| Architektur-Diagramm | 0 Modelle | 5 Modelle | Neu |
| Feature-Interaktion | Nicht abgefragt | Alle 8 Modelle | Neu |
| Plattform-spezifisch | Nicht abgefragt | Alle 8 Modelle | Neu |
| DeepSeek Output | 1.6KB (cut off) | 17.5KB (vollst.) | **+993%** |

## Verbesserungen fuer Durchlauf 3
1. NVIDIA NIM API fixen (Account/Billing Setup)
2. Cross-Validation: Modelle bewerten gegenseitig
3. Konkreten Implementierungsplan erstellen
4. Sidekick-Analyse der empfohlenen Repos (Code lesen)
5. Finale Architektur-Entscheidung mit Abstimmung
