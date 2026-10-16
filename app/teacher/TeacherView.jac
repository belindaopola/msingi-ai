"""Teacher workspace: lesson plans, material planning and parent broadcasts."""

import from ..models { GradeSummary, GradeCurriculum }
import from .LessonPlanGenerator { LessonPlanGenerator }
import from .MaterialPlanner { MaterialPlanner }
import from .ParentBroadcast { ParentBroadcast }

def:pub TeacherView(grade: GradeSummary, curriculum: GradeCurriculum | None) -> JsxElement {
    <div className="space-y-6">
        <LessonPlanGenerator grade={grade} curriculum={curriculum}/>
        <div className="grid gap-6 xl:grid-cols-2">
            <MaterialPlanner grade={grade} curriculum={curriculum}/>
            <ParentBroadcast grade={grade} curriculum={curriculum}/>
        </div>
    </div>
}
