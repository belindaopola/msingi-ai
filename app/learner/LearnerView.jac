"""Learner workspace: revision calendar, material checklist and Mwalimu Taratibu."""

import from ..models { GradeSummary, GradeCurriculum, RevisionResult }
import from .RevisionCalendar { RevisionCalendar }
import from .MaterialChecklist { MaterialChecklist }
import from .SocraticTutor { SocraticTutor }

def:pub LearnerView(grade: GradeSummary, curriculum: GradeCurriculum | None) -> JsxElement {
    # The revision walker returns both the calendar and the material checklist.
    has revision: RevisionResult | None = None;

    <div className="space-y-6">
        <RevisionCalendar
            grade={grade}
            curriculum={curriculum}
            revision={revision}
            onRevision={lambda (r: RevisionResult) { revision = r; }}
        />
        <div className="grid gap-6 xl:grid-cols-[1fr_1.15fr]">
            <MaterialChecklist grade={grade} curriculum={curriculum} revision={revision}/>
            <SocraticTutor grade={grade} curriculum={curriculum}/>
        </div>
    </div>
}
