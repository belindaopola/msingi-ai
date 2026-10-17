<!-- By Mara Msingi -->
# Msingi AI

A companion for Kenya's Competency-Based Education (CBE), with separate workspaces for teachers, learners and parents. It covers the five KICD benchmark grades: PP2, Grade 3, Grade 6, Grade 9 and Grade 12.

Msingi AI is a single full-stack [Jac](https://www.jaseci.org/) app. The server keeps the KICD curriculum as a graph (grade, then learning area, then strand, then sub-strand) and runs AI agents over it with Google Gemini. The browser UI is also written in Jac and compiles to React.

> Curriculum content is illustrative and modelled on KICD CBE designs. Always confirm against the official curriculum designs.

## Features

| Workspace | Tools |
|---|---|
| **Teacher** | KICD lesson plan generator (SLOs, inquiry questions, competencies, values, PCIs, timed steps and a 4-tier KNEC rubric) · Locally available material planner · Parent broadcast |
| **Learner** | Termly revision calendar · Practical material checklist · Mwalimu Taratibu, a tutor that guides with questions instead of giving answers |
| **Parent** | Plain-language CBE translator (English or Kiswahili) · Home activity guide · Holistic progress tracker using KNEC levels |

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
jac build                        # writes dist/msingi-ai.jab (dist/ is not committed)
jac run dist/msingi-ai.jab       # serves UI and API together on port 8000
```

If `jac build` reports "Built template package `dist/msingi-ai-.jab`" (about 60 KB) instead of the app bundle (about 1.8 MB), the `[jacpack]` section in `app/jac.toml`, which the Jac IDE adds, has switched it to template packaging. Build without that section to get the app bundle.

Set your own sign-in secret before serving, for example `export JAC_SERVE_AUTH_SECRET=$(openssl rand -hex 32)` (or `[serve.auth] secret` in `jac.toml`). Without it, a cluster deployment falls back to a known placeholder key and anyone could forge sign-in tokens.

A bare `jac run` (or `jac run main.jac --no-dev`) still starts in dev mode for this project, so run the `.jab` bundle. Rebuild after every code change.

## Accounts and data

Everyone signs in. The first visit goes to `/account`, where people create an account with their name, email, password, role (Teacher, Learner or Parent) and grade. The role and grade decide which workspace opens. An account that signs in without a profile is asked to finish setting up before the workspace opens.

Each account has its own private graph. On first use it gets its own copy of the KICD curriculum and demo people (a teacher, plus one learner and one parent per grade), and its saved plans, tutor chats and checklist ticks are visible only to that account.

The one exception is **parent broadcasts**. When a teacher sends one, it's pinned to a shared per-grade board on `root.shared`, so every parent account in that grade sees it under "From your child's teacher". Broadcasts are signed with the teacher's account name. Linking parents to their own learner's progress isn't built yet; the progress tracker shows the demo learner.

### Sample accounts

With the server running, `python3 scripts/seed_accounts.py http://localhost:8001` (from `app/`) creates a teacher, learner and parent account for every grade. The password for all of them is `MsingiDemo2026` (override with `MSINGI_DEMO_PASSWORD`). The script is safe to re-run and never changes other accounts.

| Grade | Teacher | Learner | Parent |
|---|---|---|---|
| PP2 | faith@msingiaike.com | amani@msingiaike.com | grace@msingiaike.com |
| Grade 3 | peter@msingiaike.com | baraka@msingiaike.com | christine@msingiaike.com |
| Grade 6 | mercy@msingiaike.com | imani@msingiaike.com | daniel@msingiaike.com |
| Grade 9 | john@msingiaike.com | kevin@msingiaike.com | lucy@msingiaike.com |
| Grade 12 | esther@msingiaike.com | zawadi@msingiaike.com | ouma@msingiaike.com |

Learners and parents match each grade's demo family, so the progress tracker shows the right child.

### All-workspace access

An account with the **ALL** role gets a Teacher / Learner / Parent switcher in the header. The sign-up form can't assign it; the server only grants it with a secret code it was started with. In one terminal:

```bash
cd app
export MSINGI_ALL_ACCESS_CODE=$(openssl rand -hex 32)
echo $MSINGI_ALL_ACCESS_CODE     # copy for the second terminal
jac run --dev main.jac
```

In a second terminal, once the server is ready:

```bash
cd app
MSINGI_ALL_ACCESS_CODE=<the code> python3 scripts/add_all_access_user.py "Full Name" you@msingiaike.com http://localhost:8001
```

The script asks for the account's password. For an existing account, enter its current password: it is kept, and the account is upgraded. Without `MSINGI_ALL_ACCESS_CODE` on the server, nobody can be granted the ALL role; existing ALL accounts keep their access. Codes containing `!` must be in single quotes, because bash treats `!` specially.

### Admin portal and metrics

Jac's built-in platform admin portal (users, roles, logs, metrics and a graph browser) is separate from the Msingi workspaces. In dev mode it's on the API port at http://localhost:8001/admin/; when serving the bundle it's at http://localhost:8000/admin/. The first local start creates the user `admin` with password `changeme`, which you must change at first sign-in. Promote any account to admin from the Users page.

Metrics are enabled with `[scale.monitoring] enabled = true` in `app/jac.toml`. Add `walker_metrics = true` for per-endpoint timings.

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
├── endpoints.jac         walker endpoints (POST /walker/<name>), account functions, agent runners
├── models.jac            graph nodes and edges, read models, LLM output types
├── agents.jac            byLLM agent functions (lesson plan, materials, revision, tutor, parent guide)
├── templates.jac         curriculum-grounded fallbacks used without an LLM
├── retrieval.jac         keyword retrieval of sub-strands for grounding
├── seed_data.jac         KICD curriculum and demo people for the five grades
├── utils.jac             dash scrubbing, JSON helpers, LLM gating, term week windows
├── account/              sign-up, sign-in and profile setup page
├── shell/                app shell: sidebar, header, grade tabs, overview, status banner
├── teacher/ learner/ parent/   one component per tool, grouped by workspace
├── shared/               UI kit, constants, browser helpers, curriculum picker hook
├── assets/main.css       Tailwind v4 theme (sage, eucalyptus, slate teal, ochre)
├── tests/                Jac tests (MockLLM, no key needed)
└── scripts/
    ├── smoke_test.py          end-to-end API check across every walker and grade
    ├── seed_accounts.py       sample teacher, learner and parent accounts
    └── add_all_access_user.py create or upgrade an all-workspace account
```

### API

Each walker is also a plain REST endpoint. The JSON body sets the walker's fields, and the results come back in `data.reports`. `seed_kicd_graph`, `list_grades` and `get_curriculum` are public; everything else requires a signed-in account and returns 401 without one:

| Walker | Purpose |
|---|---|
| `seed_kicd_graph` | Build the graph (idempotent; `reset: true` rebuilds it) |
| `list_grades`, `get_curriculum` | Grade summaries and the full curriculum tree for one grade |
| `generate_lesson_plan` | Teacher lesson plan with KNEC rubric |
| `plan_class_materials` | Local material list scaled to class size |
| `build_revision_and_materials` | Learner revision calendar plus material checklist |
| `socratic_tutor` | One tutor turn; pass back `session_id` to continue a chat |
| `translate_for_parent` | Plain-language guide; `broadcast: true` saves it for parents |
| `list_plans`, `get_learner_progress` | Saved plans (broadcasts come from the shared grade board) and the learner's progress record |

Account functions are served at `POST /function/<name>`: `get_current_session`, `set_account_profile`, `save_checklist_progress` and `grant_all_workspaces` (needs the server's access code).

```bash
# Register and sign in, then send the token as a Bearer header
curl -X POST localhost:8001/user/register -H 'Content-Type: application/json' \
  -d '{"identities": [{"type": "email", "value": "me@example.com"}], "credential": {"type": "password", "password": "secret123"}}'
TOKEN=$(curl -s -X POST localhost:8001/user/login -H 'Content-Type: application/json' \
  -d '{"identity": {"type": "email", "value": "me@example.com"}, "credential": {"type": "password", "password": "secret123"}}' \
  | python3 -c 'import sys, json; print(json.load(sys.stdin)["data"]["token"])')

curl -X POST localhost:8001/walker/list_plans -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' -d '{"grade_level": "Grade 6"}'
```

## Testing

```bash
cd app
jac test tests/test_agents.jac             # agent path with a mock LLM
python3 scripts/smoke_test.py http://localhost:8001   # needs the dev server; registers a throwaway account
jac check main.jac                         # type-check
```

## Notes for contributors

- Run `jac guide` before editing `.jac` files. Jac syntax looks like Python and JSX but has its own rules (see `app/AGENTS.md`).
- **Don't move or rename `models.jac`.** Persisted nodes are tied to the module path that declares them, so moving it orphans existing graph data.
- Access levels: `:pub` is public, `:protect` requires sign-in and runs on the caller's own graph, and `:priv` (or no marker) is **never served**, so the browser can't call it. Endpoints the UI uses must be `:pub` or `:protect`.
- There are no `sv`/`cl` placement markers in this Jac version. Use plain `import`; placement is inferred.
- Workspace roles are enforced in the UI only: any signed-in account can call any `:protect` endpoint through the API.
- In production, set `[serve.auth] secret` (or `JAC_SERVE_AUTH_SECRET`) so sign-in tokens are signed with your own key.
- Agent output must not contain em or en dashes. `utils.scrub` removes them, and the smoke test fails if any appear.
- Workarounds for three Jac 0.37.25 compiler issues:
  - The enums in `models.jac` are pinned to the server in `[placement.pins]`; otherwise they are emitted twice in the client bundle.
  - In components that spawn walkers, model types are imported with a `Data` suffix (e.g. `GradeSummaryData`) so they don't collide with the wire classes the compiler generates.
  - Client code updates dicts with a variable key using subscript assignment, because `{**d, key: v}` compiles to a fixed key named `key`.

## License

Released under the [MIT License](LICENSE).
