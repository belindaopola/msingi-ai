"""Deterministic fallbacks for every agent.

Used when no LLM provider is configured (or a call fails) so the mockup works
out of the box. Output is assembled straight from the KICD curriculum graph,
so it stays curriculum-accurate, just less tailored than the AI version.
"""

import math;
import from models {
    GradeNode, CurriculumNode, LessonPlan, LessonStep, RubricLevel, MaterialItem,
    WeekSlot, RevisionWeek, RevisionPlan, TutorReply, ParentGuide, HomeActivity,
    JargonTerm
}
import from retrieval { lineage, parent_of }
import from seed_data { KNEC_LEVELS, KNEC_SCORES }

glob CBC_GLOSSARY: dict[str, str] = {
    "strand": "A big topic within a subject, like 'Numbers' in Mathematics.",
    "sub-strand": "A smaller topic inside a strand, like 'Counting' inside 'Numbers'.",
    "slo": "Specific Learning Outcome: what your child should be able to do by the end of a lesson.",
    "learning outcome": "What your child should be able to do by the end of a lesson or topic.",
    "pci": "Pertinent and Contemporary Issues: real-life topics like health, safety, money skills and the environment.",
    "core competenc": "Life skills the CBC builds in every subject, like teamwork, problem solving and creativity.",
    "kiq": "Key Inquiry Question: a big question that gets children thinking and exploring.",
    "inquiry question": "A big question that gets children thinking and exploring.",
    "rubric": "The scale teachers use to describe how well a child is doing.",
    "exceeding expectations": "Doing better than expected for this grade (level 4).",
    "meeting expectations": "Doing what is expected for this grade (level 3).",
    "approaching expectations": "Nearly there, needs a little more practice (level 2).",
    "below expectations": "Needs extra support and practice at home and school (level 1).",
    "formative assessment": "Everyday checks by the teacher while learning is happening, not a final exam.",
    "portfolio": "A folder of your child's work collected over time to show progress.",
    "kpsea": "Kenya Primary School Education Assessment, taken at the end of Grade 6.",
    "kjsea": "Kenya Junior School Education Assessment, taken at the end of Grade 9.",
    "pathway": "The specialisation a learner chooses in Senior School: STEM, Social Sciences, or Arts and Sports Science.",
    "csl": "Community Service Learning: projects where learners use what they learn to help the community.",
    "community service learning": "Projects where learners use what they learn to help the community.",
    "learning area": "The CBC name for a subject.",
    "values": "Good character traits the CBC nurtures, like respect, responsibility and integrity."
};

"""Turn a third-person outcome into a learner's first-person self-check."""
def first_person(text: str) -> str {
    return text.replace("themselves", "myself").replace("their ", "my ").replace("They ", "I ");
}

def split_minutes(total: int, weights: list[int]) -> list[int] {
    w_sum = sum(weights);
    parts = [max(1, int(total * w / w_sum)) for w in weights];
    parts[-2] += total - sum(parts);
    return parts;
}

def make_rubric(sub: CurriculumNode) -> list[RubricLevel] {
    outcome = sub.specific_learning_outcomes[0].lower() if sub.specific_learning_outcomes else f"show understanding of {sub.name.lower()}";
    descriptors = {
        "EE": f"Can {outcome} independently and accurately, and explains or applies it in a new situation.",
        "ME": f"Can {outcome} accurately with little or no support.",
        "AE": f"Can {outcome} partially, with some errors, and needs some support.",
        "BE": f"Needs a lot of guidance to {outcome}; attempts with frequent errors."
    };
    return [
        RubricLevel(level=KNEC_LEVELS[code], code=code, score=KNEC_SCORES[code], descriptor=descriptors[code])
        for code in ["EE", "ME", "AE", "BE"]
    ];
}

def fallback_lesson_plan(
    g: GradeNode, sub: CurriculumNode, duration: int, class_size: int
) -> LessonPlan {
    (area, strand_name) = lineage(sub);
    strand = parent_of(sub);
    groups = max(1, math.ceil(class_size / 5));
    mins = split_minutes(duration, [15, 35, 35, 15]);
    experiences = sub.learning_experiences or ["Guided discovery in groups"];
    first_kiq = sub.key_inquiry_questions[0] if sub.key_inquiry_questions else f"What do we know about {sub.name}?";
    steps = [
        LessonStep(
            phase="Introduction",
            minutes=mins[0],
            teacher_activity=f"Pose the key inquiry question: '{first_kiq}' and link it to learners' experiences at home.",
            learner_activity="Share ideas in pairs and with the class."
        ),
        LessonStep(
            phase="Lesson Development: Step 1",
            minutes=mins[1],
            teacher_activity=f"Organise {groups} groups of about 5 and guide the activity: {experiences[0].lower()}.",
            learner_activity=f"{experiences[0]} using the locally available materials, recording observations."
        ),
        LessonStep(
            phase="Lesson Development: Step 2",
            minutes=mins[2],
            teacher_activity="Move between groups asking probing questions and noting progress on the observation checklist.",
            learner_activity=(experiences[1] if len(experiences) > 1 else "Groups present findings to the class") + ", then discuss as a class."
        ),
        LessonStep(
            phase="Conclusion",
            minutes=mins[3],
            teacher_activity="Summarise key points and invite learners to reflect on what they learnt.",
            learner_activity="Answer quick oral questions and say one thing they will try at home."
        )
    ];
    return LessonPlan(
        title=f"{g.label} {area}: {sub.name}",
        grade_level=g.code,
        learning_area=area,
        strand=strand_name,
        sub_strand=sub.name,
        duration_minutes=duration,
        specific_learning_outcomes=[f"By the end of the lesson, the learner should be able to {o[0].lower()}{o[1:]}." for o in sub.specific_learning_outcomes],
        key_inquiry_questions=sub.key_inquiry_questions,
        core_competencies=strand.core_competencies if strand else [],
        values=strand.values if strand else [],
        pcis=strand.pcis if strand else [],
        learning_resources=sub.resources + [f"{m} (locally available)" for m in sub.local_materials],
        lesson_steps=steps,
        assessment_rubric=make_rubric(sub),
        assessment_methods=["Observation with checklist", "Oral questions", "Group presentation", "Learner portfolio entry"],
        reflection_prompts=[
            "Which learners need extra support on this sub-strand?",
            "Did the local materials work well, and what could replace any that were missing?",
            f"Extended activity for home: {sub.home_activity}"
        ]
    );
}

def materials_from(subs: list[CurriculumNode], class_size: int) -> list[MaterialItem] {
    groups = max(1, math.ceil(class_size / 5));
    seen: set[str] = set();
    items: list[MaterialItem] = [];
    for sub in subs {
        (area, _) = lineage(sub);
        for m in sub.local_materials {
            key = m.lower();
            if key in seen {
                continue;
            }
            seen.add(key);
            risky = `any([w in key for w in ["nail", "spirit", "wire", "knife", "glass", "needle", "cell", "foil"]]);
            items.append(MaterialItem(
                item=m,
                purpose=f"Hands-on learning for {sub.name}.",
                learning_area=area,
                quantity=f"1 set per group ({groups} groups of about 5)",
                where_to_find="Home, school compound or local market",
                safety_note="Handle under adult supervision." if risky else ""
            ));
        }
    }
    return items[:10];
}

def fallback_revision_plan(
    g: GradeNode,
    learner_name: str,
    slots: list[WeekSlot],
    subs: list[CurriculumNode],
    daily_minutes: int
) -> RevisionPlan {
    weeks: list[RevisionWeek] = [];
    for slot in slots {
        match_subs = [s for s in subs if lineage(s)[1] == slot.strand];
        sub = match_subs[0] if match_subs else None;
        if sub is None {
            weeks.append(RevisionWeek(
                week_number=slot.week_number,
                start_date=slot.start_date,
                end_date=slot.end_date,
                learning_area=slot.learning_area,
                strand=slot.strand,
                focus="Mixed review of the whole term, at a gentle pace.",
                activities=["Revisit your weakest topic for 2 days", "Teach a family member something you learnt", "Rest well and play outdoors"],
                daily_minutes=daily_minutes,
                checkpoint="Can I explain each topic in my own words?"
            ));
            continue;
        }
        activities = [f"Practise: {e}" for e in sub.learning_experiences[:2]];
        if sub.key_inquiry_questions {
            activities.append(f"Think and talk: {sub.key_inquiry_questions[0]}");
        }
        activities.append(f"Home task: {sub.home_activity}");
        weeks.append(RevisionWeek(
            week_number=slot.week_number,
            start_date=slot.start_date,
            end_date=slot.end_date,
            learning_area=slot.learning_area,
            strand=slot.strand,
            focus=f"Get confident with {sub.name}.",
            activities=activities,
            daily_minutes=daily_minutes,
            checkpoint=first_person(f"Can I {sub.specific_learning_outcomes[0][0].lower()}{sub.specific_learning_outcomes[0][1:]}?") if sub.specific_learning_outcomes else "What did I learn this week?"
        ));
    }
    return RevisionPlan(
        title=f"{learner_name}'s {g.label} Term Revision Plan",
        grade_level=g.code,
        learner_name=learner_name,
        weeks=weeks,
        material_checklist=materials_from(subs, 1)[:8],
        study_tips=[
            f"Keep sessions to about {daily_minutes} minutes a day, with short breaks.",
            "Revise at the same time each day, for example after evening chores.",
            "Explain what you learnt to someone at home; teaching is the best revision.",
            f"Focus on understanding, not cramming, for the {g.assessment.split(' (')[0].split(',')[0]}."
        ],
        wellbeing_note="Sleep early, eat well, play outside and ask your teacher or parent for help whenever you feel stuck."
    );
}

def fallback_tutor_reply(
    g: GradeNode, message: str, turn_number: int, retrieved: list[CurriculumNode]
) -> TutorReply {
    sub = retrieved[0] if retrieved else None;
    hint_level = min(3, 1 + turn_number // 2);
    concepts = [s.name for s in retrieved[:2]];
    if sub is None {
        return TutorReply(
            reply="That is a great thing to wonder about. Let us work it out together step by step.",
            guiding_question="What do you already know about this topic?",
            hint_level=1,
            concepts=[],
            encouragement="Every expert started as a beginner!"
        );
    }
    kiqs = sub.key_inquiry_questions or [f"What do you notice about {sub.name.lower()}?"];
    if hint_level == 1 {
        reply = f"Good question! This connects to what you are learning in {sub.name}. Before I give any hints, I want to hear your thinking.";
        question = kiqs[0];
    } elif hint_level == 2 {
        reply = f"You are getting closer. Here is a hint: think about how we {sub.learning_experiences[0].lower() if sub.learning_experiences else 'explored this in class'}.";
        question = kiqs[1] if len(kiqs) > 1 else kiqs[0];
    } else {
        reply = f"Let us try a similar example together. Use something at home, like {sub.local_materials[0].lower() if sub.local_materials else 'everyday objects'}, and test your idea step by step.";
        question = "What happened when you tried it, and what does that tell you about your answer?";
    }
    return TutorReply(
        reply=reply,
        guiding_question=question,
        hint_level=hint_level,
        concepts=concepts,
        encouragement="You are thinking like a scientist! Keep going." if g.order >= 3 else "Well done for trying! You are doing great."
    );
}

def fallback_parent_guide(
    g: GradeNode, teacher_update: str, child_name: str, retrieved: list[CurriculumNode]
) -> ParentGuide {
    lower = teacher_update.lower();
    jargon = [JargonTerm(term=t.upper() if len(t) <= 5 else t.title(), meaning=m) for (t, m) in CBC_GLOSSARY.items() if t in lower];
    if not jargon {
        jargon = [JargonTerm(term="Strand", meaning=CBC_GLOSSARY["strand"]), JargonTerm(term="Meeting Expectations", meaning=CBC_GLOSSARY["meeting expectations"])];
    }
    activities = [
        HomeActivity(
            title=f"Home practice: {s.name}",
            time_minutes=max(10, g.daily_study_minutes // 3),
            materials=s.local_materials[:3],
            steps=[step.strip() for step in s.home_activity.split(". ") if step.strip()] + ["Praise the effort, not just the result."],
            link_to_learning=f"Builds the school topic '{s.name}' in {lineage(s)[0]}."
        )
        for s in retrieved[:3]
    ];
    learning = [f"{lineage(s)[0]}: {s.name}. {s.specific_learning_outcomes[0] if s.specific_learning_outcomes else ''}".strip() for s in retrieved[:3]];
    return ParentGuide(
        headline=f"What {child_name} is learning in {g.label} right now",
        plain_summary=f"The teacher shared an update about {child_name}'s learning. In simple terms, {child_name} is working on {', '.join([s.name.lower() for s in retrieved[:2]]) or 'core skills for this grade'}. You can help a lot at home with short, fun activities using things you already have.",
        what_child_is_learning=learning,
        home_activities=activities,
        questions_to_ask=[q.replace("we ", "you ").replace("our ", "your ") for s in retrieved[:2] for q in s.key_inquiry_questions[:1]] + ["What was the best part of school today?"],
        signs_of_progress=[f"{child_name} can {o[0].lower()}{o[1:]}." for s in retrieved[:2] for o in s.specific_learning_outcomes[:1]],
        jargon_buster=jargon,
        encouragement="You do not need to be a teacher to help. Your interest and encouragement make the biggest difference."
    );
}
