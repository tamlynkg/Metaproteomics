#!/usr/bin/env Rscript

library('limma')
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
 
#option_list = list(
#make_option(c("-q", "--quant_regex"), type="character", default=NULL,
#        help="Quant regex", metavar="character"),
#make_option(c("-p", "--peptides"), type="character", default=NULL,
#        help="Path to the peptides.txt file", metavar="character"),
#make_option(c("-o","--output"), type="character", default=NULL,
#        help="Path to the output file", metavar="character")) 

#opt_parser = OptionParser(option_list=option_list);

#opt = parse_args(opt_parser);

outdir=paste('normalizeandimpute2',sep='') #define

dir.create(outdir, showWarnings = TRUE, recursive = FALSE, mode = "0777")

path="ibaqintensitypanproteome.txt"
#data <- read.csv(path, header=TRUE, sep=',', dec = ',')
data <- read.delim(path, header =TRUE, sep = "\t", dec = ",")
#?read.csv


#quant_regex=opt$q

#source(exp_design)

#quant_reqex = "X"

cols <- names(data)[grep("iBAQ.",names(data))] 

print(cols)

data$ID <- 1:nrow(data)

#rownames(data) <- data$Identifier

orig_data <- data

data4 <- orig_data
print(cols)

print(data$ID)

#data[, cols] <- lapply(data[,cols], function(x) {replace(x, is.infinite(x), NA)})
#data[, cols] <- t(t(data[, cols])/colSums(data[, cols]))
data[, cols] <- lapply(data[, cols], function(x){replace(x, x == 0,  NA)})
data[, cols] <- lapply(data[, cols], function(x){ log2(x)})

data4 <- data
#data <- data[!rowSums(is.na(data)) > ncol(data)*.1,]
#data <- data[rowSums(is.na(data[,cols]))<= length(cols)-length(cols)/100, ]
data <- data[rowSums(is.na(data[,cols])) < length(cols), ]
max_missing <- 0.01 # at least 50 percent of samples have the protein ID
data <- data[rowSums(is.na(data[,cols]))<= max_missing, ]
#add a rule: if more than ~50% of data is NA for a protein - exclude
#data <- data[rowSums(is.na(data[,cols])) < 0.3,]

#######################################################
# Create MSnBase object, normalization and imputation #
#######################################################

print('Creating msnbase object')
msnbase_path=paste(outdir,'msnbase/',sep='')
dir.create(msnbase_path, showWarnings = TRUE, recursive = FALSE, mode = "0777")

msnpath = paste(outdir, "msnbase/cleaned.csv",sep='')
write.csv(data, file=msnpath)

ecol <- cols
fname <- "ID"
eset <- readMSnSet2(msnpath, cols, fname)
eset@phenoData$sampleNames <- cols
#eset@phenoData$sampleGroups <- f

png(paste(msnbase_path,'boxplots_unnormalized.png',sep=''),units="in", width=11, height=8.5, res=300)
par(mfrow = c(2, 1))
boxplot(exprs(eset), notch=TRUE, col=(c("gold")), main="Samples", ylab="peptide log2(Intensity)", las=2) 
dev.off()

#x.nrm <- eset
x.nrm <- normalise(eset, "quantiles")
x.imputed <- impute(x.nrm, method = "QRILC")
x.nrm <- x.imputed

#x.imputed <- x.nrm

png(paste(msnbase_path,'boxplots_normalized.png',sep=''),units="in",width=11,height=8.5,res=300)
par(mfrow = c(2, 1))
boxplot(exprs(x.nrm), notch=TRUE, col=(c("gold")), main="Samples", ylab="intensity ratio", las=2) 
dev.off()
png(paste(msnbase_path,'all_data_heatmap_normalized.png',sep=''),units="in",width=11,height=8.5,res=300)
heatmap(exprs(x.nrm), margins=c(10,17))
dev.off()

data <- ms2df(x.nrm)
#data[, cols] <- lapply(data[, cols], function(x){replace(x, x == NA,  0)})
data[is.na(data)] <- 0

imputedpath = paste(outdir, "msnbase/normalized.csv",sep='')

write.csv(data, file= imputedpath)
#write.table(data, file =imputedpath)
#write.csv(data, file= imputedpath)

#idata <- read.delim("ImputeQuarterForLog.txt", header = T, sep = "\t")

#log <- log2(idata)

#write.table(log, "All_kingdoms_imputedquarter_log2.txt", sep="\t")
quit()

