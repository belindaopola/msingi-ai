
import from "lucide-react" { GraduationCap }

def short_stage(stage: str) -> str {
    return stage.replace(" (Pre-Primary)", "").replace("Early Years Education", "Early Years");
}

def:pub GradeSwitcher(
    tabs: list[dict[str, str]],
    gradeCode: str,
    onGrade: Callable[[str], None]
) -> JsxElement {
    def handle_key(e: KeyboardEvent) {
        codes = [t["code"] for t in tabs];
        i = codes.index(gradeCode) if gradeCode in codes else 0;
        if e.key == "ArrowRight" {
            onGrade(codes[(i + 1) % len(codes)]);
        } elif e.key == "ArrowLeft" {
            onGrade(codes[(i - 1 + len(codes)) % len(codes)]);
        }
    }

    return <div className="mx-auto w-full max-w-6xl px-4 pb-4 pt-4 sm:px-8">
        <div role="tablist" aria-label="Benchmark grade" onKeyDown={handle_key} className="scrollbar-none flex gap-3 overflow-x-auto px-1 py-1">
            {for t in tabs {
                active = t["code"] == gradeCode;
                <button
                    key={t["code"]}
                    role="tab"
                    aria-selected={active}
                    tabIndex={0 if active else -1}
                    onClick={lambda (e: MouseEvent) { onGrade(t["code"]); }}
                    className={"role-grade flex min-w-[8.5rem] flex-1 items-center justify-center gap-2 rounded-xl border bg-white px-3 py-3 text-center shadow-[0_2px_6px_rgba(0,0,0,0.04)] transition duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-[var(--role-secondary)] " + ("role-grade-active text-white" if active else "border-ivory-dark text-teal hover:border-[var(--role-secondary)]")}
                >
                    {active and <GraduationCap size={17} aria-hidden="true"/>}
                    <span className="flex flex-col items-center">
                        <span className="text-sm font-bold">{t["code"]}</span>
                        <span className={"text-[11px] " + ("text-white/80" if active else "text-teal-400")}>{short_stage(t["stage"])}</span>
                    </span>
                </button>
            }}
        </div>
    </div>;
}
