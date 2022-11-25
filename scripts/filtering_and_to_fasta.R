library(tidyverse)

dir_data <- "/run/user/1000/gvfs/sftp:host=storage-brno3-cerit.metacentrum.cz/home/agata/TR_duplications/Tracheophyta/analysis/"
dir_res <- "/run/user/1000/gvfs/sftp:host=storage-brno3-cerit.metacentrum.cz/home/agata/TR_duplications/Tracheophyta/analysis/fasta/"

setwd(dir_data)

data <- read_tsv("TRACHEOPHYTA_TRs.tsv") 

dane <- data %>% 
  filter( label == "HIT") %>% 
  mutate(align_seq = str_to_upper(align_seq),
         align_seq_new = gsub("[.]", "", align_seq)) %>% 
  select(-align_seq) %>% 
  mutate(align_seq = gsub("[-]", "", align_seq_new) ) %>% 
  select(c(1:9), align_seq, everything(), -align_seq_new, -number, -suma) %>% 
  #mutate(GCA = gsub("[.].", "", GCA)) %>%    it will not possible to run database further in BLAST pipeline
  select(-evalue, -gc, -score, -label, - X19) %>% 
  distinct() %>% 
  select(GCA, name, class, model, everything(), mdl_from)


fasta <- dane %>% 
   mutate(name = word(name, 1, 2),
          name = gsub("[ ]", "_", name),
          header = paste0(model, "_", name),
          title = paste0(GCA, "#", name)) %>% 
  select(GCA, title, header, align_seq) 


it_po <- fasta %>% 
  pull(GCA) %>% 
  unique()

library(phylotools)

setwd(dir_res)

for (org in it_po) {
  file <- fasta %>% 
    filter(GCA == org) %>% 
    select(-title, -GCA) %>% 
    rename(seq.name = header, seq.text = align_seq)
  
  title <- fasta %>% 
    filter(GCA == org) %>% 
    pull(title) %>% 
    unique()
  
  dat2fasta(file, outfile = paste0(title, ".fasta"))
} 


write_csv(dane, "output_table-filtered.csv")


write_tsv(filtered, "filtered.txt")






