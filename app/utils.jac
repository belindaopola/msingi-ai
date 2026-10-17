# By Mara Msingi
"""Shared helpers: house-style scrubbing, serialization, dates and LLM gating."""

import os;
import json;
import math;
import from enum { Enum }
import from datetime { datetime, date, timedelta }

# Spelled as escapes so the dash characters never appear literally in source.
glob EM_DASH: str = "—";
glob EN_DASH: str = "–";

glob LLM_KEY_VARS: list[str] = [
    "GEMINI_API_KEY", "GOOGLE_API_KEY", "ANTHROPIC_API_KEY", "OPENAI_API_KEY"
];

"""Replace em and en dashes in any string, list, dict or obj (in place for objs)."""
def scrub(value: any) -> any {
    if isinstance(value, Enum) {
        return value;
    }
    if isinstance(value, str) {
        return value.replace(f" {EM_DASH} ", ", ").replace(EM_DASH, ", ").replace(EN_DASH, "-");
    }
    if isinstance(value, list) {
        return [scrub(v) for v in value];
    }
    if isinstance(value, dict) {
        return {k: scrub(v) for (k, v) in value.items()};
    }
    if hasattr(value, "__dict__") {
        for (k, v) in list(vars(value).items()) {
            if not k.startswith("_") {
                setattr(value, k, scrub(v));
            }
        }
    }
    return value;
}

"""Convert objs, lists and dicts into JSON-safe plain Python values."""
def to_plain(value: any) -> any {
    if isinstance(value, Enum) {
        return value.value;
    }
    if isinstance(value, (str, int, float, bool)) or value is None {
        return value;
    }
    if isinstance(value, list) {
        return [to_plain(v) for v in value];
    }
    if isinstance(value, dict) {
        return {str(k): to_plain(v) for (k, v) in value.items()};
    }
    if hasattr(value, "__dict__") {
        return {k: to_plain(v) for (k, v) in vars(value).items() if not k.startswith("_")};
    }
    return str(value);
}

def to_json(value: any) -> str {
    return json.dumps(to_plain(value), ensure_ascii=False);
}

def now_iso -> str {
    return datetime.now().isoformat(timespec="seconds");
}

"""True when an LLM call should be attempted (a provider key is set and offline mode is off)."""
def llm_enabled -> bool {
    if os.environ.get("MSINGI_OFFLINE", "").lower() in ["1", "true", "yes"] {
        return False;
    }
    model = os.environ.get("BYLLM_DEFAULT_MODEL", "");
    if model.startswith("ollama/") or model.startswith("local:") {
        return True;
    }
    return `any([os.environ.get(k, "") for k in LLM_KEY_VARS]);
}

"""Split a term into consecutive week windows (max 16) starting on the term start date."""
def week_windows(term_start: str, term_end: str) -> list[tuple[str, str]] {
    start = date.fromisoformat(term_start);
    end = date.fromisoformat(term_end);
    if end < start {
        (start, end) = (end, start);
    }
    total_days = (end - start).days + 1;
    weeks = max(1, min(16, math.ceil(total_days / 7)));
    windows: list[tuple[str, str]] = [];
    for i in range(weeks) {
        w_start = start + timedelta(days=7 * i);
        w_end = min(end, w_start + timedelta(days=6));
        windows.append((w_start.isoformat(), w_end.isoformat()));
    }
    return windows;
}
