library(tidyverse)
library(phylotools)

dir_data <- "/run/user/1000/gvfs/sftp:host=storage-brno3-cerit.metacentrum.cz/home/agata/TR_duplications/Tracheophyta/analysis/BLAST/for_petr"

setwd(dir_data)

dirs <- list.dirs(path = ".", full.names = TRUE, recursive = FALSE) 
dirs <- dirs[grepl("GCA", dirs)]

missing <- vector()

for (folder in dirs) {
  
  #folder <- "./GCA_904848315.1#Hordeum_vulgare_subsp._vulgare_32"
  
  setwd(folder)
  
  GCA_name <- unlist(strsplit(folder, "#"))
  GCA <- GCA_name[1]
  GCA <- gsub("./", "", GCA)
  name <- GCA_name[2]
  
  files <- list.files( pattern = ".txt")
  
  
  
  if (length(files) == 0 ) {
    
    missing <- c(missing, GCA)
    
    setwd("../")
    
  }
  else {
  
  
  fasta <- read.fasta(files[1])

  fasta <- fasta %>% 
   as_tibble(fasta) 
  
  iter <- nrow(fasta)
  
  names <- fasta %>% 
    pull(seq.name)
  
  fasta_df <- as.data.frame(fasta)
  
  empty_df = data.frame()
  
  for (head in 1:iter) {
    
    without_name <- gsub(name, "", names[head]) 
    without_model <- gsub("_RF00024__", "", without_name)
    without_plus <- gsub("us_", "us:", without_model)
    without_identity <- gsub("identity:", "", without_plus)
    without_query <- gsub("_query_cov:", "", without_identity)
    without_strand <- gsub("strand:", "", without_query)
    
    all <- unlist(strsplit(without_strand, "_"))
    all <- all[nchar(all) > 8]
    
    
    header <- paste0(GCA, "\t", name, "\t", head, "\t", all[1], "\t", all[2])
    
    empty_df[head, 1] <- header
    empty_df[head, 2] <- fasta_df[head, 2]
  }
  
  colnames(empty_df) <- c("seq.name", "seq.text")
  
  dat2fasta(empty_df, outfile = paste0(GCA, "_", name, ".fasta"))
  
  setwd("../") 
  
  }
  
}

missing <- as.data.frame(missing)
write_delim(missing, "missing.txt")





