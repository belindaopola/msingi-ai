"""Browser-side helpers: dates, remembered choices and readable error messages."""

"""Format an ISO date (or datetime) for Kenyan readers, e.g. '16 Oct'."""
def:pub format_date(iso: str, opts: dict[str, str] | None = None) -> str {
    if not iso {
        return "";
    }
    d = new(Date, iso[:10] + "T00:00:00");
    if isNaN(d.getTime()) {  # jac:ignore[W2001]
        return iso;
    }
    return d.toLocaleDateString("en-KE", opts or {"day": "numeric", "month": "short"});
}

"""Format an ISO datetime with its time, e.g. '16 Oct, 09:30'."""
def:pub format_date_time(iso: str) -> str {
    if not iso {
        return "";
    }
    d = new(Date, iso);
    if isNaN(d.getTime()) {  # jac:ignore[W2001]
        return iso;
    }
    return d.toLocaleDateString("en-KE", {"day": "numeric", "month": "short", "hour": "2-digit", "minute": "2-digit"});
}

"""Local calendar date as YYYY-MM-DD."""
def:pub iso_day(d: any) -> str {
    month = ("0" + str(d.getMonth() + 1))[-2:];
    day = ("0" + str(d.getDate()))[-2:];
    return f"{d.getFullYear()}-{month}-{day}";
}

def:pub read_stored(key: str, fallback: str) -> str {
    try {
        return localStorage.getItem(key) or fallback;
    } except Exception {
        return fallback;
    }
}

def:pub write_stored(key: str, value: str) -> None {
    try {
        localStorage.setItem(key, value);
    } except Exception {
        # Storage unavailable: the choice simply is not remembered.
        return;
    }
}

def:pub error_text(err: any) -> str {
    if err and err.message {
        return err.message;
    }
    return str(err) or "Something went wrong.";
}

"""Parse a numeric form field, falling back when it is blank or not a number."""
def:pub to_int(text: str, fallback: int) -> int {
    n = parseInt(text, 10) as int;  # jac:ignore[W2001]
    return fallback if isNaN(n) else n;  # jac:ignore[W2001]
}
