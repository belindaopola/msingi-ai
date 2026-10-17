# By Mara Msingi
"""Mwalimu Taratibu guides learners with questions and hints so they discover answers themselves."""

import from "lucide-react" { HelpCircle, Lightbulb, MessagesSquare, RotateCcw, SendHorizontal }
import from ..endpoints { socratic_tutor }
# Aliased: spawning a walker emits same-named wire classes for its report types in this module.
import from ..models { GradeSummary as GradeSummaryData, GradeCurriculum as GradeCurriculumData, TutorReply as TutorReplyData }
import from ..shared.constants { TUTOR_STARTERS }
import from ..shared.browser { error_text }
import from ..shared.ui { Badge, Button, Card, ErrorNote, Select, SourceBadge }

def:pub SocraticTutor(grade: GradeSummaryData, curriculum: GradeCurriculumData | None) -> JsxElement {
    has sessionId: str = "",
        messages: list[dict[str, any]] = [],
        draft: str = "",
        area: str = "",
        loading: bool = False,
        error: str = "";
    has scrollRef: Ref[HTMLDivElement] = Ref();

    can with (messages, loading) entry {
        if scrollRef.current {
            scrollRef.current.scrollTo({"top": scrollRef.current.scrollHeight, "behavior": "smooth"});
        }
    }

    async def send(text: str) -> None {
        message = text.strip();
        if not message or loading {
            return;
        }
        draft = "";
        messages = messages + [{"role": "learner", "text": message}];
        loading = True;
        error = "";
        try {
            response = root spawn socratic_tutor(
                grade_level=grade.code,
                message=message,
                session_id=sessionId,
                learning_area=area
            );
            turn = response.reports[0];
            sessionId = turn.session_id;
            messages = messages + [{"role": "tutor", "reply": turn.reply, "source": turn.source, "retrieved": turn.retrieved}];
        } except Exception as err {
            error = error_text(err);
        }
        loading = False;
    }

    def submit(e: FormEvent) -> None {
        e.preventDefault();
        send(draft);
    }

    def restart -> None {
        sessionId = "";
        messages = [];
    }

    areas = [a.name for a in curriculum.areas] if curriculum else [];
    starters = TUTOR_STARTERS[grade.code] or [];

    <Card
        id="tutor"
        icon={<MessagesSquare size={18} aria-hidden="true"/>}
        title="Mwalimu Taratibu"
        subtitle="Your tutor answers with questions and hints so you discover the answer yourself. It will not do your homework for you."
        actions={len(messages) > 0 and <Button variant="ghost" icon={<RotateCcw size={16} aria-hidden="true"/>} onClick={restart}>New chat</Button>}
    >
        <div className="mb-3 max-w-xs">
            <Select label="Learning area" value={area} onValue={lambda (v: str) { area = v; }} placeholder="Any learning area" options={areas}/>
        </div>

        <div ref={scrollRef} className="h-[22rem] space-y-3 overflow-y-auto rounded-xl border border-teal-50 bg-white p-3" aria-live="polite">
            {if not messages {
                <div className="flex h-full flex-col items-center justify-center text-center">
                    <HelpCircle className="text-eucalyptus-600" size={28} aria-hidden="true"/>
                    <p className="mt-2 text-sm font-medium">What are you wondering about?</p>
                    <div className="mt-3 flex flex-wrap justify-center gap-2">
                        {for s in starters {
                            <button
                                key={s}
                                type="button"
                                onClick={lambda (e: MouseEvent) { send(s); }}
                                className="rounded-full border border-teal-100 px-3 py-1 text-xs hover:border-sage hover:text-sage"
                            >
                                {s}
                            </button>
                        }}
                    </div>
                </div>
            }}
            {for (i, m) in enumerate(messages) {
                if m["role"] == "learner" {
                    <LearnerBubble key={i} text={m["text"]}/>
                } else {
                    <TutorBubble key={i} reply={m["reply"]} source={m["source"]} retrieved={m["retrieved"]}/>
                }
            }}
            {loading and <p className="animate-pulse text-sm text-teal-400">Tutor is thinking...</p>}
        </div>

        <ErrorNote message={error}/>

        <form onSubmit={submit} className="mt-3 flex gap-2">
            <input
                value={draft}
                onChange={lambda (e: ChangeEvent) { draft = e.target.value; }}
                placeholder="Type your question or your thinking..."
                aria-label="Message the tutor"
                className="min-w-0 flex-1 rounded-xl border border-teal-100 bg-white px-3 py-2 text-sm focus:border-sage focus:outline-none focus:ring-2 focus:ring-sage/30"
            />
            <Button submit={True} label="Send" icon={<SendHorizontal size={16} aria-hidden="true"/>} loading={loading} disabled={not draft.strip()}>
                <span className="hidden sm:inline">Send</span>
            </Button>
        </form>
    </Card>
}

def:pub LearnerBubble(text: str) -> JsxElement {
    <div className="flex justify-end">
        <p className="max-w-[85%] rounded-2xl rounded-br-md bg-sage px-3.5 py-2 text-sm text-white">{text}</p>
    </div>
}

def:pub TutorBubble(reply: TutorReplyData, source: str, retrieved: list[str]) -> JsxElement {
    <div className="max-w-[92%] rounded-2xl rounded-bl-md bg-ivory px-3.5 py-3 text-sm">
        <p>{reply.reply}</p>
        <p className="mt-2 flex items-start gap-2 rounded-lg bg-white px-2.5 py-2 font-medium text-teal">
            <Lightbulb size={16} className="mt-0.5 shrink-0 text-ochre" aria-hidden="true"/> {reply.guiding_question}
        </p>
        <p className="mt-2 text-sage-700">{reply.encouragement}</p>
        <div className="mt-2 flex flex-wrap items-center gap-1.5">
            <span className="text-[11px] text-teal-400" title="1 light nudge, 2 targeted hint, 3 worked similar example">
                Hint level {reply.hint_level}/3
            </span>
            {for c in reply.concepts {
                <Badge key={c} tone="teal">{c}</Badge>
            }}
            <SourceBadge source={source}/>
        </div>
        {retrieved and <p className="mt-1.5 text-[11px] text-teal-400">Grounded in: {", ".join(retrieved)}</p>}
    </div>
}
