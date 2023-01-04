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

################################################################################
#######################   MAIN    ##############################################
################################################################################

extended_genomic_region <- as_tibble(read.fasta(cmdBLAST_output)) %>%
  separate(seq.name, c("GCA", "model_number"), sep = "#") %>%
  mutate(number = str_extract(model_number, "(?<=_)[^_]*$"),
         label = "HIT",
         model = sapply(strsplit(model_number, "_", fixed = TRUE),
                        function(i) paste(head(i, -1), collapse = "_")) ) %>% 
  rename(extended_genomic_region = seq.text) %>%
  select(model, GCA, number, label, extended_genomic_region)

write.csv(extended_genomic_region, cmdBLAST_table, row.names = FALSE)  
  

