library(bnlearn)

my_data <- read.delim("fungivsclinvar.txt", row.names = 1, header = TRUE)
#bn_df <- t(my_data)
bn_df1 <- as.data.frame(my_data)
bn_df1 <- transform(bn_df1, HC = as.numeric(HC), 
                    Cytokines = as.numeric(Cytokines), Nugent.Score = as.numeric(Nugent.Score))
str(bn_df1)
res <- hc(bn_df1)
plot(res)
res$arcs <- res$arcs[-which((res$arcs[,'from'] == "M..Work" & res$arcs[,'to'] == "Family")),]
