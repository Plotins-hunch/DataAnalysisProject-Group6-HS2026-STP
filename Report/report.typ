// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Compile from the repo root:  typst compile --root . --font-path <ABC Areal folder> Report/report.typ
// Show the grid:               add  --input grid=true
//
// ONE UNIT   X = 4.5pt, the x-height of the text (ABC Areal: x-height 0.519 em).
// ONE GRID   a baseline every 3X, and three columns, the same on every row:
//              A  labels    16X   72pt
//              B  text      54X   243pt
//              C  evidence  35X   157.5pt      gutters 3X
// FOUR RULES
//   1  Size follows column. A and B are set at the text size (x-height X, 8.67pt); C, and the
//      text inside every plot, at the small size (x-height ¾X, 6.50pt). Two sizes, nothing else.
//   2  Every left edge sits on A, B or C. Plot panels fill their column: no y-axes, values are
//      labelled on the data, so the data starts on the column edge.
//   2b Breakout: a figure whose data needs width spans B+C in a row of its own, label in A.
//      Only Figure 2 (long tail, heaping at whole hours, the cut point) qualifies.
//   3  A row's elements start on the same baseline: label, text and caption share line one.
//   4  Rows are separated by one empty line; a row is as tall as its tallest element, in whole lines.
// HIERARCHY of information, expressed only by position, ink and size:
//   1  the answer and its evidence (Figure 4)      top of the page, ink
//   2  the question                                 top of the page, ink
//   3  section headings 1–5 (the rubric's parts)    column A, ink
//   4  body text: the reasoning                     column B, ink
//   5  evidence: figures, Table 1, notes            column C, small size
//   6  context: data, method, names, course         grey
// ONE FAMILY, ONE WEIGHT   ABC Areal regular throughout. ABC Areal Mono only for variable names.
// THREE INKS   ink for content; grey for supporting information; red for one meaning only:
//              group 1 (above the mean) and the cut point, in figures and text alike.
// DATA   every figure and number comes from Working/Group6_InternetAndLoneliness/Exploration_00.R.
//        The licensed fonts stay out of the repo; without them Typst falls back to Arial.

#let X      = 4.5pt
#let xh     = 0.519
#let u      = 3 * X                               // one line
#let gut    = 3 * X
#let col-a  = 16 * X
#let col-b  = 54 * X
#let col-c  = 35 * X
#let tw     = col-a + col-b + col-c + 2 * gut     // 111X = 499.5pt
#let nlin   = 55
#let th     = nlin * u
#let text-size  = X / xh                          // 8.67pt
#let small-size = 0.75 * X / xh                   // 6.50pt
#let hair   = X / 10
#let base-drop = 3.5pt                            // baseline sits 3.5pt above each line's bottom
#let show-grid = sys.inputs.at("grid", default: "false") == "true"

#let ink  = rgb("#1a1a1a")
#let grey = luma(42%)
#let red  = rgb("#b2182b")

#set page(paper: "a4", margin: (left: 12 * X, top: 10 * X, right: 595.28pt - 12 * X - tw, bottom: 841.89pt - 10 * X - th),
  background: if show-grid { place(dx: 12 * X, dy: 10 * X, {
    for (x, w) in ((0pt, col-a), (col-a + gut, col-b), (col-a + col-b + 2 * gut, col-c)) {
      place(dx: x, rect(width: w, height: th, fill: luma(94%), stroke: none))
    }
    for i in range(nlin) { place(dy: i * u + u - base-drop, line(length: tw, stroke: 0.25pt + rgb(0, 120, 255, 50%))) }
  }) })

#set text(font: ("ABC Areal", "Arial"), size: text-size, fill: ink,
          top-edge: u - base-drop, bottom-edge: -base-drop, lang: "en", hyphenate: true)
#set par(justify: false, leading: 0pt, spacing: 0pt)
#set block(spacing: 0pt)
#show raw: set text(font: ("ABC Areal Mono", "Courier New"), size: 1.25em)   // variable names only

#let out = "/Working/Group6_InternetAndLoneliness/figures/"
#let n = {
  let d = (:)
  for row in csv(out + "report_numbers.csv").slice(1) {
    let v = row.at(1)
    d.insert(row.at(0), if v.starts-with("-") { "−" + v.slice(1) } else { v })   // true minus sign
  }
  d
}

#let meta(body) = text(fill: grey, body)
#let g1(body) = text(fill: red, body)
// column C: everything at the small size, tabular figures
#let evidence(body) = text(size: small-size, number-width: "tabular", body)
#let fig(caption, file, lines, width: col-c) = evidence({
  caption
  image(out + file, width: width, height: lines * u)
})

// one row of the page: A | B | C, all starting on the same line
#let row(a, b, c) = (a, b, c)

#grid(
  columns: (col-a, col-b, col-c),
  column-gutter: gut,
  row-gutter: u,
  // header: title and course | names
  ..row(meta[Report 1 \ Group 6, HS2026],
        [Internet use and loneliness in Switzerland \ #meta[Data Analysis for Public Policy, ETH Zürich]],
        evidence(meta[Gabriele Pizzi, Marlo (Clara) Roth \ Ole Handschug, Joshua Silalahi])),
  // fact sheet: each label on the line it labels (rule 3); the result's evidence beside it
  grid.cell(colspan: 2, grid(columns: (col-a, col-b), column-gutter: gut,
    meta[Question], [Is people's internet use associated with their feeling of loneliness?],
    meta[Data],     meta[European Social Survey Round 11, Switzerland, N #n.n_total],
    meta[Method],   meta[Split at mean internet use (#n.cut min); Welch t-test],
    meta[Answer],   [#lorem(6) #g1[above the mean] #lorem(6)],
  )),
  fig([Figure 4 Mean loneliness, 95% CI; dashed: all], "fig4_means.png", 2),
  // 1 Variables
  ..row([1 Variables \ #meta[Dependent]],
        [#lorem(50)],
        fig([Figure 1 Felt lonely, `fltlnl`, N #n.lonely_n], "fig1_lonely.png", 4)),
  ..row(meta[Independent],
        [#lorem(50)],
        evidence(meta[Asked only of people online most days: 168 not asked, 4 don't know. Kept missing, not 0 minutes.])),
  // the breakout (rule 2b): Figure 2 across B and C, its label in A
  meta[Figure 2],
  grid.cell(colspan: 2, fig([Minutes online per day, `netustm`, N #(n.net_n); #g1[red: above the mean]. White lines every 50 people.], "fig2_internet.png", 3, width: col-b + gut + col-c)),
  // 2 Grouping
  ..row([2 Grouping],
        [#lorem(10) #g1[above the mean (1)] #lorem(12)],
        fig([Figure 3 Groups, `net_group`, N #n.group_n, mode #n.group_mode], "fig3_groups.png", 2)),
  // 3 Descriptives
  ..row([3 Descriptives],
        [#lorem(50)],
        evidence(table(columns: (1fr, 1fr, 1fr), stroke: none, inset: 0pt, align: (left, right, right),
          [Table 1], [Loneliness], [Minutes],
          table.hline(stroke: hair),
          [Mean],     n.lonely_mean,   n.net_mean,
          [Median],   n.lonely_median, n.net_median,
          [Mode],     n.lonely_mode,   n.net_mode,
          [Variance], n.lonely_var,    n.net_var,
          [SD],       n.lonely_sd,     n.net_sd,
          [Range],    n.lonely_range,  n.net_range,
          [IQR],      n.lonely_iqr,    n.net_iqr,
        ))),
  // 4 Test: the test result as the evidence
  ..row([4 Test],
        [#lorem(32)],
        evidence[Welch t-test, #g1[1] − 0 \ difference #n.diff, 95% CI #n.diff_lo to #n.diff_hi \ t #n.t, df #n.df, p #n.p]),
  // 5 Interpretation
  ..row([5 Interpretation],
        [#lorem(52)],
        fig([Figure 5 Loneliness per band, 95% CI; dashed: all], "fig5_bands.png", 3)),
)
