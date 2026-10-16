# Draft plot suite: monochrome, Arial, sized to the report's grid modules.
# Run from the repo root:  Rscript Report/make_figures_draft.R Report/figures
# (draft only; the final plot code moves into the main analysis script)
suppressMessages({library(readr); library(dplyr); library(ggplot2)})
args <- commandArgs(TRUE); out <- args[1]; fam <- if (length(args) > 1) args[2] else "Arial"

ess <- read_csv("Working/Group6_InternetAndLoneliness/ESS11_CHData.csv",
                col_types = cols(.default = col_character())) %>%
  mutate(lonely = as.integer(factor(fltlnl, levels = c("None or almost none of the time",
           "Some of the time", "Most of the time", "All or almost all of the time"))),
         net_min = suppressWarnings(as.numeric(netustm)))
cut_point <- mean(ess$net_min, na.rm = TRUE)
ess <- ess %>% mutate(net_group = factor(ifelse(net_min > cut_point, 1, 0), levels = 0:1,
                                         labels = c("At or below mean", "Above mean")))
lab4 <- c("None or almost none", "Some", "Most", "All or almost all")

# ---- grid geometry (points): must match report.typ ----
pt <- 1 / 72                     # inches per point
half_w <- 240 * pt; full_w <- 492 * pt; plot_h <- 120 * pt   # module minus its caption line
# ---- monochrome ink ----
black <- "#000000"; grey <- "#8c8c8c"; light <- "#d0d0d0"
fs <- 7                          # all plot text 7pt
mm <- function(x) x / ggplot2::.pt   # pt -> ggplot text size

theme_grid <- function() theme_void(base_size = fs, base_family = fam) +
  theme(text = element_text(colour = black),
        axis.text = element_text(colour = black, size = fs),
        axis.text.x = element_text(margin = margin(t = 2)),
        axis.text.y = element_text(margin = margin(r = 3), hjust = 1),
        legend.position = "none",
        plot.margin = margin(4, 2, 0, 0),
        plot.background = element_rect(fill = "white", colour = NA))
white_grid <- function(at) geom_hline(yintercept = at, colour = "white", linewidth = 0.4)
txt <- function(..., colour = black, size = fs) annotate("text", family = fam, size = mm(size), colour = colour, ...)
save <- function(p, name, w) ggsave(file.path(out, name), p, width = w, height = plot_h, dpi = 600)

# F1 DV histogram
dv <- filter(ess, !is.na(lonely)) %>% count(lonely) %>% mutate(p = n / sum(n))
m_dv <- mean(ess$lonely, na.rm = TRUE)
f1 <- ggplot(dv, aes(lonely, n)) +
  geom_col(width = 0.9, fill = black) + white_grid(c(250, 500, 750)) +
  geom_text(aes(label = paste0(format(n, big.mark = ","), " (", round(100 * p), "%)")),
            vjust = -0.5, family = fam, size = mm(fs)) +
  scale_x_continuous(breaks = 1:4, labels = lab4) +
  scale_y_continuous(limits = c(0, 1180), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.y = element_blank())
save(f1, "f1_dv_hist.png", half_w)

# F2 IV histogram
iv <- filter(ess, !is.na(net_min)); med_iv <- median(iv$net_min)
f2 <- ggplot(iv, aes(net_min)) +
  geom_histogram(binwidth = 10, boundary = 0, closed = "left", fill = black) +
  white_grid(c(50, 100, 150)) +
  annotate("segment", x = cut_point, xend = cut_point, y = 0, yend = 182, linewidth = 0.3) +
  txt(x = cut_point + 6, y = 178, hjust = 0, label = sprintf("mean = cut point %.1f min", cut_point)) +
  annotate("segment", x = med_iv, xend = med_iv, y = 0, yend = 128, linewidth = 0.3, linetype = "22", colour = grey) +
  txt(x = med_iv, y = 136, label = "median 180", colour = grey) +
  scale_x_continuous(breaks = seq(0, 1080, 60), labels = function(b) ifelse(b %% 120 == 0, ifelse(b == 0, "0", paste0(b / 60, "h")), ""),
                     expand = expansion(add = c(5, 20))) +
  scale_y_continuous(breaks = c(50, 100, 150), limits = c(0, 190), expand = c(0, 0)) +
  theme_grid()
save(f2, "f2_iv_hist.png", full_w)

# F3 group bar chart
gc <- filter(ess, !is.na(net_group)) %>% count(net_group) %>% mutate(p = n / sum(n))
f3 <- ggplot(gc, aes(n, net_group, fill = net_group)) +
  geom_col(width = 0.5) +
  geom_text(aes(label = sprintf("%d (%.0f%%)", n, 100 * p)), hjust = -0.15, family = fam, size = mm(fs)) +
  scale_fill_manual(values = c(grey, black)) +
  scale_x_continuous(limits = c(0, 1000), expand = c(0, 0)) +
  theme_grid() + theme(axis.text.x = element_blank())
save(f3, "f3_group_bar.png", half_w)

# F4 DV answers within each group (hollow = group 0, filled = group 1)
dist <- filter(ess, !is.na(net_group), !is.na(lonely)) %>% count(net_group, lonely) %>%
  group_by(net_group) %>% mutate(p = 100 * n / sum(n)) %>% ungroup() %>%
  mutate(cat = factor(lab4[lonely], levels = rev(lab4)))
f4 <- ggplot(dist, aes(p, cat)) +
  geom_line(aes(group = cat), colour = light, linewidth = 0.8) +
  geom_point(aes(fill = net_group), shape = 21, size = 1.8, stroke = 0.5, colour = black) +
  scale_fill_manual(values = c("white", black)) +
  annotate("segment", x = 0, xend = 80, y = 0.4, yend = 0.4, linewidth = 0.3) +
  scale_x_continuous(breaks = seq(0, 80, 20), labels = paste0(seq(0, 80, 20), "%"), limits = c(0, 84)) +
  theme_grid()
save(f4, "f4_dv_by_group.png", half_w)

# F5 group means + 95% CI
gm <- filter(ess, !is.na(net_group), !is.na(lonely)) %>% group_by(net_group) %>%
  summarise(m = mean(lonely), se = sd(lonely) / sqrt(n()), n = n()) %>%
  mutate(lo = m - qt(.975, n - 1) * se, hi = m + qt(.975, n - 1) * se)
f5 <- ggplot(gm, aes(m, net_group)) +
  geom_segment(aes(x = lo, xend = hi, yend = net_group), linewidth = 0.5) +
  geom_point(aes(fill = net_group), shape = 21, size = 1.8, stroke = 0.5) +
  geom_text(aes(label = sprintf("%.2f", m)), vjust = -1.1, family = fam, size = mm(fs)) +
  scale_fill_manual(values = c("white", black)) +
  annotate("segment", x = 1.2, xend = 1.45, y = 0.45, yend = 0.45, linewidth = 0.3) +
  scale_x_continuous(limits = c(1.2, 1.45), breaks = seq(1.2, 1.45, 0.05)) +
  theme_grid()
save(f5, "f5_group_means.png", half_w)

# F6 loneliness across internet-time bands
br <- c(0, 60, 120, 180, 240, 360, 480, 1080)
bands <- filter(ess, !is.na(net_min), !is.na(lonely)) %>%
  mutate(band = cut(net_min, br, right = FALSE, include.lowest = TRUE)) %>%
  group_by(band) %>% summarise(x = median(net_min), m = mean(lonely), se = sd(lonely) / sqrt(n()), n = n()) %>%
  mutate(x = ifelse(row_number() < n(), (head(br, -1) + br[-1])[row_number()] / 2, x))
f6 <- ggplot(bands, aes(x, m)) +
  annotate("segment", x = cut_point, xend = cut_point, y = 1.06, yend = 1.55, linewidth = 0.3, linetype = "22") +
  txt(x = cut_point + 6, y = 1.53, hjust = 0, label = "cut point") +
  geom_segment(aes(xend = x, y = m - 1.96 * se, yend = m + 1.96 * se), linewidth = 0.5) +
  geom_point(size = 1.6) +
  geom_text(aes(y = 1.07, label = paste0("n = ", n)), colour = grey, family = fam, size = mm(fs)) +
  scale_x_continuous(breaks = seq(0, 720, 60), labels = function(b) ifelse(b %% 120 == 0, ifelse(b == 0, "0", paste0(b / 60, "h")), ""),
                     limits = c(0, 740), expand = c(0.005, 0)) +
  scale_y_continuous(limits = c(1.04, 1.56), breaks = seq(1.2, 1.5, 0.1)) +
  theme_grid()
save(f6, "f6_bands.png", full_w)

tt <- t.test(lonely ~ net_group, data = ess)
cat(sprintf("t=%.2f df=%.0f p=%.3f ci=[%.3f,%.3f]\n", tt$statistic, tt$parameter, tt$p.value, tt$conf.int[1], tt$conf.int[2]))
print(gm); s <- function(x) c(mean(x), median(x), var(x), sd(x), IQR(x), as.numeric(names(which.max(table(x)))))
print(round(s(na.omit(ess$lonely)), 3)); print(round(s(na.omit(ess$net_min)), 1))
