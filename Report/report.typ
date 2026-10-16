// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Each lorem(n) is that section's word budget. Show the grid: typst compile report.typ --input grid=true
//
// Type system: one face (Arial), two sizes, two weights.
//   9pt  text: title, names, headings, body          bold only for the title and run-in headings
//   7pt  data: captions, table, text inside plots

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
#let fig(c, l, n, lines, caption, file) = at(c, l, n, {
  block(height: u, small(caption))
  image("figures/" + file, width: span(n), height: lines * u)
})

// ---------- lines 1–2: header ----------
#at(1, 1, 4, [*Internet use and loneliness in Switzerland*])
#at(5, 1, 2, [Group 6 · HS2026])
#at(1, 2, 6, [Gabriele Pizzi, Marlo (Clara) Roth, Ole Handschug, Joshua Silalahi])

// ---------- lines 4–42: text, two columns ----------
#at(1, 4, 6, block(height: 39 * u, columns(2, gutter: gut)[
  #set par(spacing: u)   // one empty line between sections
  *Research question* Is people's internet use associated with their feeling of loneliness? #lorem(10)

  *1 Operationalisation* The dependent variable is `fltlnl`. #lorem(95)

  The independent variable is `netustm`. #lorem(95)

  *2 Grouping variable* #lorem(55)

  *3 Descriptive statistics* #lorem(75)

  *4 t-test* #lorem(55)

  *5 Interpretation* #lorem(130)
]))

// ---------- lines 44–51: F1 and F2 ----------
#fig(1, 44, 2, 7, [Figure 1  Felt lonely, past week (`fltlnl`), N = 1,382], "f1_dv_hist.png")
#fig(3, 44, 4, 7, [Figure 2  Internet use per day in minutes (`netustm`), 10-min bins, N = 1,212], "f2_iv_hist.png")

// ---------- lines 53–59: F3 and Table 1 ----------
#fig(1, 53, 2, 3, [Figure 3  Groups, split at the mean, N = 1,212], "f3_group_bar.png")
#let r = table.hline(stroke: 0.4pt)
#at(3, 53, 4, small({
  block(height: u)[Table 1  Descriptive statistics. Welch t = −0.63, df = 1004, p = 0.53]
  table(columns: (72pt,) + (31.5pt,) * 8, stroke: none, inset: 0pt, align: (left,) + (right,) * 8,
    r,
    [], [N], [Mean], [Median], [Mode], [Var.], [SD], [Range], [IQR],
    r,
    [Loneliness (1–4)],   [1,382], [1.31],  [1],   [1],   [0.38],   [0.61],  [1–4],     [0],
    [Internet (min/day)], [1,212], [235.6], [180], [120], [39,098], [197.7], [4–1,080], [270],
    [Group (0/1)],        [1,212], table.cell(colspan: 7, align: left)[#h(6pt)0: 717 (59%) · 1: 495 (41%) · mode 0],
    [Loneliness, group 0], [715],  [1.30],  [], [], [], [0.59], [], [],
    [Loneliness, group 1], [495],  [1.33],  [], [], [], [0.65], [], [],
    r,
  )
}))
