# By Mara Msingi
"""End-to-end smoke test for the Msingi AI walker endpoints.

Usage: python3 scripts/smoke_test.py [base_url]   (default http://localhost:8000)
Registers a throwaway account (the agent walkers are walker:protect), then
exercises every walker for every benchmark grade and fails on any error or
on any em/en dash in a response.
"""

import json
import sys
import time
import urllib.request

BASE = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
GRADES = ["PP2", "Grade 3", "Grade 6", "Grade 9", "Grade 12"]
DASHES = ("—", "–")
TOKEN = ""


def post(path, body):
    req = urllib.request.Request(
        f"{BASE}{path}",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode())


def sign_in():
    email = f"smoke{int(time.time())}@example.com"
    credential = {"type": "password", "password": "smoke-test-pass"}
    post("/user/register", {"identities": [{"type": "email", "value": email}], "credential": credential})
    return post("/user/login", {"identity": {"type": "email", "value": email}, "credential": credential})["data"]["token"]


def call(walker, body=None):
    req = urllib.request.Request(
        f"{BASE}/walker/{walker}",
        data=json.dumps(body or {}).encode(),
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            raw = resp.read().decode()
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
    env = json.loads(raw)
    if not env.get("ok"):
        raise AssertionError(f"{walker} failed: {env.get('error')}")
    for d in DASHES:
        assert d not in raw, f"{walker} response contains a forbidden dash"
    return env["data"]["reports"]


def main():
    global TOKEN
    TOKEN = sign_in()
    seed = call("seed_kicd_graph", {"reset": True})[0]
    print("seed:", seed["status"], seed["grades"], seed["curriculum_nodes"], "nodes,", seed["users"], "users")
    assert seed["grades"] == GRADES

    grades = call("list_grades")
    assert [g["code"] for g in grades] == GRADES, [g["code"] for g in grades]

    for code in GRADES:
        tree = call("get_curriculum", {"grade_level": code})[0]
        area = tree["areas"][0]
        strand = area["children"][0]
        sub = strand["children"][0]

        lesson = call("generate_lesson_plan", {
            "grade_level": code, "learning_area": area["name"], "strand": strand["name"],
            "class_size": 42, "teacher_name": "Tr. Faith Njeri",
        })[0]
        plan = lesson["plan"]
        assert [r["code"] for r in plan["assessment_rubric"]] == ["EE", "ME", "AE", "BE"]
        assert sum(s["minutes"] for s in plan["lesson_steps"]) == plan["duration_minutes"]

        mats = call("plan_class_materials", {"grade_level": code, "learning_area": area["name"], "class_size": 42})[0]
        assert mats["materials"]

        rev = call("build_revision_and_materials", {
            "grade_level": code, "term_start": "2026-10-19", "term_end": "2026-11-27",
        })[0]
        assert len(rev["plan"]["weeks"]) == 6, len(rev["plan"]["weeks"])

        t1 = call("socratic_tutor", {"grade_level": code, "message": f"Can you just tell me the answer about {sub['name']}?"})[0]
        t2 = call("socratic_tutor", {"grade_level": code, "message": "I think it is because of the materials", "session_id": t1["session_id"]})[0]
        assert t2["session_id"] == t1["session_id"] and len(t2["turns"]) == 4

        guide = call("translate_for_parent", {
            "grade_level": code,
            "teacher_update": f"This week we covered the strand {strand['name']}. Most learners are Approaching Expectations on the SLO.",
        })[0]
        assert guide["guide"]["home_activities"] and guide["plan_id"]

        plans = call("list_plans", {"grade_level": code})[0]
        assert {p["plan_type"] for p in plans} >= {"LESSON_PLAN", "MATERIAL_CHECKLIST", "REVISION_SCHEDULE", "PARENT_BROADCAST"}

        prog = call("get_learner_progress", {"grade_level": code})[0]
        assert prog["areas"] and prog["parent_name"]

        print(f"{code:9} ok  lesson={lesson['source']} tutor={t1['source']} retrieved={t1['retrieved'][:1]} weeks={len(rev['plan']['weeks'])} plans={len(plans)} learner={prog['learner_name']}")

    try:
        call("get_curriculum", {"grade_level": "Grade 7"})
        raise SystemExit("expected unknown grade to fail")
    except AssertionError as e:
        print("unknown grade rejected:", str(e)[:90])
    print("ALL CHECKS PASSED")


if __name__ == "__main__":
    main()
