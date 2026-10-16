"""Parent broadcast: teachers write in CBC terms; parents receive a plain-language guide."""

import from "lucide-react" { CheckCircle2, Megaphone, Send }
import from ..endpoints { translate_for_parent, list_plans }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { ParentGuideResult as ParentGuideResultData, PlanSummary as PlanSummaryData }
import from ..models { GradeSummary, GradeCurriculum }
import from ..shared.constants { LANGUAGES, SAMPLE_TEACHER_UPDATES, DEMO_TEACHER_NAME }
import from ..shared.browser { error_text, format_date }
import from ..shared.ui { Button, Card, ErrorNote, Field, Select, SourceBadge, TextArea }

def:pub ParentBroadcast(grade: GradeSummary, curriculum: GradeCurriculum | None) -> JsxElement {
    has update: str = SAMPLE_TEACHER_UPDATES[grade.code] or "",
        area: str = "",
        language: str = "English",
        history: list[PlanSummaryData] = [],
        result: ParentGuideResultData | None = None,
        loading: bool = False,
        error: str = "";

    async can with entry {
        await load_history();
    }

    async def load_history -> None {
        try {
            response = root spawn list_plans(grade_level=grade.code, plan_type="PARENT_BROADCAST", limit=5);
            history = response.reports[0] if response.reports else [];
        } except Exception {
            history = [];
        }
    }

    async def submit(e: FormEvent) -> None {
        e.preventDefault();
        loading = True;
        error = "";
        try {
            response = root spawn translate_for_parent(
                grade_level=grade.code,
                teacher_update=update,
                learning_area=area,
                language=language,
                teacher_name=DEMO_TEACHER_NAME,
                broadcast=True
            );
            result = response.reports[0];
            await load_history();
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    areas = [a.name for a in curriculum.areas] if curriculum else [];

    <Card
        id="broadcast"
        icon={<Megaphone size={18} aria-hidden="true"/>}
        title="Parent Broadcast"
        subtitle="Write your update in CBC terms. Parents receive a plain-language version with home activities."
    >
        <form onSubmit={submit} className="space-y-3">
            <Field label="Your update to parents">
                <TextArea
                    rows={4}
                    value={update}
                    onValue={lambda (v: str) { update = v; }}
                    placeholder="e.g. This week we covered the Numbers strand..."
                />
            </Field>
            <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Learning area (optional)">
                    <Select value={area} onValue={lambda (v: str) { area = v; }} placeholder="Detect from update" options={areas}/>
                </Field>
                <Field label="Parent language">
                    <Select value={language} onValue={lambda (v: str) { language = v; }} options={LANGUAGES}/>
                </Field>
            </div>
            <Button submit={True} icon={<Send size={16} aria-hidden="true"/>} loading={loading} disabled={not update.strip()}>
                Translate and send to parents
            </Button>
        </form>

        <ErrorNote message={error}/>

        {result and <div className="mt-5 rounded-xl border border-eucalyptus bg-eucalyptus-50 p-4">
            <div className="flex flex-wrap items-center justify-between gap-2">
                <p className="flex items-center gap-2 text-sm font-semibold text-sage-700">
                    <CheckCircle2 size={16} aria-hidden="true"/> Sent to {grade.label} parents
                </p>
                <SourceBadge source={result.source}/>
            </div>
            <p className="mt-2 font-serif font-semibold text-teal">{result.guide.headline}</p>
            <p className="mt-1 text-sm text-teal">{result.guide.plain_summary}</p>
            <p className="mt-2 text-xs text-teal-400">
                Includes {len(result.guide.home_activities)} home activities and {len(result.guide.jargon_buster)} jargon explanations. Linked to: {", ".join(result.retrieved)}.
            </p>
        </div>}

        {if history {
            <div className="mt-5">
                <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-teal-400">Recent broadcasts</p>
                <ul className="space-y-2">
                    {for h in history {
                        <li key={h.id} className="flex items-center justify-between gap-3 rounded-lg bg-white px-3 py-2 text-sm">
                            <span className="truncate">{h.title}</span>
                            <span className="shrink-0 text-xs text-teal-400">{format_date(h.created_at)}</span>
                        </li>
                    }}
                </ul>
            </div>
        }}
    </Card>
}
