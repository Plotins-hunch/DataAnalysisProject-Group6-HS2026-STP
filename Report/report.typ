// Group Report #1 — one page, figures included (lorem ipsum placeholders)
// Compile from the repo root:  typst compile --root . --font-path <ABC Areal folder> Report/report.typ
// Show the grid:               add  --input grid=true
//
// ONE UNIT   X = A4 width / 135 = 4.41pt, the x-height of the text (ABC Areal: 0.519 em).
// ONE GRID   a baseline every 2.5X (11pt, 130%); 6 columns of 16X, gutters 3X, margins 12X (page = 135X).
//            Three zones, each a whole number of columns, the same on every row:
//              A  labels    1 column    16X
//              B  text      3 columns   54X
//              C  evidence  2 columns   35X
// FOUR RULES
//   1  Size follows role. Three sizes, all from X:
//        title  x-height 3X (26pt), two lines on a leading of two grid lines, the one large thing
//        text   x-height X  (8.67pt): columns A and B
//        small  x-height ⅚X (7.23pt): column C and the text inside every plot
//   2  Every left edge sits on A, B or C. Plot panels fill their column: no y-axes, values are
//      labelled on the data, so the data starts on the column edge.
//      Every piece of evidence sits in C beside the paragraph that reads it.
//   2b One breakout: the figure that shows the question itself (Figure 5, every respondent)
//      spans B+C in a row of its own, label in A.
//   7  Text and evidence never repeat each other. Captions say only what is drawn (variable,
//      unit, encoding), never a finding; the text never restates a number shown in C, it
//      says why and what it means.
//   3  A row's elements hang from one line: the cap height of every first line, whatever its
//      size (title, text, small), sits on the same hang line.
//   4  A row is as tall as its tallest element, in whole lines.
//   5  Clearance: nothing comes closer than X to anything else: caption to plot, label to mark.
//   6  Spacing scale, all in lines: 0 inside a block · 1 between rows · 2 between zones
//      (statement | description 1–3 | inference 4–5). As in the CV grid: every entry sits on
//      the baseline grid, groups are parted by empty lines, never by rules.
// VOICES  sans for content; grey ABC Areal Mono for metadata (labels, keys, credits).
// FOOT    the credits sit at the foot of the page on the same three zones.
//      Figures are vector (SVG), so every line and letter stays sharp.
// MINIMUM VIABLE VISUALISATION   each figure shows only what its job needs; anything the
//   table, a caption or another figure already carries is left out of the plot.
// HIERARCHY of information, expressed only by position, ink and size:
//   1  the question, as the title                   top of the page, display size
//   2  the findings, two sentences                  under it, ink; the data beside them in C
// ZERO REDUNDANCY   every fact is printed once, where it is used: the cut point in Grouping,
//   the missing count with the IV, the test result under Figure 4, nothing as a pointer.
//   3  section headings 1–5 (the rubric's parts)    column A, ink
//   3b key facts under each heading                  column A, grey (name, scale, N, cut, p)
//   4  body text: the reasoning                     column B, ink
//   5  evidence: figures, Table 1, notes            column C, small size
//   6  context: data, method, names, course         grey
// ONE FAMILY, ONE WEIGHT   ABC Areal regular throughout. ABC Areal Mono only for variable names.
// THREE INKS   ink for content; grey for supporting information; red for one meaning only:
//              group 1 (above the mean) and the cut point, in figures and text alike.
// TEXT   how to write the body text against the figures: Report/WRITING_NOTES.md
// DATA   every figure and number comes from Working/Group6_InternetAndLoneliness/Exploration_00.R.
//        The licensed fonts stay out of the repo; without them Typst falls back to Arial.

// X is taken from the page: A4 width = 135X, so margins and columns divide it exactly
#let X      = 595.28pt / 135                      // 4.41pt
#let xh     = 0.519
#let u      = 2.5 * X                             // one line, 11pt
#let gut    = 3 * X
// BASE GRID: 6 equal columns of 16X with gutters of 3X (one line), margins 12X:
// 12 + 6·16 + 5·3 + 12 = 135X = the page width. Labels 1 column, text 3, evidence 2,
// the Figure 2 breakout 5.
#let ncol   = 6
#let col    = 16 * X
#let margin = 12 * X
#let span(n) = n * col + (n - 1) * gut
#let col-a  = span(1)                             // 16X  70.6pt
#let col-b  = span(3)                             // 54X  238.1pt
#let col-c  = span(2)                             // 35X  154.3pt
#let tw     = span(ncol)                          // 111X 489.5pt
#let nlin   = 66
#let th     = nlin * u
#let text-size  = X / xh                          // 8.67pt
#let small-size = 5 / 6 * X / xh                  // 7.23pt
#let cap    = 0.716                               // ABC Areal cap height / em
#let title-size = 2 * u / cap                      // cap height = 2 lines (5X), 30.8pt; leading 3 lines
#let hair   = X / 10
#let base-drop = 0.6 * X                          // text baseline sits 0.6X above each line's bottom
// HANG LINE (rule 3): every size hangs its capitals from the same line, `hang` below the top of
// a grid line. Text sits exactly on the baseline grid; small text and the title take the
// baseline offset that puts their cap height on the same hang line.
#let hang   = u - base-drop - cap * text-size
#let hung(size, lines: 1) = (top-edge: hang + cap * size, bottom-edge: -(lines * u - hang - cap * size))
#let show-grid = sys.inputs.at("grid", default: "false") == "true"

#let ink  = rgb("#1a1a1a")
#let grey = luma(42%)
#let red  = rgb("#b2182b")

// vertical: top margin 12X, 55 lines of 3X; the rest of A4 (13.9X) is the bottom margin,
// which holds the credits
#set page(paper: "a4", margin: (left: margin, right: margin, top: margin, bottom: 841.89pt - margin - th),
  background: if show-grid { place(dx: margin, dy: margin, {
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
    set text(size: small-size, fill: grey, number-width: "tabular", font: ("ABC Areal Mono", "Courier New"))
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
// metadata voice (after the CV grid): grey mono for labels, keys and credits; sans for content
#let tag(body) = text(font: ("ABC Areal Mono", "Courier New"), fill: grey, body)
#let g1(body) = text(fill: red, body)
// column C: everything at the small size, tabular figures
#let evidence(body) = text(size: small-size, number-width: "tabular", ..hung(small-size), body)
#let fig(caption, file, lines, width: col-c) = evidence({
  caption
  image(out + file, width: width, height: lines * u)
})

// one row of the page: A | B | C, all starting on the same line
#let row(a, b, c) = (a, b, c)

#let keys(..lines) = tag(lines.pos().join(linebreak()))    // grey mono key facts, one per line
#let small-table(..cells) = evidence(table(columns: (1.6fr, 1fr, 1fr), stroke: none, inset: 0pt,
  align: (left, right, right), ..cells))
#let rule = table.hline(stroke: hair)

#grid(
  columns: (col-a, col-b, col-c),
  column-gutter: gut,
  //           title  facts→DV  DV   IV   grp  desc→test  test  fig5
  row-gutter: (2 * u, 2 * u,    u,   u,   u,   2 * u,     u,    u),

  // ---- header: the title is the one large thing on the page (rule 1) ----
  tag[Report 1 \ Group 6],
  grid.cell(colspan: 2, { set par(leading: 3 * u - title-size); text(size: title-size, top-edge: hang + cap * title-size, bottom-edge: -(3 * u - hang - cap * title-size))[Is internet use associated \ with loneliness?] }),

  // ---- findings: the first row, built like every other row (label | text | evidence) ----
  // two sentences: the result in plain language, then its meaning and main caveat
  ..row(tag[Findings],
        [#lorem(14) #g1[above the mean] #lorem(18)],
        evidence(meta[European Social Survey Round 11 \ Switzerland, 2023 \ N #n.n_total respondents])),

  // ---- 1 Variables ----
  ..row([1 Variables \ #keys([Dependent], `fltlnl`, [scale 1–4], [N #n.lonely_n])],
        [#lorem(56)],
        fig([Figure 1 Felt lonely in the past week], "fig1_lonely.svg", 5)),
  ..row(keys([Independent], `netustm`, [min per day], [N #n.net_n], [#n.net_missing missing]),
        [#lorem(58)],
        fig([Figure 2 Time online, #g1[red above the mean]], "fig2_internet.svg", 5)),

  // ---- 2 Grouping: the group bar chart and the boundary note ----
  ..row([2 Grouping \ #keys(`net_group`, [cut #n.cut min])],
        [#lorem(12) #g1[above the mean (1)] #lorem(20)],
        evidence({
          [Figure 3 Groups, N #n.group_n, mode #n.group_mode]
          image(out + "fig3_groups.svg", width: col-c, height: 3 * u)
          meta[#n.on_cut on the mean; missing in neither group]
        })),

  // ---- 3 Descriptives: Table 1 beside its reading ----
  ..row([3 Descriptives],
        [#lorem(56)],
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

  // ---- 4 Test: the case for Welch beside the text ----
  ..row([4 Test],
        [#lorem(26)],
        evidence[0 at or below: N #n.n0, SD #n.sd0 \ #g1[1 above: N #n.n1, SD #n.sd1]]),

  // ---- the one breakout (rule 2b): Figure 5, the question itself, across B and C ----
  tag[Figure 5],
  grid.cell(colspan: 2, fig([Every respondent, loneliness (1–4, jittered) by minutes online, #g1[red above the mean]], "fig5_scatter.svg", 5, width: col-b + gut + col-c)),

  // ---- 5 Interpretation: the result beside its reading ----
  ..row([5 Interpretation],
        [#lorem(60)],
        fig([Figure 4 Mean loneliness, 95% CI \ Welch #g1[1] − 0: #n.diff (#n.diff_lo to #n.diff_hi) \ t #n.t, df #n.df, p #n.p], "fig4_means.svg", 4)),
)
