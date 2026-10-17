# Msingi AI

A companion for Kenya's Competency-Based Curriculum (CBC), with separate workspaces for teachers, learners and parents. It covers the five KICD benchmark grades: PP2, Grade 3, Grade 6, Grade 9 and Grade 12.

Msingi AI is a single full-stack [Jac](https://www.jaseci.org/) app. The server keeps the KICD curriculum as a graph (grade, then learning area, then strand, then sub-strand) and runs AI agents over it with Google Gemini. The browser UI is also written in Jac and compiles to React.

> Curriculum content is illustrative and modelled on KICD CBC designs. Always confirm against the official curriculum designs.

## Features

| Workspace | Tools |
|---|---|
| **Teacher** | KICD lesson plan generator (SLOs, inquiry questions, competencies, values, PCIs, timed steps and a 4-tier KNEC rubric) · Locally available material planner · Parent broadcast |
| **Learner** | Termly revision calendar · Practical material checklist · Socratic tutor that guides with questions instead of giving answers |
| **Parent** | Plain-language CBC translator (English or Kiswahili) · Home activity guide · Holistic progress tracker using KNEC levels |

When an agent call fails, or no API key is set, each agent falls back to a template built from the curriculum graph, so the app works offline. Every result is labelled either **AI generated** or **Curriculum template**.

## Requirements

- The `jac` CLI, version 0.37.25 (pinned in `app/jac.toml`)
- A Gemini API key, for AI output (optional)

You don't need to install Node.js. `jac install` provisions the JavaScript toolchain and npm packages itself.

## Getting started

```bash
cd app
jac install                      # Python and npm dependencies (first time only)
export GEMINI_API_KEY=your-key   # optional; omit it to use curriculum templates
jac run --dev main.jac
```

Then open http://localhost:8000. In dev mode the UI is served on port 8000 with hot reload, and the API on port 8001.

### Production, sandboxes and proxies

Dev mode depends on a Vite hot-reload websocket. Behind a proxy that doesn't forward it (common in cloud sandboxes), the page reloads in a loop, and the log fills with `GET /__build_status` and repeated `seed_kicd_graph` / `list_grades` calls. Build and serve a sealed bundle instead:

```bash
cd app
jac build                        # writes dist/msingi-ai.jab
jac run dist/msingi-ai.jab       # serves UI and API together on port 8000
```

A bare `jac run` (or `jac run main.jac --no-dev`) still starts in dev mode for this project, so run the `.jab` bundle. Rebuild after every code change.

The curriculum graph and demo people (a teacher, plus one learner and one parent per grade) are created automatically on first use. **Reset demo data** in the sidebar wipes saved plans and tutor chats and rebuilds the graph.

## Configuration

| Setting | Where | Default |
|---|---|---|
| LLM model | `[byllm.model] default_model` in `app/jac.toml`, or the `BYLLM_DEFAULT_MODEL` env var | `gemini/gemini-3.8-flash` |
| Provider key | `GEMINI_API_KEY` (or `GOOGLE_API_KEY`); Anthropic and OpenAI keys also work with a matching model | none (template mode) |
| Force template mode | `MSINGI_OFFLINE=1` | off |

Model names are passed to LiteLLM, so any model id LiteLLM supports will work, including `ollama/...` for local models.

## Project structure

```
app/
├── main.jac              entry point: registers the server walkers, mounts the UI
├── endpoints.jac         walker:pub endpoints (POST /walker/<name>) and agent runners
├── models.jac            graph nodes and edges, read models, LLM output types
├── agents.jac            byLLM agent functions (lesson plan, materials, revision, tutor, parent guide)
├── templates.jac         curriculum-grounded fallbacks used without an LLM
├── retrieval.jac         keyword retrieval of sub-strands for grounding
├── seed_data.jac         KICD curriculum and demo people for the five grades
├── utils.jac             dash scrubbing, JSON helpers, LLM gating, term week windows
├── shell/                app shell: sidebar, header, grade tabs, overview, status banner
├── teacher/ learner/ parent/   one component per tool, grouped by workspace
├── shared/               UI kit, constants, browser helpers, curriculum picker hook
├── assets/main.css       Tailwind v4 theme (sage, eucalyptus, slate teal, ochre)
├── tests/                Jac tests (MockLLM, no key needed)
└── scripts/smoke_test.py end-to-end API check across every walker and grade
```

### API

Each walker is also a plain REST endpoint. The JSON body sets the walker's fields, and the results come back in `data.reports`:

| Walker | Purpose |
|---|---|
| `seed_kicd_graph` | Build the graph (idempotent; `reset: true` rebuilds it) |
| `list_grades`, `get_curriculum` | Grade summaries and the full curriculum tree for one grade |
| `generate_lesson_plan` | Teacher lesson plan with KNEC rubric |
| `plan_class_materials` | Local material list scaled to class size |
| `build_revision_and_materials` | Learner revision calendar plus material checklist |
| `socratic_tutor` | One tutor turn; pass back `session_id` to continue a chat |
| `translate_for_parent` | Plain-language guide; `broadcast: true` saves it for parents |
| `list_plans`, `get_learner_progress` | Saved plans and the learner's progress record |

```bash
curl -X POST localhost:8001/walker/get_curriculum \
  -H 'Content-Type: application/json' -d '{"grade_level": "Grade 6"}'
```

## Testing

```bash
cd app
jac test tests/test_agents.jac             # agent path with a mock LLM
python3 scripts/smoke_test.py http://localhost:8001   # needs the dev server running
jac check main.jac                         # type-check
```

## Notes for contributors

- Run `jac guide` before editing `.jac` files. Jac syntax looks like Python and JSX but has its own rules (see `app/AGENTS.md`).
- **Don't move or rename `models.jac`.** Persisted nodes are tied to the module path that declares them, so moving it orphans existing graph data.
- Agent output must not contain em or en dashes. `utils.scrub` removes them, and the smoke test fails if any appear.
- Workarounds for three Jac 0.37.25 compiler issues:
  - The enums in `models.jac` are pinned to the server in `[placement.pins]`; otherwise they are emitted twice in the client bundle.
  - In components that spawn walkers, model types are imported with a `Data` suffix (e.g. `GradeSummaryData`) so they don't collide with the wire classes the compiler generates.
  - Client code updates dicts with a variable key using subscript assignment, because `{**d, key: v}` compiles to a fixed key named `key`.

## License

Released under the [MIT License](LICENSE).
