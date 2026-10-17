
import from "@jac/runtime" { jacLogin, jacSignup, useNavigate }
import from "lucide-react" { Sprout, LockKeyhole, UserRound, ArrowRight }
sv import from ..endpoints { get_current_session, set_account_profile }
import from ..shared.ui { Button, Field, Input, Select }

 glob ACCESS_ROLES: list[dict[str, str]] = [
    {"value": "TEACHER", "label": "Teacher"},
    {"value": "LEARNER", "label": "Learner"},
    {"value": "PARENT", "label": "Parent"}
];
glob ACCESS_GRADES: list[dict[str, str]] = [
    {"value": "PP2", "label": "PP2 Early Years"},
    {"value": "Grade 3", "label": "Grade 3"},
    {"value": "Grade 6", "label": "Grade 6"},
    {"value": "Grade 9", "label": "Grade 9"},
    {"value": "Grade 12", "label": "Grade 12"}
];

def:pub AccountAccess() -> JsxElement {
    nav = useNavigate();
    has mode: str = "signup",
        name: str = "",
        email: str = "",
        password: str = "",
        role: str = "TEACHER",
        grade: str = "PP2",
        error: str = "",
        busy: bool = False;

    async def submit(e: FormEvent) -> None {
        e.preventDefault();
        if len(password) < 8 {
            error = "Use a password with at least 8 characters.";
            return;
        }
        busy = True;
        error = "";
        try {
            if mode == "signup" {
                signup_result: dict | None = None;
                signup_result = await jacSignup(email.strip(), password);
                if not signup_result["success"] {
                    error = str(signup_result["error"] or "Could not create the account.");
                    busy = False;
                    return;
                }
            }
            login_ok: bool = False;
            login_ok = await jacLogin(email.strip(), password);
            if not login_ok {
                error = "Sign in failed. Check your email and password.";
                busy = False;
                return;
            }
            existing = await get_current_session();
            if mode == "signup" or existing is None {
                profile = await set_account_profile(name.strip() or email.split("@")[0], email.strip(), role, grade);
                nav("/");
            } else {
                nav("/");
            }
        } except Exception as err {
            error = str(err) or "Account access failed. Please try again.";
        }
        busy = False;
    }

    return <div className="grid min-h-screen bg-alabaster lg:grid-cols-[1fr_1fr]">
        <aside className="relative hidden overflow-hidden bg-[linear-gradient(145deg,#132838,#1e3d59_62%,#2b547e)] px-10 py-12 text-white lg:flex lg:flex-col lg:justify-between">
            <div className="absolute -right-24 -top-24 size-96 rounded-full bg-white/5 blur-3xl"/>
            <div className="relative flex items-center gap-3">
                <span className="grid size-11 place-items-center rounded-2xl bg-white/10 ring-1 ring-white/20"><Sprout size={22}/></span>
                <div><p className="font-serif text-xl font-bold">Msingi AI</p><p className="text-sm text-white/70">CBE companion</p></div>
            </div>
            <div className="relative max-w-lg">
                <p className="mb-3 text-xs font-semibold uppercase tracking-[0.18em] text-eucalyptus">Learning, rooted in community</p>
                <h1 className="font-serif text-4xl font-bold leading-tight">A workspace for every learning journey.</h1>
                <p className="mt-4 max-w-md leading-relaxed text-white/75">Save your plans and learning progress in your own account. Choose the workspace that fits your role.</p>
            </div>
            <p className="relative text-xs text-white/60">Curriculum content is illustrative and modelled on KICD CBE designs.</p>
        </aside>
        <main className="flex min-h-screen items-center justify-center px-5 py-10 sm:px-8">
            <section className="w-full max-w-md rounded-3xl border border-ivory-dark bg-white p-6 shadow-[0_18px_50px_rgba(30,61,89,0.1)] sm:p-8">
                <div className="mb-6 flex items-center gap-3 lg:hidden">
                    <span className="grid size-10 place-items-center rounded-xl bg-teal text-white"><Sprout size={20}/></span>
                    <div><p className="font-serif text-lg font-bold text-teal">Msingi AI</p><p className="text-xs text-teal-400">CBE companion</p></div>
                </div>
                <div className="mb-6">
                    <div className="mb-4 grid size-11 place-items-center rounded-2xl bg-[var(--role-surface-tint)] text-[var(--role-primary)]"><LockKeyhole size={20}/></div>
                    <h2 className="font-serif text-2xl font-bold text-teal">{ "Create your account" if mode == "signup" else "Welcome back" }</h2>
                    <p className="mt-1 text-sm text-teal-400">{ "Your plans and saved learning work stay with your account." if mode == "signup" else "Sign in to continue to your Msingi workspace." }</p>
                </div>
                <div role="tablist" aria-label="Account action" className="mb-5 flex rounded-xl bg-ivory p-1">
                    <button type="button" role="tab" aria-selected={mode == "signup"} onClick={lambda (e: MouseEvent) { mode = "signup"; error = ""; }} className={"flex-1 rounded-lg px-3 py-2 text-sm font-semibold " + ("bg-white text-teal shadow-sm" if mode == "signup" else "text-teal-400")}>Create account</button>
                    <button type="button" role="tab" aria-selected={mode == "login"} onClick={lambda (e: MouseEvent) { mode = "login"; error = ""; }} className={"flex-1 rounded-lg px-3 py-2 text-sm font-semibold " + ("bg-white text-teal shadow-sm" if mode == "login" else "text-teal-400")}>Sign in</button>
                </div>
                <form onSubmit={submit} className="flex flex-col gap-4">
                    {mode == "signup" and <Field label="Your name"><Input value={name} onValue={lambda (v: str) { name = v; }} placeholder="e.g. Wanjiku Kamau" required={True}/></Field>}
                    <Field label="Email address"><Input kind="email" value={email} onValue={lambda (v: str) { email = v; }} placeholder="you@example.com" required={True}/></Field>
                    <Field label="Password" hint="Use at least 8 characters."><Input kind="password" value={password} onValue={lambda (v: str) { password = v; }} placeholder="At least 8 characters" required={True}/></Field>
                    {mode == "signup" and <div className="grid gap-4 sm:grid-cols-2">
                        <Field label="Your role"><Select value={role} onValue={lambda (v: str) { role = v; }} options={ACCESS_ROLES}/></Field>
                        <Field label="Grade"><Select value={grade} onValue={lambda (v: str) { grade = v; }} options={ACCESS_GRADES}/></Field>
                    </div>}
                    {error and <p role="alert" className="rounded-xl border border-ochre/50 bg-ochre-50 px-3 py-2 text-sm text-ochre-700">{error}</p>}
                    <Button submit={True} loading={busy} className="mt-1 w-full rounded-full bg-[var(--role-primary)] text-white shadow-md">{ "Create account" if mode == "signup" else "Sign in" } <ArrowRight size={16}/></Button>
                </form>
                <p className="mt-5 flex items-start gap-2 text-xs leading-relaxed text-teal-400"><UserRound size={14} className="mt-0.5 shrink-0"/>Parents need an account link from their learner before learner-specific progress can be shared.</p>
            </section>
        </main>
    </div>;
}
