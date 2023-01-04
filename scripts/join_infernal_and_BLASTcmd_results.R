#!/usr/bin/env Rscript
#
#
################################################################################
################################################################################
################################################################################
#
#                  join_infernal_and_BLASTcmd_results
#
################################################################################
# The script joins outputs coming from infernal search and searching for extended
# genomic region (BLASTcmd). In case the second file is empty the empty column is
# added to join all results at the end into one table.
################################################################################


#Author           : Agata Kilar                                                
#Email            : 242679@muni.cz  

#Lastly modified  : 6th December 2022

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

INFERNAL_part = args[1]
BLASTcmd_part = args[2]
PART_TABLE = args[3]

################################################################################
#######################   MAIN    ##############################################
################################################################################


if (file.size(BLASTcmd_part) == 0L) {
  
  table_temp <- read_csv(INFERNAL_part, show_col_types = FALSE) %>%
    mutate(extended_genomic_region = "NA")
  
} else {
  
  table_temp <- read_csv(INFERNAL_part, show_col_types = FALSE) %>%
    left_join(read_csv(BLASTcmd_part, show_col_types = FALSE), by = c("GCA", "number", "model", "label"))
    
}
 
table <- table_temp %>% 
  rename(infernal_seq = align_seq) %>% 
  rename(name = ScientificName) %>% 
  select(model, GCA, name, family, label, number, evalue, extended_genomic_region, infernal_seq, sec_struct, ID, phylum, class, order)

write_csv(table, PART_TABLE, col_names = FALSE)

















