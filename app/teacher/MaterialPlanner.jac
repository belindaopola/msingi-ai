# By Mara Msingi
"""Locally available material planner: free and low-cost items scaled to the class."""

import from "lucide-react" { Package, ShieldAlert, Wand2 }
import from ..endpoints { plan_class_materials }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData, MaterialPlanResult as MaterialPlanResultData }
import from ..shared.useCurriculumPicker { useCurriculumPicker }
import from ..shared.constants { DEMO_TEACHER_NAME }
import from ..shared.browser { error_text, to_int }
import from ..shared.ui { Button, Card, EmptyState, ErrorNote, Field, Input, Select, SourceBadge }

def:pub MaterialPlanner(grade: GradeSummaryData, curriculum: GradeCurriculumData | None) -> JsxElement {
    has classSize: str = "40",
        result: MaterialPlanResultData | None = None,
        loading: bool = False,
        error: str = "";

    picker = useCurriculumPicker(curriculum, False);

    async def submit(e: FormEvent) -> None {
        e.preventDefault();
        loading = True;
        error = "";
        try {
            response = root spawn plan_class_materials(
                grade_level=grade.code,
                learning_area=picker["areaName"],
                strand=picker["strandName"],
                class_size=to_int(classSize, 40),
                teacher_name=DEMO_TEACHER_NAME
            );
            result = response.reports[0];
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    <Card
        id="materials"
        icon={<Package size={18} aria-hidden="true"/>}
        title="Locally Available Material Planner"
        subtitle="Free and low-cost materials from home, school and market, scaled to your class."
        actions={result and <SourceBadge source={result.source}/>}
    >
        <form onSubmit={submit} className="grid gap-3 sm:grid-cols-3">
            <Field label="Learning area" className="sm:col-span-3">
                <Select value={picker["areaName"]} onValue={picker["setAreaName"]} options={[a.name for a in picker["areas"]]}/>
            </Field>
            <Field label="Strand" className="sm:col-span-2">
                <Select value={picker["strandName"]} onValue={picker["setStrandName"]} placeholder="All strands" options={[s.name for s in picker["strands"]]}/>
            </Field>
            <Field label="Class size">
                <Input kind="number" min="1" max="120" value={classSize} onValue={lambda (v: str) { classSize = v; }}/>
            </Field>
            <div className="sm:col-span-3">
                <Button submit={True} icon={<Wand2 size={16} aria-hidden="true"/>} loading={loading} disabled={not picker["areaName"]}>
                    Plan materials
                </Button>
            </div>
        </form>

        <ErrorNote message={error}/>

        <div className="mt-5">
            {if result {
                <ul className="divide-y divide-ivory-dark rounded-xl border border-teal-50 bg-white">
                    {for (i, m) in enumerate(result.materials) {
                        <li key={i} className="px-4 py-3">
                            <div className="flex flex-wrap items-baseline justify-between gap-2">
                                <p className="font-semibold text-teal">{m.item}</p>
                                <span className="text-xs font-medium text-sage">{m.quantity}</span>
                            </div>
                            <p className="mt-0.5 text-sm text-teal-400">{m.purpose}</p>
                            <p className="mt-1 text-xs text-teal-400">Where to find: {m.where_to_find}</p>
                            {m.safety_note and <p className="mt-1.5 inline-flex items-center gap-1.5 rounded-lg bg-ochre-100 px-2 py-1 text-xs text-ochre-700">
                                <ShieldAlert size={12} aria-hidden="true"/> {m.safety_note}
                            </p>}
                        </li>
                    }}
                </ul>
            } else {
                <EmptyState icon={<Package size={28} aria-hidden="true"/>} title="Plan your practical materials">
                    Msingi suggests bottle tops, sisal, clay and other items learners can bring from home.
                </EmptyState>
            }}
        </div>
    </Card>
}
