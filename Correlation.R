my_data <- read.delim("Fungi_corr.txt", sep = "\t", header = TRUE, row.names = 1)
my_data1 <- t(my_data)
res <- cor(my_data1)
round(res, 2)
cor(my_data1, use = "complete.obs")

library("Hmisc")
res2 <- rcorr(as.matrix(my_data1))
res2

# Extract the correlation coefficients
res2$r
# Extract p-values
res2$P

flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}

library(Hmisc)

hp <- flattenCorrMatrix(res2$r, res2$P)
write.csv(hp, file = "correlation_fungi.csv")

install.packages("corrplot")
library(corrplot)
par(cex = 0.7)
corrplot(res, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45, cl.cex=0.9)
