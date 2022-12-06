#!/usr/bin/env Rscript
#
#
################################################################################
################################################################################
################################################################################
#
#                      transform_cmdBLAST_output
#
################################################################################
# 
################################################################################


#Author           : Agata Kilar                                                
#Email            : 242679@muni.cz  

#Lastly modified  : 6th December 2022

################################################################################
################# BEFORE RUNNING THE SCRIPT ####################################
################################################################################

# Install all required packages:
suppressMessages(require(tidyverse))
suppressMessages(require(phylotools))

# For Rscript - passing arguments from bash to R
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("Please provide the list of inputs!", call.=FALSE)
}

################################################################################
##################### SETUP VARIABLES ##########################################
################################################################################

cmdBLAST_output = args[1]
cmdBLAST_table = args[2]

cmdBLAST_output = "results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/extended/GCA_022817605.1_ASM2281760v1_genomic_bombus_extended_region.txt"
cmdBLAST_table = "results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/extended/GCA_022817605.1_ASM2281760v1_genomic_bombus_extended_region.csv"

################################################################################
#######################   MAIN    ##############################################
################################################################################

extended_genomic_region <- as_tibble(read.fasta(cmdBLAST_output)) %>%
  separate(seq.name, c("GCA", "model_number"), sep = "#") %>%
  mutate(number = str_extract(model_number, "(?<=_)[^_]*$"),
         model = sapply(strsplit(model_number, "_", fixed = TRUE),
                        function(i) paste(head(i, -1), collapse = "_")) ) %>% 
  rename(extended_genomic_region = seq.text) %>%
  select(model, GCA, number, extended_genomic_region)

write.csv(extended_genomic_region, cmdBLAST_table, row.names = FALSE)  

#
#USE_all <- USE_all %>%
#    bind_rows(USE)
  

