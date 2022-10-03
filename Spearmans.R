install.packages("ggpubr")
library("ggpubr")

#Spearman rho, which are rank-based correlation coefficients (non-parametric)

data <- read.delim("Spearmanscorrelation.txt")

head(data, 6)

ggscatter(data, x = "Fungi", y = c("Human", "Bacteria"), combine = TRUE,
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Human and Bacterial protein intensity", ylab = "Fungal protein intensity")

?ggscatter

# Shapiro-Wilk normality test for mpg
shapiro.test(data$Bacteria) # => p = 0.1229
# Shapiro-Wilk normality test for wt
shapiro.test(data$Fungi) # => p = 0.09

# mpg
ggqqplot(data$Human, ylab = "Human Protein Intensity")
# wt
ggqqplot(data$Fungi, ylab = "Fungal Protein Intensity")

res2 <-cor.test(data$Bacteria, data$Fungi,  method = "pearson")
res2
