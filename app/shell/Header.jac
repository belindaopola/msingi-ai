
import from "lucide-react" { Sprout }

glob WORKSPACES: list[list[str]] = [["TEACHER", "Teacher"], ["LEARNER", "Learner"], ["PARENT", "Parent"]];

def:pub Header(role: str, allAccess: bool = False, onRole: Callable[[str], None] | None = None) -> JsxElement {
    label = "Teacher" if role == "TEACHER" else ("Learner" if role == "LEARNER" else "Parent");
    blurb = "Plan KICD lessons, gather local materials and update parents." if role == "TEACHER" else ("Plan your revision and learn at your pace." if role == "LEARNER" else "Support learning and understand CBE progress.");
    return <div className="mx-auto flex w-full max-w-6xl flex-wrap items-center justify-between gap-3 px-4 pt-4 sm:px-8">
        <div className="flex items-center gap-3">
            <span className="grid h-9 w-9 place-items-center rounded-xl bg-teal text-eucalyptus lg:hidden"><Sprout size={20} aria-hidden="true"/></span>
            <div>
                <h1 className="font-serif text-xl font-bold text-teal sm:text-2xl">{label} workspace</h1>
                <p className="hidden text-sm text-teal-400 sm:block">{blurb}</p>
            </div>
        </div>
        {if allAccess and onRole {
            <div role="tablist" aria-label="Choose a workspace" className="inline-flex rounded-xl border border-teal-100 bg-white p-1">
                {for w in WORKSPACES {
                    <button
                        key={w[0]}
                        type="button"
                        role="tab"
                        aria-selected={w[0] == role}
                        onClick={lambda (e: MouseEvent) { onRole(w[0]); }}
                        className={"rounded-lg px-3 py-1.5 text-sm font-semibold transition sm:px-4 " + ("bg-sage text-white shadow-sm" if w[0] == role else "text-teal-400 hover:text-teal")}
                    >
                        {w[1]}
                    </button>
                }}
            </div>
        } else {
            <span className="rounded-full border border-teal-100 bg-white px-3 py-1.5 text-xs font-semibold text-teal-400">Signed-in role</span>
        }}
    </div>;
}
