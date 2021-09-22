library(gplots)
library("heatmap.plus")
library("RColorBrewer")
library('ggbiplot')
library('gplots')
library('dendextend')
library('imputeLCMD')
library('pvclust')
library('colorspace')
library('data.table')
library('qvalue')
library("optparse")
library('MSnbase')
library("dplyr")

#Set output directory
outdir=paste('BV',sep='')

#Set path for heatmap
heatmap_path=paste(outdir,'heatmaps/',sep='')

#Crete directory
dir.create(heatmap_path, showWarnings = TRUE, recursive = FALSE, mode = "0777")

#Load data
data <- read.table("Results/Excluded <2 peptides/BPheatmaps/bp_bv_limma.txt", sep = "\t", row.names = 1, header = TRUE)

Negative <- data[grep("Negative_", row.names(data)),]
Intermediate <- data[grep("Intermediate_", row.names(data)),]
Positive <- data[grep("Positive_", row.names(data)),]

#Set condition colours
condition_colors <- unlist(lapply(rownames(data), function(x){
  if(grepl("Negative", x)) '#FF0000'
  else if(grepl("Positive", x)) '#228B22'
  else if(grepl("Intermediate",x)) '#0000FF'
}))

#Transpose data
input <- as.matrix(t(data))

#Set colour palette
my_palette <- colorRampPalette(c("blue", "white", "red"))(n = 299)

#Select colour for brances
cols_branches <- c("orange", "purple", "magenta")

#Dendogram
dend_c <- t(input) %>% dist(method="euclidean") %>% hclust(method="ward.D") %>% as.dendrogram %>% ladderize 
dend_r <- input %>% dist(method="euclidean") %>% hclust(method="ward.D") %>% as.dendrogram %>% ladderize %>% color_branches(k=10)

dend_c <- color_branches(dend_c, k = 3, col = cols_branches)

hm <- function(df, heatmap_path, file,  main, xlab, dend_c, dend_r ) {
  png(paste(heatmap_path, file, sep=''), units="in", width=11, height=8.5, res=300)
  gplots::heatmap.2(as.matrix(input),
                    srtCol = 90,
                    main = main,
                    #Rowv = dend_c,
                    Colv = dend_c,
                    trace="none",
                    ColSideColors = condition_colors,
                    margins =c(10,17),
                    key.xlab = xlab,
                    denscol = "grey",
                    density.info = "density",
                    cexRow = 0.7,
                    ylab = NULL,
                    col = my_palette)
  
  legend(0.9, 0.9, legend = c("Positive", "Negative", "Intermediate"), fill=c('#FF0000', '#228B22', '#0000FF'), cex = 0.6)  
  dev.off() }



# Heatmap of global data set
hm(input, heatmap_path ,"heatmap_iBAQ.jpeg", "BPs Between BV States", "log2(iBAQ intensity)", dend_c, dend_r)

