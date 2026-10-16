"""Static UI data: roles, benchmark grade tabs, KNEC levels and demo prompts."""

glob ROLES: list[dict[str, any]] = [
    {
        "id": "TEACHER",
        "label": "Teacher",
        "blurb": "Plan KICD lessons, gather local materials and update parents.",
        "panels": [
            {"id": "lesson-plan", "label": "Lesson Plan Generator"},
            {"id": "materials", "label": "Material Planner"},
            {"id": "broadcast", "label": "Parent Broadcast"}
        ]
    },
    {
        "id": "LEARNER",
        "label": "Learner",
        "blurb": "Plan your revision, collect materials and think it through with your tutor.",
        "panels": [
            {"id": "revision", "label": "Revision Calendar"},
            {"id": "checklist", "label": "Material Checklist"},
            {"id": "tutor", "label": "Socratic Tutor"}
        ]
    },
    {
        "id": "PARENT",
        "label": "Parent",
        "blurb": "Understand CBC updates and support learning at home.",
        "panels": [
            {"id": "translator", "label": "CBC Translator"},
            {"id": "home-activities", "label": "Home Activity Guide"},
            {"id": "progress", "label": "Progress Tracker"}
        ]
    }
];

"""Grade tabs shown before the server answers; replaced by `list_grades` once online."""
glob GRADE_TABS: list[dict[str, str]] = [
    {"code": "PP2", "stage": "Early Years Education (Pre-Primary)"},
    {"code": "Grade 3", "stage": "Lower Primary (End)"},
    {"code": "Grade 6", "stage": "Upper Primary (End)"},
    {"code": "Grade 9", "stage": "Junior School (End)"},
    {"code": "Grade 12", "stage": "Senior School (End)"}
];

glob KNEC_LEVELS: list[dict[str, str]] = [
    {"code": "EE", "label": "Exceeding Expectations"},
    {"code": "ME", "label": "Meeting Expectations"},
    {"code": "AE", "label": "Approaching Expectations"},
    {"code": "BE", "label": "Below Expectations"}
];

glob SAMPLE_TEACHER_UPDATES: dict[str, str] = {
    "PP2": "This week in Mathematical Activities, strand Numbers, sub-strand Rote Counting and Number Recognition, most learners are Approaching Expectations on recognising numerals 1 to 9. Core competency focus: Critical Thinking and Problem Solving.",
    "Grade 3": "Literacy Activities update: we are on the Reading strand, sub-strand Reading Fluency. The SLO is reading a Grade 3 text at about 60 words per minute ahead of the KNEC monitoring assessment. Several learners are Approaching Expectations.",
    "Grade 6": "Science and Technology: we covered the Force and Energy strand, sub-strand Electrical Energy (simple circuits). Learners will be assessed through a practical portfolio task before KPSEA. PCI focus: Safety.",
    "Grade 9": "Mathematics: Algebra strand, Linear Equations sub-strand. Learners Meeting Expectations can form and solve equations; those Approaching Expectations need support forming equations from word problems before KJSEA. Pathway selection forms are due next month.",
    "Grade 12": "Community Service Learning: learners are in the implementation phase of their CSL project. Portfolios must include reflection journals and photo evidence. Core competencies assessed: Citizenship, and Communication and Collaboration."
};

glob TUTOR_STARTERS: dict[str, list[str]] = {
    "PP2": ["Why do we wear a sweater when it is cold?", "How many legs does a chicken have?"],
    "Grade 3": ["Why should I brush my teeth at night?", "Which soil is best for growing sukuma wiki?"],
    "Grade 6": ["Why does my torch bulb not light up?", "Why does my heart beat fast after running?"],
    "Grade 9": ["How do I solve 3x + 5 = 20?", "Why does cabbage juice change colour in soap water?"],
    "Grade 12": ["How does a transformer step down voltage?", "How should I plan my CSL project?"]
};

glob LANGUAGES: list[str] = ["English", "Kiswahili"];

glob DEMO_TEACHER_NAME: str = "Tr. Faith Njeri";
