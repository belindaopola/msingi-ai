"""Msingi AI: full-stack Jac app.

Server: the KICD curriculum graph and agent walkers live in `endpoints.jac`
(each `walker:pub` is served at `POST /walker/<name>`).
Client: the React UI is written in Jac under `shell/`, `teacher/`, `learner/`,
`parent/` and `shared/`, and calls the walkers with `root spawn`.
"""

import from endpoints {
    seed_kicd_graph, list_grades, get_curriculum, generate_lesson_plan,
    plan_class_materials, build_revision_and_materials, socratic_tutor,
    translate_for_parent, list_plans, get_learner_progress
}

import "./assets/main.css";
import from .shell.AppShell { AppShell }

def:pub app -> JsxElement {
    <AppShell/>
}
