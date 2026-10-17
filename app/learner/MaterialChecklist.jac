# By Mara Msingi

import from "lucide-react" { BellRing, ListChecks, ShieldAlert }
import from ..models { GradeSummary, GradeCurriculum, RevisionResult }
import from ..endpoints { save_checklist_progress }
import from ..shared.ui { Card, EmptyState, ProgressBar, ErrorNote }

"""Before a plan exists, preview locally available materials from the curriculum graph."""
def preview_items(curriculum: GradeCurriculum | None) -> list[dict[str, str]] {
    seen: list[str] = [];
    preview: list[dict[str, str]] = [];
    if not curriculum { return preview; }
    for area in curriculum.areas {
        for strand in area.children {
            for sub in strand.children {
                for m in sub.local_materials {
                    if m.lower() not in seen and len(preview) < 8 {
                        seen.append(m.lower());
                        preview.append({"item": m, "purpose": "For " + sub.name, "quantity": "", "where_to_find": "Home or school compound", "safety_note": ""});
                    }
                }
            }
        }
    }
    return preview;
}

def:pub MaterialChecklist(grade: GradeSummary, curriculum: GradeCurriculum | None, revision: RevisionResult | None) -> JsxElement {
    has checked: dict[str, bool] = {},
        busy_item: str = "",
        error: str = "";

    planned = revision.plan.material_checklist if revision else [];
    items: list[any] = planned if planned else preview_items(curriculum);
    plan_key = revision.plan_id if revision else "preview-" + grade.code;

    async def toggle(item: str) -> None {
        if busy_item { return; }
        busy_item = item;
        error = "";
        try {
            next_checked: dict[str, bool] = {**checked};
            next_checked[item] = not bool(checked[item]);
            saved = await save_checklist_progress(plan_key, grade.code, item, next_checked[item]);
            checked = saved;
        } except Exception as err {
            error = str(err);
        }
        busy_item = "";
    }

    done = len([i for i in items if checked[i.item]]);
    remaining = len(items) - done;

    return <Card
        id="checklist"
        icon={<ListChecks size={18} aria-hidden="true"/>}
        title="Practical Material Collection Checklist"
        subtitle={"Collect these before the term gets busy." if revision else "Preview from your curriculum. Build a revision plan for a personalised list."}
    >
        <ErrorNote message={error}/>
        {if not items {
            <EmptyState icon={<ListChecks size={28} aria-hidden="true"/>} title="No materials yet"/>
        } else {
            <div className="mb-4 space-y-2">
                <div className="flex items-center justify-between text-sm"><span className="font-medium">{done} of {len(items)} collected</span><span className="text-teal-400">{round(done / len(items) * 100)}%</span></div>
                <ProgressBar value={done} max={len(items)} label="Materials collected"/>
                {remaining > 0 and <p className="flex items-center gap-2 rounded-lg bg-ochre-100 px-3 py-2 text-sm text-ochre-700"><BellRing size={14} aria-hidden="true"/> {remaining} {"item" if remaining == 1 else "items"} still to collect</p>}
            </div>
            <ul className="space-y-2">
                {for m in items {
                    <li key={m.item}>
                        <label className={"flex cursor-pointer gap-3 rounded-xl border p-3 transition " + ("border-eucalyptus bg-eucalyptus-50" if checked[m.item] else "border-teal-50 bg-white hover:border-eucalyptus")}>
                            <input type="checkbox" className="mt-1 h-4 w-4 shrink-0 accent-sage" checked={bool(checked[m.item])} disabled={busy_item != ""} onChange={lambda (e: ChangeEvent) { toggle(m.item); }}/>
                            <span className="min-w-0">
                                <span className={"block text-sm font-semibold " + ("text-teal-400 line-through" if checked[m.item] else "text-teal")}>{m.item}{m.quantity and <span className="ml-2 text-xs font-normal text-sage">{m.quantity}</span>}</span>
                                <span className="block text-xs text-teal-400">{m.purpose} · {m.where_to_find}</span>
                                {m.safety_note and <span className="mt-1 inline-flex items-center gap-1 text-xs text-ochre-700"><ShieldAlert size={12} aria-hidden="true"/> {m.safety_note}</span>}
                            </span>
                        </label>
                    </li>
                }}
            </ul>
        }}
    </Card>;
}
