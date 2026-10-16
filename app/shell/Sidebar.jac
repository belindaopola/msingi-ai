"""Desktop sidebar: role navigation, tool anchors for the active role, server status and demo reset."""

import from "lucide-react" { BookOpenCheck, GraduationCap, HeartHandshake, RotateCcw, Sprout }
import from ..shared.constants { ROLES }

glob ROLE_ICONS: dict[str, any] = {
    "TEACHER": <BookOpenCheck size={18} aria-hidden="true"/>,
    "LEARNER": <GraduationCap size={18} aria-hidden="true"/>,
    "PARENT": <HeartHandshake size={18} aria-hidden="true"/>
};

def:pub Sidebar(
    role: str,
    onRole: Callable[[str], None],
    status: str,
    onReset: Callable[[], None]
) -> JsxElement {
    def confirm_reset(e: MouseEvent) {
        if window.confirm("Reset all demo data? Saved plans and tutor chats will be cleared.") {
            onReset();
        }
    }

    found = [r for r in ROLES if r["id"] == role];
    active: dict[str, any] = found[0] if found else ROLES[0];
    dot = "bg-eucalyptus" if status == "online" else ("bg-ochre" if status == "offline" else "animate-pulse bg-teal-200");
    status_text = "Jac service connected" if status == "online" else ("Service unreachable" if status == "offline" else "Connecting...");

    <aside className="sticky top-0 hidden h-screen w-64 shrink-0 flex-col bg-teal text-teal-100 lg:flex print:hidden">
        <div className="flex items-center gap-3 px-6 py-6">
            <span className="grid h-10 w-10 place-items-center rounded-xl bg-sage text-white">
                <Sprout size={22} aria-hidden="true"/>
            </span>
            <div>
                <p className="font-serif text-xl font-bold text-white">Msingi AI</p>
                <p className="text-xs text-eucalyptus">CBC companion</p>
            </div>
        </div>

        <nav aria-label="Roles" className="px-3">
            <p className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-wider text-teal-200">Workspace</p>
            {for r in ROLES {
                <button
                    key={r["id"]}
                    onClick={lambda (e: MouseEvent) { onRole(r["id"]); }}
                    aria-current={"page" if r["id"] == role else None}
                    className={"mb-1 flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-medium transition " + ("bg-sage text-white" if r["id"] == role else "text-teal-100 hover:bg-teal-600")}
                >
                    {ROLE_ICONS[r["id"]]}
                    {r["label"]}
                </button>
            }}
        </nav>

        <nav aria-label={active["label"] + " tools"} className="mt-6 px-3">
            <p className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-wider text-teal-200">{active["label"]} tools</p>
            {for p in active["panels"] {
                <a key={p["id"]} href={"#" + p["id"]} className="block rounded-lg px-3 py-2 text-sm text-teal-100 hover:bg-teal-600 hover:text-white">
                    {p["label"]}
                </a>
            }}
        </nav>

        <div className="mt-auto space-y-3 px-6 py-6 text-xs">
            <div className="flex items-center gap-2">
                <span className={"h-2 w-2 rounded-full " + dot} aria-hidden="true"/>
                <span>{status_text}</span>
            </div>
            <button onClick={confirm_reset} className="flex items-center gap-2 text-teal-200 hover:text-white">
                <RotateCcw size={14} aria-hidden="true"/> Reset demo data
            </button>
        </div>
    </aside>
}
