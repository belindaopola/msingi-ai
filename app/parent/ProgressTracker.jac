"""Holistic progress tracker: learning areas, core competencies and values, using KNEC levels."""

import from "lucide-react" { Activity, Award, StickyNote }
import from ..endpoints { get_learner_progress }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, LearnerProgress as LearnerProgressData }
import from ..shared.constants { KNEC_LEVELS }
import from ..shared.browser { error_text }
import from ..shared.ui { Badge, Card, ErrorNote, LevelBadge, ProgressBar, SectionLabel }

def:pub ProgressTracker(grade: GradeSummaryData) -> JsxElement {
    has progress: LearnerProgressData | None = None,
        loading: bool = True,
        error: str = "";

    async can with entry {
        try {
            response = root spawn get_learner_progress(grade_level=grade.code);
            progress = response.reports[0];
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    <Card
        id="progress"
        icon={<Activity size={18} aria-hidden="true"/>}
        title="Holistic Progress Tracker"
        subtitle={f"{progress.learner_name}, {progress.grade_code} at {progress.school}" if progress else "Learning areas, core competencies and values, using KNEC performance levels."}
    >
        <ErrorNote message={error}/>
        {loading and <p className="text-sm text-teal-400">Loading progress...</p>}
        {if progress {
            <div className="grid gap-6 lg:grid-cols-[1.3fr_1fr]">
                <div>
                    <SectionLabel>Learning areas</SectionLabel>
                    <ul className="space-y-3">
                        {for a in progress.areas {
                            <li key={a.learning_area} className="rounded-xl bg-white p-3">
                                <div className="flex items-center gap-3">
                                    <LevelBadge code={a.level_code}/>
                                    <div className="min-w-0 flex-1">
                                        <div className="flex flex-wrap items-baseline justify-between gap-x-2">
                                            <p className="text-sm font-semibold">{a.learning_area}</p>
                                            <p className="text-xs text-teal-400">{a.level_label}</p>
                                        </div>
                                        <div className="mt-1.5">
                                            <ProgressBar value={a.score} max={4} tone={"sage" if a.score >= 3 else "ochre"} label={a.learning_area + " level"}/>
                                        </div>
                                    </div>
                                </div>
                                <p className="mt-2 text-xs text-teal-400">{a.comment}</p>
                            </li>
                        }}
                    </ul>
                    <div className="mt-3 flex flex-wrap gap-3 text-[11px] text-teal-400">
                        {for l in KNEC_LEVELS {
                            <span key={l["code"]} className="inline-flex items-center gap-1">
                                <LevelBadge code={l["code"]}/> {l["label"]}
                            </span>
                        }}
                    </div>
                </div>

                <div className="space-y-5">
                    <div>
                        <SectionLabel>Core competencies</SectionLabel>
                        <ul className="space-y-2.5 rounded-xl bg-white p-3">
                            {for (name, score) in progress.competency_scores.items() {
                                <li key={name}>
                                    <div className="mb-1 flex justify-between text-xs">
                                        <span>{name}</span>
                                        <span className="text-teal-400">{score}/4</span>
                                    </div>
                                    <ProgressBar value={score} max={4} label={name}/>
                                </li>
                            }}
                        </ul>
                    </div>
                    <div>
                        <SectionLabel>
                            <span className="inline-flex items-center gap-1"><Award size={13} aria-hidden="true"/> Values observed</span>
                        </SectionLabel>
                        <div className="flex flex-wrap gap-2">
                            {for v in progress.values_observed {
                                <Badge key={v} tone="eucalyptus">{v}</Badge>
                            }}
                        </div>
                    </div>
                    <div className="rounded-xl border border-ochre/40 bg-ochre-50 p-3 text-sm">
                        <p className="mb-1 flex items-center gap-1.5 font-semibold text-ochre-700">
                            <StickyNote size={14} aria-hidden="true"/> Note from the teacher
                        </p>
                        <p>{progress.teacher_note}</p>
                        {progress.parent_name and <p className="mt-2 text-xs text-teal-400">Shared with {progress.parent_name}</p>}
                    </div>
                </div>
            </div>
        }}
    </Card>
}
