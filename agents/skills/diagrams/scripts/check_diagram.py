"""Check a Unicode box-drawing diagram for alignment problems.

Copied from the `text-diagrams` skill (original author unknown).

Usage:
    python check_diagram.py diagram.txt
    cat diagram.txt | python check_diagram.py

If the input contains ``` fences, each fenced block is checked separately.

What it reports:
  ERROR    a line char points into a neighbour that doesn't connect back
           (e.g. a ┐ with a ─ directly below it, or "─┃" side by side)
  DANGLING a vertical line or corner opens onto a space/text above or below.
           This is how a box border shifted by one column shows up. A
           deliberate line end (a leader line running into a label) is fine;
           anything else should be fixed.
  WIDTH    a character that renders double-width (CJK, most emoji) or a tab,
           which will push everything after it out of alignment.

Exit code is 0 when nothing is found, 1 otherwise.
"""
import pathlib
import sys
import unicodedata

U, D, L, R = 1, 2, 4, 8

ARMS = {}


def _add(chars, arms):
    for ch in chars:
        ARMS[ch] = arms


# light, heavy, double, rounded (weight is ignored when matching)
_add("─━═", L | R)
_add("│┃║", U | D)
_add("┌┏╔╭╒╓", R | D)
_add("┐┓╗╮╕╖", L | D)
_add("└┗╚╰╘╙", U | R)
_add("┘┛╝╯╛╜", U | L)
_add("├┣╠╞╟┝┠", U | D | R)
_add("┤┫╣╡╢┥┨", U | D | L)
_add("┬┳╦╤╥┯┰", L | R | D)
_add("┴┻╩╧╨┷┸", L | R | U)
_add("┼╋╬╪╫┿╂", U | D | L | R)
_add("╴╸", L)
_add("╶╺", R)
_add("╵╹", U)
_add("╷╻", D)
# arrowheads: they receive a line from one side and end it
_add("▼▽↓", U)
_add("▲△↑", D)
_add("▶▷►→", L)
_add("◀◁◄←", R)

# Dashed / dotted lines (┄┅┈┉╌╍ ┆┇┊┋╎╏) are decorative separators that may
# start, end and cross solid lines anywhere, so they are treated like text
# and never checked.

OPPOSITE = {U: D, D: U, L: R, R: L}


def char_at(grid, r, c):
    if 0 <= r < len(grid) and 0 <= c < len(grid[r]):
        return grid[r][c]
    return " "


def check_block(lines, offset=0):
    issues = []
    grid = [line.rstrip("\n") for line in lines]

    for r, line in enumerate(grid):
        for c, ch in enumerate(line):
            if ch == "\t":
                issues.append(("WIDTH", r, c, "tab character; use spaces"))
            elif unicodedata.east_asian_width(ch) in ("W", "F"):
                issues.append(("WIDTH", r, c, f"double-width character {ch!r}"))

    for r, line in enumerate(grid):
        for c, ch in enumerate(line):
            arms = ARMS.get(ch)
            if not arms:
                continue
            for arm, (dr, dc) in ((U, (-1, 0)), (D, (1, 0)), (R, (0, 1))):
                if not arms & arm:
                    continue
                nb = char_at(grid, r + dr, c + dc)
                nb_arms = ARMS.get(nb, 0)
                if nb_arms & OPPOSITE[arm]:
                    continue
                if nb in ARMS:
                    issues.append((
                        "ERROR", r, c,
                        (
                            f"{ch!r} connects {'up' if arm == U else 'down' if arm == D else 'right'}"
                            f" but neighbour {nb!r} doesn't connect back"
                        ),
                    ))
                elif arm in (U, D):
                    issues.append((
                        "DANGLING", r, c,
                        f"{ch!r} opens {'up' if arm == U else 'down'} onto {nb!r}",
                    ))
                # horizontal lines ending on text are normal (labels set into
                # borders like "╔═ API ═══╗"), so they are not reported.
    return [(kind, r + offset, c, msg) for kind, r, c, msg in issues]


def split_blocks(text):
    lines = text.splitlines()
    if not any(l.strip().startswith("```") for l in lines):
        return [(0, lines)]
    blocks, current, start, inside = [], [], 0, False
    for i, line in enumerate(lines):
        if line.strip().startswith("```"):
            if inside:
                blocks.append((start, current))
                current = []
            else:
                start = i + 1
            inside = not inside
        elif inside:
            current.append(line)
    if inside:
        blocks.append((start, current))
    return blocks


def main():
    text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8") if len(sys.argv) > 1 else sys.stdin.read()
    all_issues = []
    fences = [i for i, line in enumerate(text.splitlines()) if line.strip().startswith("```")]
    if len(fences) % 2:
        all_issues.append(("ERROR", fences[-1], 0, "code fence opened here is never closed"))

    for start, block in split_blocks(text):
        all_issues += check_block(block, start)
    if not all_issues:
        print("OK: no alignment issues found")
        return 0
    for kind, r, c, msg in sorted(all_issues, key=lambda x: (x[1], x[2])):
        print(f"{kind:8} line {r + 1}, col {c + 1}: {msg}")
    print(f"\n{len(all_issues)} issue(s). Lines and columns are 1-based.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
