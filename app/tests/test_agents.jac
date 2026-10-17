"""Agent-path tests: MockLLM stands in for the provider so no API key is needed."""

import os;
import agents;
import from jaclang.byllm.lib { MockLLM }
import from models { TutorReply }
import from endpoints { socratic_tutor, seed_kicd_graph }

test "Mwalimu Taratibu uses the AI agent and scrubs em dashes" {
    os.environ["GEMINI_API_KEY"] = "test-key";
    os.environ.pop("MSINGI_OFFLINE", None);
    mock = MockLLM(outputs=[TutorReply(
        reply="Interesting idea — what made you think of it?",
        guiding_question="What happens to the bulb if one wire is removed?",
        hint_level=1,
        concepts=["Simple Circuits"],
        encouragement="Great thinking!"
    )]);
    agents.llm = mock;
    root spawn seed_kicd_graph(reset=True);
    result = root spawn socratic_tutor(grade_level="Grade 6", message="Why does my bulb not light?");
    out = result.reports[0];
    assert out.source == "AI";
    assert "—" not in out.reply.reply;
    assert out.reply.guiding_question.startswith("What happens");
    assert "Electrical Energy: Simple Circuits" in out.retrieved;
    assert "Never use em dashes" in str(mock.sent("messages"));
}
