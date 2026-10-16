"""Banner describing the selected benchmark grade and its learning areas."""

import from "lucide-react" { CalendarClock, Target, Users }
import from ..models { GradeSummary, GradeCurriculum }
import from ..shared.ui { Badge }

def:pub Fact(icon: any, label: str, value: str) -> JsxElement {
    <div className="flex gap-3 rounded-xl bg-teal-600/70 px-3 py-2.5">
        <span className="mt-0.5 shrink-0 text-eucalyptus">{icon}</span>
        <div>
            <dt className="text-[11px] uppercase tracking-wider text-teal-200">{label}</dt>
            <dd className="text-teal-50">{value}</dd>
        </div>
    </div>
}

def:pub GradeOverview(grade: GradeSummary, curriculum: GradeCurriculum | None) -> JsxElement {
    areas = curriculum.areas if curriculum else [];

    <section className="overflow-hidden rounded-2xl bg-teal text-white shadow-card print:hidden">
        <div className="grid gap-4 p-5 sm:p-6 md:grid-cols-[1.4fr_1fr]">
            <div>
                <p className="text-xs font-semibold uppercase tracking-wider text-eucalyptus">{grade.stage}</p>
                <h2 className="mt-1 font-serif text-2xl font-bold">{grade.label}</h2>
                <p className="mt-2 text-sm text-teal-100">{grade.focus}</p>
                <div className="mt-4 flex flex-wrap gap-2">
                    {for a in areas {
                        <Badge key={a.id} tone="eucalyptus">
                            {a.name}
                            {a.pathway and <span className="text-sage-600">· {a.pathway}</span>}
                        </Badge>
                    }}
                </div>
            </div>
            <dl className="grid content-start gap-3 text-sm">
                <Fact icon={<Users size={16} aria-hidden="true"/>} label="Age range" value={grade.age_range}/>
                <Fact icon={<Target size={16} aria-hidden="true"/>} label="Benchmark assessment" value={grade.assessment}/>
                <Fact
                    icon={<CalendarClock size={16} aria-hidden="true"/>}
                    label="Lesson / home study"
                    value={f"{grade.lesson_minutes} min lessons, about {grade.daily_study_minutes} min a day at home"}
                />
            </dl>
        </div>
    </section>
}
