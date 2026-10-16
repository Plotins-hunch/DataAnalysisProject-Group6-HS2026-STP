// Group Report #1 — layout sketch on a Müller-Brockmann grid (lorem ipsum placeholders)
// Word budget: 600 words of running text. Title, names, tables, plots and captions don't count.
// Each lorem(n) is that section's word budget; the total is 600.
// Compile with the grid shown:  typst compile report.typ --input grid=true

// ---------- grid construction (A4, all units in points) ----------
// one baseline unit u = 12pt; 6 columns of 72pt with 12pt (= 1u) gutters;
// 5 module rows of 11 lines with a 1-line gutter -> 59 lines of type area.
#let u    = 12pt
#let colw = 72pt
#let gut  = u
#let ml   = 60pt                        // left margin  (5u)
#let mt   = 48pt                        // top margin   (4u)
#let ncol = 6
#let nlin = 59
#let tw   = ncol * colw + (ncol - 1) * gut   // type width  = 492pt
#let th   = nlin * u                         // type height = 708pt
#let span(n) = n * colw + (n - 1) * gut      // width of n columns
#let x(c)    = (c - 1) * (colw + gut)        // left edge of column c
#let y(r)    = (r - 1) * 12 * u              // top edge of module row r
#let show-grid = sys.inputs.at("grid", default: "false") == "true"

#let overlay = if show-grid {
  place(dx: ml, dy: mt, {
    for c in range(1, ncol + 1) {
      place(dx: x(c), rect(width: colw, height: th, fill: rgb(0, 0, 0, 6%), stroke: none))
    }
    for i in range(nlin) {                     // baselines (3pt above each line's bottom)
      place(dy: i * u + 9pt, line(length: tw, stroke: 0.25pt + rgb(0, 120, 255, 45%)))
    }
    for r in range(1, 6) {                     // module rows
      place(dy: y(r), rect(width: tw, height: 11 * u, stroke: 0.4pt + rgb(255, 0, 0, 40%)))
    }
  })
}

#set page(paper: "a4", margin: (left: ml, top: mt, right: 595.28pt - ml - tw, bottom: 841.89pt - mt - th),
          background: overlay)
// every line box is exactly 1u tall, so text sits on the baseline grid
#set text(font: ("Arial", "Liberation Sans"), size: 9pt, top-edge: 9pt, bottom-edge: -3pt,
          lang: "en", hyphenate: true)
#set par(justify: false, leading: 0pt, spacing: u)
#show raw: set text(font: ("Arial", "Liberation Sans"), size: 1.25em)   // variable names in Arial at body size (raw defaults to 0.8em)
#show heading: it => block(above: u, below: 0pt, text(size: 9pt, weight: "bold", it.body))
#show heading.where(level: 1): set heading(numbering: none)

// ---------- page 1: text ----------
// title: 18pt on 2 lines (24pt box, baseline on grid line 2)
#text(size: 18pt, weight: "bold", top-edge: 21pt, bottom-edge: -3pt)[Internet Use and Loneliness in Switzerland]
#grid(columns: (span(3), span(3)), column-gutter: gut,
  [Gabriele Pizzi, Clara Roth, Ole Handschug, Joshua Silalahi],
  [Group 6 · Data Analysis for Public Policy · HS2026],
)
#place(dy: 3pt, line(length: tw, stroke: 0.75pt))
#v(u)

#columns(2, gutter: gut)[
  *Research question.* Is people's internet use associated with their feeling of loneliness? #lorem(10)

  = 1 Operationalisation
  *Dependent variable.* `fltlnl`, felt lonely in the past week (1–4). #lorem(100)

  *Independent variable.* `netustm`, minutes of internet use on a typical day. #lorem(100)

  = 2 Grouping variable
  #lorem(60)

  = 3 Descriptive statistics
  #lorem(80)

  = 4 Comparing the two groups
  #lorem(60)

  = 5 Interpretation
  #lorem(140)
]

// ---------- page 2: tables and figures placed on the module grid ----------
#pagebreak()
#let cap(id, body) = block(height: u, spacing: 0pt, text(size: 8pt)[*#id* #h(4pt) #body])
#let module(c, r, n, body) = place(dx: x(c), dy: y(r), block(width: span(n), {
  set par(spacing: 0pt)
  set block(spacing: 0pt)
  body
}))
// a figure module = 1 caption line + 10 lines of plot = 11 lines
#let figure-module(c, r, n, id, caption, file) = module(c, r, n, {
  cap(id, caption)
  image("figures/" + file, width: span(n), height: 10 * u)
})
#let rule = table.hline(stroke: 0.5pt)

// row 1: Table 1 (lines 1–6) and Table 2 (lines 8–11)
#module(1, 1, 6, {
  set text(size: 8pt)
  cap("Table 1", [Descriptive statistics. Valid N excludes refusals, “don't know” and respondents not asked.])
  table(columns: (span(2) + gut,) + (40.5pt,) * 8, stroke: none, inset: 0pt,
    align: (left,) + (right,) * 8,
    rule,
    [], [Valid N], [Mean], [Median], [Mode], [Variance], [SD], [Range], [IQR],
    rule,
    [Loneliness, `fltlnl` (1–4)], [1,382], [1.31], [1], [1], [0.38], [0.61], [1–4], [0],
    [Internet use, `netustm` (min/day)], [1,212], [235.6], [180], [120], [39,098], [197.7], [4–1,080], [270],
    [Group, `net_group` (0/1)], [1,212], table.cell(colspan: 7, align: left)[#h(12pt) 0 = at or below mean: 717 (59%) · 1 = above mean: 495 (41%) · mode: 0],
    rule,
  )
  v(2 * u)
  cap("Table 2", [Welch two-sample t-test of loneliness by group.])
  table(columns: (span(2) + gut,) + (40.5pt,) * 8, stroke: none, inset: 0pt,
    align: (left,) + (right,) * 8,
    rule,
    [], [Valid N], [Mean], [SD], [], [Difference], [Welch t], [df], [p],
    rule,
    [0 = at or below mean], [715], [1.30], [0.59], [], table.cell(rowspan: 2, align: right + top)[0.02],
      table.cell(rowspan: 2, align: right + top)[0.63], table.cell(rowspan: 2, align: right + top)[1004],
      table.cell(rowspan: 2, align: right + top)[0.53],
    [1 = above mean], [495], [1.33], [0.65], [],
    rule,
  )
})

#figure-module(1, 2, 3, "F1", [Felt lonely, past week (`fltlnl`) · N = 1,382], "f1_dv_hist.png")
#figure-module(4, 2, 3, "F3", [Groups, split at the mean (235.6 min) · N = 1,212], "f3_group_bar.png")
#figure-module(1, 3, 6, "F2", [Internet use per day, minutes (`netustm`), 10-minute bins · N = 1,212 regular users], "f2_iv_hist.png")
#figure-module(1, 4, 3, "F4", [Answers within each group · ○ at or below mean · ● above], "f4_dv_by_group.png")
#figure-module(4, 4, 3, "F5", [Mean loneliness and 95% CI · ○ at or below mean · ● above], "f5_group_means.png")
#figure-module(1, 5, 6, "F6", [Mean loneliness and 95% CI by band of daily internet time · dashed line = cut point], "f6_bands.png")
