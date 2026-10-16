# Internet Use and Loneliness: Group 6

**Course:** Data Analysis for Public Policy Research (860-0041-00L), ETH Zurich, HS2026
**Assignment:** Group Report #1: Operationalisation, Descriptives, and Comparing Two Groups (due 28 October 2026)
**Group members:** Gabriele Pizzi, Clara Roth, Ole Handschug, Joshua Silalahi

**Research question:** Is people's internet use associated with their feeling of loneliness?

---

## Files

| File | What it is |
|---|---|
| `00_exploration.R` | Exploration script: dataset choice, variable selection, cleaning and labelling |
| `ESS11_CHData.csv` | European Social Survey Round 11, Switzerland (**the dataset we use**) |
| `ESS10_CHData.csv` | ESS Round 10, Switzerland (only its column names are checked) |
| `ESS11_CH_codebook.html`, `ESS10_CH_codebook.html` | Codebooks: variable names, question wording, answer codes |
| `ESS11_CH_questionnaire.pdf`, `ESS10_CH_questionnaire.pdf` | Original questionnaires |
| `Group_Research_Project_Report_1_Assignment_Details.pdf` | Assignment brief and grading rubric |
| `figures/` | ggplot charts made by Step 3 of the script: DV histogram, IV histogram, group bar chart |

1. **Chose the dataset: ESS Round 11.** The only direct loneliness question (`fltlnl`) exists in Round 11 but not in Round 10. The whole "how much of the time during the past week did you…" block is missing from Round 10.
2. **Listed all candidate items** for each concept by searching the column names and the codebook.
3. **Compared the candidates** on number of valid answers, number of answer options, and how concentrated the answers are.
4. **Chose one item per role** using three checks in priority order: (1) does it measure our concept, (2) is it continuous or Likert-type, (3) does it vary enough.

### Chosen variables

| Role | Variable | Question | Notes |
|---|---|---|---|
| Dependent (DV) | `fltlnl` | How much of the time during the past week did you feel lonely? (1–4) | 1,382 valid answers; 75% answer "none or almost none of the time" |
| Independent (IV) | `netustm` | Minutes of internet use on a typical day | 1,212 valid answers; mean ≈ 236 min, median 180 min |

### Candidates considered

| Variable | Why rejected |
|---|---|
| `sclmeet` (how often you meet people socially) | Measures social contact (isolation), not the feeling of loneliness |
| `inprdsc` (how many people you can discuss intimate matters with) | Measures network size; answers in uneven bins (4–6, 7–9, 10+) |
| `sclact` (social activity compared with people your age) | A relative comparison, not loneliness |
| `fltsd` / `fltdpr` (felt sad / felt depressed) | Measure low mood or depression, a different construct |
| `netusoft` (how often you use the internet) | 80% answer "Every day", so too little variation |

## Key takeaways

- **The concept decides the variable before the numbers do.** `fltlnl` has the least spread-out answers among the loneliness candidates, but it's the only item that measures loneliness itself.
- **Variable choice isn't based on which item correlates best.** Picking whichever item "works" would be fishing for results.
- **`netustm` only covers regular internet users.** The question was only asked of people who use the internet most days or every day; 168 less frequent users were skipped by design. We keep them as missing rather than setting them to 0 minutes, so results describe regular internet users only.
- **Limitations to report:**
  - `fltlnl`: a single item, past week only, 4 coarse categories, and most people in the lowest category (floor effect).
  - `netustm`: includes work use, self-reported, answers heaped at round numbers, right-skewed (max 1,080 min).
- **Next steps:** create the mean-split grouping variable, report descriptive statistics with ggplot charts, and run a Welch two-sample t-test.

## How to run

1. Put the R script and the data files in the same folder, and open that folder as an RStudio Project (or set it as the working directory).
2. Install the packages once if needed:
   ```r
   install.packages(c("readr", "dplyr", "ggplot2"))
   ```
3. Open `00_exploration.R` and run it from top to bottom: line by line with Ctrl/Cmd + Enter, or all at once with **Source**.

The script reads all columns as text, because the CSV stores answers as labels (e.g. "Some of the time"). It then converts the variables we use into numbers itself.
