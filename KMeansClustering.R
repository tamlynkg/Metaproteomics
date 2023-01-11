df <- read.delim("Non-imputed/kingdom_nonimputed.txt", header = TRUE, sep = "\t", row.names = 1)
df <- scale(df)
df <- na.omit(df)


# View the firt 3 rows of the data
head(df, n = 3)

install.packages("factoextra")
library(factoextra)

kmeans(x, centers, iter.max = 10, nstart = 1)

# Compute k-means with k = 4
set.seed(123)
km.res <- kmeans(df, 2, nstart = 25)
?kmeans
??nstart

print(km.res)

dd <- cbind(df, cluster = km.res$cluster)
head(dd)

# Cluster number for each of the observations
km.res$cluster
# Cluster size
km.res$size
# Cluster means
km.res$centers

#How to find the number of clusters

fviz_nbclust(df, kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2)

fviz_nbclust(
  df,
  FUNcluster = kmeans,
  method = c("wss"),
  diss = NULL,
  k.max = 10,
  verbose = interactive(),
  barfill = "steelblue",
  barcolor = "steelblue",
  linecolor = "steelblue",
  print.summary = TRUE,
) 

library(cluster)
gap_stat <- clusGap(df, FUN = hcut, K.max = 10, B = 500)
fviz_gap_stat(gap_stat)

fviz_cluster(, data = df)

write.table(df)
write.csv(dd, file = "3cluster_individuals_nonimputedmetaproteome.csv")

library(cluster)

# Generate a k-means model using the pam() function with a k = 2
pam_k2 <- pam(df, k = 2)

# Plot the silhouette visual for the pam_k2 model
plot(silhouette(pam_k2))

# Generate a k-means model using the pam() function with a k = 3
pam_k3 <- ___

# Plot the silhouette visual for the pam_k3 model

avg_sil <- function(k) {
  km.res <- kmeans(df, centers = k, nstart = 25)
  ss <- silhouette(km.res$cluster, dist(df))
  mean(ss[, 3])
}

# Compute and plot wss for k = 2 to k = 15
k.values <- 2:15

install.packages("tidyverse")
library("tidyverse")
# extract avg silhouette for 2-15 clusters
avg_sil_values <- map_dbl(k.values, avg_sil)

plot(k.values, avg_sil_values,
     type = "b", pch = 19, frame = FALSE, 
     xlab = "Number of clusters K",
     ylab = "Average Silhouettes")


