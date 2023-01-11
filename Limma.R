library(limma)
#COPY protein/samples (no meta data included) 
df<-  read.delim(pipe("pbpaste"), sep = "\t", header=TRUE, row.names = 1) 

#COPY MetaDATA 
df1<-read.delim(pipe("pbpaste"), sep = "\t", header=TRUE)
#data matrix
dataMatrix<-data.matrix(df)
###################################################
### significant DA proteins between high and low pro_infla
###################################################
design1 <- model.matrix(~df1$pro_infla+
                          as.numeric(df1$age)+
                          df1$STIs+
                          df1$PSA+
                          df1$BV
                        )
fit <- lmFit(dataMatrix, design1)
fit <- eBayes(fit)
Toplist<-(topTable(fit, coef = 2 , adjust='fdr', number=Inf))
####Save toplist to CSV
write.csv(Toplist, file="Pro_infla.csv")
