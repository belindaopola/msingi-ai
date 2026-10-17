# By Mara Msingi
"""KICD lesson plan generator with a printable plan document and 4-tier KNEC rubric."""

import from "lucide-react" { ClipboardList, Printer, Wand2 }
import from ..endpoints { generate_lesson_plan }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData, LessonPlan as LessonPlanData, LessonPlanResult as LessonPlanResultData }
import from ..shared.useCurriculumPicker { useCurriculumPicker }
import from ..shared.constants { DEMO_TEACHER_NAME }
import from ..shared.browser { error_text, to_int }
import from ..shared.ui {
    Badge, BulletList, Button, Card, EmptyState, ErrorNote, Field, Input, LevelBadge,
    SectionLabel, Select, SourceBadge, TextArea
}

def:pub LessonPlanGenerator(grade: GradeSummaryData, curriculum: GradeCurriculumData | None) -> JsxElement {
    has duration: str = str(grade.lesson_minutes),
        classSize: str = "40",
        notes: str = "",
        result: LessonPlanResultData | None = None,
        loading: bool = False,
        error: str = "";

    picker = useCurriculumPicker(curriculum);

    async def submit(e: FormEvent) -> None {
        e.preventDefault();
        loading = True;
        error = "";
        try {
            response = root spawn generate_lesson_plan(
                grade_level=grade.code,
                learning_area=picker["areaName"],
                strand=picker["strandName"],
                sub_strand=picker["subName"],
                duration_minutes=to_int(duration, 0),
                class_size=to_int(classSize, 40),
                teacher_name=DEMO_TEACHER_NAME,
                teacher_notes=notes
            );
            result = response.reports[0];
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    def print_plan -> None {
        window.print();  # jac:ignore[E1030]
    }

    <Card
        id="lesson-plan"
        icon={<ClipboardList size={18} aria-hidden="true"/>}
        title="KICD Lesson Plan Generator"
        subtitle="Traverses the curriculum graph for your strand and drafts a CBE lesson plan with a 4-tier KNEC rubric."
        actions={result and <Button variant="secondary" icon={<Printer size={16} aria-hidden="true"/>} onClick={print_plan}>Print</Button>}
    >
        <form onSubmit={submit} className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 print:hidden">
            <Field label="Learning area">
                <Select value={picker["areaName"]} onValue={picker["setAreaName"]} options={[a.name for a in picker["areas"]]}/>
            </Field>
            <Field label="Strand">
                <Select value={picker["strandName"]} onValue={picker["setStrandName"]} options={[s.name for s in picker["strands"]]}/>
            </Field>
            <Field label="Sub-strand">
                <Select value={picker["subName"]} onValue={picker["setSubName"]} placeholder="First sub-strand" options={[s.name for s in picker["subs"]]}/>
            </Field>
            <Field label="Lesson duration (minutes)" hint={f"KICD standard for {grade.label}: {grade.lesson_minutes} minutes"}>
                <Input kind="number" min="10" max="120" value={duration} onValue={lambda (v: str) { duration = v; }}/>
            </Field>
            <Field label="Class size">
                <Input kind="number" min="1" max="120" value={classSize} onValue={lambda (v: str) { classSize = v; }}/>
            </Field>
            <Field label="Notes for the planner (optional)">
                <TextArea
                    rows={2}
                    placeholder="e.g. Include an outdoor activity; 3 learners need visual support."
                    value={notes}
                    onValue={lambda (v: str) { notes = v; }}
                />
            </Field>
            <div className="sm:col-span-2 lg:col-span-3">
                <Button submit={True} icon={<Wand2 size={16} aria-hidden="true"/>} loading={loading} disabled={not picker["strandName"]}>
                    {"Drafting lesson plan..." if loading else "Generate lesson plan"}
                </Button>
            </div>
        </form>

        <ErrorNote message={error}/>

        <div className="mt-6">
            {if result {
                <LessonPlanDocument plan={result.plan} source={result.source}/>
            } else {
                <EmptyState icon={<ClipboardList size={28} aria-hidden="true"/>} title="No lesson plan yet">
                    Pick a strand and generate a plan. It will include SLOs, competencies, values, PCIs, resources and an assessment rubric.
                </EmptyState>
            }}
        </div>
    </Card>
}

def:pub LessonPlanDocument(plan: LessonPlanData, source: str) -> JsxElement {
    <article className="rounded-2xl border border-teal-100 bg-white p-5 sm:p-6">
        <header className="flex flex-wrap items-start justify-between gap-3 border-b border-teal-50 pb-4">
            <div>
                <h3 className="font-serif text-xl font-bold text-teal">{plan.title}</h3>
                <div className="mt-2 flex flex-wrap gap-2">
                    <Badge tone="teal">{plan.grade_level}</Badge>
                    <Badge tone="teal">{plan.learning_area}</Badge>
                    <Badge tone="teal">Strand: {plan.strand}</Badge>
                    <Badge tone="teal">Sub-strand: {plan.sub_strand}</Badge>
                    <Badge tone="eucalyptus">{plan.duration_minutes} minutes</Badge>
                </div>
            </div>
            <SourceBadge source={source}/>
        </header>

        <div className="mt-5 grid gap-6 md:grid-cols-2">
            <div>
                <SectionLabel>Specific Learning Outcomes</SectionLabel>
                <BulletList items={plan.specific_learning_outcomes} ordered={True}/>
            </div>
            <div>
                <SectionLabel>Key Inquiry Questions</SectionLabel>
                <BulletList items={plan.key_inquiry_questions}/>
            </div>
            <div>
                <SectionLabel>Core Competencies</SectionLabel>
                <BulletList items={plan.core_competencies}/>
            </div>
            <div>
                <SectionLabel>Values</SectionLabel>
                <BulletList items={plan.values}/>
            </div>
            <div>
                <SectionLabel>Pertinent and Contemporary Issues (PCIs)</SectionLabel>
                <BulletList items={plan.pcis}/>
            </div>
            <div>
                <SectionLabel>Learning Resources</SectionLabel>
                <BulletList items={plan.learning_resources}/>
            </div>
        </div>

        <div className="mt-6">
            <SectionLabel>Lesson Steps</SectionLabel>
            <div className="overflow-x-auto rounded-xl border border-teal-50">
                <table className="w-full min-w-[560px] text-left text-sm">
                    <thead className="bg-ivory text-xs uppercase tracking-wider text-teal-400">
                        <tr>
                            <th className="px-3 py-2">Phase</th>
                            <th className="px-3 py-2">Time</th>
                            <th className="px-3 py-2">Teacher activity</th>
                            <th className="px-3 py-2">Learner activity</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-teal-50">
                        {for (i, s) in enumerate(plan.lesson_steps) {
                            <tr key={i} className="align-top">
                                <td className="px-3 py-2.5 font-medium">{s.phase}</td>
                                <td className="whitespace-nowrap px-3 py-2.5">{s.minutes} min</td>
                                <td className="px-3 py-2.5">{s.teacher_activity}</td>
                                <td className="px-3 py-2.5">{s.learner_activity}</td>
                            </tr>
                        }}
                    </tbody>
                </table>
            </div>
        </div>

        <div className="mt-6">
            <SectionLabel>KNEC Assessment Rubric</SectionLabel>
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                {for r in plan.assessment_rubric {
                    <div key={r.code} className="rounded-xl border border-teal-50 bg-alabaster p-3">
                        <div className="flex items-center gap-2">
                            <LevelBadge code={r.code}/>
                            <span className="text-sm font-semibold">{r.level}</span>
                        </div>
                        <p className="mt-2 text-sm text-teal-400">{r.descriptor}</p>
                    </div>
                }}
            </div>
        </div>

        <div className="mt-6 grid gap-6 md:grid-cols-2">
            <div>
                <SectionLabel>Assessment Methods</SectionLabel>
                <BulletList items={plan.assessment_methods}/>
            </div>
            <div>
                <SectionLabel>Teacher Reflection</SectionLabel>
                <BulletList items={plan.reflection_prompts}/>
            </div>
        </div>
    </article>
}
