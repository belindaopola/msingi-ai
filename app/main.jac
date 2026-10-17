
import from "@jac/runtime" { Router, Routes, Route, AuthGuard, Navigate }
import from endpoints {
    seed_kicd_graph, list_grades, get_curriculum, generate_lesson_plan,
    plan_class_materials, build_revision_and_materials, socratic_tutor,
    translate_for_parent, list_plans, get_learner_progress,
    save_checklist_progress
}
import "./assets/main.css";
import from .shell.AppShell { AppShell }
import from .account.AccountAccess { AccountAccess }

def:pub app -> JsxElement {
    return <Router>
        <Routes>
            <Route path="/account" element={<AccountAccess/>}/>
            <Route path="/" element={<AuthGuard redirect="/account"/>}><AppShell/></Route>
            <Route path="*" element={<Navigate to="/" replace={True}/>}/>
        </Routes>
    </Router>;
}
