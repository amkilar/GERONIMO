#!/usr/bin/env Rscript
#
#
################################################################################
################################################################################
################################################################################
#
#                       create_input_for_cmdBLAST
#
################################################################################

################################################################################


#Author           : Agata Kilar                                                
#Email            : 242679@muni.cz  

#Lastly modified  : 5th December 2022

################################################################################
################# BEFORE RUNNING THE SCRIPT ####################################
################################################################################

# Install all required packages:
suppressMessages(require(tidyverse))

# For Rscript - passing arguments from bash to R
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("Please provide the list of inputs!", call.=FALSE)
}

################################################################################
##################### SETUP VARIABLES ##########################################
################################################################################

INFERNAL_RESULT = args[1]
extract_length = as.numeric(args[2])
OUTPUT <- args[3]

#INFERNAL_RESULT = "results/infernal/bombus/GCA_022817605.1_ASM2281760v1_genomic.csv"
#extract_length = 200
#OUTPUT <- "results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/GCA_022817605.1_ASM2281760v1_genomic_filtered.txt"

################################################################################
#######################   FILTERING    #########################################
################################################################################

filtered_table <- suppressWarnings(read_csv(INFERNAL_RESULT, show_col_types = FALSE)) %>% 
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

GCA <- filtered_table %>% pull(GCA) %>% unique()

as_filtered <- filtered_table %>% 
  rename(n_header = GCA) %>% 
  mutate(header = paste0(n_header,"#", model)) %>% 
  select(header, n_header, number, ID, number, number, strand, range) %>% 
  select(-n_header)


### Save results
write_tsv(as_filtered, OUTPUT, col_names = FALSE)
  


