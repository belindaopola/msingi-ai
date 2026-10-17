
import from "@jac/runtime" { jacIsLoggedIn, Navigate }
sv import from ..endpoints { seed_kicd_graph, list_grades, get_curriculum, get_current_session }
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData }
import from ..shared.browser { error_text }
import from .Sidebar { Sidebar }
import from .Header { Header }
import from .GradeSwitcher { GradeSwitcher }
import from .GradeOverview { GradeOverview }
import from .BackendBanner { BackendBanner }
import from ..teacher.TeacherView { TeacherView }
import from ..learner.LearnerView { LearnerView }
import from ..parent.ParentView { ParentView }

def:pub AppShell(role: str, gradeCode: str) -> JsxElement {
    has grades: list[GradeSummaryData] = [],
        curricula: dict[str, GradeCurriculumData] = {},
        status: str = "connecting",
        statusMessage: str = "";

    async can with entry {
        if jacIsLoggedIn() {
            try {
                current = await get_current_session();
                if current is None {
                    status = "profile-required";
                } else {
                    role = current.app_role;
                    gradeCode = current.grade_code;
                    await boot(False);
                }
            } except Exception as err {
                status = "offline";
                statusMessage = error_text(err);
            }
        }
    }

    async can with (gradeCode, status) entry {
        if not jacIsLoggedIn() or status != "online" or curricula[gradeCode] { return; }
        code = gradeCode;
        try {
            result = root spawn get_curriculum(grade_level=code);
            updated = {**curricula};
            updated[code] = result.reports[0];
            curricula = updated;
        } except Exception as err {
            status = "offline";
            statusMessage = error_text(err);
        }
    }

    async def boot(reset: bool) -> None {
        status = "connecting";
        statusMessage = "";
        try {
            root spawn seed_kicd_graph(reset=reset);
            result = root spawn list_grades();
            if result.reports { grades = result.reports; }
            if reset { curricula = {}; }
            status = "online";
        } except Exception as err {
            status = "offline";
            statusMessage = error_text(err);
        }
    }

    def choose_grade(code: str) -> None {
        if code in ["PP2", "Grade 3", "Grade 6", "Grade 9", "Grade 12"] { gradeCode = code; }
    }
    def retry -> None { boot(False); }
    def reset_demo -> None { boot(True); }

    if not jacIsLoggedIn() { return <Navigate to="/account" replace={True}/>; }
    matches = [g for g in grades if g.code == gradeCode];
    grade: GradeSummaryData | None = matches[0] if matches else (grades[0] if grades else None);
    curriculum: GradeCurriculumData | None = curricula[grade.code] if grade else None;
    fallback_tabs: list[dict[str, str]] = [
        {"code": "PP2", "stage": "Early Years Education (Pre-Primary)"},
        {"code": "Grade 3", "stage": "Lower Primary (End)"},
        {"code": "Grade 6", "stage": "Upper Primary (End)"},
        {"code": "Grade 9", "stage": "Junior School (End)"},
        {"code": "Grade 12", "stage": "Senior School (End)"}
    ];
    tabs: list[dict[str, str]] = [{"code": g.code, "stage": g.stage} for g in grades] if grades else fallback_tabs;
    view_key = role + "-" + gradeCode;
    theme = role.lower();

    return <div data-theme={theme} className="flex min-h-screen bg-alabaster text-teal">
        <Sidebar role={role} status={status}/>
        <div className="flex min-w-0 flex-1 flex-col">
            <div className="sticky top-0 z-20 border-b border-teal-100 bg-alabaster/95 backdrop-blur print:hidden">
                <Header role={role}/>
                <GradeSwitcher tabs={tabs} gradeCode={gradeCode} onGrade={choose_grade}/>
            </div>
            <main className="mx-auto w-full max-w-6xl flex-1 space-y-6 px-4 py-6 sm:px-8">
                <BackendBanner status={status} message={statusMessage} onRetry={retry}/>
                {if grade {
                    <GradeOverview grade={grade} curriculum={curriculum}/>
                    if status == "online" {
                        if role == "LEARNER" { <LearnerView key={view_key} grade={grade} curriculum={curriculum}/> }
                        elif role == "PARENT" { <ParentView key={view_key} grade={grade} curriculum={curriculum}/> }
                        else { <TeacherView key={view_key} grade={grade} curriculum={curriculum}/> }
                    }
                }}
            </main>
            <footer className="px-4 pb-6 text-center text-xs text-teal-400 sm:px-8 print:hidden">Msingi AI demo. Curriculum content is illustrative and modelled on KICD CBE designs; always confirm against the official curriculum designs.</footer>
        </div>
    </div>;
}
