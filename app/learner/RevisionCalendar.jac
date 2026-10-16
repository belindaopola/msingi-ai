"""Termly revision calendar: week-by-week plan paced for the learner's age."""

import from "lucide-react" { CalendarDays, CheckCircle, Clock, HeartPulse, Wand2 }
import from ..endpoints { build_revision_and_materials }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData, RevisionResult as RevisionResultData }
import from ..shared.browser { error_text, format_date, iso_day }
import from ..shared.ui { Badge, Button, Card, EmptyState, ErrorNote, Field, Input, SourceBadge }

"""Next Monday to the Friday of week 6."""
def default_term -> dict[str, str] {
    today = new(Date);
    start = new(Date, today.getTime());
    start.setDate(today.getDate() + (((8 - today.getDay()) % 7) or 7));
    end = new(Date, start.getTime());
    end.setDate(start.getDate() + 6 * 7 - 3);
    return {"start": iso_day(start), "end": iso_day(end)};
}

def:pub RevisionCalendar(
    grade: GradeSummaryData,
    curriculum: GradeCurriculumData | None,
    revision: RevisionResultData | None,
    onRevision: Callable[[RevisionResultData], None]
) -> JsxElement {
    has term: dict[str, str] = default_term(),
        learnerName: str = "",
        focus: list[str] = [],
        loading: bool = False,
        error: str = "";

    def toggle_focus(name: str) -> None {
        focus = [f for f in focus if f != name] if name in focus else focus + [name];
    }

    async def submit(e: FormEvent) -> None {
        e.preventDefault();
        loading = True;
        error = "";
        try {
            response = root spawn build_revision_and_materials(
                grade_level=grade.code,
                term_start=term["start"],
                term_end=term["end"],
                learner_name=learnerName,
                focus_areas=focus
            );
            onRevision(response.reports[0]);
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    areas = curriculum.areas if curriculum else [];
    plan = revision.plan if revision else None;
    today_iso = iso_day(new(Date));

    <Card
        id="revision"
        icon={<CalendarDays size={18} aria-hidden="true"/>}
        title="Termly Revision Calendar"
        subtitle={f"Week-by-week plan for {grade.label}, paced for {grade.age_range} (about {grade.daily_study_minutes} minutes a day)."}
        actions={revision and <SourceBadge source={revision.source}/>}
    >
        <form onSubmit={submit} className="grid gap-4 md:grid-cols-4">
            <Field label="Term starts">
                <Input kind="date" value={term["start"]} onValue={lambda (v: str) { term = {**term, "start": v}; }} required={True}/>
            </Field>
            <Field label="Term ends">
                <Input kind="date" value={term["end"]} min={term["start"]} onValue={lambda (v: str) { term = {**term, "end": v}; }} required={True}/>
            </Field>
            <Field label="Your first name" hint="Leave blank to use the demo learner.">
                <Input value={learnerName} onValue={lambda (v: str) { learnerName = v; }} placeholder="e.g. Wanjiku"/>
            </Field>
            <div className="flex items-end">
                <Button submit={True} icon={<Wand2 size={16} aria-hidden="true"/>} loading={loading} className="w-full">
                    Build my plan
                </Button>
            </div>
            <fieldset className="md:col-span-4">
                <legend className="mb-1.5 text-sm font-medium text-teal">Areas to focus on (optional)</legend>
                <div className="flex flex-wrap gap-2">
                    {for a in areas {
                        <button
                            type="button"
                            key={a.id}
                            aria-pressed={a.name in focus}
                            onClick={lambda (e: MouseEvent) { toggle_focus(a.name); }}
                            className={"rounded-full border px-3 py-1 text-xs font-medium transition " + ("border-sage bg-sage text-white" if a.name in focus else "border-teal-100 bg-white text-teal hover:border-sage")}
                        >
                            {a.name}
                        </button>
                    }}
                </div>
                <p className="mt-1 text-xs text-teal-400">With no selection, Msingi starts with areas where your progress record says you are still Approaching Expectations.</p>
            </fieldset>
        </form>

        <ErrorNote message={error}/>

        <div className="mt-6">
            {if plan {
                <h3 className="font-serif text-lg font-semibold">{plan.title}</h3>
                <ol className="mt-3 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                    {for w in plan.weeks {
                        <li
                            key={w.week_number}
                            className={"flex flex-col rounded-xl border bg-white p-4 " + ("border-sage ring-2 ring-sage/20" if w.start_date <= today_iso and today_iso <= w.end_date else "border-teal-50")}
                        >
                            <div className="flex items-center justify-between gap-2">
                                <span className="text-xs font-semibold uppercase tracking-wider text-teal-400">Week {w.week_number}</span>
                                {if w.start_date <= today_iso and today_iso <= w.end_date {
                                    <Badge tone="sage">This week</Badge>
                                } else {
                                    <span className="text-xs text-teal-400">{format_date(w.start_date)} to {format_date(w.end_date)}</span>
                                }}
                            </div>
                            <p className="mt-2 text-sm font-semibold text-teal">{w.strand}</p>
                            <Badge tone="eucalyptus" className="mt-1 w-fit">{w.learning_area}</Badge>
                            <p className="mt-2 text-sm text-teal-400">{w.focus}</p>
                            <ul className="mt-2 flex-1 list-disc space-y-1 pl-4 text-sm marker:text-sage">
                                {for (i, act) in enumerate(w.activities) {
                                    <li key={i}>{act}</li>
                                }}
                            </ul>
                            <div className="mt-3 space-y-1 border-t border-ivory-dark pt-2 text-xs text-teal-400">
                                <p className="flex items-center gap-1.5"><Clock size={12} aria-hidden="true"/> {w.daily_minutes} minutes a day</p>
                                <p className="flex items-start gap-1.5"><CheckCircle size={12} className="mt-0.5 shrink-0 text-sage" aria-hidden="true"/> {w.checkpoint}</p>
                            </div>
                        </li>
                    }}
                </ol>
                <div className="mt-4 grid gap-3 md:grid-cols-[2fr_1fr]">
                    <div className="rounded-xl bg-white p-4">
                        <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-teal-400">Study tips</p>
                        <ul className="list-disc space-y-1 pl-4 text-sm marker:text-sage">
                            {for (i, tip) in enumerate(plan.study_tips) {
                                <li key={i}>{tip}</li>
                            }}
                        </ul>
                    </div>
                    <div className="rounded-xl bg-eucalyptus-50 p-4 text-sm">
                        <p className="mb-1 flex items-center gap-1.5 font-semibold text-sage-700"><HeartPulse size={14} aria-hidden="true"/> Rest and wellbeing</p>
                        <p>{plan.wellbeing_note}</p>
                    </div>
                </div>
            } else {
                <EmptyState icon={<CalendarDays size={28} aria-hidden="true"/>} title="Your revision calendar will appear here">
                    Enter your term dates and Msingi spreads your learning areas across the weeks, with a review week at the end.
                </EmptyState>
            }}
        </div>
    </Card>
}
