"""Top bar with the role switcher (Teacher, Learner, Parent)."""

import from "lucide-react" { Sprout }
import from ..shared.constants { ROLES }

def:pub Header(role: str, onRole: Callable[[str], None]) -> JsxElement {
    found = [r for r in ROLES if r["id"] == role];
    active: dict[str, any] = found[0] if found else ROLES[0];

    <div className="mx-auto flex w-full max-w-6xl flex-wrap items-center justify-between gap-3 px-4 pt-4 sm:px-8">
        <div className="flex items-center gap-3">
            <span className="grid h-9 w-9 place-items-center rounded-xl bg-teal text-eucalyptus lg:hidden">
                <Sprout size={20} aria-hidden="true"/>
            </span>
            <div>
                <h1 className="font-serif text-xl font-bold text-teal sm:text-2xl">{active["label"]} workspace</h1>
                <p className="hidden text-sm text-teal-400 sm:block">{active["blurb"]}</p>
            </div>
        </div>

        <div role="tablist" aria-label="Choose your role" className="inline-flex rounded-xl border border-teal-100 bg-white p-1">
            {for r in ROLES {
                <button
                    key={r["id"]}
                    role="tab"
                    aria-selected={r["id"] == role}
                    onClick={lambda (e: MouseEvent) { onRole(r["id"]); }}
                    className={"rounded-lg px-3 py-1.5 text-sm font-semibold transition sm:px-4 " + ("bg-sage text-white shadow-sm" if r["id"] == role else "text-teal-400 hover:text-teal")}
                >
                    {r["label"]}
                </button>
            }}
        </div>
    </div>
}
