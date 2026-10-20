// THE TEXT OF THE REPORT. This is the only file to edit when writing.
//
// Each section is a #let name = [ ... ]; write full sentences inside the brackets.
// The layout (report.typ) places each section beside its figure, so the text must fit its row:
// the number of lines is given above each section (about 9 words per line). After writing,
// compile and check that the page is still one page.
//
// Numbers from the script are inserted with #n.name, never typed:
//   #n.n_total #n.cut #n.on_cut #n.net_missing #n.lonely_n #n.net_n #n.group_n
//   #n.n0 #n.n1 #n.sd0 #n.sd1 #n.diff #n.diff_lo #n.diff_hi #n.t #n.df #n.p
// (every name is in Working/Group6_InternetAndLoneliness/figures/report_numbers.csv)
// Group 1 is red everywhere: write it as #g1[above the mean]. Variable names in backticks: `fltlnl`.
// Do not repeat a number that the figure or table beside the text already shows; say what it means.
// Longer guidance per section: WRITING_NOTES.md.

#import "numbers.typ": n, g1

#let title = [Is internet use linked \ to self-reported loneliness?]
#let authors = [Gabriele Pizzi, Marlo (Clara) Roth, Ole Handschug, Joshua Silalahi]

// FINDINGS, 3 lines. Two sentences: the result in plain language, then what it means and the
// main caveat (regular internet users only; a mean split is a crude test). No numbers.
#let findings = [
  Placeholder: people who spend more time online than average report no more loneliness than
  those #g1[above the mean] are compared with. Placeholder: this holds for regular users only.
]

// DEPENDENT VARIABLE, 7 lines (beside Figure 1). Why `fltlnl`: the only item that asks about the
// feeling of loneliness itself (the others measure contact or mood). What Figure 1 shows: almost
// everyone in the lowest category, so little variation to explain. Limitations: one item, past
// week only, four coarse categories, self-reported.
#let dependent = [
  Placeholder: why `fltlnl` was chosen over the other candidate items. Placeholder: why it captures
  the feeling of loneliness. Placeholder: what Figure 1 shows and what that means for the analysis.
  Placeholder: at least one limitation of this measure.
]

// INDEPENDENT VARIABLE, 7 lines (beside Figure 2). Why `netustm`: minutes per day is continuous
// and spread out, while `netusoft` is "every day" for 80%. What Figure 2 shows: right-skewed,
// long tail, spikes at whole hours (people round). Limitations: includes work use, self-reported
// and heaped, asked only of people online most days (the #n.net_missing not asked stay missing).
#let independent = [
  Placeholder: why `netustm` was chosen. Placeholder: what Figure 2 shows about the distribution.
  Placeholder: who was not asked the question and how those #n.net_missing respondents are handled.
  Placeholder: at least one limitation of this measure.
]

// GROUPING, 4 lines (beside Figure 3). How the variable was made: split at the mean of
// #n.cut minutes, 1 = above, 0 = at or below, original variable kept, cut point one line in the
// script. Boundary: a value equal to the mean goes to group 0; #n.on_cut respondents sit on it.
// Why the groups are unequal: the skew pulls the mean above the median.
#let grouping = [
  Placeholder: the split at #n.cut minutes, with 1 for #g1[above the mean] and 0 for at or below.
  Placeholder: how a value exactly on the mean is handled. Placeholder: why the groups are unequal.
]

// DESCRIPTIVES, 9 lines (beside Table 1). Read the table back without copying it: recoding from
// text labels to numbers; the DV's median, mode and IQR all at the bottom of the scale; the IV's
// mean far above its median and an SD close to the mean (strong skew); the mode of 120 minutes
// reflects rounding to whole hours; who is missing and why.
#let descriptives = [
  Placeholder: the recoding performed. Placeholder: what the descriptives of loneliness show.
  Placeholder: what the descriptives of internet time show. Placeholder: anything notable, such as
  heaping, outliers or missingness.
]

// TEST, 3 lines (beside the group N and SD). Which test and why: Welch's two-sample t-test, two
// independent groups of unequal size and spread, no equal-variance assumption. H0 in words.
#let test = [
  Placeholder: the test chosen and why it fits two independent groups of unequal size and spread.
  Placeholder: the hypothesis being tested.
]

// INTERPRETATION, 8 lines (beside Figure 4, under Figure 5). Four things: which groups and their
// means (point to Figure 4); the difference, its direction and that it is not significant (the
// numbers are in Figure 4's caption); the plain-language meaning; the cut-point limitation, using
// Figure 5 (the split ignores all variation within the groups; Report 2 uses the minutes in full).
#let interpretation = [
  Placeholder: the two groups compared and what Figure 4 shows about their means. Placeholder: the
  direction and size of the difference and what the p-value says. Placeholder: what this means for
  the research question in plain language. Placeholder: the limitation of the cut point, read from
  Figure 5, and what Report 2 will do instead.
]
