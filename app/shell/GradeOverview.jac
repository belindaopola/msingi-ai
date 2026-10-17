
import from "lucide-react" { CalendarClock, Target, Users, FlaskConical, Palette, Globe2 }
import from ..models { GradeSummary, GradeCurriculum }
import from ..shared.ui { Badge }

def:pub Fact(icon: any, label: str, value: str) -> JsxElement {
    return <div className="role-fact flex gap-3 px-3 py-3">
        <span className="mt-0.5 shrink-0 text-eucalyptus">{icon}</span>
        <div>
            <dt className="text-[11px] uppercase tracking-wider text-white/65">{label}</dt>
            <dd className="text-sm text-white">{value}</dd>
        </div>
    </div>;
}

def:pub GradeOverview(grade: GradeSummary, curriculum: GradeCurriculum | None) -> JsxElement {
    areas = curriculum.areas if curriculum else [];

    return <section className="role-hero relative isolate overflow-hidden rounded-3xl text-white shadow-[0_18px_48px_rgba(19,40,56,0.18)] print:hidden">
        <div className="pointer-events-none absolute -right-14 -top-20 -z-10 size-72 rounded-full border border-white/10 bg-white/[0.03]" />
        <div className="pointer-events-none absolute -bottom-28 left-1/3 -z-10 size-64 rounded-full border border-white/10 bg-white/[0.03]" />
        <div className="grid gap-5 p-5 sm:p-7 md:grid-cols-[1.4fr_1fr] md:gap-8">
            <div className="flex flex-col items-start">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-eucalyptus">{grade.stage}</p>
                <h2 className="mt-2 font-serif text-3xl font-bold tracking-tight">{grade.label}</h2>
                <p className="mt-2 max-w-2xl text-sm leading-relaxed text-white/80">{grade.focus}</p>
                <div className="mt-5 flex flex-wrap gap-2">
                    {for a in areas {
                        icon = <Globe2 size={13} aria-hidden="true"/>;
                        if "Computer Science" in a.name { icon = <FlaskConical size={13} aria-hidden="true"/>; }
                        elif "Sports" in a.name or "Creative" in a.name { icon = <Palette size={13} aria-hidden="true"/>; }
                        <Badge key={a.id} tone="eucalyptus" className="inline-flex items-center gap-1.5 rounded-full border border-white/20 bg-[#dce9e0] px-3 py-1 text-[#132838]">
                            {icon}{a.name}
                            {a.pathway and <span className="text-sage-700">· {a.pathway}</span>}
                        </Badge>
                    }}
                </div>
            </div>
            <dl className="grid content-start gap-3 text-sm">
                <Fact icon={<Users size={17} aria-hidden="true"/>} label="Age range" value={grade.age_range}/>
                <Fact icon={<Target size={17} aria-hidden="true"/>} label="Benchmark assessment" value={grade.assessment}/>
                <Fact
                    icon={<CalendarClock size={17} aria-hidden="true"/>}
                    label="Lesson / home study"
                    value={f"{grade.lesson_minutes} min lessons, about {grade.daily_study_minutes} min a day at home"}
                />
            </dl>
        </div>
    </section>;
}
