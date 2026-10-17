# By Mara Msingi

import from "@jac/runtime" { jacLogout, useNavigate }
import from "lucide-react" { BookOpenCheck, GraduationCap, HeartHandshake, LogOut, Sprout, CalendarDays, ClipboardCheck, MessageCircleQuestion }

glob ROLE_ICONS: dict[str, any] = {
    "TEACHER": <BookOpenCheck size={18} aria-hidden="true"/>,
    "LEARNER": <GraduationCap size={18} aria-hidden="true"/>,
    "PARENT": <HeartHandshake size={18} aria-hidden="true"/>
};
glob TOOL_ICONS: dict[str, any] = {
    "revision": <CalendarDays size={15} aria-hidden="true"/>,
    "checklist": <ClipboardCheck size={15} aria-hidden="true"/>,
    "tutor": <MessageCircleQuestion size={15} aria-hidden="true"/>
};

def:pub Sidebar(role: str, status: str) -> JsxElement {
    nav = useNavigate();
    label = "Teacher" if role == "TEACHER" else ("Learner" if role == "LEARNER" else "Parent");
    panels: list[dict[str, str]] = [];
    if role == "TEACHER" {
        panels = [{"id":"lesson-plan", "label":"Lesson Plan Generator"},{"id":"materials", "label":"Material Planner"},{"id":"broadcast", "label":"Parent Broadcast"}];
    } elif role == "LEARNER" {
        panels = [{"id":"revision", "label":"Revision Calendar"},{"id":"checklist", "label":"Material Checklist"},{"id":"tutor", "label":"Mwalimu Taratibu"}];
    } else {
        panels = [{"id":"translator", "label":"CBE Translator"},{"id":"home-activities", "label":"Home Activity Guide"},{"id":"progress", "label":"Progress Tracker"}];
    }
    dot = "bg-eucalyptus" if status == "online" else ("bg-ochre" if status == "offline" else "animate-pulse bg-teal-200");
    status_text = "Jac service connected" if status == "online" else ("Service unreachable" if status == "offline" else "Connecting...");
    def do_logout(e: MouseEvent) {
        jacLogout();
        nav("/account");
    }
    return <aside data-theme={role.lower()} className="role-sidebar sticky top-0 hidden h-screen w-64 shrink-0 flex-col text-teal-100 lg:flex print:hidden">
        <div className="flex items-center gap-3 px-6 py-6">
            <span className="grid size-10 place-items-center rounded-xl bg-white/10 text-white ring-1 ring-white/15"><Sprout size={22} aria-hidden="true"/></span>
            <div><p className="font-serif text-xl font-bold text-white">Msingi AI</p><p className="text-xs text-white/65">CBE companion</p></div>
        </div>
        <div className="mx-3 flex items-center gap-3 rounded-xl border border-[var(--role-secondary)] bg-white/5 px-3 py-3 text-sm font-semibold text-white shadow-sm">
            <span className="drop-shadow-[0_0_6px_var(--role-secondary)]">{ROLE_ICONS[role]}</span>{label} workspace
        </div>
        <nav aria-label={label + " tools"} className="mt-6 px-3">
            <p className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-wider text-teal-200">{label} tools</p>
            {for p in panels {
                tool_icon = TOOL_ICONS[p["id"]] if p["id"] in TOOL_ICONS else None;
                <a key={p["id"]} href={"#" + p["id"]} className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-teal-100 transition hover:bg-white/5 hover:text-white">
                    {tool_icon and <span className="text-ochre">{tool_icon}</span>}{p["label"]}
                </a>
            }}
        </nav>
        <div className="mt-auto space-y-4 px-6 py-6 text-xs">
            <div className="flex items-center gap-2"><span className={"size-2 rounded-full " + dot} aria-hidden="true"/><span>{status_text}</span></div>
            <button onClick={do_logout} className="flex items-center gap-2 text-teal-200 hover:text-white"><LogOut size={15} aria-hidden="true"/> Sign out</button>
        </div>
    </aside>;
}
