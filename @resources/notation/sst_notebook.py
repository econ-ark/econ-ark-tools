# /// script
# requires-python = ">=3.10"
# dependencies = ["pyyaml", "nbformat", "jupytext"]
# ///
"""sst_notebook.py: a notebook's single source of truth (SST), written with the registry's macros, and the
notebooks generated from it with every macro spelled out in the LaTeX it prints.

Why. Econ-ARK documents write every economic object with its macro (`\\CRRA`, `\\cNrm`, `\\PermGroFac`), so a
change in the registry reaches them all (rule D, Chris Carroll, 2026-11-15). A web build reads the macros'
definitions (MyST's `extends: [econark-math.yml]`); a notebook a reader downloads and opens in Jupyter, VS
Code, Colab, Binder or on GitHub does not. So the notebook people open is generated from the SST:

    <Name>_SST.ipynb  or  <Name>_SST.md (MyST)   the source: math written with the macros; edit only this
    <Name>.ipynb  /  <Name>.md                   generated: the same cells, ids and outputs, macros spelled out

What it does.
  - `generate SST [-o OUT]`: writes the generated notebook. Markdown math ($...$, $$...$$, outside code) has
    each macro replaced, recursively, by its definition; text and code cells are untouched (a figure label in
    code is written literally, or with a helper the reader's environment has, such as the book's
    `intertemporal_choice.notation.tex`). The SST's definitions cell is left out. `--remove-tags answer` drops
    the cells carrying any of those tags, so one SST gives a students' version and a key (`--remove-tags
    instructor`). OUT defaults to the SST's name without `_SST`; its extension picks the format.
  - `definitions SST`: rewrites, in place, the SST's one Markdown cell tagged `notation-definitions`: a
    `\\newcommand` for each macro its Markdown uses, so that the SST itself renders in Jupyter. It comes first
    (after a frontmatter cell): MathJax defines a macro only for the math after its definition.
  - `check SST [-o OUT]`: exit 1 if the SST's definitions cell, or OUT when given, is not what this script
    writes. For CI and pre-commit hooks.
  - `self-test`.

The definitions. By default the registry beside this script (econark-math.yml, generated from
econark-shortcuts.sty and notation.yml), then each `--local` block on top, later ones winning, in the same
`project: math:` format, as a MyST `extends:` list would apply them. A project's own conflicts and
overrides go in its local block, never in the SST.

No spurious changes. Output depends only on the SST's content and the definitions; a file is rewritten
only when its bytes would change. Stripping outputs or execution counts is the calling repository's
business (its nbstripout filter), done before this script reads the SST.

Derived from the Intertemporal Choice book's code/notebook_math.py and intertemporal_choice/notation.py
(intertemporal-choice/intertemporal-choice.github.io), generalized on Chris Carroll's request of
2026-11-16 to live beside the registry for every Econ-ARK repository.

Usage:
    uv run sst_notebook.py generate Chapter_SST.ipynb [-o Chapter.ipynb] [--local block.yml] [--remove-tags answer]
    uv run sst_notebook.py definitions Question_SST.md [--local block.yml]
    uv run sst_notebook.py check Chapter_SST.ipynb -o Chapter.ipynb
    uv run sst_notebook.py self-test
"""
from __future__ import annotations

import argparse
import copy
import re
import sys
from pathlib import Path

import nbformat
import yaml

HERE = Path(__file__).resolve().parent
REGISTRY = HERE / "econark-math.yml"
SUFFIX = "_SST"
TAG = "notation-definitions"
BY = "econ-ark-tools @resources/notation/sst_notebook.py"
DEFINITIONS_NOTE = (
    "<!-- The notation for this notebook: a definition for each macro its Markdown uses, so that it renders "
    "in Jupyter. Written by sst_notebook.py from the registry{local}; don't edit. The generated notebook "
    "leaves this cell out. -->"
)
GENERATED_NOTE = (
    "<!-- Generated from {sst} by sst_notebook.py. Don't edit this notebook: edit {sst}, where the math is "
    "written with the macros, and run the script. -->"
)

CONTROL_WORD = re.compile(r"\\[A-Za-z]+")
PARAMETER = re.compile(r"#([1-9])")
ENDS_IN_CONTROL_WORD = re.compile(r"\\[A-Za-z]+$")
FENCE = re.compile(r"(?ms)^[ ]{0,3}(`{3,}|~{3,}).*?^[ ]{0,3}\1[ \t]*$")
CODE_SPAN = re.compile(r"(`+)(?!`).+?(?<!`)\1(?!`)", re.S)
DISPLAY = re.compile(r"(?<!\\)\$\$(.+?)(?<!\\)\$\$", re.S)
INLINE = re.compile(r"(?<![\\$])\$(?!\$)(.+?)(?<![\\$])\$(?!\$)", re.S)


# --- the definitions -------------------------------------------------------------------------------------

def load_macros(registry: Path = REGISTRY, local: list[Path] = ()) -> dict[str, str]:
    """The registry's definitions, with each local block's on top (later blocks win)."""
    macros: dict[str, str] = {}
    for path in [registry, *local]:
        macros.update(yaml.safe_load(Path(path).read_text(encoding="utf-8"))["project"]["math"])
    return macros


def arity(body: str) -> int:
    """How many arguments a definition takes: its highest #n."""
    return max((int(n) for n in PARAMETER.findall(body)), default=0)


def _argument(tex: str, i: int) -> tuple[str, int]:
    """The argument that starts at tex[i], spaces skipped: a braced group's content, a control word or
    symbol, or one character; and the index just past it."""
    while i < len(tex) and tex[i] == " ":
        i += 1
    if i >= len(tex):
        raise ValueError("a macro is missing an argument")
    if tex[i] == "{":
        depth, j = 0, i
        while j < len(tex):
            if tex[j] == "\\":
                j += 2
                continue
            depth += {"{": 1, "}": -1}.get(tex[j], 0)
            if depth == 0:
                return tex[i + 1:j], j + 1
            j += 1
        raise ValueError("an argument's braces do not close")
    if tex[i] == "\\":
        m = CONTROL_WORD.match(tex, i)
        return (m.group(0), m.end()) if m else (tex[i:i + 2], i + 2)
    return tex[i], i + 1


def expand(tex: str, macros: dict[str, str], _depth: int = 0) -> str:
    """tex with every macro in `macros` replaced, recursively, by what it prints. Other control words
    (\\frac, \\alpha) are left as they are."""
    if _depth > 30:
        raise ValueError("macros that expand into each other without end")
    out: list[str] = []
    i = 0
    while i < len(tex):
        if tex[i] != "\\":
            out.append(tex[i]); i += 1; continue
        m = CONTROL_WORD.match(tex, i)
        if not m:                                   # a control symbol: \, \{ \\ ...
            out.append(tex[i:i + 2]); i += 2; continue
        if m.group(0) not in macros:
            out.append(m.group(0)); i = m.end(); continue
        body, i = macros[m.group(0)], m.end()
        for n in range(1, arity(body) + 1):
            argument, i = _argument(tex, i)
            body = body.replace(f"#{n}", argument)
        text = expand(body, macros, _depth + 1)
        # A control word must not run into the letters around it: \alpha\kap is \alpha k, not \alphak.
        if text[:1].isalpha() and out and ENDS_IN_CONTROL_WORD.search(out[-1]):
            text = " " + text
        if ENDS_IN_CONTROL_WORD.search(text) and tex[i:i + 1].isalpha():
            text += " "
        out.append(text)
    return "".join(out)


# --- Markdown --------------------------------------------------------------------------------------------

def math_spans(markdown: str) -> list[tuple[int, int]]:
    """(start, end) of each math span's content, $$...$$ or $...$, outside code."""
    masked = FENCE.sub(lambda m: " " * len(m.group(0)), markdown)
    masked = CODE_SPAN.sub(lambda m: " " * len(m.group(0)), masked)
    spans = [m.span(1) for m in DISPLAY.finditer(masked)]
    for start, end in spans:
        masked = masked[:start - 2] + " " * (end - start + 4) + masked[end + 2:]
    spans += [m.span(1) for m in INLINE.finditer(masked) if "\n\n" not in m.group(1)]
    return sorted(spans)


def expand_markdown(markdown: str, macros: dict[str, str]) -> str:
    """Markdown with each macro in its math spelled out; text and code untouched."""
    for start, end in reversed(math_spans(markdown)):
        markdown = markdown[:start] + expand(markdown[start:end], macros) + markdown[end:]
    return markdown


def macros_used(markdown: str, macros: dict[str, str]) -> set[str]:
    return {name for s, e in math_spans(markdown) for name in CONTROL_WORD.findall(markdown[s:e]) if name in macros}


def definitions(used: set[str], macros: dict[str, str], note: str) -> str:
    """The definitions cell's source: one \\newcommand per macro, each spelled out in full."""
    lines = [note]
    for name in sorted(used, key=lambda n: (n.lower(), n)):
        body, n = macros[name], arity(macros[name])
        lines.append(f"$\\newcommand{{{name}}}{f'[{n}]' if n else ''}{{{expand(body, macros)}}}$")
    return "\n".join(lines)


# --- notebooks -------------------------------------------------------------------------------------------

def read(path: Path):
    """A notebook from .ipynb, or from a jupytext text format (MyST .md, percent .py), with the format kept."""
    if path.suffix == ".ipynb":
        return nbformat.reads(path.read_text(encoding="utf-8"), as_version=4)
    import jupytext
    nb = jupytext.reads(path.read_text(encoding="utf-8"), fmt=path.suffix[1:])
    # jupytext gives each cell a random id on every read; ids by position keep the output reproducible
    for i, cell in enumerate(nb.cells):
        cell["id"] = TAG if has_tag(cell, TAG) else f"cell-{i}"
    return nb


def text_of(nb, path: Path, like=None) -> str:
    """The notebook as `path`'s format stores it. A text format keeps the source's jupytext format."""
    if path.suffix == ".ipynb":
        out = nbformat.writes(nb)
        return out if out.endswith("\n") else out + "\n"
    import jupytext
    rep = (like or nb).metadata.get("jupytext", {}).get("text_representation", {})
    fmt = rep.get("format_name")
    out = jupytext.writes(nb, fmt=f"{path.suffix[1:]}:{fmt}" if fmt else path.suffix[1:])
    # jupytext stamps its own version into the header; keep the source's, so a rewrite changes nothing else
    if rep.get("jupytext_version"):
        out = re.sub(r"(?m)^(\s*jupytext_version: ).*$", lambda m: m.group(1) + rep["jupytext_version"], out, count=1)
    return out


def has_tag(cell, tag: str) -> bool:
    return tag in (cell.get("metadata", {}).get("tags") or [])


def is_frontmatter(cell) -> bool:
    return cell.cell_type in ("markdown", "raw") and cell.source.lstrip().startswith("---")


def with_definitions(nb, macros: dict[str, str], note: str):
    """The SST with its definitions cell current, first after any frontmatter cell."""
    nb = copy.deepcopy(nb)
    used = set()
    for cell in nb.cells:
        if cell.cell_type == "markdown" and not has_tag(cell, TAG):
            used |= macros_used(cell.source, macros)
    cells = [c for c in nb.cells if has_tag(c, TAG)]
    if len(cells) > 1:
        raise ValueError(f"more than one cell is tagged {TAG}")
    cell = cells[0] if cells else nbformat.v4.new_markdown_cell(
        "", id=TAG, metadata={"tags": [TAG], "jupyter": {"source_hidden": True}})
    cell.source = definitions(used, macros, note)
    nb.cells = [c for c in nb.cells if not has_tag(c, TAG)]
    nb.cells.insert(1 if nb.cells and is_frontmatter(nb.cells[0]) else 0, cell)
    return nb


def generated(nb, macros: dict[str, str], sst_name: str, remove_tags=(), note: str | None = GENERATED_NOTE,
              metadata_key: str = "sst_notebook", by: str = BY):
    """The notebook people open: the SST's cells and outputs, macros spelled out, no definitions cell, and
    no cell carrying a tag in `remove_tags`. `note` (a format string with {sst}, or None) heads the first
    Markdown cell after any frontmatter; the notebook's metadata says where it came from."""
    nb = copy.deepcopy(nb)
    nb.cells = [c for c in nb.cells if not has_tag(c, TAG) and not any(has_tag(c, t) for t in remove_tags)]
    noted = note is None
    for cell in nb.cells:
        if cell.cell_type != "markdown":
            continue
        cell.source = expand_markdown(cell.source, macros)
        if not noted and not cell.source.lstrip().startswith("---"):
            cell.source = note.format(sst=sst_name) + "\n" + cell.source
            noted = True
    nb.metadata[metadata_key] = {"generated_from": sst_name, "by": by}
    return nb


def myst_with_definitions(text: str, source: str) -> str:
    """A MyST notebook's text with its definitions cell set to `source`, edited as text, so that nothing
    else in the file changes (a jupytext round trip drops empty cells and restamps its header). The cell
    replaces an existing one, or goes first, right after the YAML header."""
    meta = '+++ {"tags": ["' + TAG + '"], "jupyter": {"source_hidden": true}}'
    block = f"{meta}\n\n{source}\n"
    lines = text.split("\n")
    start = next((i for i, l in enumerate(lines) if l.startswith("+++ {") and f'"{TAG}"' in l), None)
    if start is not None:
        end = next((j for j in range(start + 1, len(lines))
                    if lines[j] == "+++" or lines[j].startswith(("+++ ", "```{code-cell}"))), len(lines))
        while end > start + 1 and lines[end - 1] == "":
            end -= 1
        return "\n".join(lines[:start] + block.rstrip("\n").split("\n") + lines[end:])
    head = 0
    if lines and lines[0] == "---":
        head = next(j for j in range(1, len(lines)) if lines[j] == "---") + 1
    rest = lines[head:]
    first = next((l for l in rest if l.strip()), "")
    tail = "" if first.startswith(("+++", "```{code-cell}")) else "\n+++\n"
    return "\n".join(lines[:head] + ["", *block.rstrip("\n").split("\n"), *tail.split("\n")[:-1]] + rest)


def default_out(sst: Path) -> Path:
    if not sst.stem.endswith(SUFFIX):
        raise SystemExit(f"{sst.name}: an SST's name ends in {SUFFIX}; give -o for the generated notebook")
    return sst.with_name(sst.stem[:-len(SUFFIX)] + sst.suffix)


def write_if_changed(path: Path, text: str) -> bool:
    if path.exists() and path.read_text(encoding="utf-8") == text:
        return False
    path.write_text(text, encoding="utf-8")
    return True


# --- self-test -------------------------------------------------------------------------------------------

def self_test() -> list[str]:
    m = {"\\cNrm": "c", "\\cLvl": "\\boldsymbol{c}", "\\CRRA": "\\varrho", "\\kap": "k", "\\Steady": "\\bar{#1}",
         "\\Ex": "\\mathbb{E}", "\\DiscFac": "\\beta"}
    cases = [
        (expand(r"\cNrm_{t}", m), "c_{t}"),
        (expand(r"\Steady{\cNrm}", m), r"\bar{c}"),
        (expand(r"\alpha\kap", m), r"\alpha k"),
        (expand(r"\DiscFac x", m), r"\beta x"),
        (expand(r"\Ex_{t}[\cLvl]", m), r"\mathbb{E}_{t}[\boldsymbol{c}]"),
        (expand_markdown("cost $\\cNrm$ and `\\cNrm` in code, $$\\CRRA$$", m), "cost $c$ and `\\cNrm` in code, $$\\varrho$$"),
        (expand_markdown("```\n$\\cNrm$\n```", m), "```\n$\\cNrm$\n```"),
        (sorted(macros_used("$\\cNrm + \\frac{1}{\\CRRA}$ and \\kap", m)), ["\\CRRA", "\\cNrm"]),
    ]
    nb = nbformat.v4.new_notebook(cells=[
        nbformat.v4.new_markdown_cell("---\ntitle: t\n---"),
        nbformat.v4.new_markdown_cell("Utility $\\cNrm^{1-\\CRRA}$."),
        nbformat.v4.new_code_cell("x = r'$\\cNrm$'"),
        nbformat.v4.new_markdown_cell("Answer: $\\Steady{\\cNrm}$", metadata={"tags": ["answer"]}),
    ])
    sst = with_definitions(nb, m, "<!-- defs -->")
    gen = generated(sst, m, "T_SST.ipynb", remove_tags=("answer",))
    cases += [
        (sst.cells[1].metadata["tags"], [TAG]),
        (sst.cells[1].source.splitlines()[1:], ["$\\newcommand{\\cNrm}{c}$", "$\\newcommand{\\CRRA}{\\varrho}$",
                                                "$\\newcommand{\\Steady}[1]{\\bar{#1}}$"]),
        (len(gen.cells), 3),
        (gen.cells[1].source.splitlines()[-1], "Utility $c^{1-\\varrho}$."),
        (gen.cells[2].source, "x = r'$\\cNrm$'"),
        (with_definitions(sst, m, "<!-- defs -->").cells == sst.cells, True),
    ]
    return [f"case {i}: got {got!r}, wanted {want!r}" for i, (got, want) in enumerate(cases) if got != want]


# --- command line ----------------------------------------------------------------------------------------

def main(argv=None) -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("command", choices=["generate", "definitions", "check", "self-test"])
    p.add_argument("sst", nargs="?", type=Path)
    p.add_argument("-o", "--out", type=Path, help="the generated notebook (default: the SST's name without _SST)")
    p.add_argument("--registry", type=Path, default=REGISTRY, help="the registry's math (default: beside this script)")
    p.add_argument("--local", type=Path, action="append", default=[], help="a local block on top (repeatable)")
    p.add_argument("--remove-tags", default="", help="comma-separated cell tags to leave out of the generated notebook")
    p.add_argument("--no-note", action="store_true", help="no generated-from note in the generated notebook")
    p.add_argument("--note", default=GENERATED_NOTE, help="the generated-from note, a format string with {sst}")
    p.add_argument("--definitions-note", default=None, help="the definitions cell's note")
    p.add_argument("--metadata-key", default="sst_notebook", help="the generated notebook's metadata key")
    p.add_argument("--by", default=BY, help="what the metadata says generated it")
    a = p.parse_args(argv)
    if a.command == "self-test":
        bad = self_test()
        print("\n".join(bad) or "self-test: all cases pass")
        return 1 if bad else 0
    if a.sst is None:
        p.error("an SST notebook is needed")
    macros = load_macros(a.registry, a.local)
    dnote = a.definitions_note or DEFINITIONS_NOTE.format(local="".join(f" and {x.name}" for x in a.local))
    nb = read(a.sst)
    sst = with_definitions(nb, macros, dnote)
    if a.sst.suffix == ".md":       # edited as text: a round trip would change more than the cell
        cell = next(c for c in sst.cells if has_tag(c, TAG))
        sst_text = myst_with_definitions(a.sst.read_text(encoding="utf-8"), cell.source)
    else:
        sst_text = text_of(sst, a.sst, like=nb)
    if a.command == "definitions":
        print(f"{a.sst}: {'definitions cell rewritten' if write_if_changed(a.sst, sst_text) else 'current'}")
        return 0
    out = a.out or (default_out(a.sst) if a.command == "generate" else None)
    gen_text = None
    if out is not None:
        tags = tuple(t for t in a.remove_tags.split(",") if t)
        gen = generated(sst, macros, a.sst.name, tags, None if a.no_note else a.note, a.metadata_key, a.by)
        gen_text = text_of(gen, out, like=nb)
    if a.command == "generate":
        print(f"{out}: {'written' if write_if_changed(out, gen_text) else 'current'}")
        return 0
    stale = []
    if a.sst.read_text(encoding="utf-8") != sst_text:
        stale.append(f"{a.sst}: its {TAG} cell is not current (run: sst_notebook.py definitions {a.sst})")
    if out is not None and (not out.exists() or out.read_text(encoding="utf-8") != gen_text):
        stale.append(f"{out}: not what sst_notebook.py generates from {a.sst.name}")
    print("\n".join(stale) or "check: current")
    return 1 if stale else 0


if __name__ == "__main__":
    sys.exit(main())
