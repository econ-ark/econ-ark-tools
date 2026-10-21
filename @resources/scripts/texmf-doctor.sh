#!/usr/bin/env bash
# texmf-doctor.sh -- check that this machine's TeX resource wiring is sane.
#
# Every problem this checks for has actually happened, and every one of them
# failed SILENTLY: builds kept succeeding while quietly using the wrong file, or
# no file at all. Run it on any machine, on macOS or Linux, with a TeX Live or a
# distro TeX installation. No arguments.
#
#   PASS  fine
#   WARN  works today, but is a known trap
#   FAIL  wrong now; exit status is non-zero
#
# Written 2026-08-02 after a day spent finding these one at a time.

set -uo pipefail

pass=0; warn=0; fail=0
ok()   { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
warned(){ printf '  WARN  %s\n' "$1"; warn=$((warn+1)); }
bad()  { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
note() { printf '        %s\n' "$1"; }

# Resolve a path to its physical location without requiring GNU readlink -f.
canon() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
  elif readlink -f / >/dev/null 2>&1; then
    readlink -f "$1"
  else
    printf '%s\n' "$1"
  fi
}

# Which git repo, if any, does a path live in?
repo_of() { git -C "$(dirname "$1")" rev-parse --show-toplevel 2>/dev/null; }

printf '\ntexmf-doctor: %s\n\n' "$(uname -s) $(hostname)"

# ---------------------------------------------------------------- 1. TEXMFLOCAL
printf '1. TEXMFLOCAL\n'
if ! command -v kpsewhich >/dev/null 2>&1; then
  bad "kpsewhich not on PATH -- cannot check anything else"
  note "on some machines TeX is not on the non-interactive PATH; try the"
  note "absolute path, e.g. /usr/local/texlive/YYYY/bin/<arch>/kpsewhich"
  printf '\n%d passed, %d warnings, %d failures\n\n' "$pass" "$warn" "$fail"
  exit 1
fi
TEXMFLOCAL="$(kpsewhich -var-value=TEXMFLOCAL 2>/dev/null | tr ';' '\n' | head -1)"
if [ -d "$TEXMFLOCAL" ]; then
  ok "TEXMFLOCAL = $TEXMFLOCAL"
  note "-> $(canon "$TEXMFLOCAL")"
else
  bad "TEXMFLOCAL ($TEXMFLOCAL) does not exist"
  note "symlink it at a clone of github.com/llorracc/texmf-local, then mktexlsr"
fi

# ------------------------------------------------------------------- 2. ls-R
printf '\n2. Filename database\n'
if kpsewhich -var-value=TEXMF 2>/dev/null | grep -q '!!'; then
  if [ -f "$TEXMFLOCAL/ls-R" ]; then
    ok "ls-R present (TEXMF uses '!!', so the tree is searched via ls-R ONLY)"
  else
    bad "no ls-R, but TEXMF marks TEXMFLOCAL '!!' -- the whole tree is invisible"
    note "fix: mktexlsr $TEXMFLOCAL   (needed after ADDING or REMOVING files)"
  fi
else
  ok "TEXMF does not use '!!' for this tree; disk search, no ls-R needed"
fi

# ------------------------------------------------------------ 3. dangling links
printf '\n3. Dangling symlinks under TEXMFLOCAL\n'
dangling=0
if [ -d "$TEXMFLOCAL" ]; then
  while IFS= read -r l; do
    [ -e "$l" ] || { bad "dangling: ${l#"$TEXMFLOCAL"/} -> $(readlink "$l")"; dangling=$((dangling+1)); }
  done < <(find "$TEXMFLOCAL/" -type l 2>/dev/null)
fi
[ "$dangling" -eq 0 ] && ok "none"
[ "$dangling" -gt 0 ] && note "absolute symlinks committed to a repo dangle on other machines;"
[ "$dangling" -gt 0 ] && note "links between sibling repos must be RELATIVE"

# ------------------------------------------------------------- 4. bibliography
printf '\n4. Bibliography\n'
sysbib="$(kpsewhich system.bib 2>/dev/null)"
if [ -n "$sysbib" ] && [ -s "$sysbib" ]; then
  ok "system.bib -> $sysbib"
  note "-> $(canon "$sysbib")"
  r="$(repo_of "$(canon "$sysbib")")"
  case "$r" in
    */texmf-local) ok "served from the texmf-local repo (the references SST)" ;;
    "")            warned "not inside a git repo -- is this a stray copy?" ;;
    *)             warned "served from $r, expected a texmf-local checkout" ;;
  esac
else
  bad "system.bib not found or empty"
  note "papers will build without the global bibliography, usually silently"
fi

# ------------------------------------------------------- 5. ur-source freshness
printf '\n5. Ur-source (econ-ark-tools) checkout\n'
probe="$(kpsewhich econark.sty 2>/dev/null)"
if [ -n "$probe" ]; then
  ur="$(repo_of "$(canon "$probe")")"
  case "$ur" in
    *econ-ark-tools)
      ok "econark.sty resolves into the ur-source: $ur"
      br="$(git -C "$ur" rev-parse --abbrev-ref HEAD 2>/dev/null)"
      if [ "$br" = "master" ]; then
        ok "on master"
      else
        warned "on branch '$br', not master -- may serve stale files"
      fi
      if git -C "$ur" rev-parse '@{u}' >/dev/null 2>&1; then
        behind="$(git -C "$ur" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)"
        if [ "${behind:-0}" -eq 0 ]; then
          ok "up to date with its remote"
        else
          warned "$behind commit(s) behind -- links look fine but serve OLD content"
        fi
      fi ;;
    *BufferStockTheory*|*HAFiscal*)
      bad "econark.sty resolves from a DOWNSTREAM copy: $ur"
      note "the ur-source is econ-ark/econ-ark-tools/@resources -- nothing may"
      note "resolve from a copy of it" ;;
    "") warned "econark.sty at $probe is not in a git repo" ;;
    *)  warned "econark.sty resolves from $ur (expected econ-ark-tools)" ;;
  esac
else
  warned "econark.sty not found (may be fine if this machine builds nothing)"
fi

# ------------------------------------------------------------------ 6. TEXMFHOME
printf '\n6. TEXMFHOME must stay empty\n'
TEXMFHOME="$(kpsewhich -var-value=TEXMFHOME 2>/dev/null)"
n_tex=0
[ -d "$TEXMFHOME" ] && n_tex="$(find "$TEXMFHOME" \( -name '*.sty' -o -name '*.cls' -o -name '*.bst' -o -name '*.bib' \) 2>/dev/null | wc -l | tr -d ' ')"
if [ "${n_tex:-0}" -eq 0 ]; then
  ok "TEXMFHOME ($TEXMFHOME) holds no TeX files"
else
  bad "TEXMFHOME holds $n_tex TeX file(s) -- it OUTRANKS TEXMFLOCAL, so these win"
  note "policy: keep ~/texmf empty; see its AGENTS.md"
fi

# ------------------------------------------------------------- 7. end-to-end
printf '\n7. End-to-end detection probe\n'
# Projects normally load this by relative path out of their own @resources
# rather than from a texmf tree, so look there too before giving up. Pass a
# project directory as $1 to point the probe somewhere specific.
sty="$(kpsewhich econark-bibfilesfind.sty 2>/dev/null)"
styinputs=""
if [ -z "$sty" ]; then
  for cand in "${1:-$PWD}" "$PWD"; do
    p="$cand/@resources/texlive/texmf-local/tex/latex"
    if [ -f "$p/econark-bibfilesfind.sty" ]; then sty="$p/econark-bibfilesfind.sty"; styinputs="$p:"; break; fi
  done
fi
if [ -z "$sty" ]; then
  warned "econark-bibfilesfind.sty found neither on the kpsewhich path nor under ./@resources"
  note "run this from a project directory, or pass one as an argument"
elif ! command -v pdflatex >/dev/null 2>&1; then
  warned "pdflatex not on PATH -- cannot run the probe"
else
  t="$(mktemp -d)"; trap 'rm -rf -- "$t"' EXIT
  printf '%s\n' '\documentclass{article}' '\usepackage{econark-bibfilesfind}' \
    '\begin{document}' '\bibfilesfind{probe}' \
    '\typeout{DOCTOR-RESULT: [\bibfilesfound]}' 'x' '\end{document}' > "$t/probe.tex"
  printf '@misc{d, title={t}}\n' > "$t/probe.bib"
  note "using $sty"
  ( cd "$t" && TEXINPUTS="${styinputs}${TEXINPUTS:-}" pdflatex -interaction=nonstopmode probe.tex >/dev/null 2>&1 )
  got="$(grep -o 'DOCTOR-RESULT: \[[^]]*\]' "$t/probe.log" 2>/dev/null | head -1)"
  route="$(grep -oE 'system.bib (found via kpsewhich|found at canonical TEXMFLOCAL|not found)' "$t/probe.log" 2>/dev/null | head -1)"
  case "$got" in
    *system*) ok "$got  ($route)" ;;
    "")       bad "probe produced no result -- see errors in the log" ;;
    *)        bad "$got -- system.bib was NOT picked up ($route)" ;;
  esac
  if [ -f "$t/probe.sysbib" ]; then
    warned "a .sysbib artifact was written -- an old write18-based .sty is in use"
  fi
fi

printf '\n%d passed, %d warnings, %d failures\n\n' "$pass" "$warn" "$fail"
[ "$fail" -eq 0 ]
