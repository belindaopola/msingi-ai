"""Msingi AI graph schema and wire types.

Graph shape (persistent, hangs off the shared root):

    root -> GradeNode -HasArea-> CurriculumNode(LEARNING_AREA)
                                   -HasPart-> CurriculumNode(STRAND)
                                                -HasPart-> CurriculumNode(SUB_STRAND)
    GradeNode -GradePlan-> PlanNode -Covers-> CurriculumNode
    GradeNode -HasSession-> TutorSessionNode
    UserNode -EnrolledIn-> GradeNode
    UserNode(PARENT) -ParentOf-> UserNode(LEARNER)
    UserNode(LEARNER) -Assessed-> CurriculumNode(LEARNING_AREA)

LLM-facing types are `obj`s (never nodes): agents fill an obj, walkers copy
what must persist into a node.
"""

glob BENCHMARK_GRADES: list[str] = ["PP2", "Grade 3", "Grade 6", "Grade 9", "Grade 12"];

enum Role: str {
    TEACHER = "TEACHER",
    LEARNER = "LEARNER",
    PARENT = "PARENT"
}

enum CurriculumLevel: str {
    LEARNING_AREA = "LEARNING_AREA",
    STRAND = "STRAND",
    SUB_STRAND = "SUB_STRAND"
}

enum PlanType: str {
    LESSON_PLAN = "LESSON_PLAN",
    REVISION_SCHEDULE = "REVISION_SCHEDULE",
    MATERIAL_CHECKLIST = "MATERIAL_CHECKLIST",
    PARENT_BROADCAST = "PARENT_BROADCAST"
}


# ---------------------------------------------------------------- graph nodes

node GradeNode {
    has code: str,
        label: str,
        stage: str,
        age_range: str,
        assessment: str,
        focus: str,
        order: int,
        lesson_minutes: int,
        daily_study_minutes: int,
        learner_profile: str;
}

node CurriculumNode {
    has kind: str,
        name: str,
        grade_code: str,
        pathway: str = "",
        description: str = "",
        specific_learning_outcomes: list[str] = [],
        key_inquiry_questions: list[str] = [],
        core_competencies: list[str] = [],
        values: list[str] = [],
        pcis: list[str] = [],
        learning_experiences: list[str] = [],
        resources: list[str] = [],
        local_materials: list[str] = [],
        home_activity: str = "";
}

node UserNode {
    has name: str,
        role: str,
        grade_code: str = "",
        school: str = "",
        county: str = "",
        competency_scores: dict[str, int] = {},
        values_observed: list[str] = [],
        teacher_note: str = "";
}

node AccountProfile {
    has display_name: str,
        email: str,
        app_role: str,
        grade_code: str = "PP2";
}

"""Per-grade board on root.shared that teacher broadcasts (PlanNodes) hang off, so parents' roots can read them."""
node BroadcastBoard {
    has grade_code: str;
}

obj AccountSession {
    has display_name: str,
        email: str,
        app_role: str,
        grade_code: str;
}

node PlanNode {
    has plan_type: str,
        title: str,
        grade_code: str,
        learning_area: str = "",
        strand: str = "",
        author: str = "",
        source: str = "AI",
        created_at: str = "",
        payload_json: str = "{}";
}

node TutorSessionNode {
    has sid: str,
        learner_name: str,
        grade_code: str,
        learning_area: str = "",
        created_at: str = "",
        turns: list[dict[str, str]] = [];
}


# ---------------------------------------------------------------- graph edges

edge HasArea: GradeNode --> CurriculumNode {}

edge HasPart: CurriculumNode --> CurriculumNode {}

edge EnrolledIn: UserNode --> GradeNode {}

edge ParentOf: UserNode --> UserNode {}

edge Assessed: UserNode --> CurriculumNode {
    has learning_area: str,
        level_code: str,
        score: int,
        comment: str = "";
}

edge GradePlan: GradeNode --> PlanNode {}

edge Covers: PlanNode --> CurriculumNode {}

edge HasSession: GradeNode --> TutorSessionNode {}


# ---------------------------------------------------------------- read models

obj GradeSummary {
    has code: str,
        label: str,
        stage: str,
        age_range: str,
        assessment: str,
        focus: str,
        order: int,
        lesson_minutes: int,
        daily_study_minutes: int,
        learning_areas: list[str] = [];
}

obj CurriculumBranch {
    has id: str,
        kind: str,
        name: str,
        pathway: str = "",
        description: str = "",
        specific_learning_outcomes: list[str] = [],
        key_inquiry_questions: list[str] = [],
        core_competencies: list[str] = [],
        values: list[str] = [],
        pcis: list[str] = [],
        learning_experiences: list[str] = [],
        resources: list[str] = [],
        local_materials: list[str] = [],
        home_activity: str = "",
        children: list[CurriculumBranch] = [];
}

obj GradeCurriculum {
    has grade: GradeSummary,
        areas: list[CurriculumBranch] = [];
}

obj SeedSummary {
    has status: str,
        grades: list[str] = [],
        curriculum_nodes: int = 0,
        users: int = 0;
}

obj PlanSummary {
    has id: str,
        plan_type: str,
        title: str,
        grade_code: str,
        learning_area: str,
        strand: str,
        author: str,
        source: str,
        created_at: str,
        payload_json: str;
}

obj AreaProgress {
    has learning_area: str,
        level_code: str,
        level_label: str,
        score: int,
        comment: str;
}

obj LearnerProgress {
    has learner_name: str,
        parent_name: str,
        grade_code: str,
        school: str,
        areas: list[AreaProgress] = [],
        competency_scores: dict[str, int] = {},
        values_observed: list[str] = [],
        teacher_note: str = "";
}


# ---------------------------------------------------------------- LLM output types

obj RubricLevel {
    has level: str,
        code: str,
        score: int,
        descriptor: str;
}
sem RubricLevel.level = "KNEC performance level name: Exceeding Expectations, Meeting Expectations, Approaching Expectations or Below Expectations.";
sem RubricLevel.code = "Short code: EE, ME, AE or BE.";
sem RubricLevel.score = "Numeric level: 4 for EE, 3 for ME, 2 for AE, 1 for BE.";
sem RubricLevel.descriptor = "Observable learner behaviour at this level, tied to the specific learning outcomes of this lesson.";

obj LessonStep {
    has phase: str,
        minutes: int,
        teacher_activity: str,
        learner_activity: str;
}
sem LessonStep.phase = "Lesson phase: Introduction, Lesson Development (Step 1, Step 2, ...), Conclusion, or Extended Activity.";
sem LessonStep.minutes = "Minutes allocated. All steps together must add up to the lesson duration.";
sem LessonStep.learner_activity = "What learners actively do, in a learner-centred CBC style (inquiry, pairs, groups, outdoor work).";

obj LessonPlan {
    has title: str,
        grade_level: str,
        learning_area: str,
        strand: str,
        sub_strand: str,
        duration_minutes: int,
        specific_learning_outcomes: list[str],
        key_inquiry_questions: list[str],
        core_competencies: list[str],
        values: list[str],
        pcis: list[str],
        learning_resources: list[str],
        lesson_steps: list[LessonStep],
        assessment_rubric: list[RubricLevel],
        assessment_methods: list[str],
        reflection_prompts: list[str];
}
sem LessonPlan.specific_learning_outcomes = "3 to 4 outcomes starting with 'By the end of the lesson, the learner should be able to:' style action verbs (identify, demonstrate, appreciate).";
sem LessonPlan.core_competencies = "KICD core competencies developed, each with a short note on how, e.g. 'Critical Thinking and Problem Solving: learners test which soil holds the most water'.";
sem LessonPlan.values = "KICD national values nurtured (Love, Responsibility, Respect, Unity, Peace, Patriotism, Social Justice, Integrity) with how.";
sem LessonPlan.pcis = "Pertinent and Contemporary Issues addressed, e.g. Environmental Education, Health Education, Safety, Financial Literacy.";
sem LessonPlan.learning_resources = "Resources, favouring free locally available materials found in a Kenyan school or home.";
sem LessonPlan.assessment_rubric = "Exactly four levels in order EE, ME, AE, BE.";
sem LessonPlan.assessment_methods = "Formative assessment methods, e.g. observation, oral questions, checklist, portfolio, project.";

obj MaterialItem {
    has item: str,
        purpose: str,
        learning_area: str,
        quantity: str,
        where_to_find: str,
        safety_note: str = "";
}
sem MaterialItem.item = "A low-cost or free material commonly available in Kenyan homes, schools or markets (bottle tops, sisal, maize stalks, clay, old newspapers).";
sem MaterialItem.purpose = "How the material is used for this learning area, in one sentence.";
sem MaterialItem.quantity = "How much to collect, e.g. '10 bottle tops' or '1 per group of 5'.";
sem MaterialItem.where_to_find = "Where a learner or teacher can get it locally, e.g. kitchen, school compound, jua kali artisan, market.";
sem MaterialItem.safety_note = "A short safety reminder if the item could hurt a child, otherwise an empty string.";

obj WeekSlot {
    has week_number: int,
        start_date: str,
        end_date: str,
        learning_area: str,
        strand: str;
}

obj RevisionWeek {
    has week_number: int,
        start_date: str,
        end_date: str,
        learning_area: str,
        strand: str,
        focus: str,
        activities: list[str],
        daily_minutes: int,
        checkpoint: str;
}
sem RevisionWeek.focus = "One-line goal for the week in learner-friendly words.";
sem RevisionWeek.activities = "3 to 5 short, age-appropriate revision activities, practical and screen-light.";
sem RevisionWeek.checkpoint = "A simple self-check the learner can do at the end of the week.";

obj RevisionPlan {
    has title: str,
        grade_level: str,
        learner_name: str,
        weeks: list[RevisionWeek],
        material_checklist: list[MaterialItem],
        study_tips: list[str],
        wellbeing_note: str;
}
sem RevisionPlan.weeks = "One entry per given week slot, keeping the given dates, learning area and strand.";
sem RevisionPlan.material_checklist = "6 to 10 practical materials to collect for the term, using locally available items.";
sem RevisionPlan.wellbeing_note = "A short reminder about rest, play, chores balance and asking for help.";

obj TutorReply {
    has reply: str,
        guiding_question: str,
        hint_level: int,
        concepts: list[str],
        encouragement: str;
}
sem TutorReply.reply = "Short Socratic response that reacts to the learner's thinking and nudges, never states the final answer.";
sem TutorReply.guiding_question = "One question that moves the learner one step closer to discovering the answer themselves.";
sem TutorReply.hint_level = "How much scaffolding was given: 1 light nudge, 2 targeted hint, 3 worked example on a similar but different problem.";
sem TutorReply.concepts = "1 to 3 curriculum concepts this turn touches.";
sem TutorReply.encouragement = "A brief warm encouragement suited to the learner's age.";

obj HomeActivity {
    has title: str,
        time_minutes: int,
        materials: list[str],
        steps: list[str],
        link_to_learning: str;
}
sem HomeActivity.materials = "Household items only, nothing that must be bought.";
sem HomeActivity.steps = "3 to 5 simple steps a busy parent can follow.";
sem HomeActivity.link_to_learning = "One sentence on which school skill this builds.";

obj JargonTerm {
    has term: str,
        meaning: str;
}

obj ParentGuide {
    has headline: str,
        plain_summary: str,
        what_child_is_learning: list[str],
        home_activities: list[HomeActivity],
        questions_to_ask: list[str],
        signs_of_progress: list[str],
        jargon_buster: list[JargonTerm],
        encouragement: str;
}
sem ParentGuide.plain_summary = "2 to 3 sentences in plain, warm language without CBC jargon.";
sem ParentGuide.home_activities = "2 or 3 activities that fit into normal home routines (cooking, shopping, farming, chores).";
sem ParentGuide.questions_to_ask = "Friendly questions a parent can ask the child at supper or on the way to school.";
sem ParentGuide.jargon_buster = "Every CBC term that appears in the teacher update (strand, sub-strand, SLO, PCI, rubric levels), explained simply.";


# ---------------------------------------------------------------- walker responses

obj LessonPlanResult {
    has plan_id: str,
        source: str,
        plan: LessonPlan;
}

obj MaterialPlanResult {
    has source: str,
        grade_level: str,
        learning_area: str,
        class_size: int,
        materials: list[MaterialItem];
}

obj RevisionResult {
    has plan_id: str,
        source: str,
        plan: RevisionPlan;
}

obj ChatTurn {
    has role: str,
        text: str;
}

obj TutorTurnResult {
    has session_id: str,
        source: str,
        reply: TutorReply,
        turns: list[ChatTurn],
        retrieved: list[str] = [];
}

obj ParentGuideResult {
    has plan_id: str,
        source: str,
        guide: ParentGuide,
        retrieved: list[str] = [];
}