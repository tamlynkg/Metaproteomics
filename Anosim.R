
library(vegan)

# read in otu table data matrix

otu_table <- read.table("Results/PCA/Vaginal pH/PCA_genus_pH.txt", header=T, row.names=1, sep="\t")

#Transpose OTU table to have samples as rows and otus as columns

#otu_table_transposed <- t(otu_table)

otu_table_transposed <- otu_table

# read in environmental table indicating the group of samples

envir <- read.table("Results/PCA/Vaginal pH/Factorfile_pH.txt", header=T, sep="\t", row.names = 1)

envir
attach(envir)

location <-envir[,1]

location

# construct a distance hemi-matrix for biodata

otu_table_transposed.dist<-vegdist(otu_table_transposed)

# test null hypothesis of no difference in otu_table_transposed composition

otu_table_transposed.anosim<-anosim(otu_table_transposed.dist, location, permutations = 999, distance = "bray")

otu_table_transposed.anosim

#anova(otu_table_transposed.anosim)
#output results

ANOSIM statistic R: 0.4613 
Significance: 0.001 

Permutation: free
Number of permutations: 999

# boxplot of data
plot(otu_table_transposed.anosim, main="Fungal genera between Vaginal pH")


R value range from -1 to +1 (+1 indicates perfect separation amongst the groups), zero indicate no differences amongst groups

0.75 < R < 1 - highly different
0.5 < R < 0.75 -  different
0.25 < R < 0.5 -  different with some overlap
0.1 < R < 0.25 - similar with some differences (or high overlap)
R < 0.1 - similar

# note that within group variation is low
# between group variation is high (hence R is sig.)
# reject H0


#R value test for statistical significance between the groups defined (Agriculture vs Grassland)
#P value test for statistical significance within the groups (Amongt the samples of each group)
