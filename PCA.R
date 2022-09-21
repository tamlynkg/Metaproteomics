df <- read.delim(file = "v2_BV_proteins_copy.txt", sep = "\t", header = TRUE, row.names = 1) #COPY DATA
factor <- read.delim("BV_factor.txt", sep = "\t", header = TRUE)

install.packages("httpuv")
library(mixOmics)

BiocManager::install('mixOmics')
if (!requireNamespace("BiocManager", quietly = TRUE)) 
  install.packages("BiocManager") 
install.packages("rgl")
library("rgl")

library(devtools)
library(ggbiplot)
install_github("vqv/ggbiplot")

library(ggplot2)
install.packages("ggfortify")
library(ggfortify)

library(gplots)
library(RColorBrewer)


pca_res <- prcomp(df, scale. = TRUE)
autoplot(pca_res)

autoplot(pca_res, data = df, group = factor$BV_Status, legend = TRUE)

#PCA for v2

MyResult.pca <- pca(as.data.frame(df))     # 1 Run the method
plotIndiv(MyResult.pca)
plotVar(MyResult.pca)      # 3 Plot the variables
plotIndiv(MyResult.pca, group = factor$BV_Status, 
          legend = TRUE)



pca.res<- pca(df, ncomp = 10, scale = FALSE)
plot(pca.res) #shows eigenvalues

plotIndiv(pca.res,group = factor$BV_Status, 
          centroid = FALSE, legend=TRUE,
          label = TRUE, star=FALSE, 
          ind.names = FALSE, lTRUEd =TRUE, legend.title="BV Status", col= c("Blue", "Green", "Red")) #plot to PLSDA output

#plotIndiv(pca.res, ind.names = FALSE, legend=TRUE, group = factor$BV_Status,
#          ellipse = TRUE, star = FALSE, title = 'BV Status',
#          X.label = 'PLS-DA 1', Y.label = 'PLS-DA 2')


#plotIndiv(pca.res,group=df$Chemokines, 
#          title='Genus', 
#          centroid = FALSE,
#          label = TRUE, star=FALSE, 
#          ind.names = FALSE, ellipse = TRUE, legend =TRUE, legend.title="BV Status", col= c("Blue", "Green","Red")) #plot to PLSDA output

##3d plot
plotIndiv(pca.res, group=factor$BV_Status, title='BV status',
          centroid = TRUE,
          label = FALSE, star=TRUE, 
          ind.names = FALSE, style ='3d',  ellipse = TRUE, legend =TRUE, legend.title="BV Status") #plot to PLSDA output



##plsda
#Y<-df$Pro.Infla  #assign the y variable, or group that you'd like to distinguish
#plsda <- plsda(logdf, Y, ncomp = 10)
#plotIndiv(group = df$Pro.Infla, 
#          plsda, title='Genus',  col = c("red","blue", "pink"), 
#          centroid = FALSE,
#          label = FALSE, star=FALSE, 
#          ind.names = FALSE, ellipse = TRUE, legend =TRUE, legend.title="Pro-inflammatory cytokines") #plot to PLSDA output


#PCA for v2

df1<-df[,6:ncol(df)]
autoplot(prcomp(df), data =df,
         label = FALSE, frame = FALSE, scale=FALSE, frame.type = 'norm', label.size = 3)

##complete
autoplot(prcomp(df1), data =sdf, colour = 'Serotype', loadings = TRUE, loadings.colour = 'blue',
         label = FALSE, frame = TRUE, scale=FALSE, frame.type = 'norm', label.size = 3)

help('prccomp')

df <- counts
##complex heatmap
install.packages("GetoptLong")
source("https://bioconductor.org/biocLite.R")
biocLite("ComplexHeatmap")
library(ComplexHeatmap)
library(circlize)
library(colorspace)
library(GetoptLong)
head(df[1:3,18:24])
newdf <- df[,18:ncol(df)]
newdf()
logmiss<-log2(df)
head(logmiss[1:4,5:7])


rnames <- df[,1] #where the name for each row is
mat<- data.matrix(df) #labeling numerical data as matrix
str(df)
rownames(mat) <- rnames

max(mat)
min(mat)
mean(mat)
median(mat)

##heatmap samples
my_palette <- colorRampPalette(c("red", "white", "blue"))(n = 299)

Heatmap(matrix = df, name = "Presence/Absence of Proteins in Samples", km =1, col = my_palette, clustering_distance_rows = "euclidean", clustering_method_rows = "complete")

?Heatmap

Heatmap(df, name = "Location", width = unit(5, "mm"), 
        col=c("red", "blue")) 

Heatmap(df$X125v2, name = "Serotype", width = unit(5, "mm"), 
          col=c("gold", "green","plum","blue","red","skyblue",
                "black","lightgreen"))

summary(df$Location)
help(Heatmap)
scatter(logdf)


#heatmap

mat<- data.matrix(df[,2:ncol(df)]) #labeling numerical data as matrix
my_palette <- colorRampPalette(c("red", "white", "blue"))(n = 10)
?colorRampPalette
##col_breaks = c(seq(0,0.000001,length=100), # for red
## seq(0.000001001,0.000001002,length=100))#,  # for white
##  seq(0.99999999,1,length=100)) # for blue
clusters<-factor$BV_Status
nofclust.height <-  length(unique(as.vector(clusters)));
selcol2 <- colorRampPalette(c(rep("red", 369), rep("blue", 826)))
clustcol.height = selcol2(nofclust.height);
summary(clusters)

selcol1 <- colorRampPalette(c(rep("Gold", 129), rep("green", 21),
                              rep("darkblue", 57), rep("blue", 27),
                              rep("darkred", 117),rep("skyblue", 55), 
                              rep("plum", 1059),rep("lightgreen", 15)))

dend_c <- t(mat) %>% dist(method="man") %>% hclust(method="ward.D") %>% as.dendrogram %>% ladderize%>% color_branches(k=3)
dend_r <- mat %>% dist(method="man") %>% hclust(method="ward.D") %>% as.dendrogram %>% ladderize %>% color_branches(k=10)

heatmap.2(mat, scale = "none",
         # col= my_palette,
         col = "heat.colors",
         Colv = dend_c,
          #labCol = FALSE,
          #labRow = FALSE,
          margins = c(5,5),
          ##breaks=col_breaks,
         cexRow = 0.4,
         cexCol = 0.4,
          density.info="density",  # turns off density plot inside color legend
          trace="none",

)
?heatmap.2
legend(y=1.5, x=.95, xpd=TRUE, # location of the legend on the heatmap plot
       legend = c("CSF", "Blood", "N"), # category labels
       col = clustcol.height[clusters],  # color key
       lty= 1,             # line style
       lwd = 5,            # line width
       cex=0.55,
       fill="white",
       border="white",
       box.col="white"
) 



