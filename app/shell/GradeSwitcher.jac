"""Prominent benchmark grade tab bar: PP2, Grade 3, Grade 6, Grade 9, Grade 12."""

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

    <div className="mx-auto w-full max-w-6xl px-4 pb-3 pt-4 sm:px-8">
        <div
            role="tablist"
            aria-label="Benchmark grade"
            onKeyDown={handle_key}
            className="scrollbar-none flex gap-2 overflow-x-auto rounded-2xl bg-ivory p-1.5"
        >
            {for t in tabs {
                <button
                    key={t["code"]}
                    role="tab"
                    aria-selected={t["code"] == gradeCode}
                    tabIndex={0 if t["code"] == gradeCode else -1}
                    onClick={lambda (e: MouseEvent) { onGrade(t["code"]); }}
                    className={"flex min-w-[7.5rem] flex-1 flex-col items-center rounded-xl px-3 py-2 transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-sage " + ("bg-sage text-white shadow-card" if t["code"] == gradeCode else "text-teal hover:bg-white")}
                >
                    <span className="text-sm font-bold">{t["code"]}</span>
                    <span className={"text-[11px] " + ("text-eucalyptus-100" if t["code"] == gradeCode else "text-teal-400")}>{short_stage(t["stage"])}</span>
                </button>
            }}
        </div>
    </div>
}
