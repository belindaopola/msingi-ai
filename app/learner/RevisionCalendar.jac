
import from "lucide-react" { CalendarDays, CheckCircle, Clock, HeartPulse, Wand2, Sparkles, Check, Leaf, UserRound }
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
    greeting_name = learnerName.strip() or "Learner";

    return <Card
        id="revision"
        icon={<CalendarDays size={18} aria-hidden="true"/>}
        title="Termly Revision Calendar"
        subtitle={f"Week-by-week plan for {grade.label}, paced for {grade.age_range} (about {grade.daily_study_minutes} minutes a day)."}
        actions={revision and <SourceBadge source={revision.source}/>}
        className="relative isolate overflow-hidden border-ivory-dark/80 bg-[radial-gradient(ellipse_at_bottom_right,#e1eee3_0%,#f4f1ea_48%,#ffffff_100%)] shadow-[0_14px_40px_rgba(30,61,89,0.08)]"
    >
        <div className="pointer-events-none absolute -right-8 bottom-12 -z-10 text-sage-500/10"><Leaf size={116} aria-hidden="true"/></div>
        <div className="mb-4 flex items-center justify-end gap-2 rounded-xl border border-white/70 bg-white/55 px-3 py-2 shadow-sm backdrop-blur-sm">
            <Sparkles size={15} className="text-ochre" aria-hidden="true"/>
            <span className="text-sm font-semibold text-teal">Habari, {greeting_name}!</span>
            <span className="grid size-8 place-items-center rounded-full bg-[var(--role-surface-tint)] text-[var(--role-primary)]"><UserRound size={16} aria-hidden="true"/></span>
        </div>
        <form onSubmit={submit} className="grid gap-4 md:grid-cols-4">
            <Field label="Term starts"><Input kind="date" value={term["start"]} onValue={lambda (v: str) { term = {**term, "start": v}; }} required={True}/></Field>
            <Field label="Term ends"><Input kind="date" value={term["end"]} min={term["start"]} onValue={lambda (v: str) { term = {**term, "end": v}; }} required={True}/></Field>
            <Field label="Your first name" hint="Personalizes your greeting and revision plan."><Input value={learnerName} onValue={lambda (v: str) { learnerName = v; }} placeholder="e.g. Wanjiku"/></Field>
            <div className="flex items-end">
                <Button submit={True} icon={<Wand2 size={16} aria-hidden="true"/>} loading={loading} className="role-cta w-full rounded-full border-0 text-white transition-transform active:scale-[0.98]">
                    Build my plan
                </Button>
            </div>
            <fieldset className="md:col-span-4">
                <legend className="mb-2 text-sm font-semibold text-teal">Areas to focus on <span className="font-normal text-teal-400">(optional)</span></legend>
                <div className="flex flex-wrap gap-2">
                    {for a in areas {
                        selected = a.name in focus;
                        <button type="button" key={a.id} aria-pressed={selected} onClick={lambda (e: MouseEvent) { toggle_focus(a.name); }} className={"inline-flex items-center gap-1.5 rounded-full border px-3.5 py-2 text-xs font-semibold transition hover:-translate-y-0.5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--role-primary)] " + ("border-[var(--role-primary)] bg-[var(--role-surface-tint)] text-[var(--role-primary)] shadow-sm" if selected else "border-ivory-dark bg-white/85 text-teal hover:border-[var(--role-secondary)]")}>
                            {selected and <Check size={13} aria-hidden="true"/>}{a.name}
                        </button>
                    }}
                </div>
                <p className="mt-2 text-xs text-teal-400">With no selection, Msingi starts with areas where your progress record says you are still Approaching Expectations.</p>
            </fieldset>
        </form>
        <ErrorNote message={error}/>
        <div className="mt-6">
            {if plan {
                <h3 className="font-serif text-xl font-semibold text-teal">{plan.title}</h3>
                <ol className="mt-3 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                    {for w in plan.weeks {
                        <li key={w.week_number} className={"flex flex-col rounded-2xl border bg-white/90 p-4 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md " + ("border-[var(--role-primary)] ring-2 ring-[var(--role-primary)]/20" if w.start_date <= today_iso and today_iso <= w.end_date else "border-ivory-dark")}>
                            <div className="flex items-center justify-between gap-2">
                                <span className="text-xs font-semibold uppercase tracking-wider text-teal-400">Week {w.week_number}</span>
                                {if w.start_date <= today_iso and today_iso <= w.end_date { <Badge tone="sage">This week</Badge> } else { <span className="text-xs text-teal-400">{format_date(w.start_date)} to {format_date(w.end_date)}</span> }}
                            </div>
                            <p className="mt-2 text-sm font-semibold text-teal">{w.strand}</p>
                            <Badge tone="eucalyptus" className="mt-1 w-fit">{w.learning_area}</Badge>
                            <p className="mt-2 text-sm text-teal-400">{w.focus}</p>
                            <ul className="mt-2 flex-1 list-disc space-y-1 pl-4 text-sm marker:text-sage">
                                {for (i, act) in enumerate(w.activities) { <li key={i}>{act}</li> }}
                            </ul>
                            <div className="mt-3 space-y-1 border-t border-ivory-dark pt-2 text-xs text-teal-400">
                                <p className="flex items-center gap-1.5"><Clock size={12} aria-hidden="true"/> {w.daily_minutes} minutes a day</p>
                                <p className="flex items-start gap-1.5"><CheckCircle size={12} className="mt-0.5 shrink-0 text-sage" aria-hidden="true"/> {w.checkpoint}</p>
                            </div>
                        </li>
                    }}
                </ol>
                <div className="mt-4 grid gap-3 md:grid-cols-[2fr_1fr]">
                    <div className="rounded-2xl border border-white/70 bg-white/85 p-4 shadow-sm">
                        <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-teal-400">Study tips</p>
                        <ul className="list-disc space-y-1 pl-4 text-sm marker:text-sage">{for (i, tip) in enumerate(plan.study_tips) { <li key={i}>{tip}</li> }}</ul>
                    </div>
                    <div className="rounded-2xl border border-eucalyptus-100 bg-eucalyptus-50 p-4 text-sm">
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
    </Card>;
}
