// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Each lorem(n) is that block's word budget. Show the grid: typst compile report.typ --input grid=true
//
// ONE UNIT. Everything is a multiple of X, the x-height of the body text.
//   X        = 4.5pt                       Arial x-height = 0.5186 em → body 8.68pt
//   line     = 3X  = 13.5pt                baseline grid
//   gutter   = 3X  = one line
//   column   = 16X = 72pt                  6 columns
//   margins  = 12X left, 10X top
//   module   = 3 lines + 1 empty line; 14 module rows = 55 lines
//   type     title x-height 2X (17.35pt) · body X (8.68pt) · small ¾X (6.51pt)
//   rules    X/10 = 0.45pt
//   figures  whole columns wide, whole lines tall (make_figures_draft.R uses the same numbers)
//
// Construction (Müller-Brockmann): every element starts on a module top and spans whole
// modules (1 = 3 lines, 2 = 7, 3 = 11). Only three widths are used:
//   column 1      labels: report details, Question / Answer, section headings
//   columns 2–4   text
//   columns 5–6   margin: small figures, Table 1 and notes beside the text they serve
//   columns 2–6   one breakout, Figure 2, whose long tail needs the width
// Captions always sit on the first line of their field.

// ---------- the unit and everything derived from it ----------
#let X     = 4.5pt
#let xh    = 0.5186                          // Arial x-height / em
#let u     = 3 * X                           // line
#let gut   = 3 * X
#let colw  = 16 * X
#let ml    = 12 * X
#let mt    = 10 * X
#let ncol  = 6
#let nmod  = 14
#let nlin  = 4 * nmod - 1                    // 55 lines
#let body-size  = X / xh                     // 8.68pt
#let title-size = 2 * X / xh                 // 17.35pt
#let small-size = 0.75 * X / xh              // 6.51pt
#let hair  = X / 10                          // 0.45pt
#let tw    = ncol * colw + (ncol - 1) * gut  // 499.5pt
#let th    = nlin * u                        // 742.5pt
#let span(n) = n * colw + (n - 1) * gut
#let cx(c)   = (c - 1) * (colw + gut)
#let ly(l)   = (l - 1) * u
#let mtop(m) = (m - 1) * 4 + 1               // first line of module row m
#let show-grid = sys.inputs.at("grid", default: "false") == "true"

// every line box is exactly one line (3X): the baseline sits 3.5pt above the box bottom
#let base-drop = 3.5pt

#set page(paper: "a4",
  margin: (left: ml, top: mt, right: 595.28pt - ml - tw, bottom: 841.89pt - mt - th),
  background: if show-grid { place(dx: ml, dy: mt, {
    for c in range(1, ncol + 1) { place(dx: cx(c), rect(width: colw, height: th, fill: luma(94%), stroke: none)) }
    for i in range(nlin) { place(dy: i * u + u - base-drop, line(length: tw, stroke: 0.25pt + rgb(0, 120, 255, 50%))) }
    for m in range(1, nmod + 1) { place(dy: ly(mtop(m)), rect(width: tw, height: 3 * u, stroke: 0.4pt + rgb(255, 0, 0, 45%))) }
  }) })

#set text(font: ("Arial", "Liberation Sans"), size: body-size,
          top-edge: u - base-drop, bottom-edge: -base-drop, lang: "en", hyphenate: true)
#set par(justify: false, leading: 0pt, spacing: 0pt)
#show raw: set text(font: ("Arial", "Liberation Sans"), size: 1.25em)   // variable names in Arial at body size

#let at(c, l, n, body) = place(dx: cx(c), dy: ly(l), block(width: span(n), { set block(spacing: 0pt); body }))
#let small(body) = text(size: small-size, body)
#let label(id) = text(weight: "bold", id)
#let meta(body) = text(fill: luma(42%), body)
#let side(m, body) = at(5, mtop(m), 2, small(meta(body)))
#let fig(m, lines, caption, file, c: 5, cols: 2) = at(c, mtop(m), cols, {
  block(height: u, small(caption))
  image("figures/" + file, width: span(cols), height: lines * u)
})
#let sec(m, heading: none, sub: none, body) = {
  if heading != none { at(1, mtop(m), 1, text(weight: "bold", heading)) }
  if sub != none { at(1, mtop(m) + (if heading != none { 1 } else { 0 }), 1, meta(sub)) }
  at(2, mtop(m), 3, body)
}

// ---------- module 1: header ----------
#at(1, mtop(1), 1, meta[Report 1 \ Group 6 \ HS2026])
#at(2, mtop(1), 5, text(size: title-size, weight: "bold", top-edge: 2 * u - base-drop, bottom-edge: -base-drop)[Internet use and loneliness in Switzerland])
#at(2, mtop(1) + 2, 5, meta[Gabriele Pizzi, Marlo (Clara) Roth, Ole Handschug, Joshua Silalahi])

// ---------- module 2: question and answer ----------
#at(1, mtop(2), 1, meta[Question])
#at(2, mtop(2), 5, [Is people's internet use associated with their feeling of loneliness?])
#at(1, mtop(2) + 1, 1, meta[Answer])
#at(2, mtop(2) + 1, 5, [*#lorem(26)*])

// ---------- modules 3–6: 1 Variables ----------
#sec(3, heading: [1 Variables], sub: [Dependent])[#lorem(56)]
#fig(3, 6, [#label[Figure 1]  Felt lonely, past week (`fltlnl`), N = 1,382], "f1_dv_hist.png")

#sec(5, sub: [Independent])[#lorem(56)]
#side(5)[Asked only of people online most days or every day: 168 others were not asked and 4 said “don't know”. They stay missing rather than 0 minutes.]

// ---------- modules 7–8: Figure 2 breakout ----------
#fig(7, 6, [#label[Figure 2]  Internet use per day (`netustm`), 10-min bins, N = 1,212. #meta[Lower panel: mean loneliness per band, 95% CI; dashed = all.]], "f2_iv_hist.png", c: 2, cols: 5)

// ---------- module 9: 2 Grouping ----------
#sec(9, heading: [2 Grouping])[#lorem(24)]
#fig(9, 2, [#label[Figure 3]  Groups (`net_group`), N = 1,212, mode 0], "f3_group_bar.png")

// ---------- modules 10–11: 3 Descriptives, 4 Test; Table 1 in the margin ----------
#sec(10, heading: [3 Descriptives])[#lorem(24)]
#sec(11, heading: [4 Test])[#lorem(24)]
#let r = table.hline(stroke: hair)
#at(5, mtop(10), 2, small(table(columns: (span(2) / 3,) * 3, stroke: none, inset: 0pt, align: (left, right, right),
  [#label[Table 1]], [Loneliness], [Internet, min],
  r,
  [Valid N],  [1,382], [1,212],
  [Mean],     [1.31],  [235.6],
  [Median],   [1],     [180],
  [Mode],     [1],     [120],
  [Variance], [0.38],  [39,098],
  [SD],       [0.61],  [197.7],
  [Range],    [1–4],   [4–1,080],
  [IQR],      [0],     [270],
  r,
)))

// ---------- modules 12–14: 5 Interpretation; Figure 4 and the test result in the margin ----------
#sec(12, heading: [5 Interpretation])[#lorem(80)]
#fig(13, 2, [#label[Figure 4]  Mean loneliness by group, 95% CI], "f4_group_means.png")
#side(14)[#label[Welch t-test]  group 1 − group 0: +0.02, 95% CI −0.05 to 0.09; t~=~0.63, df~=~1004, p~=~0.53]
