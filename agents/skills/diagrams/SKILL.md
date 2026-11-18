---
name: diagrams
description: This skill should be used when the user asks to explain something visually, "draw", "diagram", "flowchart", "show me how X flows", "sketch the architecture", "visualize the request path", a sequence or state diagram, "a diagram like turbopuffer's docs", an ASCII or text diagram, or asks to fix or extend an existing text diagram. Also use it, even without the word "diagram", when the user asks how components connect or how a request, job or data moves through a system and a picture would explain it better than prose. Draws turbopuffer-style Unicode box-drawing diagrams in a code block. Default for any diagram unless the user names another format (Mermaid, PlantUML, Graphviz, a chart, an image, an artifact or page).
---

# Diagrams

A text diagram in the style of turbopuffer's docs, with double-bordered
systems, `░` drop shadows, light inner boxes, labels set into borders, and
labelled arrows.

```
                    ╔═ turbopuffer ════════════════════════════════╗
╔══════════╗        ║                                              ║░
║          ║░       ║  ┌────────────────┐      ┌────────────────┐  ║░
║  client  ║───API─▶║  │   memory/ssd   │─────▶│ object storage │  ║░
║          ║░       ║  │     cache      │      │      (s3)      │  ║░
╚══════════╝░       ║  └────────────────┘      └────────────────┘  ║░
 ░░░░░░░░░░░░       ║                                              ║░
                    ╚══════════════════════════════════════════════╝░
                     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
```

Alignment is the hard part: one column off and a border visibly breaks.
The workflow is plan, draw into a file, run the checker, fix, deliver.

## Workflow

1. **Pick the structure.** Nodes, containers (what sits inside what), flows
   between them, decisions, and states worth showing with fills. If the
   request is vague, pick a structure and state the assumption in one line.

2. **Plan the grid.** Decide each box's columns before drawing:
   - Labels get two spaces of padding on each side, or one when that keeps
     siblings aligned. Siblings share a width.
   - Boxes joined by a vertical line get an odd inner width, so a centred
     junction (`┬`, `╤`) has equal runs on both sides.
   - At least one blank row or column between a box and its container
     border, and between neighbouring boxes.
   - Under 100 columns.

3. **Draw into `diagram.txt` in the session scratchpad directory** (the
   absolute path from the system prompt; `mktemp -d` when the session has
   none), not straight into the reply. Beyond a few boxes, generate rows
   with a short Python script (`str.center`, `ljust`) instead of typing
   spaces.

4. **Run the checker** with the absolute path:

   ```sh
   python3 -I ~/.dotfiles/agents/skills/diagrams/scripts/check_diagram.py <scratchpad>/diagram.txt
   ```

   It reports `DANGLING` (a line opening onto nothing, usually a border
   shifted by one), `ERROR` (a line meeting a char that doesn't connect,
   usually `═│═` where `═╪═` belongs, or a code fence never closed) and
   `WIDTH` (tabs, emoji, CJK). Fix and rerun until it prints `OK`. The
   only acceptable leftover is a `DANGLING` leader line that deliberately
   runs into a text label.

5. **Deliver** in a bare fenced code block in the reply. Put it in a file
   (README, docstring, Markdown doc) only when the user named that file.

## Visual language

| Weight | Chars       | Use for                                                                                             |
| ------ | ----------- | --------------------------------------------------------------------------------------------------- |
| Double | `╔═╗ ║ ╚═╝` | top-level systems, regions, external actors (client, user)                                          |
| Light  | `┌─┐ │ └─┘` | components inside a system, flowchart steps                                                         |
| Heavy  | `┏━┓ ┃ ┗━┛` | storage units shown on their own, such as files or segments in a storage row                        |
| Dashed | `╌ ┊`       | separator lines only (phases, logical groupings); never box borders, the checker can't connect them |

- **Label in border**: `╔═ turbopuffer ═══╗` names a container without
  spending a row. One border char on each side of the label.
- **Drop shadow**: `░` one column right of the right border on every row
  below the top, plus a `░` row under the bottom border shifted right by
  one, so it is one char longer than the border. Only on double-bordered
  boxes. A row carrying an outgoing arrow replaces the shadow cell with
  the line.
- **Arrows**: lines end in `▶ ◀ ▲ ▼`; hollow `▷ ▽` for async or optional.
  Label flows on the line (`───API─▶`) or beside a vertical one
  (`│ group commit (<= 1/s)`).
- **Junctions**: vertical lines leaving or entering a horizontal border,
  and lines crossing a border, use junctions (`┬ ┴ ┼`, `╤ ╧ ╪` on double
  borders). Horizontal arrows start and end at a plain vertical border.
- **Fills encode state**, darkest for the most finished: `█ ▓ ▞ ░`, plus
  markers `■ ◈` for items in a queue or cache. The legend underneath
  defines what each fill means in that diagram.
- **Text**: lowercase, short labels. Code names (`./tpuf query`,
  `s3://bucket/wal`) are fine. Numbers and captions (`~10ms`) go below
  the box.

`references/patterns.md` has the character table, junction cheat sheet,
and checked templates: shadowed container, pipeline, flowchart with
decisions and loops, storage row with legend, phase timeline, fan-out,
ASCII fallback. Start from a template when one fits.

## Pitfalls

- No emoji or CJK inside diagrams: they render double-width and shift
  everything after them.
- Use the ASCII fallback in `references/patterns.md` when the destination
  mangles box drawing (Bitbucket, some email clients, East Asian terminal
  settings).
- Editing an existing diagram: copy it to a file, change it, rerun the
  checker on the whole thing. Inserting a box usually means widening the
  container and its shadow.

## Credits

- Visual style copied from the architecture diagrams in turbopuffer's docs:
  https://turbopuffer.com/docs/architecture
- Adapted from the `text-diagrams` skill (SKILL.md, `references/patterns.md`,
  `scripts/check_diagram.py`), shared as `text-diagrams.skill`. Original
  author unknown.
