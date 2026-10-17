
import from "lucide-react" { Sprout }

def:pub Header(role: str) -> JsxElement {
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
        <span className="rounded-full border border-teal-100 bg-white px-3 py-1.5 text-xs font-semibold text-teal-400">Signed-in role</span>
    </div>;
}
