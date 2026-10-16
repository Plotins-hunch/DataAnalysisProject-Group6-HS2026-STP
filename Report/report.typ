// Group Report #1 — layout sketch (lorem ipsum placeholders)
// Word budget: 600 words of running text. Title, names, tables, plots, captions don't count.
// Each lorem(n) below is that section's word budget; the total is 600.

#set page(paper: "a4", margin: (x: 1.9cm, y: 1.6cm), numbering: none)
#set text(font: "Libertinus Serif", size: 10pt, lang: "en")
#set par(justify: true, leading: 0.55em, spacing: 0.75em)
#show heading: it => block(above: 0.9em, below: 0.4em,
  text(size: 10pt, weight: "regular", smallcaps(it.body)))

// placeholder box for a figure (replace with image("../figures/....png") later)
#let fig(id, what, h) = rect(width: 100%, height: h, stroke: 0.5pt + luma(170),
  inset: 6pt, align(center + horizon, text(fill: luma(120), size: 9pt)[*#id* · #what]))

// ---------- header (not counted) ----------
#align(center)[
  #text(size: 15pt)[Internet Use and Loneliness in Switzerland] \
  #v(-0.2em)
  #text(size: 9.5pt, fill: luma(90))[Gabriele Pizzi · Clara Roth · Ole Handschug · Joshua Silalahi — Group 6, Data Analysis for Public Policy, HS2026]
]
#v(0.2em)
*Research question.* Is people's internet use associated with their feeling of loneliness? #lorem(10)

= 1 · Operationalisation
*Dependent variable — `fltlnl`* (felt lonely in the past week, 1–4). #lorem(100)

*Independent variable — `netustm`* (minutes of internet use on a typical day). #lorem(100)

= 2 · Grouping variable
#lorem(60)

= 3 · Descriptive statistics
#lorem(80)

// descriptives table (not counted)
#v(0.2em)
#align(center, text(size: 8.5pt, table(
  columns: 9, stroke: none, align: (left,) + (right,) * 8, inset: (x: 5pt, y: 2.5pt),
  table.hline(stroke: 0.6pt),
  [], [Valid N], [Mean], [Median], [Mode], [Variance], [SD], [Range], [IQR],
  table.hline(stroke: 0.4pt),
  [Loneliness (1–4)], [1,382], [x.xx], [x], [x], [x.xx], [x.xx], [1–4], [x],
  [Internet (min/day)], [1,212], [235.6], [180], [xxx], [xxxxx], [xxx.x], [4–1080], [xxx],
  [Group: at or below / above mean], [1,212], table.cell(colspan: 7, align: left)[717 (59%) / 495 (41%) · mode: at or below mean],
  table.hline(stroke: 0.6pt),
)))

= 4 · Comparing the two groups
#lorem(60)

= 5 · Interpretation
#lorem(140)

// ---------- figures (not counted) ----------
#pagebreak()
#grid(columns: (1fr, 1fr), gutter: 10pt,
  fig("F1", "Loneliness histogram (required)", 5.6cm),
  fig("F2", "Internet-minutes histogram (required)", 5.6cm),
  fig("F3", "Group bar chart (required)", 3.6cm),
  fig("F5", "Group means + 95% CI, t-test (recommended)", 3.6cm),
  grid.cell(colspan: 2, fig("F4", "Loneliness answers within each group (recommended)", 4.2cm)),
  grid.cell(colspan: 2, fig("F6", "Loneliness across internet-time bands (optional)", 4.6cm)),
)
