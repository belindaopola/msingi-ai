"""Connection notice: a spinner while loading, an alert with Retry when the server is unreachable."""

import from "lucide-react" { Loader2, ServerCrash }
import from ..shared.ui { Button }

def:pub BackendBanner(status: str, message: str, onRetry: Callable[[], None]) -> JsxElement {
    if status == "connecting" {
        return <div className="flex items-center gap-2 rounded-xl bg-ivory px-4 py-3 text-sm text-teal-400">
            <Loader2 size={16} className="animate-spin" aria-hidden="true"/>
            Connecting to the Msingi AI service and loading the KICD curriculum graph...
        </div>;
    }
    if status != "offline" {
        return <></>;
    }
    return <div role="alert" className="rounded-2xl border border-ochre bg-ochre-50 p-5">
        <div className="flex items-start gap-3">
            <ServerCrash className="mt-0.5 shrink-0 text-ochre-700" size={20} aria-hidden="true"/>
            <div className="flex-1 text-sm text-teal">
                <p className="font-semibold">The Msingi AI server is not reachable.</p>
                <p className="mt-1 text-teal-400">{message}</p>
                <p className="mt-2">
                    Restart it with <code className="rounded bg-white px-1.5 py-0.5 text-xs">cd app && jac run</code>, then retry.
                </p>
            </div>
            <Button variant="secondary" onClick={onRetry}>Retry</Button>
        </div>
    </div>;
}
