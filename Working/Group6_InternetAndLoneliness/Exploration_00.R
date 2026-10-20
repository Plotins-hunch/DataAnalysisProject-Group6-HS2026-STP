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


# ------------------- STEP 3 - ILLUSTRATIONS -------------------------- #
# one ggplot per variable, as the assignment asks:
#   DV (lonely)       -> histogram
#   IV (net_min)      -> histogram
#   group (net_group) -> bar chart
# every plot drops NA, so each one shows the valid N only.
# plots are also saved as png into a "figures" folder for the report.

dir.create("figures", showWarnings = FALSE) # make folder if it is not there yet

# shared look for all plots, so they read as one set
theme_set(theme_minimal(base_size = 12) +
            theme(panel.grid.minor = element_blank(),
                  plot.title.position = "plot"))
bar_fill <- "#4C72B0" # one colour for all bars

# part 3.a - DV histogram
# lonely only takes the values 1-4, so binwidth = 1 gives one bar per answer.
# the x axis keeps the answer labels, so the reader sees what 1-4 mean.
n_dv <- sum(!is.na(ess$lonely)) # valid N, printed in the subtitle

plot_dv <- ggplot(filter(ess, !is.na(lonely)), aes(x = lonely)) +
  geom_histogram(binwidth = 1, fill = bar_fill, colour = "white") +
  geom_vline(xintercept = mean(ess$lonely, na.rm = TRUE),
             linetype = "dashed") + # dashed line = mean
  scale_x_continuous(breaks = 1:4,
                     labels = c("None or\nalmost none", "Some",
                                "Most", "All or\nalmost all")) +
  labs(title = "Felt lonely, past week (fltlnl)",
       subtitle = paste0("Valid N = ", n_dv, "; dashed line = mean"),
       x = "How much of the time (1-4)", y = "Number of respondents")
plot_dv
ggsave("figures/fig1_dv_lonely_hist.png", plot_dv, width = 6, height = 4, dpi = 300)
# READ: most people sit in the lowest category (floor effect, right-skewed)

# part 3.b - IV histogram
# binwidth = 30 minutes (half an hour). the dashed line is the mean,
# which is also the cut point for the grouping variable (step 2.b).
n_iv <- sum(!is.na(ess$net_min))

plot_iv <- ggplot(filter(ess, !is.na(net_min)), aes(x = net_min)) +
  geom_histogram(binwidth = 30, boundary = 0, fill = bar_fill, colour = "white") +
  geom_vline(xintercept = cut_point, linetype = "dashed") +
  annotate("text", x = cut_point, y = Inf, vjust = 1.5, hjust = -0.05,
           label = paste0("mean / cut point = ", round(cut_point, 1), " min")) +
  scale_x_continuous(breaks = seq(0, 1080, by = 120)) + # tick every 2 hours
  labs(title = "Internet use on a typical day (netustm)",
       subtitle = paste0("Valid N = ", n_iv,
                         " (regular internet users only); bins of 30 min"),
       x = "Minutes per day", y = "Number of respondents")
plot_iv
ggsave("figures/fig2_iv_netmin_hist.png", plot_iv, width = 6, height = 4, dpi = 300)
# READ: right-skewed with a long tail up to 1,080 min; spikes at round
# numbers (e.g. 60, 120, 180 min) show response heaping

# part 3.c - bar chart of the grouping variable
# count and share of each group are written on top of the bars
group_counts <- ess %>%
  filter(!is.na(net_group)) %>%
  count(net_group) %>%
  mutate(share = n / sum(n),
         label = paste0(n, " (", round(100 * share), "%)"))
group_counts

plot_group <- ggplot(group_counts, aes(x = net_group, y = n)) +
  geom_col(fill = bar_fill, width = 0.6) +
  geom_text(aes(label = label), vjust = -0.5) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) + # room for labels
  labs(title = "Grouping variable: internet use split at the mean",
       subtitle = paste0("Valid N = ", sum(group_counts$n),
                         "; cut point = ", round(cut_point, 1), " min"),
       x = NULL, y = "Number of respondents")
plot_group
ggsave("figures/fig3_group_bar.png", plot_group, width = 6, height = 4, dpi = 300)
# READ: both groups are reasonably large; the "at or below mean" group is
# bigger because the right-skewed tail pulls the mean above the median


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
