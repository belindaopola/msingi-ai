"""Parent workspace: CBC translator, home activities and the holistic progress tracker."""

import from ..endpoints { list_plans }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData, PlanSummary as PlanSummaryData }
import from .CbcTranslator { CbcTranslator }
import from .HomeActivityGuide { HomeActivityGuide }
import from .ProgressTracker { ProgressTracker }

"""The guide being read: {"guide", "source", "teacherUpdate", "fromId"}. Saved broadcasts arrive as
parsed JSON and fresh translations as ParentGuide objs; both are read by attribute."""
def:pub ParentView(grade: GradeSummaryData, curriculum: GradeCurriculumData | None) -> JsxElement {
    has broadcasts: list[dict[str, any]] = [],
        active: dict[str, any] | None = None;

    # Teacher broadcasts arrive as saved PARENT_BROADCAST plans; open the newest one by default.
    async can with entry {
        try {
            response = root spawn list_plans(grade_level=grade.code, plan_type="PARENT_BROADCAST", limit=5);
            plans: list[PlanSummaryData] = response.reports[0] if response.reports else [];
            parsed: list[dict[str, any]] = [];
            for p in plans {
                payload: any = None;
                try {
                    payload = JSON.parse(p.payload_json);
                } except Exception {
                    payload = None;
                }
                parsed.append({"plan": p, "payload": payload});
            }
            broadcasts = parsed;
            readable = [b for b in parsed if b["payload"] and b["payload"].guide];
            if readable {
                open_broadcast(readable[0]);
            }
        } except Exception {
            broadcasts = [];
        }
    }

    def open_broadcast(b: dict[str, any]) -> None {
        active = {
            "guide": b["payload"].guide,
            "source": b["plan"].source,
            "teacherUpdate": b["payload"].teacher_update,
            "fromId": b["plan"].id
        };
    }

    <div className="space-y-6">
        <div className="grid gap-6 xl:grid-cols-[1.2fr_1fr]">
            <CbcTranslator
                grade={grade}
                broadcasts={broadcasts}
                active={active}
                onOpenBroadcast={open_broadcast}
                onGuide={lambda (g: dict[str, any]) { active = g; }}
            />
            <HomeActivityGuide grade={grade} curriculum={curriculum} guide={active["guide"] if active else None}/>
        </div>
        <ProgressTracker grade={grade}/>
    </div>
}
