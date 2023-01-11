library(vegan)

# read the table
soil_chem <- read.delim("", header = T)

# attach the table for easy access
attach(soil_chem)

#check the col names
names(soil_chem)

as.numeric(Inflammation_Status)
##check the data by bnoxplot
boxplot(TotalN~Index, data = soil_chem, xlab = "Tree Index (Density/Distance", ylab = "Total N per plot (g/sqm)")

?boxplot
##anova of moisture by carbon
anova_nitrogen <-aov(TotalN~Treatment.Group, data = soil_chem)
# Stats summary
summary(anova_nitrogen)
#tukey HSD post hoc test
tukey.plot.aov <- TukeyHSD(anova_nitrogen)


plot(tukey.plot.aov, las = 0.5, cex.axis = 0.5)

mean.yield.data <- soil_chem %>%
  group_by(Treatment) %>%
  summarise(
    TotalC = mean(TotalC)
  )

mean.yield.data
?plot
# AnOVA and Tukey HSD for pH
anova_pH <-aov(pH~Moisture, data = soil_chem)
summary(anova_pH)
tukey_pH <- TukeyHSD(anova_pH)
