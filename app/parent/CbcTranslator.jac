# By Mara Msingi
"""Plain-language CBE translator: turns school messages full of CBE terms into practical guidance."""

import from "lucide-react" { BookA, Inbox, Languages, MessageCircleQuestion, Sparkle, TrendingUp }
import from ..endpoints { translate_for_parent }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData }
import from ..shared.constants { LANGUAGES }
import from ..shared.browser { error_text, format_date_time }
import from ..shared.ui {
    BulletList, Button, Card, EmptyState, ErrorNote, Field, SectionLabel, Select, SourceBadge, TextArea
}

def:pub CbcTranslator(
    grade: GradeSummaryData,
    broadcasts: list[dict[str, any]],
    active: dict[str, any] | None,
    onOpenBroadcast: Callable[[dict[str, any]], None],
    onGuide: Callable[[dict[str, any]], None]
) -> JsxElement {
    has update: str = "",
        language: str = "English",
        loading: bool = False,
        error: str = "";

    async def submit(e: FormEvent) -> None {
        e.preventDefault();
        loading = True;
        error = "";
        try {
            response = root spawn translate_for_parent(
                grade_level=grade.code,
                teacher_update=update,
                language=language,
                broadcast=False
            );
            result = response.reports[0];
            onGuide({"guide": result.guide, "source": result.source, "teacherUpdate": update, "fromId": ""});
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    guide: any = active["guide"] if active else None;

    <Card
        id="translator"
        icon={<Languages size={18} aria-hidden="true"/>}
        title="Plain-language CBE Translator"
        subtitle="Turn school messages full of CBE terms into clear, practical guidance."
    >
        {if broadcasts {
            <div className="mb-4">
                <p className="mb-2 flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-teal-400">
                    <Inbox size={13} aria-hidden="true"/> From your child's teacher
                </p>
                <div className="flex flex-wrap gap-2">
                    {for b in broadcasts {
                        <button
                            key={b["plan"].id}
                            type="button"
                            onClick={lambda (e: MouseEvent) {
                                if b["payload"] and b["payload"].guide {
                                    onOpenBroadcast(b);
                                }
                            }}
                            className={"rounded-lg border px-3 py-1.5 text-left text-xs transition " + ("border-sage bg-sage-50" if active and active["fromId"] == b["plan"].id else "border-teal-100 bg-white hover:border-sage")}
                        >
                            <span className="block font-medium text-teal">{b["plan"].author or "Teacher"}</span>
                            <span className="text-teal-400">{format_date_time(b["plan"].created_at)}</span>
                        </button>
                    }}
                </div>
            </div>
        }}

        <form onSubmit={submit} className="space-y-3">
            <Field label="Paste a message from school">
                <TextArea
                    rows={3}
                    value={update}
                    onValue={lambda (v: str) { update = v; }}
                    placeholder="e.g. Your child is Approaching Expectations in the Numbers strand..."
                />
            </Field>
            <div className="flex flex-wrap items-end gap-3">
                <div className="w-40">
                    <Field label="Explain in">
                        <Select value={language} onValue={lambda (v: str) { language = v; }} options={LANGUAGES}/>
                    </Field>
                </div>
                <Button submit={True} icon={<Sparkle size={16} aria-hidden="true"/>} loading={loading} disabled={not update.strip()}>
                    Explain simply
                </Button>
            </div>
        </form>

        <ErrorNote message={error}/>

        <div className="mt-5">
            {if guide {
                <div className="space-y-5 rounded-xl bg-white p-4">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                        <h3 className="font-serif text-lg font-semibold">{guide.headline}</h3>
                        <SourceBadge source={active["source"]}/>
                    </div>
                    {active["teacherUpdate"] and <blockquote className="border-l-4 border-teal-100 pl-3 text-xs italic text-teal-400">
                        Teacher wrote: {active["teacherUpdate"]}
                    </blockquote>}
                    <p className="text-sm leading-relaxed">{guide.plain_summary}</p>
                    <div>
                        <SectionLabel>What your child is learning</SectionLabel>
                        <BulletList items={guide.what_child_is_learning}/>
                    </div>
                    <div className="grid gap-5 md:grid-cols-2">
                        <div>
                            <SectionLabel>
                                <span className="inline-flex items-center gap-1"><MessageCircleQuestion size={13} aria-hidden="true"/> Questions to ask</span>
                            </SectionLabel>
                            <BulletList items={guide.questions_to_ask}/>
                        </div>
                        <div>
                            <SectionLabel>
                                <span className="inline-flex items-center gap-1"><TrendingUp size={13} aria-hidden="true"/> Signs of progress</span>
                            </SectionLabel>
                            <BulletList items={guide.signs_of_progress}/>
                        </div>
                    </div>
                    <div>
                        <SectionLabel>
                            <span className="inline-flex items-center gap-1"><BookA size={13} aria-hidden="true"/> Jargon buster</span>
                        </SectionLabel>
                        <dl className="grid gap-2 sm:grid-cols-2">
                            {for j in guide.jargon_buster {
                                <div key={j.term} className="rounded-lg bg-ivory px-3 py-2">
                                    <dt className="text-sm font-semibold">{j.term}</dt>
                                    <dd className="text-xs text-teal-400">{j.meaning}</dd>
                                </div>
                            }}
                        </dl>
                    </div>
                    <p className="rounded-lg bg-eucalyptus-50 px-3 py-2 text-sm text-sage-700">{guide.encouragement}</p>
                </div>
            } else {
                <EmptyState icon={<Languages size={28} aria-hidden="true"/>} title="Nothing to translate yet">
                    Paste a school message above, or open a teacher broadcast when one arrives.
                </EmptyState>
            }}
        </div>
    </Card>
}
