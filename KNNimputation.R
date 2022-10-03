## The function is currently defined as
resultKNN <-  impute.knn(data2, k = 10, rowmax = 0.99, colmax = 0.99, maxp = 1500, rng.seed = sample(1:1000, 1))
dataSet.imputed = resultKNN[[1]]

write.table(dataSet.imputed, "Kingdoms_imputed_KNN", sep="\t")

####

library(impute)

data <- read.delim("Desktop/normalizemsnbase/normalizeibaqintensityproteinscopy.txt", header = TRUE, row.names = 1)

data2 <- as.matrix(data)
str(data2)
imputed <- impute.knn(data2, k = 10, rowmax = 0.8, colmax = 0.8, maxp = 1500, rng.seed=362436069)
??impute.knn
