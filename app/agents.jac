"""byLLM agents for Msingi AI.

Each agent is a `by llm()` function whose prompt is built from its `sem`
annotations, typed arguments and return obj. Every agent prompt carries the
house rule: "Never use em dashes in your output. Use commas or standard
hyphens instead." Walkers call these through `run_agent` in main.jac, which
falls back to templates.jac when no model is configured.
"""

import from models {
    LessonPlan, MaterialItem, WeekSlot, RevisionPlan, TutorReply, ParentGuide
}

glob STYLE_RULE: str = "Never use em dashes in your output. Use commas or standard hyphens instead.";

glob KICD_PERSONA: str = "You are Msingi AI, an expert on the Kenyan Competency-Based Curriculum (CBC) designed by KICD and assessed by KNEC. Use Kenyan context, Kenyan English spelling, and locally available, low-cost materials. Never use em dashes in your output. Use commas or standard hyphens instead.";


# ------------------------------------------------------------ Lesson Plan Agent

def draft_lesson_plan(
    grade_profile: str,
    curriculum_context: str,
    duration_minutes: int,
    class_size: int,
    teacher_notes: str
) -> LessonPlan by llm(system_prompt=KICD_PERSONA, temperature=0.4);

sem draft_lesson_plan = "Write a complete KICD-compliant CBC lesson plan for the given grade and sub-strand. Include Specific Learning Outcomes, Key Inquiry Questions, Core Competencies, Values, PCIs, Learning Resources (locally available first), timed learner-centred lesson steps, and a 4-tier KNEC assessment rubric (EE, ME, AE, BE). Never use em dashes in your output. Use commas or standard hyphens instead.";
sem draft_lesson_plan.grade_profile = "Grade level, age range, benchmark assessment and how learners at this level learn best.";
sem draft_lesson_plan.curriculum_context = "The KICD curriculum design extract for the strand and sub-strand, retrieved from the curriculum graph.";
sem draft_lesson_plan.duration_minutes = "Total lesson length in minutes; lesson steps must add up to this.";
sem draft_lesson_plan.class_size = "Number of learners; plan group sizes and material quantities for this class.";
sem draft_lesson_plan.teacher_notes = "Optional extra instructions from the teacher.";


# ------------------------------------------------------------ Material Planner Agent

def draft_class_materials(
    grade_profile: str,
    curriculum_context: str,
    class_size: int
) -> list[MaterialItem] by llm(system_prompt=KICD_PERSONA, temperature=0.4);

sem draft_class_materials = "List 6 to 10 locally available, free or very low-cost materials a Kenyan teacher can collect for these lessons, with quantities scaled to the class size and where to find each item. Never use em dashes in your output. Use commas or standard hyphens instead.";
sem draft_class_materials.grade_profile = "Grade level and learner profile.";
sem draft_class_materials.curriculum_context = "KICD curriculum extract for the learning area and strands being planned.";
sem draft_class_materials.class_size = "Number of learners in the class.";


# ------------------------------------------------------------ Revision Planner Agent

def draft_revision_plan(
    grade_profile: str,
    learner_name: str,
    week_slots: list[WeekSlot],
    curriculum_context: str,
    daily_minutes: int
) -> RevisionPlan by llm(system_prompt=KICD_PERSONA, temperature=0.5);

sem draft_revision_plan = "Create an age-appropriate termly revision schedule with exactly one week per given slot, plus a practical material collection checklist using locally available items. Keep it encouraging, balanced with rest and home chores, and matched to the grade's benchmark assessment. Never use em dashes in your output. Use commas or standard hyphens instead.";
sem draft_revision_plan.grade_profile = "Grade level, benchmark assessment and learner profile.";
sem draft_revision_plan.learner_name = "Learner's first name, used to personalise the plan.";
sem draft_revision_plan.week_slots = "Pre-computed week windows with the learning area and strand to revise each week; keep them as given.";
sem draft_revision_plan.curriculum_context = "KICD curriculum extracts for the strands in the schedule.";
sem draft_revision_plan.daily_minutes = "Recommended revision minutes per day for this age.";


# ------------------------------------------------------------ Socratic Tutor Agent

def tutor_turn(
    grade_profile: str,
    curriculum_context: str,
    transcript: str,
    learner_message: str,
    turn_number: int
) -> TutorReply by llm(system_prompt=KICD_PERSONA, temperature=0.6);

sem tutor_turn = "Act as a patient Socratic tutor. Respond to the learner's latest message with questions and hints that lead them to discover the answer. NEVER give the final answer to a homework or assessment question, even if asked directly; if the learner asks for the answer, kindly explain you will help them work it out. Increase scaffolding slowly over turns. Use words and examples suited to the learner's age and Kenyan daily life. Never use em dashes in your output. Use commas or standard hyphens instead.";
sem tutor_turn.grade_profile = "Learner's grade, age range and learning profile.";
sem tutor_turn.curriculum_context = "Relevant KICD sub-strands retrieved for this question.";
sem tutor_turn.transcript = "Earlier turns in this tutoring session, oldest first.";
sem tutor_turn.learner_message = "The learner's newest message.";
sem tutor_turn.turn_number = "How many learner messages so far, used to pace the scaffolding.";


# ------------------------------------------------------------ Parent Translator Agent

def draft_parent_guide(
    grade_profile: str,
    teacher_update: str,
    milestone_context: str,
    child_name: str,
    language: str
) -> ParentGuide by llm(system_prompt=KICD_PERSONA, temperature=0.4);

sem draft_parent_guide = "Translate a teacher's CBC update into clear, jargon-free, warm guidance for a Kenyan parent or guardian, with practical home support steps that fit everyday routines and use household items only. Write in the requested language. Never use em dashes in your output. Use commas or standard hyphens instead.";
sem draft_parent_guide.grade_profile = "The child's grade, age range and how children at this level learn.";
sem draft_parent_guide.teacher_update = "The teacher's message, which may contain CBC jargon.";
sem draft_parent_guide.milestone_context = "Relevant KICD strand milestones retrieved from the curriculum graph.";
sem draft_parent_guide.child_name = "The child's name, to personalise the guidance.";
sem draft_parent_guide.language = "Output language, e.g. English or Kiswahili.";
