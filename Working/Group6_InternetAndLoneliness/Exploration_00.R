# ---------- STEP 1 -------------- #

# ----- part 0 - Setup ---------
# install packages
library(readr)    # read_csv()
library(dplyr)    # mutate(), select(), filter(), %>%
library(ggplot2)  # plot visualization

# ----- part 1 - Which survey round to use --------
# only one survey round is permitted and this is decided by the dependent
# variable. the only direct loneliness question seem to only exist
# in the round 11 of the survey (ess11)

# read only columns of ess 10 (n_max = 0), to check what it contains
ess10_colnames <- names(read_csv("ESS10_CHData.csv", n_max = 0,
                                 show_col_types = FALSE))
# print colnames
ess10_colnames

# browse as scrollable, searchable table
View(data.frame(column = ess10_colnames))

# search which of these columns relate to the term or data for
# loneliness-related items
grep("lnl|lone", ess10_colnames, value = TRUE)
# returns character(0) = no match
# grep() searches text for a pattern.
#"lnl|lone" means “contains lnl OR lone”, and value = TRUE returns
# the matching names rather than their positions

# READ ESS11 as text
ess11 <- read_csv("ESS11_CHData.csv",
                  col_types = cols(.default = col_character()))
ess11_colnames <- names(ess11)


# ---- part 2 - Finding the candidates ----
# are the chosen DV and IV (alt IV) present?
c("fltlnl", "netustm", "netusoft") %in% ess11_colnames
# result : [1] TRUE TRUE TRUE , definition:
# Felt lonely, how often past week | Internet use, how much time on typical day
# , in minutes | Internet use, how often

grep("lnl|lone", ess11_colnames, value = TRUE)   # loneliness  -> [1] "fltlnl"
grep("^net", ess11_colnames, value = TRUE)       # internet    -> [1] "netusoft" "netustm"
grep("^scl|^inprdsc", ess11_colnames, value = TRUE) # social life -> [1] "sclmeet" "inprdsc" "sclact"
grep("^flt", ess11_colnames, value = TRUE)       # "felt ..." items -> [1] "fltdpr"  "flteeff" "fltlnl"  "fltsd"


# ----- part 3 - Compare the candidates -----
# goal: for every candidate check:
# a.how many real answer it has
# b. how many different answer option it has (type)
# c. how concentrated the answers are (variation)

# answer codes that are not real answers are to be treated as missing
missing_codes <- c("Refusal", "Don't know", "No answer", "Not applicable")

# function: summarise ONE survey item (x = one column of ess11)
describe_item <- function(x){
  valid <- x[!is.na(x) & !(x %in% missing_codes)] # only real answers kept
  counts <- table(valid) # counts how often each answers occur
  data.frame(
    valid_n = length(valid), #number of real answers
    missing_n = length(x) - length(valid), #refusals. don't know, not asked
    n_answers = length(counts), # num of distinct answer options
    top_answer = names(which.max(counts)), # data mode is most common answer
    top_share = round(max(counts) / length(valid), 2)
    # proportion of respondents who chose the most common answer (0-1)
    # top_share = (number of people giving the most common answer)
    # / (number of valid answers)
  )
}

# testing func - to see one survey item
describe_item(ess11$fltlnl)
describe_item(ess11$netustm)
describe_item(ess11$netusoft)
describe_item(ess11$agegroup)


# candidates for DV and IV
dv_candidates <- c("fltlnl", "sclmeet", "sclact", "inprdsc", "fltsd","fltdpr")
iv_candidates <- c("netustm", "netusoft")
#LEGEND
# fltlnl - Felt lonely, how often past week
# sclmeet - How often socially meet with friends, relatives or colleagues
# sclact - Take part in social activities compared to others of same age
# inprdsc - How many people with whom you can discuss personal matters
# fltsd - Felt sad, how often past week
# fltdpr - Felt depressed, how often past week
#
# netustm - Internet use, how much time on typical day in minutes
# netusoft - how often does someone use internet

# lapply() to run describe_item on every column listed
# do.call(rblind, ...) stack results into one table

dv_compare <- do.call(rbind, lapply(ess11[dv_candidates], describe_item))
iv_compare <- do.call(rbind, lapply(ess11[iv_candidates], describe_item))

dv_compare
iv_compare
# RESULT :
# try to interpret the concentration of the top share and the top answer.
# that should give a view of how the candidate data looks like

# n_answers and top_share:
#           n_answers top_share
# fltlnl      2         0.75
# sclmeet     2         0.35
# sclact      8         0.46
# inprdsc     2         0.36
# fltsd       3         0.57
# fltdpr      1         0.69

#           n_answers  top_share
# netustm       47       0.15
# netusoft      5        0.80


# the frequency item, how concentrated:
round(prop.table(table(ess11$netusoft)), 2) # share in each answer option
# multiply by 100 and read out the percentage
# 4 out of 5 respondents gave the same answer (80%)
# question can’t tell those 80% apart, because a daily 20-minute user and a
# daily 10-hour user both answer “Every day”.
# it has too little variation to compare people,
# and a mean split would just be “every day” vs. “everyone else”.

# the minutes item: who was not asked? (cross-check with netusoft)
table(ess11$netusoft[ess11$netustm %in% missing_codes])
# result: 172 people have no minutes answer. 168 use the internet less than
# "most days" -> skipped by design (question only asked if most days/every day).
# The other 4 were asked but said "Don't know".
# -> netustm results describe REGULAR internet users only (limitation);
#    we keep the skipped people as NA rather than recoding them to 0 minutes.


# --- part 4: decide which items to use ---

# Code and their Questions on the codebook
# fltlnl - how much of the time during the past week... ...you felt lonely?
# sclmeet - how often do you meet socially with relatives / colleagues?
# inprdsc - How many people ... you can discuss intimate and personal matters?
# sclact - how often would you say you take part in social activities?
# fltsd - how much of the time during the past week... ...you felt sad?
# fltdpr - how much of the time during the past week... ...you felt depressed?
# netustm - how much time do you spend using the internet on a computer,
# tablet, smartphone or other device, whether for work or personal use /day?
# netusoft - How often do you use the internet on these or any other devices?


# MEASURE:
# Candidates are checked in priority order, stops at the first failure:
#   (1) concept   - does the question wording measure our construct?
#   (2) type      - continuous or Likert-type
#   (3) variation - do answers spread out enough (top_share (0-1, most->least))
# a well-spread item that measures the wrong thing, still the wrong item.

decision_table <- data.frame(
  item     = c("fltlnl", "sclmeet", "inprdsc", "sclact", "fltsd / fltdpr",
               "netustm", "netusoft"),
  role     = c("DV", "DV", "DV", "DV", "DV", "IV", "IV"),
  measures = c("felt lonely, past week",
               "how often meet people socially",
               "number of people to discuss intimate matters with",
               "social activity compared with people of same age",
               "felt sad / depressed, past week",
               "minutes of internet use on a typical day",
               "how often use the internet"),
  fails_at = c("-", "concept", "concept (+ type)", "concept", "concept",
               "-", "variation"),
  decision = c("USE", "reject", "reject", "reject", "reject",
               "USE", "reject"),
  reason   = c("only item measuring the FEELING of loneliness",
               "measures social contact (isolation), not loneliness",
               "network size; uneven bins (4-6, 7-9, 10+)",
               "relative comparison with peers, not loneliness",
               "measures low mood / depression, a different construct",
               "continuous, widely spread (47 values, top share 0.15)",
               "80% answer 'Every day' (top share 0.80)")
)
decision_table
View(decision_table)

# CONCLUSION
# DV = fltlnl. only item that measures the feeling of loneliness,
# so it wins at step 1 (concept). Limitation: 75% answer "none or almost
# none of the time" (floor effect), 4 coarse categories, past week only.
# IV = netustm. Both internet items measure internet use, so step 1 does not
# separate them; netustm wins at steps 2-3 (continuous, well spread).
# Limitation: only asked of people using the internet most days/every day
# (see part 3) -> results describe regular internet users only; includes
# work use; self-reported, heaped at round numbers.



# ------------------- STEP 2 -------------------------- #

# part 2.a
# the given csv stores answer as text so we need to convert them manually
# factor(x, levels = ...) puts the answers in their logical order.
# use as.integer() to give each answers its position
# anything not in the levels (refusals, don't know) is automatically N/A

lonely_levels <- c("None or almost none of the time",   # 1
                   "Some of the time",                  # 2
                   "Most of the time",                  # 3
                   "All or almost all of the time")     # 4


ess <- ess11 %>%
  mutate(
    lonely_f = factor(fltlnl, levels = lonely_levels),  # DV with answer labels
    lonely   = as.integer(lonely_f),                    # DV as numbers 1-4 (higher = lonelier)
    net_min  = suppressWarnings(as.numeric(netustm))    # IV in minutes; text codes -> NA
  )

# CHECK 1: each raw answer should map to exactly one number,
#  only Refusal / Don't know should become NA
table(raw = ess$fltlnl, new = ess$lonely, useNA = "ifany")
# result: each answer maps to one number (None=1: 1040, Some=2: 280,
# Most=3: 37, All=4: 25); only Refusal (1) and Don't know (1) became NA
# new
#raw                                  1    2    3    4 <NA>
#  All or almost all of the time      0    0    0   25    0
#  Don't know                         0    0    0    0    1
#  Most of the time                   0    0   37    0    0
#  None or almost none of the time 1040    0    0    0    0
#  Refusal                            0    0    0    0    1
#  Some of the time                   0  280    0    0    0

# CHECK 2: only the text codes should have become NA in net_min
table(ess$netustm[is.na(ess$net_min)], useNA = "ifany")
# result: Don't know 4, Not applicable 168

# part 2.b - grouping variables
# split net_min at its mean
# The cut point is stored on its own, so changing the split
cut_point <- mean(ess$net_min, na.rm = TRUE)
cut_point   # round up to 235.6 minutes

ess <- ess %>%
  mutate(
    # 1 = above the mean, 0 = at or below the mean.
    # ifelse() keeps NA as NA, so people without a minutes answer
    # are not put into group 0 by mistake.
    net_high  = ifelse(net_min > cut_point, 1, 0),
    net_group = factor(net_high, levels = c(0, 1),
                       labels = c("At or below mean", "Above mean"))
  )

# CHECK 3: boundary handling - how many people sit exactly ON the mean?
sum(ess$net_min == cut_point, na.rm = TRUE)
# result: 0 (the mean is not a whole number). by the rule that is set,
# anyone equal to the mean would go into the "at or below mean" group (0)

# CHECK 4: are both groups reasonably large?
table(ess$net_group, useNA = "ifany")
# result: At or below mean 717, Above mean 495, NA 172


# ------------------- STEP 3 -------------------------- #
# descriptive statistics for the three variables, and Figures 1-3 for the report

# part 3.a - DV and continuous IV: valid N, mean, median, mode, variance, sd, range, IQR
# R has no built-in mode, so stat_mode() takes the most common value
stat_mode <- function(x) as.numeric(names(which.max(table(x))))

describe_num <- function(x) {
  x <- x[!is.na(x)]                             # valid answers only
  c(valid_n = length(x), mean = mean(x), median = median(x), mode = stat_mode(x),
    variance = var(x), sd = sd(x), min = min(x), max = max(x), iqr = IQR(x))
}
desc <- data.frame(lonely = describe_num(ess$lonely), net_min = describe_num(ess$net_min))
round(desc, 2)
# result:     lonely   net_min
#  valid_n   1382.00   1212.00
#  mean         1.31    235.55
#  median       1.00    180.00
#  mode         1.00    120.00
#  variance     0.38  39098.04
#  sd           0.61    197.73
#  min / max    1 / 4   4 / 1080
#  iqr          0.00    270.00

# part 3.b - binary grouping variable: valid N, count and share in each group, mode
# (no mean, sd, range or IQR: they mean nothing for a 0/1 category)
group_counts <- ess %>%
  filter(!is.na(net_group)) %>%
  count(net_group) %>%
  mutate(share = n / sum(n))
group_counts
group_mode <- as.character(group_counts$net_group[which.max(group_counts$n)])
group_mode
# result: valid N 1212; at or below mean 717 (59%), above mean 495 (41%); mode = at or below mean

# part 3.c - one look for all figures
# each figure is saved as an SVG at the exact size of its slot in the report (Report/report.typ)
library(svglite)                  # install.packages("svglite") once if needed
fig_w  <- 2.14                    # width of the figure column, inches
wide_w <- 5.63                    # width of text + figure columns, inches (Figure 5 only)
line_h <- 0.153                   # height of one line of text in the report, inches
txt    <- 2.5                     # text size inside the plots (ggplot units, about 7 pt)
# colours: red = group 1 (above the mean) and the cut point, grey = group 0, dark = everything else
red <- "#b2182b"; grey <- "#a6a6a6"; dark <- "#5c5c5c"; text_grey <- "#666666"
# the report's font if it is installed, otherwise the system sans-serif
fam <- if ("ABC Areal Variable" %in% systemfonts::system_fonts()$family) "ABC Areal Variable" else "sans"

# no axes, no grid, no legend: the values are written on the data
theme_report <- theme_void(base_family = fam) +
  theme(axis.text.x = element_text(colour = text_grey, size = 7),
        legend.position = "none",
        plot.margin = margin(4, 0, 0, 0))

# save at the slot size; the report knows the font as "ABC Areal"
save_fig <- function(p, file, width, lines) {
  path <- file.path("figures", file)
  ggsave(path, p, width = width, height = lines * line_h)
  writeLines(gsub("ABC Areal Variable", "ABC Areal", readLines(path), fixed = TRUE), path)
}
dir.create("figures", showWarnings = FALSE)

# part 3.d - Figure 1: histogram of the DV, one bar per answer, share of respondents on top
lonely_counts <- ess %>%
  filter(!is.na(lonely)) %>%
  count(lonely) %>%
  mutate(label = paste0(round(100 * n / sum(n)), "%"))

fig1 <- ggplot(filter(ess, !is.na(lonely)), aes(lonely)) +
  geom_histogram(binwidth = 1, fill = dark) +
  geom_vline(xintercept = c(1.5, 2.5, 3.5), colour = "white", linewidth = 1.5) +  # gaps between the bars
  geom_text(data = lonely_counts, aes(lonely, n, label = label), vjust = -0.7, family = fam, size = txt) +
  scale_x_continuous(breaks = 1:4, labels = c("None", "Some", "Most", "All")) +
  scale_y_continuous(limits = c(0, 1300), expand = c(0, 0)) +
  theme_report
fig1
save_fig(fig1, "fig1_lonely.svg", fig_w, lines = 6)

# part 3.e - Figure 2: histogram of the IV in 10-minute bins, bars coloured by group,
# the mean (= cut point) marked; white lines every 50 people stand in for a y-axis
fig2 <- ggplot(filter(ess, !is.na(net_min)), aes(net_min, fill = net_group)) +
  geom_histogram(binwidth = 10, boundary = 0) +
  geom_hline(yintercept = c(50, 100, 150), colour = "white", linewidth = 0.3) +
  geom_vline(xintercept = cut_point, colour = red, linewidth = 0.2) +
  annotate("text", x = cut_point + 25, y = 200, label = "mean (cut)", hjust = 0,
           colour = red, family = fam, size = txt) +
  scale_fill_manual(values = c(grey, red)) +
  scale_x_continuous(breaks = c(240, 480, 720, 960), labels = c("4h", "8h", "12h", "16h"),
                     limits = c(0, 1080), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 220), expand = c(0, 0)) +
  theme_report
fig2
save_fig(fig2, "fig2_internet.svg", fig_w, lines = 6)

# part 3.f - Figure 3: bar chart of the grouping variable, count and share of each group
group_counts <- group_counts %>%
  mutate(label = paste0(c("0 at or below", "1 above"), "  ", n, " (", round(100 * share), "%)"))

fig3 <- ggplot(group_counts, aes(n, net_group, fill = net_group)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = label, colour = net_group), hjust = 0, nudge_x = 60, family = fam, size = txt) +
  scale_fill_manual(values = c(grey, red)) +
  scale_colour_manual(values = c(text_grey, red)) +
  scale_x_continuous(limits = c(0, 2200), expand = c(0, 0)) +
  scale_y_discrete(expand = expansion(add = 0.7)) +
  theme_report + theme(axis.text.x = element_blank())
fig3
save_fig(fig3, "fig3_groups.svg", fig_w, lines = 3)



# ------------------- STEP 4 -------------------------- #
# Is the average level of the dependent variable different for respondents on one side of the
# binary variable compared with respondents on the other side of the binary variable?
# is the mean of feeling lonely different between high and low internet usage?

# chosen t-test: Independent two-sample t-test
# reason: we want to compare the means of fltlnl for the two independent groups high and low
# internet usage

ess %>%
  group_by(net_group) %>%
  summarise(
    n = sum(!is.na(lonely)),
    mean_lonely = mean(lonely, na.rm = TRUE),
    sd_lonely = sd(lonely, na.rm = TRUE)
  )

# OUTPUT:
#  net_group            n mean_lonely sd_lonely
# At or below mean   715        1.30     0.595
# Above mean         495        1.33     0.647
# NA                 172        1.30     0.594

# H0: mean_net_high = mean_net_low
# H1: mean_net_high != mean_net_low

# the function t.test performs a t-test.
# it compares the means of the entries of lonely for net_group = "At or below mean" and "Above mean"
t.test(ess$lonely ~ ess$net_group)

# OUTPUT:
# t = -0.63251, df = 1004, p-value = 0.5272
# alternative hypothesis: true difference in means between group At or below mean and group Above mean is not equal to 0
# 95 percent confidence interval:
# -0.09499073  0.04868148
# sample estimates:
# mean in group At or below mean       mean in group Above mean
#                      1.302098                       1.325253




# part 4.b - Figure 4: mean loneliness in each group with its 95% confidence interval
tt <- t.test(ess$lonely ~ ess$net_group)        # the same test, kept as an object for the figure and step 6
group_means <- ess %>%
  filter(!is.na(net_group), !is.na(lonely)) %>%
  group_by(net_group) %>%
  summarise(n = n(), m = mean(lonely), s = sd(lonely)) %>%
  mutate(lo = m - qt(0.975, n - 1) * s / sqrt(n),      # 95% confidence interval of the mean
         hi = m + qt(0.975, n - 1) * s / sqrt(n))
group_means

fig4 <- ggplot(group_means, aes(m, net_group, colour = net_group)) +
  geom_pointrange(aes(xmin = lo, xmax = hi), linewidth = 0.4, size = 0.3) +
  geom_text(aes(x = hi, label = sprintf("%.2f", m)), hjust = -0.3, family = fam, size = txt) +
  scale_colour_manual(values = c(grey, red)) +
  scale_x_continuous(limits = c(1.2, 1.45), breaks = c(1.25, 1.3, 1.35, 1.4), expand = c(0, 0)) +
  theme_report
fig4
save_fig(fig4, "fig4_means.svg", fig_w, lines = 5)


# ------------------- STEP 5 -------------------------- #
# the limitation of the cut point: the t-test only compares two group means.
# Figure 5 shows every respondent, minutes online (x) against loneliness (y), coloured by
# group, with the cut point. loneliness has only 4 values, so the points are spread a little
# up and down (jitter) so they do not hide each other; set.seed() keeps the figure the same every run.
set.seed(6)
fig5 <- ggplot(filter(ess, !is.na(net_min), !is.na(lonely)), aes(net_min, lonely, colour = net_group)) +
  geom_jitter(width = 0, height = 0.22, size = 0.7, alpha = 0.55, stroke = 0) +
  geom_vline(xintercept = cut_point, colour = red, linewidth = 0.2) +
  scale_colour_manual(values = c(grey, red)) +
  scale_x_continuous(breaks = seq(120, 960, 120), labels = paste0(seq(2, 16, 2), "h"),
                     limits = c(0, 1080), expand = c(0, 0)) +
  scale_y_continuous(breaks = 1:4, limits = c(0.6, 4.4), position = "right", expand = c(0, 0)) +
  theme_report + theme(axis.text.y = element_text(colour = text_grey, size = 7, margin = margin(l = 4)))
fig5
save_fig(fig5, "fig5_scatter.svg", wide_w, lines = 5)
# result: loneliness is spread the same way on both sides of the cut point. the split hides
# how minutes vary inside each group, which Report 2 uses in full.


# ------------------- STEP 6 -------------------------- #
# every number printed in the report, written to one file that the report reads,
# so no number is typed by hand
f <- function(x, digits = 0) formatC(x, format = "f", digits = digits, big.mark = ",")
numbers <- c(
  n_total     = f(nrow(ess)),
  cut         = f(cut_point, 1),
  on_cut      = f(sum(ess$net_min == cut_point, na.rm = TRUE)),   # respondents exactly on the mean
  net_missing = f(sum(is.na(ess$net_min))),
  # Table 1
  lonely_n = f(desc["valid_n", "lonely"]),     net_n      = f(desc["valid_n", "net_min"]),
  lonely_mean = f(desc["mean", "lonely"], 2),  net_mean   = f(desc["mean", "net_min"], 1),
  lonely_median = f(desc["median", "lonely"]), net_median = f(desc["median", "net_min"]),
  lonely_mode = f(desc["mode", "lonely"]),     net_mode   = f(desc["mode", "net_min"]),
  lonely_var = f(desc["variance", "lonely"], 2), net_var  = f(desc["variance", "net_min"]),
  lonely_sd  = f(desc["sd", "lonely"], 2),     net_sd     = f(desc["sd", "net_min"], 1),
  lonely_range = paste0(f(desc["min", "lonely"]), "–", f(desc["max", "lonely"])),
  net_range  = paste0(f(desc["min", "net_min"]), "–", f(desc["max", "net_min"])),
  lonely_iqr = f(desc["iqr", "lonely"]),       net_iqr    = f(desc["iqr", "net_min"]),
  # groups
  group_n    = f(sum(group_counts$n)),
  group_mode = ifelse(group_mode == "Above mean", "1", "0"),
  n0 = f(group_means$n[1]), sd0 = f(group_means$s[1], 2),
  n1 = f(group_means$n[2]), sd1 = f(group_means$s[2], 2),
  # t-test, reported as group 1 minus group 0 (t.test gives group 0 minus group 1, so signs flip)
  diff    = sprintf("%+.2f", diff(tt$estimate)),
  diff_lo = sprintf("%.2f", -tt$conf.int[2]),
  diff_hi = sprintf("%.2f", -tt$conf.int[1]),
  t       = sprintf("%.2f", -tt$statistic),
  df      = sprintf("%.0f", tt$parameter),
  p       = sprintf("%.2f", tt$p.value)
)
write.csv(data.frame(name = names(numbers), value = numbers),
          "figures/report_numbers.csv", row.names = FALSE)
numbers
