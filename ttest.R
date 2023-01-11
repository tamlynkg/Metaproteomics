# Load required R packagesz
install.packages('tidyverse')
library(tidyverse)
install.packages('rstatix')
library(rstatix)
install.packages('ggpubr')
library(ggpubr)

df <- read.delim('TotalNperplot.txt')

df %>%
  group_by(Treatment.Group) %>%
  get_summary_stats(TotalN, type = "mean_sd")

res.aov <- df %>% anova_test(TotalN ~ Treatment.Group)
res.aov
write.table(res.aov,'anova_totalC.txt') 

??p.adjust.method
pwc <- df %>%
  pairwise_t_test(TotalN ~ Treatment.Group, p.adjust.method = "bonferroni")
pwc

?pairwise_t_test

write.table(pwc,'pairwise_weight.txt') 

# Show adjusted p-values
pwc <- pwc %>% add_xy_position(x = "Treatment.Group")
ggboxplot(df, x = "Treatment.Group", y = "Weight") +
  stat_pvalue_manual(pwc, label = "p.adj", tip.length = 0, step.increase = 0.1) +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )

ggboxplot(df, x = "Treatment.Group", y = "Weight", fill = c('orange','yellow','red','green')) +
  stat_pvalue_manual(pwc, hide.ns = TRUE, label = "p.adj.signif") +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )
?ggboxplot
