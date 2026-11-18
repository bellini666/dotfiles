# Patterns and character reference

Every pattern here passes `scripts/check_diagram.py`. Copy and resize them
rather than drawing from scratch.

Adapted from the `text-diagrams` skill (original author unknown); style
copied from https://turbopuffer.com/docs/architecture.

## Contents

1. Character set
2. Junctions where a line meets a border
3. Shadowed container with a label in the border
4. Horizontal pipeline
5. Flowchart with decisions and a loop
6. Storage row with fill states and a legend
7. Timeline / phases with dashed separators
8. Fan-out
9. ASCII-only fallback

## 1. Character set

| Role        | Light     | Heavy     | Double    | Other             |
| ----------- | --------- | --------- | --------- | ----------------- |
| Horizontal  | `─`       | `━`       | `═`       | dashed `╌ ┄ ┈`    |
| Vertical    | `│`       | `┃`       | `║`       | dashed `╎ ┆ ┊`    |
| Corners     | `┌ ┐ └ ┘` | `┏ ┓ ┗ ┛` | `╔ ╗ ╚ ╝` | rounded `╭ ╮ ╰ ╯` |
| T-junctions | `├ ┤ ┬ ┴` | `┣ ┫ ┳ ┻` | `╠ ╣ ╦ ╩` |                   |
| Cross       | `┼`       | `╋`       | `╬`       |                   |

Arrowheads: `▶ ◀ ▲ ▼` (filled, default), `▷ ◁ △ ▽` (hollow, optional/async).

Fills, darkest to lightest: `█ ▓ ▒ ░`. Pattern fills: `▞ ▚`. Markers: `■ □ ◆ ◈ ● ○`.
Half blocks for bar segments: `▐█` repeated (`▐█▐█▐█`).

## 2. Junctions where a line meets a border

A vertical line leaving or entering a horizontal border, or any line
crossing a border, uses a junction; a plain border char there leaves the
line visibly cut. Horizontal arrows start and end at a plain vertical
border (`║───▶`, `│────▶│`), as in turbopuffer's diagrams.

| Situation                          | Use                                          |
| ---------------------------------- | -------------------------------------------- |
| line leaves a light box downward   | `──┬──`                                      |
| line enters a light box from above | `──┴──`                                      |
| line leaves a double box downward  | `══╤══` (double horizontal, single vertical) |
| line crosses a double border       | `══╪══`                                      |
| line leaves a heavy box downward   | `━━┳━━` (heavy line) or `━━┯━━` (light line) |

Mixed-weight junctions (`╤ ╧ ╪ ┯ ┷ ┿`) keep the border's weight on the
border and the connector's weight on the connector.

## 3. Shadowed container with a label in the border

```
╔═ Region ═══════════════════╗
║                            ║░
║  ┌──────────┐ ┌──────────┐ ║░
║  │  node a  │ │  node b  │ ║░
║  └──────────┘ └──────────┘ ║░
║                            ║░
╚════════════════════════════╝░
 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
```

## 4. Horizontal pipeline

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  ingest  │────▶│  index   │────▶│  query   │
└──────────┘     └──────────┘     └──────────┘
```

Keep the gap between boxes constant (5 chars here: `────▶`).

## 5. Flowchart with decisions and a loop

```
┌───────────────┐
│ send request  │◀──────────────────┐
└───────┬───────┘                   │ yes: sleep 2^n s
        ▼                           │
┌───────────────┐  no   ┌───────────┴───┐
│    2xx ok?    │──────▶│   n < max?    │
└───────┬───────┘       └───────┬───────┘
        │ yes                   │ no
        ▼                       ▼
┌───────────────┐       ┌───────────────┐
│ return result │       │     raise     │
└───────────────┘       └───────────────┘
```

Decisions are boxes whose label ends in `?`. Label every branch leaving a
decision (`yes`, `no`, a condition) on or beside its line. Main path runs
top-down; loops return along the right side into an arrowhead on the
earlier box.

## 6. Storage row with fill states and a legend

```
s3://bucket/{namespace}/wal
┏━━━━━━┓ ┏━━━━━━┓ ┏━━━━━━┓ ┏━━━━━━┓
┃██████┃ ┃██████┃ ┃▞▞▞▞▞▞┃ ┃░░░░░░┃
┃██████┃ ┃██████┃ ┃▞▞▞▞▞▞┃ ┃░░░░░░┃
┗━━━━━━┛ ┗━━━━━━┛ ┗━━━━━━┛ ┗━━━━━━┛
 01.bin   02.bin   03.bin   04.bin

█ indexed   ▞ committed   ░ pending
```

## 7. Timeline / phases with dashed separators

```
┌──────────────┐  ┊  ┌──────────────┐  ┊  ┌──────────────┐
│   metadata   │  ┊  │   centroids  │  ┊  │   clusters   │
└──────────────┘  ┊  └──────────────┘  ┊  └──────────────┘
──────────────────────────────────────────────────────────▶
   step 1         ┊       step 2       ┊      step 3
```

## 8. Fan-out

```
                    ┌────────────┐
               ┌───▶│  query 1   │
┌────────┐     │    └────────────┘
│ client │────▶┤    ┌────────────┐
└────────┘     ├───▶│  query 2   │
               │    └────────────┘
               │    ┌────────────┐
               └───▶│  query 3   │
                    └────────────┘
```

## 9. ASCII-only fallback

For destinations that mangle Unicode box drawing (Bitbucket, some email
clients and older wikis, East Asian terminal settings):

```
+----------+     +----------+
|  client  |---->|   api    |
+----------+     +----+-----+
                      |
                      v
                 +----------+
                 |  store   |
                 +----------+
```

The checker doesn't validate ASCII diagrams; count columns by hand.
