// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Each lorem(n) is that section's word budget. Show the grid: typst compile report.typ --input grid=true
//
// Type system: one face (Arial), three sizes, two weights, two inks.
//   14pt bold    title — the only display size
//   9pt          text: answer (bold), headings (bold), body (regular)
//   7pt          data: captions, table, text inside plots
//   grey ink     supporting information: course, names, "Question"/"Answer" labels

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
#set par(justify: false, leading: 0pt, spacing: u)
#show raw: set text(font: ("Arial", "Liberation Sans"), size: 1.25em)  // variable names in Arial at body size

#let at(c, l, n, body) = place(dx: cx(c), dy: ly(l), block(width: span(n), {
  set par(spacing: 0pt); set block(spacing: 0pt); body }))
#let small(body) = text(size: 7pt, body)
#let label(id) = text(weight: "bold", id)
#let meta(body) = text(fill: luma(42%), body)   // grey ink for supporting information
#let fig(c, l, n, lines, caption, file) = at(c, l, n, {
  block(height: u, small(caption))
  image("figures/" + file, width: span(n), height: lines * u)
})

// ---------- lines 1–3: header ----------
// title: 14pt on a 2-line box, baseline on line 2; course hangs from column 5, like Figure 4
#at(1, 1, 4, text(size: 14pt, weight: "bold", top-edge: 21pt, bottom-edge: -3pt)[Internet use and loneliness in Switzerland])
#at(5, 1, 2, meta[Data Analysis for Public Policy \ Report 1 · Group 6 · HS2026])
#at(1, 3, 4, meta[Gabriele Pizzi, Marlo (Clara) Roth, Ole Handschug, Joshua Silalahi])

// hairline rules sit in the middle of an empty grid line, so they never move a baseline
#let hairline(l) = place(dx: 0pt, dy: ly(l) + u / 2, line(length: tw, stroke: 0.4pt))
#hairline(4)     // header | question and answer
#hairline(37)    // text   | data

// Reading order: title → answer → section headings → body → figures.
//   level 1  title, 14pt
//   level 2  answer sentence, bold — the result in five seconds
//   level 3  section headings, bold, on their own line with one empty line above
//   level 4  body text, regular; everything supporting is grey

// ---------- lines 5–7: question | answer ----------
#at(1, 5, 3, [#meta[Question] \ Is people's internet use associated with their feeling of loneliness?])
#at(4, 5, 3, [#meta[Answer] \ *#lorem(16)*])

// ---------- lines 9–36: text, two columns ----------
#show heading: it => block(above: u, below: 0pt, text(size: 9pt, weight: "bold", it.body))
#at(1, 9, 6, block(height: 28 * u, columns(2, gutter: gut)[
  #set par(spacing: 0pt)          // paragraphs inside a section run on; space only between sections
  = 1 Variables
  Dependent variable: loneliness (`fltlnl`). #lorem(66)

  Independent variable: internet use (`netustm`). #lorem(66)

  = 2 Grouping
  #lorem(45)

  #colbreak()   // column 1: what we measured · column 2: what we found
  = 3 Descriptives
  #lorem(60)

  = 4 Test
  #lorem(40)

  = 5 Interpretation
  #lorem(85)
]))

// ---------- lines 38–48: the two variables ----------
// one encoding throughout: grey = group 0 (at or below mean), black = group 1 (above mean)
#fig(1, 38, 2, 10, [#label[Figure 1]  Felt lonely, past week (`fltlnl`), N = 1,382], "f1_dv_hist.png")
#fig(3, 38, 4, 10, [#label[Figure 2]  Internet use per day, minutes (`netustm`), N = 1,212; below, loneliness across its range], "f2_iv_hist.png")

// ---------- lines 50–59: statistics | the two groups, read across ----------
#let r = table.hline(stroke: 0.4pt)
#at(1, 50, 2, small({
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
#fig(3, 50, 2, 6, [#label[Figure 3]  Groups (`net_group`), N = 1,212, mode 0], "f3_group_bar.png")
#fig(5, 50, 2, 6, [#label[Figure 4]  Mean loneliness by group, 95% CI], "f4_group_means.png")
#at(3, 58, 4, small[#label[Welch t-test]  Group 1 minus group 0: difference 0.02 (95% CI −0.05 to 0.09), t~=~0.63, df~=~1004, p~=~0.53.])
