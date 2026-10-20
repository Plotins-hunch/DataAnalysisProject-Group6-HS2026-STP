// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Compile from the repo root:  typst compile --root . --font-path <ABC Areal folder> Report/report.typ
// Show the grid:               add  --input grid=true
//
// ONE UNIT   X = 4.5pt, the x-height of the text (ABC Areal: x-height 0.519 em).
// ONE GRID   a baseline every 3X, and a base grid of 12 columns of 6X, gutters 3X. Three zones,
//            each a whole number of columns, the same on every row:
//              A  labels    2 columns   15X   67.5pt
//              B  text      6 columns   51X   229.5pt
//              C  evidence  4 columns   33X   148.5pt
// FOUR RULES
//   1  Size follows role. Three sizes, all from X:
//        title  x-height 3X (26pt), two lines on a leading of two grid lines, the one large thing
//        text   x-height X  (8.67pt): columns A and B
//        small  x-height ⅚X (7.23pt): column C and the text inside every plot
//   2  Every left edge sits on A, B or C. Plot panels fill their column: no y-axes, values are
//      labelled on the data, so the data starts on the column edge.
//   2b Breakout: a figure whose data needs width spans B+C in a row of its own, label in A.
//      Only Figure 2 (long tail, heaping at whole hours, the cut point) qualifies.
//   3  A row's elements hang from one line: the cap height of every first line, whatever its
//      size (title, text, small), sits on the same hang line.
//   4  Rows are separated by one empty line; a row is as tall as its tallest element, in whole lines.
//   5  Clearance: nothing comes closer than X to anything else: caption to plot, label to mark.
//   6  Zones: white space is the structure. Rows inside a zone are one empty line apart;
//      zones are two apart: statement (title, fact sheet) | description (sections 1–3) |
//      inference (sections 4–5). No rules, no boxes.
// FOOT    the credits sit at the foot of the page on the same three zones.
//      Figures are vector (SVG), so every line and letter stays sharp.
// MINIMUM VIABLE VISUALISATION   each figure shows only what its job needs; anything the
//   table, a caption or another figure already carries is left out of the plot.
// HIERARCHY of information, expressed only by position, ink and size:
//   1  the answer and its evidence (Figure 4)      top of the page, ink
//   2  the question                                 top of the page, ink
//   3  section headings 1–5 (the rubric's parts)    column A, ink
//   3b key facts under each heading                  column A, grey (name, scale, N, cut, p)
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
// BASE GRID: 12 equal columns of 6X with gutters of 3X (one line). Every width is a whole
// number of columns: labels 2, text 6, evidence 4, the Figure 2 breakout 10.
#let ncol   = 12
#let col    = 6 * X
#let span(n) = n * col + (n - 1) * gut
#let col-a  = span(2)                             // 15X  67.5pt
#let col-b  = span(6)                             // 51X  229.5pt
#let col-c  = span(4)                             // 33X  148.5pt
#let tw     = span(ncol)                          // 105X 472.5pt
#let nlin   = 55
#let th     = nlin * u
#let text-size  = X / xh                          // 8.67pt
#let small-size = 5 / 6 * X / xh                  // 7.23pt
#let title-size = 3 * X / xh                      // 26.0pt
#let hair   = X / 10
#let base-drop = 3.5pt                            // text baseline sits 3.5pt above each line's bottom
// HANG LINE (rule 3): every size hangs its capitals from the same line, `hang` below the top of
// a grid line. Text sits exactly on the baseline grid; small text and the title take the
// baseline offset that puts their cap height on the same hang line.
#let cap    = 0.716                               // ABC Areal cap height / em
#let hang   = u - base-drop - cap * text-size     // 3.79pt
#let hung(size, lines: 1) = (top-edge: hang + cap * size, bottom-edge: -(lines * u - hang - cap * size))
#let show-grid = sys.inputs.at("grid", default: "false") == "true"

#let ink  = rgb("#1a1a1a")
#let grey = luma(42%)
#let red  = rgb("#b2182b")

#set page(paper: "a4", margin: (left: 12 * X, top: 10 * X, right: 595.28pt - 12 * X - tw, bottom: 841.89pt - 10 * X - th),
  background: if show-grid { place(dx: 12 * X, dy: 10 * X, {
    for i in range(ncol) { place(dx: i * (col + gut), rect(width: col, height: th, fill: luma(94%), stroke: none)) }
    for i in range(nlin) { place(dy: i * u + u - base-drop, line(length: tw, stroke: 0.25pt + rgb(0, 120, 255, 50%))) }
  }) })

// each piece of information appears once: report and group top left, course up the margin,
// authors in the footer
#let credits = (
  [Authors],
  [Gabriele Pizzi, Marlo (Clara) Roth, Ole Handschug, Joshua Silalahi],
  [Data Analysis for Public Policy \ ETH Zürich, HS2026],
)
#set page(
  footer-descent: 0pt,
  footer: context {
    set text(size: small-size, fill: grey, number-width: "tabular")
    grid(columns: (col-a, col-b, col-c), column-gutter: gut, ..credits)
  },
)
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
#let evidence(body) = text(size: small-size, number-width: "tabular", ..hung(small-size), body)
#let fig(caption, file, lines, width: col-c) = evidence({
  caption
  image(out + file, width: width, height: lines * u)
})

// one row of the page: A | B | C, all starting on the same line
#let row(a, b, c) = (a, b, c)

#let keys(..lines) = meta(lines.pos().join(linebreak()))   // grey key facts, one per line
#let small-table(..cells) = evidence(table(columns: (1.6fr, 1fr, 1fr), stroke: none, inset: 0pt,
  align: (left, right, right), ..cells))
#let rule = table.hline(stroke: hair)

#grid(
  columns: (col-a, col-b, col-c),
  column-gutter: gut,
  //           title  facts→DV  DV   IV  Fig2  grp  desc→test  test
  row-gutter: (u,     2 * u,    u,   u,  u,    u,   2 * u,     u),

  // ---- header: the title is the one large thing on the page (rule 1) ----
  meta[Report 1 \ Group 6],
  grid.cell(colspan: 2, text(size: title-size, ..hung(title-size, lines: 2))[Internet use and loneliness \ in Switzerland]),

  // ---- fact sheet: question, context, answer; the result's evidence beside it ----
  grid.cell(colspan: 2, grid(columns: (col-a, col-b), column-gutter: gut,
    meta[Question], [Is people's internet use associated with their feeling of loneliness?],
    meta[Data],     meta[European Social Survey Round 11, Switzerland, N #n.n_total],
    meta[Method],   meta[Split at mean internet use (#n.cut min); Welch t-test],
    meta[Answer],   [#lorem(5) #g1[above the mean] #lorem(5)],
  )),
  fig([Figure 4 Mean loneliness by group, 95% CI \ Welch #g1[1] − 0: #n.diff (#n.diff_lo to #n.diff_hi) \ t #n.t, df #n.df, p #n.p], "fig4_means.svg", 3),

  // ---- 1 Variables ----
  ..row([1 Variables \ #keys([Dependent], `fltlnl`, [scale 1–4], [N #n.lonely_n])],
        [#lorem(43)],
        fig([Figure 1 Felt lonely in the past week], "fig1_lonely.svg", 5)),
  ..row(keys([Independent], `netustm`, [minutes per day], [N #n.net_n], [#n.net_missing missing]),
        [#lorem(50)],
        small-table(
          [Table 1], [Loneliness], [Minutes], rule,
          [Mean],     n.lonely_mean,   n.net_mean,
          [Median],   n.lonely_median, n.net_median,
          [Mode],     n.lonely_mode,   n.net_mode,
          [Variance], n.lonely_var,    n.net_var,
          [SD],       n.lonely_sd,     n.net_sd,
          [Range],    n.lonely_range,  n.net_range,
          [IQR],      n.lonely_iqr,    n.net_iqr, rule,
        )),
  // the breakout (rule 2b): Figure 2 across B and C, its label in A
  meta[Figure 2],
  grid.cell(colspan: 2, fig([Minutes online per day, `netustm`, N #n.net_n, grey at or below the mean, #g1[red above it], white lines every 50 people], "fig2_internet.svg", 4, width: col-b + gut + col-c)),

  // ---- 2 Grouping ----
  ..row([2 Grouping \ #keys(`net_group`, [cut #n.cut min])],
        [#lorem(9) #g1[above the mean (1)] #lorem(12)],
        evidence(meta[#n.on_cut on the mean (would go to 0) \ #n.net_missing without an answer: in neither group])),

  // ---- 3 Descriptives ----
  ..row([3 Descriptives \ #keys([Table 1], [Figures 1–3])],
        [#lorem(19)],
        fig([Figure 3 Groups, N #n.group_n, mode #n.group_mode], "fig3_groups.svg", 2)),

  // ---- 4 Test ----
  ..row([4 Test \ #keys([Welch], [p #n.p])],
        [#lorem(19)],
        small-table(
          [Loneliness], [N], [Mean · SD], rule,
          [0 at or below],   n.n0, [#n.m0 · #n.sd0],
          g1[1 above], n.n1, [#n.m1 · #n.sd1], rule,
        )),

  // ---- 5 Interpretation ----
  ..row([5 Interpretation \ #keys([Figure 5])],
        [#lorem(40)],
        fig([Figure 5 Respondents and group means], "fig5_scatter.svg", 5)),
)
