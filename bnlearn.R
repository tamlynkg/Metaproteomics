install.packages("bnlearn")
library(bnlearn)
if (!requireNamespace("BiocManager", quietly = TRUE))
 install.packages("BiocManager")
BiocManager::install()
BiocManager::install(c("graph", "Rgraphviz"))
nlibrary(Rgraphviz)

my_data <- read.delim("", row.names = 1, header = TRUE) 
bn_df <- t(my_data) bn_df <- as.data.frame(bn_df)
 
dag = hc(bn_df)
fitted = bn.fit(dag, data = bn_df)
graphviz.plot(dag, shape = "ellipse")

str(bn_df)
res <- hc(bn_df)
plot(res)
 
