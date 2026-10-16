"""Curriculum retrieval for RAG.

Ranks SUB_STRAND CurriculumNodes against a free-text query with a small
BM25 scorer over each node's KICD text (name, outcomes, inquiry questions,
experiences). It needs no embedding service, so the demo runs offline; swap
`retrieve` for a vector search to use dense embeddings instead.
"""

import re;
import math;
import from models { GradeNode, CurriculumNode, HasArea, HasPart }

glob STOPWORDS: set[str] = {
    "the", "and", "for", "are", "was", "with", "that", "this", "what", "how",
    "why", "can", "you", "your", "our", "has", "have", "from", "they", "their",
    "about", "into", "will", "would", "should", "learner", "learners", "able",
    "does", "did", "not", "but", "use", "using", "some", "which", "when", "there"
};

def tokenize(text: str) -> list[str] {
    return [t for t in re.findall("[a-z0-9]+", text.lower()) if len(t) > 2 and t not in STOPWORDS];
}

def sub_strands_of(g: GradeNode) -> list[CurriculumNode] {
    return [g ->:HasArea:-> ->:HasPart:-> ->:HasPart:->];
}

def parent_of(n: CurriculumNode) -> CurriculumNode | None {
    parents = [n <-:HasPart:<-];
    return parents[0] if parents else None;
}

"""Return (learning area, strand) names for a sub-strand node."""
def lineage(sub: CurriculumNode) -> tuple[str, str] {
    strand = parent_of(sub);
    if strand is None {
        return ("", "");
    }
    area = parent_of(strand);
    return (area.name if area else "", strand.name);
}

def node_text(n: CurriculumNode) -> str {
    (area, strand) = lineage(n);
    parts = [area, strand, n.name, n.description] + n.specific_learning_outcomes + n.key_inquiry_questions + n.learning_experiences + n.local_materials;
    return " ".join(parts);
}

"""Rank sub-strands by BM25 relevance to the query; ties keep curriculum order."""
def retrieve(query: str, docs: list[CurriculumNode], k: int = 3) -> list[CurriculumNode] {
    if not docs {
        return [];
    }
    q_terms = set(tokenize(query));
    tokenized = [tokenize(node_text(d)) for d in docs];
    avg_len = sum([len(t) for t in tokenized]) / len(tokenized);
    n_docs = len(docs);
    scored: list[tuple[float, int]] = [];
    for (i, toks) in enumerate(tokenized) {
        score = 0.0;
        for term in q_terms {
            tf = toks.count(term);
            if tf == 0 {
                continue;
            }
            df = len([1 for t in tokenized if term in t]);
            idf = math.log(1 + (n_docs - df + 0.5) / (df + 0.5));
            score += idf * (tf * 2.2) / (tf + 1.2 * (0.25 + 0.75 * len(toks) / avg_len));
        }
        scored.append((score, i));
    }
    ranked = sorted(scored, key=lambda (s: tuple[float, int]) -> tuple[float, int] { return (-s[0], s[1]); });
    return [docs[i] for (_, i) in ranked[:k]];
}

"""A compact, LLM-ready description of one sub-strand and its lineage."""
def context_block(sub: CurriculumNode) -> str {
    (area, strand_name) = lineage(sub);
    strand = parent_of(sub);
    lines = [
        f"Learning Area: {area}",
        f"Strand: {strand_name}",
        f"Sub-strand: {sub.name}",
        "Specific Learning Outcomes: " + "; ".join(sub.specific_learning_outcomes),
        "Key Inquiry Questions: " + "; ".join(sub.key_inquiry_questions),
        "Suggested Learning Experiences: " + "; ".join(sub.learning_experiences),
        "Resources: " + "; ".join(sub.resources),
        "Locally available materials: " + "; ".join(sub.local_materials),
        f"Home link: {sub.home_activity}"
    ];
    if strand {
        lines.append("Core Competencies: " + "; ".join(strand.core_competencies));
        lines.append("Values: " + "; ".join(strand.values));
        lines.append("PCIs: " + "; ".join(strand.pcis));
    }
    return "\n".join(lines);
}

def grade_profile(g: GradeNode) -> str {
    return f"{g.label} ({g.stage}), learners aged {g.age_range}. Benchmark assessment: {g.assessment}. Learner profile: {g.learner_profile} Typical lesson: {g.lesson_minutes} minutes. Recommended home study: {g.daily_study_minutes} minutes per day.";
}
