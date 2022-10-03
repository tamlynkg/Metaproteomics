library(BiocManager)
BiocManager::install("microbiome")
BiocManager::install("Rtsne")


#library(microbiome)
#library(phyloseq)
#library(ggplot2)
#install.packages("phyloseq")
data <- read.delim("Desktop/Machine learning/", header = TRUE, sep = "\t", row.names = 1)
meta <- read.delim("Desktop/Results/PCA/Inflammation/Factorfile_inflammation.txt")

pseq <- as.matrix(data)

#set.seed(4235421)
class(pseq)
ord <- ordinate(pseq, "MDS", "bray")

library(vegan)
library(microbiome)
library(Rtsne) # Load package
set.seed(423542)

method <- "tsne"
trans <- "hellinger"
distance <- "bray"

# Distance matrix for samples
ps <- microbiome::transform(pseq, trans)

# Calculate sample similarities
dm <- vegdist(ps, distance)

# Run TSNE
tsne_out <- Rtsne(dm, dims = 2) 
proj <- tsne_out$Y
rownames(proj) <- rownames(ps)

library(ggplot2)
p <- plot_landscape(proj, legend = T, size = 1) 
print(p)


library(Rtsne)
#iris <- data("iris")
iris_unique <- unique(pseq) # Remove duplicates

#iris_matrix <- as.matrix(iris_unique[,1:4])
set.seed(42) # Set a seed if you want reproducible results
#com <-  pseq[,4:ncol(pseq)]
tsne_out <- Rtsne(pseq) # Run TSNE


# Show the objects in the 2D tsne representation
plot(tsne_out$Y,col=meta$Inflammation_Status)

library(ggplot2)
tsne_plot <- data.frame(x = tsne_out$Y[,1], y = tsne_out$Y[,2], col = meta$Inflammation_Status)
ggplot(tsne_plot) + geom_point(aes(x=x, y=y, color=col))
