library(tidyverse)
library(datasets)

#tibble: the data.frame re-imagined
#readr: importing/exporting (mostly rectangular) data for humans
#dplyr + tidyr: a grammar of data manipulation
#purrr: functional programming in R
#stringr: string manipulation
#ggplot2: a grammar of graphics
#lubridate: manipulating dates
#modelr, recipes, rsample, infer: tidy modeling/statistics
#tidytext: tidy text analysis (life saver)
#tidygraph + ggraph: manipulating and plotting networks
#glue: print like a boss

ggplot(table1, aes(x = yob, y = pct_straight, color = religion)) +
  geom_smooth(method = "loess", se = FALSE)

dim(mtcars)
colnames(mtcars)
mtcars <- mtcars %>%
  mutate()  

data %>%
  filter(cyl == "6", gear > 4) %>%
  select(disp, hp)
