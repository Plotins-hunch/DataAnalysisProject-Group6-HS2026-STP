// Numbers from the analysis script, and the one colour used in the report.
// Imported by content.typ and report.typ. Nothing to edit here.

// the script's output folder (path from the repo root; compile with --root .)
#let out = "/Working/Group6_InternetAndLoneliness/figures/"

// n.name gives a number from report_numbers.csv as text, e.g. n.cut, n.net_missing, n.p
#let n = {
  let d = (:)
  for row in csv(out + "report_numbers.csv").slice(1) {
    let v = row.at(1)
    d.insert(row.at(0), if v.starts-with("-") { "−" + v.slice(1) } else { v })   // real minus sign
  }
  d
}

// red means one thing everywhere: group 1 (above the mean) and the cut point.
// g1[...] sets words in that red, e.g. #g1[above the mean]
#let red = rgb("#b2182b")
#let g1(body) = text(fill: red, body)
