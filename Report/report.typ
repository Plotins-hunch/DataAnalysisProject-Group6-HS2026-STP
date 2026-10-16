// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Each lorem(n) is that block's word budget. Show the grid: typst compile report.typ --input grid=true
//
// Page structure (Swiss, asymmetric):
//   column 1      label column: report details, Question / Answer labels, section headings
//   columns 2–4   text, one 240pt measure
//   columns 5–6   the evidence for that text: each figure sits beside the paragraph that reads it
// Every section is a row that starts on a fixed grid line. Its height is the taller of its
// text and its figure; the difference stays white, so white space follows content.
//
// Type system: one face (Arial), three sizes, two weights, two inks.
//   14pt bold    title — the only display size
//   9pt          text: answer (bold), headings (bold), body (regular)
//   7pt          data: captions, table, text inside plots
//   grey ink     supporting information and sub-labels

// ---------- grid (A4, points) ----------
// baseline unit u = 12pt · 6 columns of 72pt, 12pt gutters · 59 lines of type area
#let u    = 12pt
#let colw = 72pt
#let gut  = u
#let ml   = 60pt
#let mt   = 48pt
#let ncol = 6
#let nlin = 59
#let tw   = ncol * colw + (ncol - 1) * gut      // 492pt
#let th   = nlin * u                            // 708pt
#let span(n) = n * colw + (n - 1) * gut         // width of n columns
#let cx(c)   = (c - 1) * (colw + gut)           // left edge of column c
#let ly(l)   = (l - 1) * u                      // top edge of line l
#let show-grid = sys.inputs.at("grid", default: "false") == "true"

#set page(paper: "a4",
  margin: (left: ml, top: mt, right: 595.28pt - ml - tw, bottom: 841.89pt - mt - th),
  background: if show-grid { place(dx: ml, dy: mt, {
    for c in range(1, ncol + 1) { place(dx: cx(c), rect(width: colw, height: th, fill: luma(94%), stroke: none)) }
    for i in range(nlin) { place(dy: i * u + 9pt, line(length: tw, stroke: 0.25pt + rgb(0, 120, 255, 50%))) }
  }) })

// every line box is exactly 1u, so all text sits on the baseline grid
#set text(font: ("Arial", "Liberation Sans"), size: 9pt, top-edge: 9pt, bottom-edge: -3pt,
          lang: "en", hyphenate: true)
#set par(justify: false, leading: 0pt, spacing: 0pt)
#show raw: set text(font: ("Arial", "Liberation Sans"), size: 1.25em)  // variable names in Arial at body size

#let at(c, l, n, body) = place(dx: cx(c), dy: ly(l), block(width: span(n), {
  set block(spacing: 0pt); body }))
#let small(body) = text(size: 7pt, body)
#let label(id) = text(weight: "bold", id)
#let meta(body) = text(fill: luma(42%), body)   // grey ink for supporting information
#let fig(l, lines, caption, file) = at(5, l, 2, {
  block(height: u, small(caption))
  image("figures/" + file, width: span(2), height: lines * u)
})
// one section row: heading (and optional grey sub-label) in column 1, text in columns 2–4
#let row(l, heading: none, sub: none, body) = {
  if heading != none { at(1, l, 1, text(weight: "bold", heading)) }
  if sub != none { at(1, if heading != none { l + 1 } else { l }, 1, meta(sub)) }
  at(2, l, 3, body)
}

// ---------- lines 1–3: header ----------
#at(1, 1, 1, meta[Report 1 \ Group 6 \ HS2026])
#at(2, 1, 5, text(size: 14pt, weight: "bold", top-edge: 21pt, bottom-edge: -3pt)[Internet use and loneliness in Switzerland])
#at(2, 3, 5, meta[Gabriele Pizzi, Marlo (Clara) Roth, Ole Handschug, Joshua Silalahi])

// ---------- lines 5–7: question and answer, full measure ----------
#at(1, 5, 1, meta[Question])
#at(2, 5, 5, [Is people's internet use associated with their feeling of loneliness?])
#at(1, 6, 1, meta[Answer])
#at(2, 6, 5, [*#lorem(26)*])

// ---------- lines 9–24: 1 Variables (two rows) ----------
#row(9, heading: [1 Variables], sub: [Dependent])[#lorem(54)]
#fig(9, 6, [#label[Figure 1]  Felt lonely, past week (`fltlnl`), N = 1,382], "f1_dv_hist.png")

#row(17, sub: [Independent])[#lorem(62)]
#fig(17, 7, [#label[Figure 2]  Internet use (`netustm`), N = 1,212], "f2_iv_hist.png")

// ---------- lines 26–31: 2 Grouping ----------
#row(26, heading: [2 Grouping])[#lorem(46)]
#fig(26, 4, [#label[Figure 3]  Groups (`net_group`), N = 1,212, mode 0], "f3_group_bar.png")

// ---------- lines 33–42: 3 Descriptives ----------
#row(33, heading: [3 Descriptives])[#lorem(66)]
#let r = table.hline(stroke: 0.4pt)
#at(5, 33, 2, small({
  block(height: u)[#label[Table 1]  Descriptive statistics]
  table(columns: (52pt, 52pt, 52pt), stroke: none, inset: 0pt, align: (left, right, right),
    r,
    [], [Loneliness], [Internet, min],
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
  )
}))

// ---------- lines 44–48: 4 Test ----------
#row(44, heading: [4 Test])[#lorem(38)]
#fig(44, 4, [#label[Figure 4]  Mean loneliness by group, 95% CI], "f4_group_means.png")

// ---------- lines 50–59: 5 Interpretation ----------
#row(50, heading: [5 Interpretation])[#lorem(76)]
#fig(50, 5, [#label[Figure 5]  Loneliness across internet time, 95% CI], "f5_bands.png")
