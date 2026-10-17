# By Mara Msingi
"""Activities from the active translation, or curriculum home links when nothing has been translated yet."""

import from "lucide-react" { Clock, Home }
import from ..models { GradeSummary, GradeCurriculum }
import from ..shared.ui { Badge, Card }

def curriculum_activities(grade: GradeSummary, curriculum: GradeCurriculum | None) -> list[dict[str, any]] {
    found: list[dict[str, any]] = [];
    if not curriculum {
        return found;
    }
    for area in curriculum.areas {
        for strand in area.children {
            if strand.children and len(found) < 4 {
                sub = strand.children[0];
                found.append({
                    "title": sub.name,
                    "time_minutes": max(10, round(grade.daily_study_minutes / 3)),
                    "materials": sub.local_materials[:3],
                    "steps": [sub.home_activity],
                    "link_to_learning": area.name + ": " + strand.name
                });
            }
        }
    }
    return found;
}

def:pub HomeActivityGuide(grade: GradeSummary, curriculum: GradeCurriculum | None, guide: any) -> JsxElement {
    from_guide = guide and guide.home_activities and len(guide.home_activities) > 0;
    activities: list[any] = guide.home_activities if from_guide else curriculum_activities(grade, curriculum);

    <Card
        id="home-activities"
        icon={<Home size={18} aria-hidden="true"/>}
        title="Home Activity Guide"
        subtitle={"Linked to the update you are reading." if guide else f"Everyday ideas for {grade.label}, using things you already have."}
    >
        <ul className="space-y-3">
            {for (i, a) in enumerate(activities) {
                <li key={i} className="rounded-xl border border-teal-50 bg-white p-4">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                        <p className="font-semibold text-teal">{a.title}</p>
                        <span className="inline-flex items-center gap-1 text-xs text-teal-400">
                            <Clock size={12} aria-hidden="true"/> {a.time_minutes} min
                        </span>
                    </div>
                    <ol className="mt-2 list-decimal space-y-1 pl-5 text-sm marker:text-sage">
                        {for (j, s) in enumerate(a.steps) {
                            <li key={j}>{s}</li>
                        }}
                    </ol>
                    {if a.materials {
                        <div className="mt-2 flex flex-wrap gap-1.5">
                            {for m in a.materials {
                                <Badge key={m} tone="eucalyptus">{m}</Badge>
                            }}
                        </div>
                    }}
                    <p className="mt-2 text-xs text-teal-400">{a.link_to_learning}</p>
                </li>
            }}
        </ul>
    </Card>
}
