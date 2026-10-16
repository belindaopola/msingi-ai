"""Page shell: owns role, grade, curriculum cache and server status; renders the active workspace."""

import from ..endpoints { seed_kicd_graph, list_grades, get_curriculum }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData }
import from ..shared.constants { GRADE_TABS }
import from ..shared.browser { read_stored, write_stored, error_text }
import from .Sidebar { Sidebar }
import from .Header { Header }
import from .GradeSwitcher { GradeSwitcher }
import from .GradeOverview { GradeOverview }
import from .BackendBanner { BackendBanner }
import from ..teacher.TeacherView { TeacherView }
import from ..learner.LearnerView { LearnerView }
import from ..parent.ParentView { ParentView }

def:pub AppShell -> JsxElement {
    has role: str = read_stored("msingi-role", "TEACHER"),
        gradeCode: str = read_stored("msingi-grade", "PP2"),
        grades: list[GradeSummaryData] = [],
        curricula: dict[str, GradeCurriculumData] = {},
        status: str = "connecting",
        statusMessage: str = "";

    async can with entry {
        await boot(False);
    }

    # Fetch each grade's curriculum tree once, the first time it is selected.
    async can with (gradeCode, status) entry {
        if status != "online" or curricula[gradeCode] {
            return;
        }
        code = gradeCode;
        try {
            result = root spawn get_curriculum(grade_level=code);
            # Subscript assignment: a variable key in a dict literal compiles to a fixed JS key.
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
            if result.reports {
                grades = result.reports;
            }
            if reset {
                curricula = {};
            }
            status = "online";
        } except Exception as err {
            status = "offline";
            statusMessage = error_text(err);
        }
    }

    def choose_role(next_role: str) -> None {
        role = next_role;
        write_stored("msingi-role", next_role);
    }

    def choose_grade(code: str) -> None {
        gradeCode = code;
        write_stored("msingi-grade", code);
    }

    def retry -> None {
        boot(False);
    }

    def reset_demo -> None {
        boot(True);
    }

    matches = [g for g in grades if g.code == gradeCode];
    grade: GradeSummaryData | None = matches[0] if matches else (grades[0] if grades else None);
    curriculum: GradeCurriculumData | None = curricula[grade.code] if grade else None;
    tabs = [{"code": g.code, "stage": g.stage} for g in grades] if grades else GRADE_TABS;
    view_key = role + "-" + gradeCode;

    <div className="flex min-h-screen bg-alabaster">
        <Sidebar role={role} onRole={choose_role} status={status} onReset={reset_demo}/>
        <div className="flex min-w-0 flex-1 flex-col">
            <div className="sticky top-0 z-20 border-b border-teal-100 bg-alabaster/95 backdrop-blur print:hidden">
                <Header role={role} onRole={choose_role}/>
                <GradeSwitcher tabs={tabs} gradeCode={gradeCode} onGrade={choose_grade}/>
            </div>
            <main className="mx-auto w-full max-w-6xl flex-1 space-y-6 px-4 py-6 sm:px-8">
                <BackendBanner status={status} message={statusMessage} onRetry={retry}/>
                {if grade {
                    <GradeOverview grade={grade} curriculum={curriculum}/>
                    if status == "online" {
                        if role == "LEARNER" {
                            <LearnerView key={view_key} grade={grade} curriculum={curriculum}/>
                        } elif role == "PARENT" {
                            <ParentView key={view_key} grade={grade} curriculum={curriculum}/>
                        } else {
                            <TeacherView key={view_key} grade={grade} curriculum={curriculum}/>
                        }
                    }
                }}
            </main>
            <footer className="px-4 pb-6 text-center text-xs text-teal-400 sm:px-8 print:hidden">
                Msingi AI demo. Curriculum content is illustrative and modelled on KICD CBC designs; always confirm against the official curriculum designs.
            </footer>
        </div>
    </div>
}
