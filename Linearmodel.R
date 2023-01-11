install.packages("ggplot2")
install.packages("dplyr")
install.packages("broom")
install.packages("ggpubr")

library(ggplot2)
library(dplyr)
library(broom)
library(ggpubr)

df <- read.delim('CNRatio_Treeindex.txt')
summary(df)
hist(df$CN)

plot(CN ~ Index, data = df)
cor(df$Index, df$TotalN)

CN.lm <- lm(CN ~ Index, data = df)

summary(CN.lm)
#The p value ( Pr(>| t | ) ), aka the probability of finding the given t statistic if the null hypothesis of no relationship were true.

par(mfrow=c(2,2))
plot(CN.lm)
par(mfrow=c(1,1))


N.graph<-ggplot(df, aes(x=CN, y=Index))+
  geom_point()
N.graph

N.graph <- N.graph + geom_smooth(method="lm", col="black")
N.graph


N.graph <- N.graph +
  stat_regline_equation(label.x = 47, label.y = 9)

N.graph


N.graph +
  theme_bw() +
  labs(x = "C:N Ratio (g/sqm)",
       y = "Tree Index (Density/Distance)")

