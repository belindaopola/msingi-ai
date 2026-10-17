"""Msingi AI server: KICD curriculum graph + multi-agent walkers.

Every `walker:pub` below is a REST endpoint at `POST /walker/<name>`, with its
`has` fields as the JSON body and its `report`s in `data.reports`.

Core agent walkers:
    seed_kicd_graph              build the KICD graph for the 5 benchmark grades
    generate_lesson_plan         Teacher: KICD lesson plan + 4-tier KNEC rubric
    build_revision_and_materials Learner: termly revision calendar + material checklist
    socratic_tutor               Learner: guided Q and A that never gives answers away
    translate_for_parent         Parent: jargon-free home support from teacher updates

Supporting walkers for the UI:
    list_grades, get_curriculum, plan_class_materials, list_plans, get_learner_progress

Agents run through byLLM when a provider key is configured, otherwise they fall
back to curriculum-grounded templates (`source` is "AI" or "TEMPLATE").
"""

import os;
import hmac;
import from uuid { uuid4 }
import from models {
    BENCHMARK_GRADES, Role, CurriculumLevel, PlanType,
    GradeNode, CurriculumNode, UserNode, AccountProfile, AccountSession, BroadcastBoard, PlanNode, TutorSessionNode,
    HasArea, HasPart, EnrolledIn, ParentOf, Assessed, GradePlan, Covers, HasSession,
    GradeSummary, CurriculumBranch, GradeCurriculum, SeedSummary, PlanSummary,
    AreaProgress, LearnerProgress,
    LessonPlan, MaterialItem, WeekSlot, RevisionPlan, TutorReply, ParentGuide,
    LessonPlanResult, MaterialPlanResult, RevisionResult, ChatTurn, TutorTurnResult,
    ParentGuideResult
}
import from seed_data { KICD_SEED, DEMO_TEACHER, KNEC_LEVELS, KNEC_SCORES }
import from retrieval {
    sub_strands_of, lineage, retrieve, context_block, grade_profile
}
import from agents {
    draft_lesson_plan, draft_class_materials, draft_revision_plan, tutor_turn,
    draft_parent_guide
}
import from templates {
    fallback_lesson_plan, materials_from, fallback_revision_plan,
    fallback_tutor_reply, fallback_parent_guide
}
import from utils { scrub, to_json, now_iso, llm_enabled, week_windows }


node ChecklistProgress {
    has plan_id: str,
        grade_code: str,
        checked: dict[str, bool] = {};
}

# =============================== account profile

def:protect get_current_session() -> AccountSession | None {
    profiles = [root -->][?:AccountProfile];
    if not profiles {
        return None;
    }
    profile = profiles[0];
    return AccountSession(
        display_name=profile.display_name,
        email=profile.email,
        app_role=profile.app_role,
        grade_code=profile.grade_code
    );
}

def:protect set_account_profile(display_name: str, email: str, app_role: str, grade_code: str) -> AccountSession {
    allowed_roles = ["TEACHER", "LEARNER", "PARENT"];
    if app_role not in allowed_roles {
        raise ValueError("Choose Teacher, Learner, or Parent.");
    }
    if grade_code not in BENCHMARK_GRADES {
        raise ValueError("Choose a supported benchmark grade.");
    }
    profiles = [root -->][?:AccountProfile];
    if profiles {
        profile = profiles[0];
        profile.display_name = display_name.strip();
        profile.email = email.strip().lower();
        profile.app_role = app_role;
        profile.grade_code = grade_code;
    } else {
        profile = root ++> AccountProfile(
            display_name=display_name.strip(),
            email=email.strip().lower(),
            app_role=app_role,
            grade_code=grade_code
        );
    }
    return AccountSession(
        display_name=profile.display_name,
        email=profile.email,
        app_role=profile.app_role,
        grade_code=profile.grade_code
    );
}

"""Give the caller's account the ALL role (every workspace). Needs the server's MSINGI_ALL_ACCESS_CODE;
with no code configured it always refuses, and the public sign-up form cannot set ALL."""
def:protect grant_all_workspaces(access_code: str) -> AccountSession {
    expected = os.environ.get("MSINGI_ALL_ACCESS_CODE", "");
    if not expected or not hmac.compare_digest(access_code.encode(), expected.encode()) {
        raise PermissionError("All-workspace access is not available for this account.");
    }
    profiles = [root -->][?:AccountProfile];
    if not profiles {
        raise ValueError("Create the account profile first.");
    }
    profile = profiles[0];
    profile.app_role = "ALL";
    return AccountSession(
        display_name=profile.display_name,
        email=profile.email,
        app_role=profile.app_role,
        grade_code=profile.grade_code
    );
}

def:protect save_checklist_progress(plan_id: str, grade_code: str, item: str, is_checked: bool) -> dict[str, bool] {
    if grade_code not in BENCHMARK_GRADES or not item {
        raise ValueError("Checklist item and a supported grade are required.");
    }
    rows = [root -->][?:ChecklistProgress];
    matching = [r for r in rows if r.plan_id == plan_id and r.grade_code == grade_code];
    row = matching[0] if matching else root ++> ChecklistProgress(plan_id=plan_id, grade_code=grade_code);
    updated = {**row.checked};
    updated[item] = is_checked;
    row.checked = updated;
    return updated;
}

"""The signed-in account's display name, else the name the client sent."""
def account_name(fallback: str) -> str {
    profiles = [root -->][?:AccountProfile];
    return profiles[0].display_name if profiles and profiles[0].display_name else fallback;
}

"""The grade's broadcast board on the shared graph; every signed-in teacher may attach to it."""
def broadcast_board(code: str) -> BroadcastBoard {
    boards = [root.shared -->[?:BroadcastBoard, grade_code == code]];
    if boards {
        return boards[0];
    }
    board = root.shared ++> BroadcastBoard(grade_code=code);
    grant(board, level=AccessLevel.CONNECT);
    return board;
}

# =============================== graph building

def spec_for(code: str) -> dict[str, any] {
    for spec in KICD_SEED {
        if spec["code"] == code {
            return spec;
        }
    }
    raise ValueError(f"No seed data for grade '{code}'.");
}

def make_grade(spec: dict[str, any]) -> GradeNode {
    return GradeNode(
        code=spec["code"],
        label=spec["label"],
        stage=spec["stage"],
        age_range=spec["age_range"],
        assessment=spec["assessment"],
        focus=spec["focus"],
        order=spec["order"],
        lesson_minutes=spec["lesson_minutes"],
        daily_study_minutes=spec["daily_study_minutes"],
        learner_profile=spec["learner_profile"]
    );
}

"""Attach learning areas, strands and sub-strands under a grade. Returns nodes created."""
def build_curriculum(g: GradeNode, spec: dict[str, any]) -> int {
    created = 0;
    for a in spec["areas"] {
        area = CurriculumNode(
            kind=CurriculumLevel.LEARNING_AREA,
            name=a["name"],
            grade_code=g.code,
            pathway=a.get("pathway", ""),
            description=a.get("description", "")
        );
        g +>:HasArea():+> area;
        created += 1;
        for s in a["strands"] {
            strand = CurriculumNode(
                kind=CurriculumLevel.STRAND,
                name=s["name"],
                grade_code=g.code,
                pathway=area.pathway,
                core_competencies=s["core_competencies"],
                values=s["values"],
                pcis=s["pcis"]
            );
            area +>:HasPart():+> strand;
            created += 1;
            for ss in s["sub_strands"] {
                sub = CurriculumNode(
                    kind=CurriculumLevel.SUB_STRAND,
                    name=ss["name"],
                    grade_code=g.code,
                    pathway=area.pathway,
                    specific_learning_outcomes=ss["slos"],
                    key_inquiry_questions=ss["kiqs"],
                    learning_experiences=ss["experiences"],
                    resources=ss["resources"],
                    local_materials=ss["local_materials"],
                    home_activity=ss["home_activity"]
                );
                strand +>:HasPart():+> sub;
                created += 1;
            }
        }
    }
    return created;
}

"""Create the demo learner, parent and progress record for a grade, and link the teacher."""
def build_people(g: GradeNode, spec: dict[str, any], teacher: UserNode) -> int {
    info = spec["learner"];
    learner = UserNode(
        name=info["name"],
        role=Role.LEARNER,
        grade_code=g.code,
        school=DEMO_TEACHER["school"],
        county=DEMO_TEACHER["county"],
        competency_scores=info["competencies"],
        values_observed=info["values"],
        teacher_note=info["teacher_note"]
    );
    parent = UserNode(
        name=info["parent"],
        role=Role.PARENT,
        grade_code=g.code,
        county=DEMO_TEACHER["county"]
    );
    learner +>:EnrolledIn():+> g;
    parent +>:ParentOf():+> learner;
    teacher +>:EnrolledIn():+> g;
    for row in info["progress"] {
        (area_name, code, comment) = (row[0], row[1], row[2]);
        for area in [g ->:HasArea:->[?:CurriculumNode, name == area_name]] {
            learner +>:Assessed(learning_area=area_name, level_code=code, score=KNEC_SCORES[code], comment=comment):+> area;
        }
    }
    return 2;
}

def find_teacher(r: Root) -> UserNode {
    found = [r -->[?:UserNode, role == Role.TEACHER]];
    if found {
        return found[0];
    }
    return r ++> UserNode(
        name=DEMO_TEACHER["name"],
        role=Role.TEACHER,
        school=DEMO_TEACHER["school"],
        county=DEMO_TEACHER["county"]
    );
}

"""Remove every Msingi node hanging off this root (grades, curriculum, people, plans, sessions)."""
def purge_graph(r: Root) {
    for g in [r -->[?:GradeNode]] {
        for n in [g ->:HasArea:-> ->:HasPart:-> ->:HasPart:->] { del n; }
        for n in [g ->:HasArea:-> ->:HasPart:->] { del n; }
        for n in [g ->:HasArea:->] { del n; }
        for n in [g ->:GradePlan:->] { del n; }
        for n in [g ->:HasSession:->] { del n; }
        for learner in [g <-:EnrolledIn:<-[?:UserNode, role == Role.LEARNER]] {
            for p in [learner <-:ParentOf:<-] { del p; }
            del learner;
        }
        del g;
    }
    for t in [r -->[?:UserNode]] { del t; }
}

def summarize(r: Root, status: str) -> SeedSummary {
    grades = [r -->[?:GradeNode]];
    nodes = [r -->[?:GradeNode] ->:HasArea:->];
    nodes += [r -->[?:GradeNode] ->:HasArea:-> ->:HasPart:->];
    nodes += [r -->[?:GradeNode] ->:HasArea:-> ->:HasPart:-> ->:HasPart:->];
    users = [r -->[?:GradeNode] <-:EnrolledIn:<-];
    return SeedSummary(
        status=status,
        grades=[g.code for g in sorted(grades, key=lambda (g: GradeNode) -> int { return g.order; })],
        curriculum_nodes=len(nodes),
        users=len(users) + len([r -->[?:GradeNode] <-:EnrolledIn:<- <-:ParentOf:<-])
    );
}

"""Seed without a walker, for endpoints called before `seed_kicd_graph`."""
def ensure_seeded(r: Root) {
    if [r -->[?:GradeNode]] {
        return;
    }
    teacher = find_teacher(r);
    for spec in KICD_SEED {
        g = r ++> make_grade(spec);
        build_curriculum(g, spec);
        build_people(g, spec, teacher);
    }
}

def grade_of(n: CurriculumNode) -> GradeNode {
    current = n;
    while current.kind != CurriculumLevel.LEARNING_AREA {
        parents = [current <-:HasPart:<-];
        if not parents {
            break;
        }
        current = parents[0];
    }
    return [current <-:HasArea:<-][0];
}

def learner_of(g: GradeNode) -> UserNode | None {
    learners = [g <-:EnrolledIn:<-[?:UserNode, role == Role.LEARNER]];
    return learners[0] if learners else None;
}

def save_plan(
    g: GradeNode, plan_type: PlanType, title: str, payload: any, source: str,
    learning_area: str = "", strand: str = "", author: str = "",
    covers: list[CurriculumNode] = []
) -> PlanNode {
    pn = PlanNode(
        plan_type=plan_type,
        title=title,
        grade_code=g.code,
        learning_area=learning_area,
        strand=strand,
        author=author,
        source=source,
        created_at=now_iso(),
        payload_json=to_json(payload)
    );
    g +>:GradePlan():+> pn;
    for c in covers {
        pn +>:Covers():+> c;
    }
    return pn;
}


# ===================================================================== agent runners
# Each runner tries the byLLM agent, scrubs any stray dashes, and falls back to
# the curriculum template. Returns (result, source).

def run_lesson_agent(
    g: GradeNode, sub: CurriculumNode, duration: int, class_size: int, notes: str
) -> tuple[LessonPlan, str] {
    if llm_enabled() {
        try {
            plan = draft_lesson_plan(grade_profile(g), context_block(sub), duration, class_size, notes);
            return (scrub(plan) as LessonPlan, "AI");
        } except Exception as e {
            print(f"[msingi] lesson agent fell back to template: {e}");
        }
    }
    return (scrub(fallback_lesson_plan(g, sub, duration, class_size)) as LessonPlan, "TEMPLATE");
}

def run_materials_agent(
    g: GradeNode, subs: list[CurriculumNode], class_size: int
) -> tuple[list[MaterialItem], str] {
    if llm_enabled() {
        try {
            context = "\n\n".join([context_block(s) for s in subs]);
            items = draft_class_materials(grade_profile(g), context, class_size);
            return (scrub(items) as list[MaterialItem], "AI");
        } except Exception as e {
            print(f"[msingi] materials agent fell back to template: {e}");
        }
    }
    return (scrub(materials_from(subs, class_size)) as list[MaterialItem], "TEMPLATE");
}

def run_revision_agent(
    g: GradeNode, learner_name: str, slots: list[WeekSlot], subs: list[CurriculumNode], daily_minutes: int
) -> tuple[RevisionPlan, str] {
    if llm_enabled() {
        try {
            context = "\n\n".join([context_block(s) for s in subs]);
            plan = draft_revision_plan(grade_profile(g), learner_name, slots, context, daily_minutes);
            return (scrub(plan) as RevisionPlan, "AI");
        } except Exception as e {
            print(f"[msingi] revision agent fell back to template: {e}");
        }
    }
    return (scrub(fallback_revision_plan(g, learner_name, slots, subs, daily_minutes)) as RevisionPlan, "TEMPLATE");
}

def run_tutor_agent(
    g: GradeNode, transcript: str, message: str, turn_number: int, retrieved: list[CurriculumNode]
) -> tuple[TutorReply, str] {
    if llm_enabled() {
        try {
            context = "\n\n".join([context_block(s) for s in retrieved]);
            reply = tutor_turn(grade_profile(g), context, transcript, message, turn_number);
            return (scrub(reply) as TutorReply, "AI");
        } except Exception as e {
            print(f"[msingi] tutor agent fell back to template: {e}");
        }
    }
    return (scrub(fallback_tutor_reply(g, message, turn_number, retrieved)) as TutorReply, "TEMPLATE");
}

def run_parent_agent(
    g: GradeNode, update: str, child_name: str, language: str, retrieved: list[CurriculumNode]
) -> tuple[ParentGuide, str] {
    if llm_enabled() {
        try {
            context = "\n\n".join([context_block(s) for s in retrieved]);
            guide = draft_parent_guide(grade_profile(g), update, context, child_name, language);
            return (scrub(guide) as ParentGuide, "AI");
        } except Exception as e {
            print(f"[msingi] parent agent fell back to template: {e}");
        }
    }
    return (scrub(fallback_parent_guide(g, update, child_name, retrieved)) as ParentGuide, "TEMPLATE");
}


# ===================================================================== walkers

walker:pub seed_kicd_graph {
    """Populate the KICD graph for PP2, Grade 3, Grade 6, Grade 9 and Grade 12 (idempotent unless reset)."""
    has reset: bool = False;
    has reports: list[SeedSummary] = [];

    can start with Root entry {
        if [here -->[?:GradeNode]] {
            if not self.reset {
                report summarize(here, "already_seeded");
                disengage;
            }
            purge_graph(here);
        }
        find_teacher(here);
        for spec in KICD_SEED {
            here ++> make_grade(spec);
        }
        visit [here -->[?:GradeNode]];
    }

    can build with GradeNode entry {
        spec = spec_for(here.code);
        build_curriculum(here, spec);
        build_people(here, spec, find_teacher(root));
    }

    can finish with Root exit {
        report summarize(here, "seeded");
    }
}

"""Shared locator: resolve `grade_level` to its GradeNode (seeding on first use) and visit it."""
walker grade_walker {
    has grade_level: str;

    can locate with Root entry {
        ensure_seeded(here);
        wanted = self.grade_level;
        visit [here -->[?:GradeNode, code == wanted]] else {
            raise ValueError(f"Unknown grade level '{wanted}'. Use one of: {', '.join(BENCHMARK_GRADES)}.");
        }
    }
}

walker:pub list_grades {
    """List the five benchmark grades with their learning areas, in curriculum order."""
    has reports: list[GradeSummary] = [];

    can start with Root entry {
        ensure_seeded(here);
        visit [here -->[?:GradeNode, order]];
    }

    can collect with GradeNode entry {
        report GradeSummary(
            code=here.code,
            label=here.label,
            stage=here.stage,
            age_range=here.age_range,
            assessment=here.assessment,
            focus=here.focus,
            order=here.order,
            lesson_minutes=here.lesson_minutes,
            daily_study_minutes=here.daily_study_minutes,
            learning_areas=[a.name for a in [here ->:HasArea:->]]
        );
    }
}

def branch(n: CurriculumNode) -> CurriculumBranch {
    return CurriculumBranch(
        id=jid(n),
        kind=n.kind,
        name=n.name,
        pathway=n.pathway,
        description=n.description,
        specific_learning_outcomes=n.specific_learning_outcomes,
        key_inquiry_questions=n.key_inquiry_questions,
        core_competencies=n.core_competencies,
        values=n.values,
        pcis=n.pcis,
        learning_experiences=n.learning_experiences,
        resources=n.resources,
        local_materials=n.local_materials,
        home_activity=n.home_activity,
        children=[branch(c) for c in [n ->:HasPart:->]]
    );
}

walker:pub get_curriculum(grade_walker) {
    """Return a grade's full learning area > strand > sub-strand tree."""
    has reports: list[GradeCurriculum] = [];

    can collect with GradeNode entry {
        report GradeCurriculum(
            grade=GradeSummary(
                code=here.code,
                label=here.label,
                stage=here.stage,
                age_range=here.age_range,
                assessment=here.assessment,
                focus=here.focus,
                order=here.order,
                lesson_minutes=here.lesson_minutes,
                daily_study_minutes=here.daily_study_minutes,
                learning_areas=[a.name for a in [here ->:HasArea:->]]
            ),
            areas=[branch(a) for a in [here ->:HasArea:->]]
        );
    }
}

walker:protect generate_lesson_plan(grade_walker) {
    """Teacher agent: traverse grade > learning area > strand and draft a KICD lesson plan."""
    has learning_area: str;
    has strand: str;
    has sub_strand: str = "";
    has duration_minutes: int = 0;
    has class_size: int = 40;
    has teacher_name: str = "";
    has teacher_notes: str = "";
    has reports: list[LessonPlanResult] = [];

    can to_area with GradeNode entry {
        wanted = self.learning_area;
        visit [here ->:HasArea:->[?:CurriculumNode, name == wanted]] else {
            raise ValueError(f"'{wanted}' is not a learning area in {here.label}.");
        }
    }

    can to_strand with CurriculumNode entry {
        if here.kind == CurriculumLevel.LEARNING_AREA {
            wanted = self.strand;
            visit [here ->:HasPart:->[?:CurriculumNode, name == wanted]] else {
                raise ValueError(f"'{wanted}' is not a strand of {here.name}.");
            }
            skip;
        }
        if here.kind != CurriculumLevel.STRAND {
            skip;
        }
        subs = [here ->:HasPart:->[?:CurriculumNode]];
        picked = [s for s in subs if s.name == self.sub_strand];
        sub = picked[0] if picked else subs[0];
        g = grade_of(here);
        duration = self.duration_minutes if self.duration_minutes > 0 else g.lesson_minutes;
        (plan, source) = run_lesson_agent(g, sub, duration, self.class_size, self.teacher_notes);
        pn = save_plan(
            g, PlanType.LESSON_PLAN, plan.title, plan, source,
            learning_area=self.learning_area, strand=here.name,
            author=account_name(self.teacher_name), covers=[sub]
        );
        report LessonPlanResult(plan_id=jid(pn), source=source, plan=plan);
    }
}

walker:protect plan_class_materials(grade_walker) {
    """Teacher agent: locally available material planner for a learning area (optionally one strand)."""
    has learning_area: str;
    has strand: str = "";
    has class_size: int = 40;
    has teacher_name: str = "";
    has reports: list[MaterialPlanResult] = [];

    can to_area with GradeNode entry {
        wanted = self.learning_area;
        visit [here ->:HasArea:->[?:CurriculumNode, name == wanted]] else {
            raise ValueError(f"'{wanted}' is not a learning area in {here.label}.");
        }
    }

    can plan with CurriculumNode entry {
        subs = [here ->:HasPart:-> ->:HasPart:->[?:CurriculumNode]];
        if self.strand {
            subs = [s for s in subs if lineage(s)[1] == self.strand] or subs;
        }
        g = grade_of(here);
        (items, source) = run_materials_agent(g, subs, self.class_size);
        save_plan(
            g, PlanType.MATERIAL_CHECKLIST, f"{here.name} materials for {self.class_size} learners",
            items, source, learning_area=here.name, strand=self.strand,
            author=account_name(self.teacher_name), covers=subs
        );
        report MaterialPlanResult(
            source=source, grade_level=g.code, learning_area=here.name,
            class_size=self.class_size, materials=items
        );
    }
}

"""Interleave (area, strand) pairs across learning areas, focus areas first."""
def revision_order(g: GradeNode, focus: list[str]) -> list[tuple[str, str]] {
    areas = [g ->:HasArea:->];
    areas = sorted(areas, key=lambda (a: CurriculumNode) -> int { return 0 if a.name in focus else 1; });
    columns = [[(a.name, s.name) for s in [a ->:HasPart:->]] for a in areas];
    ordered: list[tuple[str, str]] = [];
    depth = max([len(c) for c in columns]) if columns else 0;
    for i in range(depth) {
        for col in columns {
            if i < len(col) {
                ordered.append(col[i]);
            }
        }
    }
    return ordered;
}

walker:protect build_revision_and_materials(grade_walker) {
    """Learner agent: termly revision calendar plus a practical material collection checklist."""
    has term_start: str;
    has term_end: str;
    has learner_name: str = "";
    has focus_areas: list[str] = [];
    has daily_minutes: int = 0;
    has reports: list[RevisionResult] = [];

    can plan with GradeNode entry {
        learner = learner_of(here);
        name = self.learner_name or (learner.name.split(" ")[0] if learner else "Learner");
        focus = self.focus_areas;
        if not focus and learner {
            # Default to the areas the learner's progress record flags as AE or BE.
            focus = [e.learning_area for e in [edge learner ->:Assessed:->] if e.score <= 2];
        }
        pairs = revision_order(here, focus);
        windows = week_windows(self.term_start, self.term_end);
        slots: list[WeekSlot] = [];
        for (i, (start, end)) in enumerate(windows) {
            is_review = len(windows) >= 3 and i == len(windows) - 1;
            (area, strand) = ("All Learning Areas", "Term Review") if is_review or not pairs else pairs[i % len(pairs)];
            slots.append(WeekSlot(week_number=i + 1, start_date=start, end_date=end, learning_area=area, strand=strand));
        }
        planned = {s.strand for s in slots};
        subs = [s for s in sub_strands_of(here) if lineage(s)[1] in planned];
        minutes = self.daily_minutes if self.daily_minutes > 0 else here.daily_study_minutes;
        (plan, source) = run_revision_agent(here, name, slots, subs, minutes);
        pn = save_plan(here, PlanType.REVISION_SCHEDULE, plan.title, plan, source, author=name, covers=subs);
        report RevisionResult(plan_id=jid(pn), source=source, plan=plan);
    }
}

walker:protect socratic_tutor(grade_walker) {
    """Learner agent: Socratic Q and A grounded in retrieved KICD sub-strands; never gives direct answers."""
    has message: str;
    has learner_name: str = "";
    has learning_area: str = "";
    has session_id: str = "";
    has reports: list[TutorTurnResult] = [];

    can to_session with GradeNode entry {
        wanted = self.session_id;
        visit [here ->:HasSession:->[?:TutorSessionNode, sid == wanted]] else {
            fresh = TutorSessionNode(
                sid=uuid4().hex,
                learner_name=self.learner_name or "Learner",
                grade_code=here.code,
                learning_area=self.learning_area,
                created_at=now_iso()
            );
            here +>:HasSession():+> fresh;
            visit fresh;
        }
    }

    can respond with TutorSessionNode entry {
        g = [here <-:HasSession:<-][0];
        subs = sub_strands_of(g);
        if self.learning_area {
            subs = [s for s in subs if lineage(s)[0] == self.learning_area] or subs;
        }
        recent = " ".join([t["text"] for t in here.turns[-4:] if t["role"] == "learner"]);
        retrieved = retrieve(f"{self.message} {recent}", subs, 3);
        transcript = "\n".join([f"{t['role']}: {t['text']}" for t in here.turns[-10:]]);
        turn_number = len([t for t in here.turns if t["role"] == "learner"]) + 1;
        (reply, source) = run_tutor_agent(g, transcript, self.message, turn_number, retrieved);
        here.turns = here.turns + [
            {"role": "learner", "text": self.message},
            {"role": "tutor", "text": f"{reply.reply} {reply.guiding_question}".strip()}
        ];
        report TutorTurnResult(
            session_id=here.sid,
            source=source,
            reply=reply,
            turns=[ChatTurn(role=t["role"], text=t["text"]) for t in here.turns],
            retrieved=[s.name for s in retrieved]
        );
    }
}

walker:protect translate_for_parent(grade_walker) {
    """Parent agent: turn a teacher update into jargon-free home support steps (optionally broadcast)."""
    has teacher_update: str;
    has child_name: str = "";
    has learning_area: str = "";
    has language: str = "English";
    has teacher_name: str = "";
    has broadcast: bool = True;
    has reports: list[ParentGuideResult] = [];

    can translate with GradeNode entry {
        subs = sub_strands_of(here);
        if self.learning_area {
            subs = [s for s in subs if lineage(s)[0] == self.learning_area] or subs;
        }
        retrieved = retrieve(self.teacher_update, subs, 3);
        learner = learner_of(here);
        child = self.child_name or (learner.name.split(" ")[0] if learner else "your child");
        (guide, source) = run_parent_agent(here, self.teacher_update, child, self.language, retrieved);
        plan_id = "";
        if self.broadcast {
            pn = save_plan(
                here, PlanType.PARENT_BROADCAST, guide.headline,
                {"teacher_update": self.teacher_update, "guide": guide},
                source, learning_area=self.learning_area,
                author=account_name(self.teacher_name), covers=retrieved
            );
            # Parents live on their own roots, so the broadcast is also pinned to the grade's shared board.
            broadcast_board(here.code) ++> pn;
            grant(pn, level=AccessLevel.READ);
            plan_id = jid(pn);
        }
        report ParentGuideResult(plan_id=plan_id, source=source, guide=guide, retrieved=[s.name for s in retrieved]);
    }
}

walker:protect list_plans(grade_walker) {
    """List saved plans for a grade, newest first, optionally filtered by plan type."""
    has plan_type: str = "";
    has limit: int = 10;
    has reports: list[list[PlanSummary]] = [];

    can collect with GradeNode entry {
        wanted = self.plan_type;
        if wanted == PlanType.PARENT_BROADCAST {
            code = here.code;
            plans = [p for p in [root.shared -->[?:BroadcastBoard, grade_code == code] -->[?:PlanNode]]];
        } else {
            plans = [p for p in [here ->:GradePlan:->[?:PlanNode]] if not wanted or p.plan_type == wanted];
        }
        plans = sorted(plans, key=lambda (p: PlanNode) -> str { return p.created_at; }, reverse=True);
        report [
            PlanSummary(
                id=jid(p), plan_type=p.plan_type, title=p.title, grade_code=p.grade_code,
                learning_area=p.learning_area, strand=p.strand, author=p.author,
                source=p.source, created_at=p.created_at, payload_json=p.payload_json
            )
            for p in plans[:self.limit]
        ];
    }
}

walker:protect get_learner_progress(grade_walker) {
    """Parent view: holistic progress for the grade's learner (KNEC levels, competencies, values)."""
    has reports: list[LearnerProgress] = [];

    can to_learner with GradeNode entry {
        visit [here <-:EnrolledIn:<-[?:UserNode, role == Role.LEARNER]] else {
            raise ValueError(f"No learner enrolled in {here.label}.");
        }
    }

    can collect with UserNode entry {
        parents = [here <-:ParentOf:<-[?:UserNode]];
        report LearnerProgress(
            learner_name=here.name,
            parent_name=parents[0].name if parents else "",
            grade_code=here.grade_code,
            school=here.school,
            areas=[
                AreaProgress(
                    learning_area=e.learning_area, level_code=e.level_code,
                    level_label=KNEC_LEVELS[e.level_code], score=e.score, comment=e.comment
                )
                for e in [edge here ->:Assessed:->]
            ],
            competency_scores=here.competency_scores,
            values_observed=here.values_observed,
            teacher_note=here.teacher_note
        );
        disengage;
    }
}
