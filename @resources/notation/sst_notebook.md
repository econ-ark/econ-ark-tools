# `sst_notebook.py`: notebooks written with the registry's macros

**Where it lives:** econ-ark-tools, `@resources/notation/`, beside `econark-math.yml`, which it reads by
default. Every repository that vendors `@resources` gets the tool and the definitions from the same release.
Chris Carroll chose this placement on 2026-11-16.

## The pattern

Econ-ARK documents write every economic object with its macro (`\CRRA`, `\cNrm`, `\PermGroFac`), so a change
in the registry reaches all of them (rule D). A web build reads the definitions through MyST's
`extends: [econark-math.yml]`; a notebook someone downloads and opens in Jupyter, VS Code, Colab, Binder or
on GitHub does not. So a notebook has a **single source of truth**, written with the macros, and the
notebook people open is generated from it:

```
Name_SST.ipynb  or  Name_SST.md (MyST)    the source: math written with the macros. Edit only this.
Name.ipynb  /  Name.md                    generated: the same cells, ids and outputs, macros spelled out
```

- **Only Markdown math changes.** In `$...$` and `$$...$$` outside code, each macro is replaced, recursively,
  by the LaTeX it prints. Text and code cells are untouched. A figure label in code is written literally,
  or with a helper available where the notebook runs, such as the book's `intertemporal_choice.notation.tex`.
- **The SST renders in Jupyter too.** It carries one hidden Markdown cell, tagged `notation-definitions`,
  with a `\newcommand` for each macro its Markdown uses. The tool writes that cell, first after any
  frontmatter cell, since MathJax defines a macro only for the math that follows. The generated notebook
  leaves it out.
- **A project's own macros** go in a local block (`--local`, the registry's `project: math:` format),
  applied on top of the registry as a MyST `extends:` list would apply them. Never in the SST.
- **No spurious changes.** The output depends only on the SST's content and the definitions; a file is
  rewritten only when its bytes would change. A MyST SST's definitions cell is edited as text, so nothing
  else in the file moves. Stripping execution counts and timings is the repository's own filter's job,
  before the tool reads the SST.

## Use

```bash
uv run @resources/notation/sst_notebook.py definitions Name_SST.ipynb         # the SST's definitions cell
uv run @resources/notation/sst_notebook.py generate Name_SST.ipynb            # writes Name.ipynb
uv run @resources/notation/sst_notebook.py check Name_SST.ipynb -o Name.ipynb # exit 1 if either is stale
uv run @resources/notation/sst_notebook.py self-test
```

`uv run` reads the script's inline dependencies (pyyaml, nbformat, jupytext). Options:

| option | what it does |
|---|---|
| `-o OUT` | the generated notebook; default the SST's name without `_SST`; its extension (`.ipynb`, `.md`) picks the format |
| `--registry PATH` | the registry's math; default `econark-math.yml` beside the script |
| `--local PATH` | a local block on top; repeatable, later ones win |
| `--remove-tags a,b` | leave out cells carrying any of these tags: one SST gives a students' version (`answer`) and a key (`instructor`) |
| `--no-note`, `--note TEXT` | the generated-from comment at the head of the first Markdown cell (a format string with `{sst}`) |
| `--definitions-note TEXT` | the comment at the head of the definitions cell |
| `--metadata-key`, `--by` | where and how the generated notebook's metadata records its source |

## Two ways a repository uses it

- **Committed side by side** (the Intertemporal Choice book): `Chapter_SST.ipynb` and the generated
  `Chapter.ipynb` are both committed, so the site, Colab and Binder reach a renderable file. A pre-commit
  hook runs `generate` on what is staged, and CI runs `check`. The book's `code/notebook_math.py` becomes a
  thin wrapper that adds its own parts (stripping with the repo's nbstripout options, the python3 kernelspec,
  the package's `_notation_macros.py`).
- **Generated at posting** (the course's problem-set questions): `Question_SST.md` holds the question and
  its key and is the only committed notebook. The posting script runs `generate --remove-tags answer` for
  the students' version and `--remove-tags instructor` for the key. Nothing generated is committed beside
  the SST.

## Checked when drafted (2026-11-16)

- From the book's `RamseyCassKoopmans_SST.ipynb`, with the book's registry, course block and notes, it writes
  the book's committed `RamseyCassKoopmans.ipynb` byte for byte, and `check` finds the SST's definitions
  cell current.
- On a MyST question (FriedmanPIH, written with `\yLvl`, `\pLvl`, `\cLvl`, `\tranShkEmp`, `\permShkInd`,
  `\std`): `definitions` adds only its cell and a second run changes nothing; the students' version
  and the key have every macro spelled out, the tagged cells left out, and two runs give identical bytes.
- Its self-test passes.

Derived from the book's `code/notebook_math.py` and `intertemporal_choice/notation.py`.
