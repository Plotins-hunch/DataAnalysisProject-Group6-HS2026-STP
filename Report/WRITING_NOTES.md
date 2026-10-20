# Writing notes for the report text

How to write the body text of `report.typ` so it works with the figures.

## Ground rules

- **Never restate a number that the evidence column (figures, Table 1, side notes) already shows.**
  The text says *why* and *what it means*; the evidence column shows *how much*.
  Write "most respondents sit in the lowest category (Figure 1)", not "75% answered none".
- **Captions only describe what is drawn** (variable, unit, colour). Findings belong in the text.
- **Name the figure when you lean on it**: "(Figure 2)". One mention per figure is enough.
- **Red always means group 1, above the mean.** When the text names that group, wrap it in
  `#g1[...]` so it turns red and links to the figures.
- **Full sentences, no bullet points** (brief, section 6).
- **Keep to each section's word budget**, or the page overflows. Re-compile after every section.

| Section | Words | Evidence beside it |
|---|---|---|
| Answer (fact sheet) | ~16 | — |
| 1 Variables, dependent | ~56 | Figure 1 |
| 1 Variables, independent | ~58 | Figure 2, missing-answers note |
| 2 Grouping | ~30 | Figure 3, boundary note |
| 3 Descriptives | ~64 | Table 1 |
| 4 Test | ~26 | group N and SD |
| 5 Interpretation | ~60 | Figure 4 (and Figure 5 above it) |

## What each section must say, and what to mention about its figure

### Answer
One plain sentence: no measurable difference in loneliness between heavier and lighter internet
users. No numbers (they are in Figure 4).

### 1 Variables: dependent, `fltlnl` (Figure 1)
The brief requires: why this item, why it captures loneliness, at least one limitation.
- **Why:** it is the only ESS 11 item that asks about the *feeling* of loneliness directly;
  `sclmeet`, `sclact` and `inprdsc` measure contact or network size (isolation), and `fltsd` and `fltdpr`
  measure low mood.
- **Figure 1 shows a floor effect:** almost everyone is in the lowest category, so the item can only
  separate a small minority. Say what that means: little variation to explain, and differences
  between groups will be small on this scale.
- **Limitations:** a single item, past week only, four coarse categories, self-reported.

### 1 Variables: independent, `netustm` (Figure 2, missing note)
- **Why:** minutes per day is continuous and widely spread; `netusoft` (how often) is useless because
  80% answer "every day".
- **Figure 2 shows:** a right-skewed distribution with a long tail, and spikes at whole hours (1h, 2h, 3h):
  people round their answers. The red line is the mean, which sits above the median because of
  the tail (both values are in Table 1, so do not repeat them).
- **Limitations:** includes work use; self-reported and heaped; asked only of people online most days,
  so the results describe regular internet users (the 168 not asked stay missing, not 0 minutes).

### 2 Grouping (Figure 3, boundary note)
- How the variable was made: split at the mean, 1 = above (`#g1[...]`), 0 = at or below; the original
  `netustm` is kept unchanged; the cut point is one line in the script.
- **Boundary handling** (graded): a value exactly equal to the mean would go to group 0; nobody sits
  on it. Missing answers are in neither group.
- **Figure 3 shows:** the groups are unequal but both large; mention *why* they are unequal (the skew
  pulls the mean above the median, so fewer people are above it).

### 3 Descriptives (Table 1)
"Read the descriptives back" (brief, section 3), without copying the table:
- recoding: the CSV stores labels; they were converted to 1–4 and to minutes;
- the DV's median, mode and IQR all sit at the bottom of the scale (floor effect again);
- the IV's mean is far above its median, and its SD is close to the mean: strong skew;
- the mode of 120 minutes reflects heaping at whole hours;
- missingness: who was not asked and why.

### 4 Test (group N and SD)
- Which test: Welch's two-sample t-test (R's default `t.test`).
- **Why Welch:** two independent groups of unequal size and unequal spread (the N and SD are beside
  the text); Welch does not assume equal variances.
- Hypotheses in words: H0, the two group means are equal.

### 5 Interpretation (Figure 4 beside it, Figure 5 above it)
The brief requires four things:
1. **Which groups and their means:** point to Figure 4; do not copy the numbers.
2. **Difference, direction, test statistic, p:** say the direction in words (heavier users are
   very slightly lonelier) and that the difference is small and not statistically significant; the
   figures are in Figure 4's caption.
3. **Substantive meaning in plain language:** among regular internet users in Switzerland, how
   much time people spend online tells us almost nothing about how lonely they feel.
4. **The cut-point limitation**, using **Figure 5**: the t-test only compares the two group means and
   ignores how minutes vary inside each group. Figure 5 shows every respondent: loneliness is
   spread the same way on both sides of the cut, and nothing hides inside the groups. A mean split
   is a crude version of the variable, so the result cannot bear much weight on its own; Report 2's
   regression will use the minutes in full.

## Facts from the data worth knowing (do not print them twice)

- Most common minute answers: 120 (178 people), 60 (161), 180 (112): heaping at whole hours.
- Loneliness by band of internet time stays between about 1.26 and 1.36 with overlapping
  intervals: no trend across the whole range.
- The t-test uses 1,210 people, not 1,212: two people in group 0 did not answer `fltlnl`.
