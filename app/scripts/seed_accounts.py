"""Create sample sign-in accounts: a teacher, a learner and a parent per benchmark grade.

Usage: python3 scripts/seed_accounts.py [base_url]   (default http://localhost:8000)

Emails are <firstname>@msingiaike.com (the surname where a first name is taken). Every account gets the same password,
taken from MSINGI_DEMO_PASSWORD (default below). Safe to re-run: an account
that already exists is signed into and its profile refreshed; other accounts
(such as the admin) are never touched. All accounts get the normal "user"
platform role, never admin.
"""

import json
import os
import sys
import urllib.error
import urllib.request

BASE = (sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000").rstrip("/")
PASSWORD = os.environ.get("MSINGI_DEMO_PASSWORD", "MsingiDemo2026")
DOMAIN = "msingiaike.com"

# (display name, app role, grade[, email local part]). Learners and parents match the demo
# family for each grade in seed_data.jac.
ACCOUNTS = [
    ("Faith Njeri", "TEACHER", "PP2"),
    ("Peter Kamau", "TEACHER", "Grade 3"),
    ("Mercy Atieno", "TEACHER", "Grade 6"),
    ("John Mutua", "TEACHER", "Grade 9"),
    ("Esther Wambui", "TEACHER", "Grade 12"),
    ("Amani Wanjiru", "LEARNER", "PP2"),
    ("Baraka Otieno", "LEARNER", "Grade 3"),
    ("Imani Chebet", "LEARNER", "Grade 6"),
    ("Kevin Mwangi", "LEARNER", "Grade 9"),
    ("Zawadi Achieng", "LEARNER", "Grade 12"),
    ("Grace Wanjiru", "PARENT", "PP2"),
    ("Christine Otieno", "PARENT", "Grade 3"),
    ("Daniel Kiprop", "PARENT", "Grade 6"),
    ("Lucy Wambui", "PARENT", "Grade 9"),
    ("Peter Ouma", "PARENT", "Grade 12", "ouma"),  # peter@ is the Grade 3 teacher
]


def post(path, body, token=""):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(f"{BASE}{path}", data=json.dumps(body).encode(), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.status, json.loads(resp.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, json.loads(raw)
        except json.JSONDecodeError:
            return e.code, {"raw": raw}


def login(email):
    status, env = post("/user/login", {
        "identity": {"type": "email", "value": email},
        "credential": {"type": "password", "password": PASSWORD},
    })
    return env.get("data", {}).get("token") if status == 200 and env.get("ok") else None


def ensure_account(name, role, grade, local=""):
    email = f"{local or name.split()[0].lower()}@{DOMAIN}"
    status, env = post("/user/register", {
        "identities": [{"type": "email", "value": email}],
        "credential": {"type": "password", "password": PASSWORD},
        "profile": {"firstname": name.split()[0], "lastname": name.split()[-1]},
    })
    created = status in (200, 201) and env.get("ok")
    token = login(email)
    if not token:
        reason = "already exists with a different password" if not created else f"login failed ({status})"
        return email, f"SKIPPED: {reason}"
    status, env = post("/function/set_account_profile", {
        "display_name": name, "email": email, "app_role": role, "grade_code": grade,
    }, token)
    if status != 200 or not env.get("ok"):
        return email, f"FAILED to save profile: {env.get('error') or status}"
    return email, "created" if created else "existed, profile refreshed"


def main():
    print(f"Server: {BASE}\n")
    failures = 0
    for name, role, grade, *local in ACCOUNTS:
        email, result = ensure_account(name, role, grade, *local)
        failures += result.startswith(("SKIPPED", "FAILED"))
        print(f"{role:8} {grade:9} {email:28} {result}")
    print(f"\nPassword for every account: {PASSWORD}")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
