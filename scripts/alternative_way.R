#####################################################################################################################################
###################### H Y M E N O P T E R A   ######################################################################################                        
#####################################################################################################################################

library(tidyverse)

setwd("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/home/agata/infernal_insects/results/220817_optimisation/")


table <- read_csv("220817_output_table_formiceidea2.csv")


extract_length = 200

filtered_table <- table %>% 
  filter(!(is.na(align_seq))) %>%
  mutate(sstart = seq_from, 
         send = seq_to) %>%   
  select(-gc, -score, -suma, -mdl_from, -model_seq, -seq_from, -seq_to) %>% 
  mutate(strand = ifelse(sstart < send, "plus", "minus")) %>% 
  mutate(new_sstart = ifelse(strand == "plus", sstart-extract_length, sstart+extract_length)) %>% 
  mutate(new_send = ifelse(strand == "plus", send+extract_length, send-extract_length)) %>% 
  mutate(new_sstart = ifelse(new_sstart < 0, 1, new_sstart)) %>%
  mutate(new_send = ifelse(new_send < 0, 1, new_send)) %>%
  mutate(range = ifelse(strand == 'plus', paste0(new_sstart, "-", new_send), paste0(new_send, "-", new_sstart)) )


as_filtered <- filtered_table %>% 
  rename(n_header = GCA) %>% 
  mutate(header = paste0(n_header,"#", model)) %>% 
  select(header, n_header, number, ID, number, number, strand, range)


################################################################################


BLAST <- "/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/home/agata/infernal_insects/BLAST/BLAST_220817_optimisation/"

setwd(BLAST)

loop <- as_filtered %>% 
  pull(n_header) %>%
  unique()

#dirs <- list.dirs(path = ".", recursive = FALSE)

#to_add <- c()


for (GCA in loop) {
  
  setwd(BLAST)
  
  ### Create the directory
  dir.create(paste0("./", GCA))
  
  
  ### Filter the separate results for given GCA
  temp <- as_filtered %>% 
    filter(n_header == GCA) %>% 
    select(-n_header)
  
  #  if (length(dir) > 0) {
  
  setwd(GCA)
  
  ### Save results
  write_tsv(temp, "filtered.txt", col_names = FALSE)
  

}

setwd(BLAST)

#to_add <- as.data.frame(to_add)
#write_tsv(to_add, "to_add.txt")

loop <- as.data.frame(loop)
write_tsv(loop, "all_GCA.txt")


##################################################################################################
#           RUN 01_BLAST_ALTERNATIVE

#           RUN 03_BLAST_CMD_ALTERNATIVE

##################################################################################################
################ READ IT BACK TO THE TABLE #######################################################
##################################################################################################
library(phylotools)

USE_all <- tibble()

setwd(BLAST)

loop <- loop %>% 
  pull()

for (j in loop) {
  
  setwd(BLAST)
  
  ## Do only if GCA is within already existing directories
  #dir <- dirs[grepl(loop[i], dirs)]
  
  #if (length(dir) > 0) {
  
  setwd(j)
  
  USE <- as_tibble(read.fasta(paste0(j, "_ext.txt"))) %>%
    #rowwise() %>%
    separate(seq.name, c("blank", "GCA1", "GCA2", "number"), sep = "_") %>%
    mutate(GCA = paste0(GCA1, "_", GCA2)) %>%
    rename(USE = seq.text) %>%
    separate(GCA, c("GCA", "model"), sep = "#") %>% 
    select(model, GCA, number, USE)
  
  USE_all <- USE_all %>%
    bind_rows(USE)
  
  last <- j
  
  #}
  
}

setwd(BLAST)


USE_all <- USE_all %>%
  mutate(number = as.numeric(number))

final_table <- filtered_table %>%
  left_join(USE_all, by = c("GCA", "number", "model")) %>%
  rename(infernal_seq = align_seq,
         name = ScientificName) %>% 
  select(model, GCA, name, family, evalue, USE, infernal_seq, sec_struct, ID, range, phylum, class, order)



write_csv(final_table, "220819_USE_table_Hymenoptera_representative_formi2.csv")


################################################################################
################################################################################
################################################################################
setwd(BLAST)


setwd("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/home/agata/infernal_insects/results/130422_sprintrun/")
table <- read_csv("output_table.csv") %>% 
  filter(label == "HIT")

#master_table <- read_csv("output_table.csv") %>% 
#  filter(label == "HIT")

USE_table <- read_csv("USE_table.csv")

new_table <- USE_table %>%
  left_join(master_table, by = c("GCA", "number", "name", "ID", "sec_struct")) %>%
  select(GCA, number, name, USE, sec_struct, align_seq, evalue, ID, range) %>% 
  rename(infernal_seq = align_seq)

##############################


new_table <- final_table %>%
  left_join(table, by = c("GCA", "number", "name", "ID", "sec_struct")) %>%
  select(GCA, number, name, USE, sec_struct, align_seq, evalue, ID, range) %>% 
  rename(infernal_seq = align_seq)



write_csv(new_table, "../USE_table_new.csv")
