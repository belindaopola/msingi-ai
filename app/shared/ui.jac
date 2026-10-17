"""Msingi AI UI kit: cards, buttons, badges, form fields and small display helpers."""

import from "lucide-react" { AlertTriangle, Loader2, Sparkles, FileText }

glob INPUT_CLASS: str = "w-full rounded-xl border border-teal-100 bg-white px-3 py-2 text-sm text-teal placeholder:text-teal-200 focus:border-sage focus:outline-none focus:ring-2 focus:ring-sage/30";

glob BUTTON_STYLES: dict[str, str] = {
    "primary": "bg-sage text-white hover:bg-sage-600 disabled:bg-sage-200",
    "secondary": "border border-teal-200 bg-white text-teal hover:border-sage hover:text-sage disabled:opacity-50",
    "ghost": "text-teal-400 hover:bg-teal-50 hover:text-teal"
};

glob BADGE_TONES: dict[str, str] = {
    "eucalyptus": "bg-eucalyptus-100 text-sage-700",
    "teal": "bg-teal-50 text-teal",
    "ochre": "bg-ochre-100 text-ochre-700",
    "sage": "bg-sage text-white"
};

glob LEVEL_TONES: dict[str, str] = {
    "EE": "bg-sage text-white",
    "ME": "bg-eucalyptus text-teal",
    "AE": "bg-ochre-100 text-ochre-700",
    "BE": "bg-ochre text-teal"
};

glob BAR_FILLS: dict[str, str] = {
    "eucalyptus": "bg-eucalyptus-600",
    "sage": "bg-sage",
    "ochre": "bg-ochre"
};

def:pub Card(
    title: str = "",
    subtitle: str = "",
    id: str = "",
    icon: any = None,
    actions: any = None,
    className: str = "",
    children: any = None
) -> JsxElement {
    <section id={id} className={"scroll-mt-28 rounded-2xl border border-teal-100 bg-ivory shadow-card " + className}>
        {if title or actions {
            <header className="flex flex-wrap items-start justify-between gap-3 border-b border-ivory-dark px-5 py-4">
                <div className="flex items-start gap-3">
                    {icon and <span className="mt-0.5 grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-sage-50 text-sage">{icon}</span>}
                    <div>
                        <h2 className="font-serif text-lg font-semibold text-teal">{title}</h2>
                        {subtitle and <p className="mt-0.5 text-sm text-teal-400">{subtitle}</p>}
                    </div>
                </div>
                {actions and <div className="flex items-center gap-2 print:hidden">{actions}</div>}
            </header>
        }}
        <div className="p-5">{children}</div>
    </section>
}

def:pub Button(
    variant: str = "primary",
    loading: bool = False,
    disabled: bool = False,
    submit: bool = False,
    icon: any = None,
    label: str = "",
    className: str = "",
    onClick: Callable[[], None] | None = None,
    children: any = None
) -> JsxElement {
    def handle_click(e: MouseEvent) {
        if onClick {
            onClick();
        }
    }
    <button
        type={"submit" if submit else "button"}
        aria-label={label or None}
        onClick={handle_click}
        disabled={loading or disabled}
        className={"inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2 text-sm font-semibold transition focus:outline-none focus-visible:ring-2 focus-visible:ring-sage focus-visible:ring-offset-2 disabled:cursor-not-allowed " + BUTTON_STYLES[variant] + " " + className}
    >
        {<Loader2 size={16} className="animate-spin" aria-hidden="true"/> if loading else icon}
        {children}
    </button>
}

def:pub Badge(tone: str = "eucalyptus", className: str = "", children: any = None) -> JsxElement {
    <span className={"inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium " + BADGE_TONES[tone] + " " + className}>
        {children}
    </span>
}

"""Shows whether output came from the LLM agent or the curriculum template fallback."""
def:pub SourceBadge(source: str = "") -> JsxElement {
    if not source {
        return <></>;
    }
    if source == "AI" {
        return <Badge tone="eucalyptus" className="print:hidden">
            <Sparkles size={12} aria-hidden="true"/> AI generated
        </Badge>;
    }
    <span title="No Gemini API key is configured on the server, so this was assembled from the KICD curriculum graph.">
        <Badge tone="ochre" className="print:hidden">
            <FileText size={12} aria-hidden="true"/> Curriculum template
        </Badge>
    </span>
}

def:pub Field(label: str, hint: str = "", className: str = "", children: any = None) -> JsxElement {
    <label className={"block text-sm " + className}>
        <span className="mb-1 block font-medium text-teal">{label}</span>
        {children}
        {hint and <span className="mt-1 block text-xs text-teal-400">{hint}</span>}
    </label>
}

def:pub Input(
    value: str,
    onValue: Callable[[str], None],
    kind: str = "text",
    placeholder: str = "",
    min: str = "",
    max: str = "",
    required: bool = False
) -> JsxElement {
    def handle_change(e: ChangeEvent) {
        onValue(e.target.value);
    }
    <input
        className={INPUT_CLASS}
        type={kind}
        value={value}
        onChange={handle_change}
        placeholder={placeholder}
        min={min}
        max={max}
        required={required}
    />
}

def:pub TextArea(value: str, onValue: Callable[[str], None], rows: int = 3, placeholder: str = "") -> JsxElement {
    def handle_change(e: ChangeEvent) {
        onValue(e.target.value);
    }
    <textarea
        className={INPUT_CLASS + " min-h-[96px] resize-y"}
        rows={rows}
        value={value}
        onChange={handle_change}
        placeholder={placeholder}
    />
}

def:pub Select(
    value: str,
    onValue: Callable[[str], None],
    options: list[str],
    placeholder: str | None = None,
    label: str = "",
    labels: dict[str, str] | None = None
) -> JsxElement {
    def handle_change(e: ChangeEvent) {
        onValue(e.target.value);
    }
    <select className={INPUT_CLASS} value={value} onChange={handle_change} aria-label={label or None}>
        {placeholder is not None and <option value="">{placeholder}</option>}
        {for o in options {
            <option key={o} value={o}>{(labels[o] if labels and labels[o] else o)}</option>
        }}
    </select>
}

def:pub ErrorNote(message: str = "") -> JsxElement {
    if not message {
        return <></>;
    }
    <div role="alert" className="mt-4 flex items-start gap-2 rounded-xl border border-ochre/50 bg-ochre-50 px-3 py-2 text-sm text-ochre-700">
        <AlertTriangle size={16} className="mt-0.5 shrink-0" aria-hidden="true"/>
        <span>{message}</span>
    </div>
}

def:pub EmptyState(title: str, icon: any = None, children: any = None) -> JsxElement {
    <div className="rounded-xl border border-dashed border-teal-100 bg-alabaster/60 px-4 py-8 text-center">
        {icon and <div className="flex justify-center text-eucalyptus-600">{icon}</div>}
        <p className="mt-2 font-medium text-teal">{title}</p>
        {children and <p className="mx-auto mt-1 max-w-sm text-sm text-teal-400">{children}</p>}
    </div>
}

def:pub SectionLabel(children: any = None) -> JsxElement {
    <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-teal-400">{children}</h3>
}

def:pub BulletList(items: list[str], ordered: bool = False) -> JsxElement {
    if not items {
        return <p className="text-sm text-teal-400">None listed.</p>;
    }
    list_class = "space-y-1.5 pl-5 text-sm text-teal marker:text-sage";
    if ordered {
        return <ol className={"list-decimal " + list_class}>
            {for (i, item) in enumerate(items) {
                <li key={i}>{item}</li>
            }}
        </ol>;
    }
    <ul className={"list-disc " + list_class}>
        {for (i, item) in enumerate(items) {
            <li key={i}>{item}</li>
        }}
    </ul>
}

def:pub ProgressBar(value: float, max: float = 100, tone: str = "eucalyptus", label: str = "") -> JsxElement {
    pct = Math.max(0, Math.min(100, (value / max) * 100)) if max else 0;
    <div
        className="h-2 w-full overflow-hidden rounded-full bg-teal-50"
        role="progressbar"
        aria-valuenow={value}
        aria-valuemin={0}
        aria-valuemax={max}
        aria-label={label}
    >
        <div className={"h-full rounded-full transition-all duration-500 " + BAR_FILLS[tone]} style={{"width": str(pct) + "%"}}/>
    </div>
}

def:pub LevelBadge(code: str) -> JsxElement {
    tone = LEVEL_TONES[code] or "bg-teal-50 text-teal";
    <span className={"inline-flex h-7 min-w-[2.25rem] items-center justify-center rounded-lg px-2 text-xs font-bold " + tone}>{code}</span>
}
