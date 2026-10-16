# Draft plots for the one-page report: monochrome, Arial 7pt, sized to the grid.
# Run from the repo root:  Rscript Report/make_figures_draft.R Report/figures
# (draft only; the final plot code moves into the main analysis script)
suppressMessages({library(readr); library(dplyr); library(ggplot2)})
args <- commandArgs(TRUE)
out  <- if (length(args) > 0) args[1] else "Report/figures"
fam  <- if (length(args) > 1) args[2] else "Arial"

ess <- read_csv("Working/Group6_InternetAndLoneliness/ESS11_CHData.csv",
                col_types = cols(.default = col_character())) %>%
  mutate(lonely = as.integer(factor(fltlnl, levels = c("None or almost none of the time",
           "Some of the time", "Most of the time", "All or almost all of the time"))),
         net_min = suppressWarnings(as.numeric(netustm)))
cut_point <- mean(ess$net_min, na.rm = TRUE)
ess <- ess %>% mutate(net_group = factor(ifelse(net_min > cut_point, 1, 0), levels = 0:1,
                                         labels = c("At or below mean", "Above mean")))

# ---- grid geometry in points: must match report.typ (u = 12pt, column = 72pt, gutter = 12pt) ----
pt <- 1 / 72
w2 <- 156 * pt                 # 2 columns
w4 <- 324 * pt                 # 4 columns
# ---- one size, two inks ----
fs <- 7; black <- "#000000"; grey <- "#8c8c8c"
mm <- function(x) x / ggplot2::.pt

theme_grid <- function() theme_void(base_size = fs, base_family = fam) +
  theme(text = element_text(colour = black, size = fs),
        axis.text = element_text(colour = black, size = fs),
        axis.text.x = element_text(margin = margin(t = 2)),
        axis.text.y = element_text(margin = margin(r = 3), hjust = 1),
        legend.position = "none",
        plot.margin = margin(2, 0, 0, 0),
        plot.background = element_rect(fill = "white", colour = NA))
white_grid <- function(at) geom_hline(yintercept = at, colour = "white", linewidth = 0.4)
txt <- function(..., colour = black) annotate("text", family = fam, size = mm(fs), colour = colour, ...)
save <- function(p, name, w, lines) ggsave(file.path(out, name), p, width = w, height = lines * 12 * pt, dpi = 600)

# F1 DV histogram: one bar per answer, share on top
dv <- filter(ess, !is.na(lonely)) %>% count(lonely) %>% mutate(p = n / sum(n))
f1 <- ggplot(dv, aes(lonely, n)) +
  geom_col(width = 0.86, fill = black) + white_grid(c(250, 500, 750)) +
  geom_text(aes(label = paste0(round(100 * p), "%")), vjust = -0.5, family = fam, size = mm(fs)) +
  scale_x_continuous(breaks = 1:4, labels = c("None", "Some", "Most", "All")) +
  scale_y_continuous(limits = c(0, 1200), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.y = element_blank())
save(f1, "f1_dv_hist.png", w2, 7)

# F2 IV histogram: 10-minute bins, mean (= cut point) and median marked
iv <- filter(ess, !is.na(net_min)); med_iv <- median(iv$net_min)
f2 <- ggplot(iv, aes(net_min)) +
  geom_histogram(binwidth = 10, boundary = 0, closed = "left", fill = black) +
  white_grid(c(50, 100, 150)) +
  annotate("segment", x = cut_point, xend = cut_point, y = 0, yend = 185, linewidth = 0.3) +
  txt(x = cut_point + 8, y = 180, hjust = 0, label = sprintf("mean = cut point, %.1f min", cut_point)) +
  annotate("segment", x = med_iv, xend = med_iv, y = 0, yend = 128, linewidth = 0.3, linetype = "22", colour = grey) +
  txt(x = med_iv, y = 138, label = "median", colour = grey) +
  scale_x_continuous(breaks = seq(0, 1080, 120), labels = c(0, paste0(seq(2, 18, 2), "h")),
                     expand = expansion(add = c(5, 25))) +
  scale_y_continuous(breaks = c(50, 100, 150), limits = c(0, 192), expand = c(0, 0)) +
  theme_grid()
save(f2, "f2_iv_hist.png", w4, 7)

# F3 grouping variable: two bars, count and share
gc <- filter(ess, !is.na(net_group)) %>% count(net_group) %>% mutate(p = n / sum(n))
f3 <- ggplot(gc, aes(n, net_group, fill = net_group)) +
  geom_col(width = 0.62) +
  geom_text(aes(label = sprintf("%d (%.0f%%)", n, 100 * p)), hjust = -0.1, family = fam, size = mm(fs)) +
  scale_fill_manual(values = c(grey, black)) +
  scale_y_discrete(labels = c("0  At or below", "1  Above")) +
  scale_x_continuous(limits = c(0, 1180), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.x = element_blank())
save(f3, "f3_group_bar.png", w2, 3)
