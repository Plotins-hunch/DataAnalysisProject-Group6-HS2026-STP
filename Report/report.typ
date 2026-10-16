// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Each lorem(n) is that block's word budget. Show the grid: typst compile report.typ --input grid=true
//
// Page structure (Swiss grid, Tufte layout):
//   column 1      label column: report details, Question / Answer, section headings, side captions
//   columns 2–4   main text, one 240pt measure
//   columns 5–6   margin: small figures and side notes beside the paragraph they belong to
//   columns 2–6   breakouts, only where the content needs the width (Figure 2, Table 1)
// Each element takes the width its content needs; rows start on fixed grid lines and the
// leftover stays white, so white space follows content.
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

#let side(l, body) = at(5, l, 2, small(meta(body)))   // margin note, 7pt grey

// ---------- 1 Variables: lines 9–21, text with margin figure / note ----------
#row(9, heading: [1 Variables], sub: [Dependent])[#lorem(54)]
#fig(9, 6, [#label[Figure 1]  Felt lonely, past week (`fltlnl`), N = 1,382], "f1_dv_hist.png")

#row(17, sub: [Independent])[#lorem(38)]
#side(17)[Asked only of people online most days or every day: 168 others were not asked and 4 said “don't know”. They stay missing rather than 0 minutes.]

// ---------- lines 23–32: Figure 2 breaks out to full width, caption in the label column ----------
#at(1, 23, 1, small[#label[Figure 2] \ Internet use per day, minutes (`netustm`), 10-min bins, N~=~1,212. Grey: group 0, black: group 1. \ #meta[Lower panel: mean loneliness per band, 95% CI; dashed: all.]])
#at(2, 23, 5, image("figures/f2_iv_hist.png", width: span(5), height: 10 * u))

// ---------- 2 Grouping: lines 34–37 ----------
#row(34, heading: [2 Grouping])[#lorem(30)]
#fig(34, 3, [#label[Figure 3]  Groups (`net_group`), N = 1,212, mode 0], "f3_group_bar.png")

// ---------- 3 Descriptives: lines 39–46, wide short table, one empty line, then its reading ----------
#at(1, 39, 1, text(weight: "bold")[3 Descriptives])
#let r = table.hline(stroke: 0.4pt)
#at(2, 39, 5, small({
  block(height: u)[#label[Table 1]  Descriptive statistics]
  table(columns: (84pt,) + (40.5pt,) * 8, stroke: none, inset: 0pt, align: (left,) + (right,) * 8,
    r,
    [], [Valid N], [Mean], [Median], [Mode], [Variance], [SD], [Range], [IQR],
    r,
    [Loneliness (1–4)],   [1,382], [1.31],  [1],   [1],   [0.38],   [0.61],  [1–4],     [0],
    [Internet, min/day],  [1,212], [235.6], [180], [120], [39,098], [197.7], [4–1,080], [270],
    r,
  )
}))
#at(2, 44, 3)[#lorem(24)]

// ---------- 4 Test: lines 48–51 ----------
#row(48, heading: [4 Test])[#lorem(28)]
#fig(48, 3, [#label[Figure 4]  Mean loneliness by group, 95% CI], "f4_group_means.png")

// ---------- 5 Interpretation: lines 53–59, t-test numbers as a margin note ----------
#row(53, heading: [5 Interpretation])[#lorem(52)]
#side(53)[#label[Welch t-test] \ group 1 minus group 0: +0.02 \ 95% CI −0.05 to 0.09 \ t~=~0.63, df~=~1004, p~=~0.53]
