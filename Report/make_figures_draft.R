# Draft plots for the one-page report: monochrome, Arial 7pt, sized to the grid.
# Run from the repo root:  Rscript Report/make_figures_draft.R Report/figures
# (draft only; the final plot code moves into the main analysis script)
suppressMessages({library(readr); library(dplyr); library(ggplot2); library(patchwork)})  # patchwork stacks Figure 2's two panels
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

# ---- grid geometry in points: must match report.typ ----
# margin figures sit in columns 5-6 (156pt); Figure 2 breaks out across columns 2-6 (408pt);
# heights are whole 12pt lines
pt <- 1 / 72
w  <- 156 * pt
w_wide <- 408 * pt
# ---- one size, two inks: grey = group 0 (at or below mean), black = group 1 (above) ----
fs <- 7; black <- "#000000"; grey <- "#8c8c8c"
mm <- function(x) x / ggplot2::.pt

theme_grid <- function() theme_void(base_size = fs, base_family = fam) +
  theme(text = element_text(colour = black, size = fs),
        axis.text = element_text(colour = black, size = fs),
        axis.text.x = element_text(margin = margin(t = 2)),
        axis.text.y = element_text(margin = margin(r = 3), hjust = 1),
        legend.position = "none",
        plot.margin = margin(2, 2, 0, 0),
        plot.background = element_rect(fill = "white", colour = NA))
white_grid <- function(at) geom_hline(yintercept = at, colour = "white", linewidth = 0.4)
txt <- function(..., colour = black) annotate("text", family = fam, size = mm(fs), colour = colour, ...)
save <- function(p, name, lines, width = w) ggsave(file.path(out, name), p, width = width, height = lines * 12 * pt, dpi = 600)
# minutes axis shared by Figures 2 and 5, which sit in the same columns, so their axes line up
x_minutes <- scale_x_continuous(breaks = seq(0, 1080, 120), labels = c(0, paste0(seq(2, 18, 2), "h")),
                                limits = c(0, 1080), expand = expansion(add = c(5, 10)))

# F1 DV histogram: one bar per answer, share and count on top, mean marked under the baseline
dv <- filter(ess, !is.na(lonely)) %>% count(lonely) %>% mutate(p = n / sum(n))
m_dv <- mean(ess$lonely, na.rm = TRUE)
f1 <- ggplot(dv, aes(lonely, n)) +
  geom_col(width = 0.86, fill = black) + white_grid(c(250, 500, 750)) +
  geom_text(aes(label = paste0(round(100 * p), "%\n", formatC(n, big.mark = ",", format = "d"))),
            vjust = -0.25, lineheight = 0.9, family = fam, size = mm(fs)) +
  annotate("point", x = m_dv, y = -140, shape = 17, size = 1.2) +
  txt(x = m_dv + 0.12, y = -140, hjust = 0, label = sprintf("mean %.2f", m_dv)) +
  scale_x_continuous(breaks = 1:4, labels = c("None", "Some", "Most", "All")) +
  scale_y_continuous(limits = c(-230, 1480), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.y = element_blank())
save(f1, "f1_dv_hist.png", 6)

# F2 IV histogram: 10-minute bins, shaded by group, mean (= cut point) marked (median is in Table 1)
iv <- filter(ess, !is.na(net_min)); med_iv <- median(iv$net_min)
f2 <- ggplot(iv, aes(net_min, fill = net_group)) +
  geom_histogram(binwidth = 10, boundary = 0, closed = "left") +
  scale_fill_manual(values = c(grey, black)) +
  white_grid(c(50, 100, 150)) +
  annotate("segment", x = cut_point, xend = cut_point, y = 0, yend = 195, linewidth = 0.3) +
  txt(x = cut_point + 25, y = 190, hjust = 0, label = sprintf("mean = cut point, %.1f min", cut_point)) +
  # direct labels in the ink of the bars they name, so no legend is needed
  txt(x = cut_point + 25, y = 160, hjust = 0, label = sprintf("1  above mean: %d", sum(iv$net_group == "Above mean"))) +
  txt(x = cut_point + 25, y = 138, hjust = 0, colour = grey, label = sprintf("0  at or below: %d", sum(iv$net_group == "At or below mean"))) +
  x_minutes +
  scale_y_continuous(breaks = c(50, 100, 150), limits = c(0, 205), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.x = element_blank())

# F3 grouping variable: two bars, count and share
gc <- filter(ess, !is.na(net_group)) %>% count(net_group) %>% mutate(p = n / sum(n))
f3 <- ggplot(gc, aes(n, net_group, fill = net_group)) +
  geom_col(width = 0.62) +
  geom_text(aes(label = sprintf("%d (%.0f%%)", n, 100 * p)), hjust = -0.1, family = fam, size = mm(fs)) +
  scale_fill_manual(values = c(grey, black)) +
  scale_y_discrete(labels = c("0  At or below", "1  Above")) +
  scale_x_continuous(limits = c(0, 1180), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.x = element_blank())
save(f3, "f3_group_bar.png", 3)

# F4 mean loneliness by group with 95% CI; overall mean dashed (the test result sits beside it as a margin note)
gm <- filter(ess, !is.na(net_group), !is.na(lonely)) %>% group_by(net_group) %>%
  summarise(m = mean(lonely), se = sd(lonely) / sqrt(n()), n = n()) %>%
  mutate(lo = m - qt(.975, n - 1) * se, hi = m + qt(.975, n - 1) * se)
tt <- t.test(lonely ~ net_group, data = ess)   # Welch is R's default
f4 <- ggplot(gm, aes(m, net_group, colour = net_group)) +
  annotate("segment", x = m_dv, xend = m_dv, y = 0.6, yend = 2.4, linewidth = 0.25, linetype = "22", colour = grey) +
  geom_segment(aes(x = lo, xend = hi, yend = net_group), linewidth = 0.6) +
  geom_point(size = 1.8) +
  geom_text(aes(x = hi, label = sprintf("%.2f", m)), hjust = -0.3, family = fam, size = mm(fs), colour = black) +
  scale_colour_manual(values = c(grey, black)) +
  scale_y_discrete(labels = c("0", "1")) +
  scale_x_continuous(limits = c(1.2, 1.45), breaks = c(1.2, 1.3, 1.4)) +
  theme_grid()
save(f4, "f4_group_means.png", 3)

# F2 lower panel, the cut-point limitation (task 5): mean loneliness within bands of
# internet time, on the same minutes axis. The split keeps only "left vs right of the line".
br <- c(0, 60, 120, 180, 240, 360, 480, 1080)
bands <- filter(iv, !is.na(lonely)) %>%
  mutate(band = cut(net_min, br, right = FALSE, include.lowest = TRUE)) %>%
  group_by(band) %>%
  summarise(m = mean(lonely), se = sd(lonely) / sqrt(n()), n = n()) %>%
  mutate(lo = head(br, -1), hi = br[-1], mid = (lo + hi) / 2,
         side = factor(ifelse(hi <= cut_point + 5, "At or below mean", "Above mean"), levels = levels(ess$net_group)))
f5 <- ggplot(bands) +
  annotate("segment", x = cut_point, xend = cut_point, y = 1.05, yend = 1.6, linewidth = 0.3) +
  annotate("segment", x = 0, xend = 1080, y = m_dv, yend = m_dv, linewidth = 0.25, linetype = "22", colour = grey) +
  geom_segment(aes(x = mid, xend = mid, y = m - 1.96 * se, yend = m + 1.96 * se, colour = side), linewidth = 0.3) +
  geom_segment(aes(x = lo + 4, xend = hi - 4, y = m, yend = m, colour = side), linewidth = 0.6) +
  scale_colour_manual(values = c(grey, black)) +
  x_minutes +
  scale_y_continuous(breaks = c(1.2, 1.4), limits = c(1.05, 1.6), expand = c(0, 0)) +
  theme_grid()
save(f2 / f5 + plot_layout(heights = c(6, 4)), "f2_iv_hist.png", 10, width = w_wide)
