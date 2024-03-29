library('gage')
library('limma')
library('pathview')
library('optparse')

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("pathview")

print("Starting gene set enrichment")
option_list = list(
  make_option(c("-o", "--outdir"),
              type="character",
              default=NULL,
              help="Directory containing MQ proteogenomics pipeline output files",
              metavar="character"),
  make_option(c("-i", "--indir"),
              type="character",
              default=NULL,
              help="Directory containing geneset annotations",
              metavar="character"),
  make_option(c("-k", "--keggid"),
              type="character",
              default=NULL,
              help="Directory containing MQ proteogenomics pipeline output files",
              metavar="character"),
  make_option(c("-d", "--design"),
              type="character",
              default=NULL,
              help="Experimental design",
              metavar="character"),
  make_option(c("-t", "--table"),
              type="character",
              default=NULL,
              help="Table with intensities",
              metavar="character"),
  make_option(c("-g", "--genecol"),
              type="character",
              default=NULL,
              help="Table with intensities",
              metavar="character"),
  make_option(c("-ko", "--kocol"),
              type="character",
              default="Leading.Protein.Kegg.Orthology.ID",
              help="Table with intensities",
              metavar="character"),
  make_option(c("-p", "--pval"),
              type="double",
              default=0.05,
              help="P value cutoff",
              metavar="double")
)
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

inpath = opt$indir
path = opt$outdir
species = opt$keggid
genecol = opt$genecol
pval = opt$pval
kocol =opt$kocol
table_path <- opt$table

# GENE SETS 
bp <- 'false'
bp_path <- paste(inpath,'/bpset.Rdata',sep='')
if(file.exists(bp_path)){
  load(bp_path)
  bp <- 'true'
}

mf <- 'false'
mf_path <- paste(inpath,'/mfset.Rdata',sep='')
if(file.exists(mf_path)){
  load(mf_path)
  mf <- 'true'
}
cc <- 'false'
cc_path <- paste(inpath,'/ccset.Rdata',sep='')
if(file.exists(cc_path)){
  load(cc_path)
  cc <- 'true'
}
kegg <- 'false'
kegg_path <- paste(inpath,'/keggset.Rdata',sep='')
if(file.exists(kegg_path)){
  load(kegg_path)
  kegg <- 'true'
}
ec <- 'false'
ec_path <- paste(inpath,'/ecset.Rdata',sep='')
if(file.exists(ec_path)){
  load(ec_path)
  ec <- 'true'
}
operon <-'false'
operon_path <- paste(inpath,'/operonset.Rdata',sep='')
if(file.exists(operon_path)){
  load(operon_path)
  operon <- 'true'
}

ipr <- 'false'
ipr_path <- paste(inpath,'/iprset.Rdata',sep='')
if(file.exists(ipr_path)){
  load(ipr_path)
  ipr <- 'true'
}

metacyc <- 'false'
metacyc_path <- paste(inpath,'/metacycset.Rdata',sep='')
if(file.exists(metacyc_path)){
  load(metacyc_path)
  metacyc <- 'true'
}

reactome <- 'false'
reactome_path <- paste(inpath,'/reactomeset.Rdata',sep='')
if(file.exists(reactome_path)){
  load(reactome_path)
  reactome <- 'true'
}

infile <- basename("Desktop/GO_IDS_UNIPROT_GALAXY_DIFF_ABUNDANCE.csv")

table <- read.csv("Desktop/GO_IDS_UNIPROT_GALAXY_DIFF_ABUNDANCE.csv", header = TRUE)
print(head(table))
print(table$Row.names)
row.names(table) <- table$Row.names
#quit()

table[, cols] <- lapply(table[, cols], function(x){replace(x, x == 0,  NA)})
table[, cols] <- lapply(table[, cols], function(x){ log2(x)})


# GI table
gi_table <- cbind(table)
#ids <-  as.character(gi_table$Identifier)
#genecol <- as.character(gi_table[,genecol])
#gi_table <- gi_table[,cols]
#print(length(ids))
#print(length(row.names(gi_table)))
#row.names(gi_table) <- ids
#gi_table
#print(head(gi_table))
#quit()

s <- strsplit(as.character(gi_table[,genecol]), split = ";")
newtable <- data.frame( Identifier = rep(gi_table$Identifier, sapply(s, length)), gi = unlist(s))
refdata <- merge( table, newtable, by="Identifier", all.y = TRUE)
refdata <- refdata[!duplicated(refdata$gi), ]
ref <- refdata$gi
refdata <- refdata[,cols]
print('refcols')
#row.names(refdata) <-ref
.rowNamesDF(refdata, make.names=TRUE) <- ref

ko_s <- strsplit(as.character(gi_table[,kocol]), split = ";")
ko_newtable <- data.frame( Identifier = rep(gi_table$Identifier, sapply(ko_s, length)), gi = unlist(ko_s))
kodata <- merge( table, ko_newtable, by="Identifier", all.y = TRUE)
kodata <- kodata[!duplicated(kodata$gi), ]
ko <- kodata$gi
kodata <- kodata[,cols]
print('kocols')
.rowNamesDF(kodata, make.names=TRUE) <- ko


#print(head((refdata))

#print(rownames(refdata))

ids <- table$Identifier

table <- table[,cols]

print('idcols')
row.names(table) <- ids


#outpath <-paste(path,'/gsea/comparisons',sep='')
#dir.create(outpath, showWarnings = FALSE)

analyse <- function(data, gset, refcols, sampcols, samedir) {
  cnts.p <- gage(data, gsets = gset, ref = refcols, samp = sampcols, compare ="unpaired", same.dir= samedir) # used to be unpaired 
  return(cnts.p)
}

cutoff <- pval
print(cutoff)

current_wd = getwd()

less <- function(res, samp, ref) {
  less <- as.data.frame(res$less)
  #less <- less[!is.na(less$`p.val`),]
  less$Exposed <- samp
  less$Control <- ref
  less$RowName <- as.character(row.names(less))
  less$Coregulated <- "Down"
  if (length(row.names(less)) > 0) {
    less <- less[less$`p.val` < cutoff, ]
  }
  less <- less[!is.na(less$`p.val`),]
  #print(head(less))
  return(less)
}

greater <- function(res, samp, ref) {
  greater <- as.data.frame(res$greater)
  greater$RowName <- as.character(row.names(greater))
  greater$Exposed <- samp
  greater$Control <- ref
  greater$Coregulated <- "Up"
  if (length(row.names(greater)) > 0) {
    greater <- greater[greater$`p.val` < cutoff, ]
  }
  greater <- greater[!is.na(greater$`p.val`),]
  #print(head(greater))
  return(greater)
}

both <- function(res, samp, ref) {
  both <- as.data.frame(res$greater)
  #_ <- as.data.frame(res$less)
  both$RowName <- as.character(row.names(both))
  both$Exposed <- samp
  both$Control <- ref
  both$Coregulated <- "Both"
  print(both)
  if (length(row.names(both)) > 0) {
    print(cutoff)
    both <- both[both$`p.val` < cutoff, ]
    print(head(both)) 
  }
  both <- both[!is.na(both$`p.val`),]
  #print(head(greater))
  return(both)
}

process <- function(table , refcols, sampcols, outpath, refdata, samp, ref) {
  # IPR
  print("IPR")
  dir.create(outpath, showWarnings = FALSE)
  print(outpath)
  setwd(outpath)
  #operon_table <- table[row.names(table) %in% operon.set,]
  res <- analyse(table, ipr.set, refcols, sampcols, TRUE)
  gt <- greater(res, samp, ref)
  if (length(row.names(gt)) > 0) {
    gt$SameDir <- "True"
    write.csv(gt, paste('IPR.up.', infile, sep=''))
  }
  ls <- less(res, samp, ref)
  if (length(row.names(ls)) > 0) {
    ls$SameDir <- "True"
    write.csv(ls, paste('IPR.down.', infile, sep=''))
  }
  
  # EC
  print("EC")
  #operon_table <- table[row.names(table) %in% operon.set,]
  res <- analyse(table, ec.set, refcols, sampcols, TRUE)
  gt <- greater(res, samp, ref)
  if (length(row.names(gt)) > 0) {
    gt$SameDir <- "True"
    write.csv(gt, paste('EC.up.', infile,sep=''))
  }
  ls <- less(res, samp, ref)
  if (length(row.names(ls)) > 0) {
    ls$SameDir <- "True"
    write.csv(ls,paste('EC.down.', infile, sep=''))
  }
  
  
  #res <- analyse(table, ipr.set, refcols, sampcols, FALSE)
  #gt <- greater(res, samp, ref)
  #if (length(row.names(gt)) > 0) {
  #  gt$SameDir <- "False"
  #  write.csv(gt, paste(outpath, '/IPR.up.both.csv', sep=''))
  #}
  #ls <- less(res, samp, ref)
  #if (length(row.names(ls)) > 0) {
  #  ls$SameDir <- "False"
  #  write.csv(ls, paste(outpath, '/IPR.down.both.csv',sep=''))
  #}
  
  print("KEGG")
  ref.d <- refdata[, sampcols]-rowMeans(refdata[, refcols, drop=FALSE])
  ko.d <- kodata[, sampcols]-rowMeans(kodata[, refcols, drop=FALSE])
  
  res <- analyse(table, kegg.set, refcols, sampcols, TRUE)
  ls <- less(res, samp, ref)
  if (length(row.names(ls)) > 0) {
    ls$SameDir <- "True"
    ls$RowName = paste(species, ls$RowName,sep = "")
    write.csv(ls, paste('KEGG.down.', infile, sep=''))
    less_ids <- row.names(ls) 
    try(pv.out.list <- sapply(less_ids, function(pid) pathview(gene.data = ref.d, kegg.native = T, out.suffix = infile, same.layer = F, pathway.id = paste(species, pid, sep=''), species = species)))
    try(pv.out.list <- sapply(less_ids, function(pid) pathview(gene.data = ko.d, kegg.native = T, out.suffix = infile, same.layer = F, pathway.id = paste('ko', pid, sep=''), species = 'ko')))
  }
  
  gt <- greater(res, samp, ref)
  if (length(row.names(gt)) > 0) {
    gt$SameDir <- "True"
    gt$RowName = paste(species, gt$RowName,sep = "")
    write.csv(gt, paste('KEGG.up.', infile, sep=''))
    greater_ids <- row.names(gt)
    try(pv.out.list <- sapply(greater_ids, function(pid) pathview(gene.data = ref.d, kegg.native = T, out.suffix = infile, same.layer = F, pathway.id = paste(species, pid, sep=''), species = species)))
    try(pv.out.list <- sapply(greater_ids, function(pid) pathview(gene.data = ko.d, kegg.native = T, out.suffix = infile, same.layer = F, pathway.id = paste('ko', pid, sep=''), species = 'ko')))
  }
  
  res <- analyse(table, kegg.set, refcols, sampcols, FALSE)
  #print(summary(res))
  bt <- both(res, samp, ref)
  if (length(row.names(bt)) > 0) {
    bt$SameDir <- "False"
    bt$RowName = paste(species, bt$RowName,sep = "")
    write.csv(bt, paste('KEGG.both.', infile,sep= ''))
    both_ids <- row.names(bt)
    try(pv.out.list <- sapply(both_ids, function(pid) pathview(gene.data = ref.d, kegg.native = T, out.suffix = infile, same.layer = F, pathway.id = paste(species, pid, sep=''), species = species)))
    try(pv.out.list <- sapply(both_ids, function(pid) pathview(gene.data = ko.d, kegg.native = T, out.suffix = infile, same.layer = F, pathway.id = paste('ko', pid, sep=''), species = 'ko')))
  } 
  
  # BP
  print("BP")
  res <- analyse(table, bp.set, refcols, sampcols, TRUE)
  gt <- greater(res, samp, ref)
  if (length(row.names(gt)) > 0) {
    gt$SameDir <- "True"
    write.csv(gt,paste('BP.up.',infile, sep=''))
  }
  ls <- less(res, samp, ref)
  if (length(row.names(ls)) > 0) {
    ls$SameDir <- "True"
    write.csv(ls, paste('BP.down.', infile, sep=''))
  }
  
  # MF
  print("MF")
  res <- analyse(table, mf.set, refcols, sampcols, TRUE)
  gt <- greater(res, samp, ref)
  if (length(row.names(gt)) > 0) {
    gt$SameDir <- "True"
    write.csv(gt, paste( 'MF.up.', infile, sep=''))
  }
  ls <- less(res, samp, ref)
  if (length(row.names(ls)) > 0) {
    ls$SameDir <- "True"
    write.csv(ls, paste( 'MF.down.', infile,sep= ''))
  }
  
  # CC
  print("CC")
  res <- analyse(table, cc.set, refcols, sampcols, TRUE)
  gt <- greater(res, samp, ref)
  if (length(row.names(gt)) > 0) {
    gt$SameDir <- "True"
    write.csv(gt, paste('CC.up.', infile, sep=''))
  }
  ls <- less(res, samp, ref)
  if (length(row.names(ls)) > 0) {
    ls$SameDir <- "True"
    write.csv(ls, paste('CC.down.',infile,sep= ''))
  }
  
  # OPERONS
  if (operon == 'true') {
    print("OPERONS")
    #operon_table <- table[row.names(table) %in% operon.set,]
    res <- analyse(table, operon.set, refcols, sampcols, TRUE)
    gt <- greater(res, samp, ref)
    if (length(row.names(gt)) > 0) {
      gt$SameDir <- "True"
      write.csv(gt, paste('OPERON.up.',infile, sep=''))
    }
    ls <- less(res, samp, ref)
    if (length(row.names(ls)) > 0) {
      ls$SameDir <- "True"
      write.csv(ls, paste('OPERON.down.', infile, sep=''))
    }}
  # RECTOME
  if (reactome == 'true') {
    print("REACTOME")
    res <- analyse(table, reactome.set, refcols, sampcols, TRUE)
    gt <- greater(res, samp, ref)
    if (length(row.names(gt)) > 0) {
      gt$SameDir <- "True"
      write.csv(gt, paste('REACTOME.up.', infile,sep= ''))
    }
    ls <- less(res, samp, ref)
    if (length(row.names(ls)) > 0) {
      ls$SameDir <- "True"
      write.csv(ls,paste( 'REACTOME.down.', infile , sep=''))
    }}
  # METACYC
  if (metacyc == 'true') {
    print("METACYC")
    res <- analyse(table, metacyc.set, refcols, sampcols, TRUE)
    gt <- greater(res, samp, ref)
    if (length(row.names(gt)) > 0) {
      gt$SameDir <- "True"
      write.csv(gt, paste( 'METACYC.up.', infile, sep=''))
    }
    ls <- less(res, samp, ref)
    if (length(row.names(ls)) > 0) {
      ls$SameDir <- "True"
      write.csv(ls, paste('METACYC.down.', infile, sep=''))
    }}
}

# Samples 
cols <- cols # Defined in experimental design template
f <- f # Defined in experimental design template
refmap <- data.frame(f, cols)
comparisons <- colnames(contrast.matrix)

for ( comp in comparisons){
  print(comp)
  setwd(current_wd)
  vals <- strsplit(comp,'-')
  # Get the reference cols
  ref  = as.character(vals[[1]][2])
  refdf <- refmap[refmap$f==ref,]
  #refcols <- as.character(refdf$cols)
  refcols <- as.numeric(rownames(refdf))
  
  # Get the sample cols
  samp = as.character(vals[[1]][1])
  sampdf <- refmap[refmap$f==samp,]
  sampcols <- as.numeric(rownames(sampdf))
  
  outpath <-paste( path, '/', samp, '_', ref ,sep='' ) 
  process(table, refcols, sampcols, outpath, refdata, samp, ref) }
