# By Mara Msingi
"""Cascading learning area > strand > sub-strand selection over a grade's curriculum tree."""

import from ..models { GradeCurriculum, CurriculumBranch }

def pick(nodes: list[CurriculumBranch], name: str) -> CurriculumBranch | None {
    for n in nodes {
        if n.name == name {
            return n;
        }
    }
    return None;
}

"""Selections that stop matching the tree (after a grade or area change) fall back to the first option,
or to "" for optional levels: the sub-strand always, and the strand when `requireStrand` is False."""
def:pub useCurriculumPicker(curriculum: GradeCurriculum | None, requireStrand: bool = True) -> dict[str, any] {
    has areaPick: str = "",
        strandPick: str = "",
        subPick: str = "";

    areas: list[CurriculumBranch] = curriculum.areas if curriculum else [];
    area = pick(areas, areaPick) or (areas[0] if areas else None);
    strands: list[CurriculumBranch] = area.children if area else [];
    strand = pick(strands, strandPick) or (strands[0] if strands and requireStrand else None);
    subs: list[CurriculumBranch] = strand.children if strand else [];
    sub = pick(subs, subPick);

    return {
        "areas": areas,
        "strands": strands,
        "subs": subs,
        "areaName": area.name if area else "",
        "strandName": strand.name if strand else "",
        "subName": sub.name if sub else "",
        "setAreaName": lambda (v: str) -> None { areaPick = v; },
        "setStrandName": lambda (v: str) -> None { strandPick = v; },
        "setSubName": lambda (v: str) -> None { subPick = v; }
    };
}
