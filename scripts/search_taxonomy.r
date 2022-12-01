#!/usr/bin/env Rscript
#
#
################################################################################
################################################################################
################################################################################
#
#                           taxonomy_search
#
################################################################################
# The script reads the GCA id from the infernal output file and translates it to
# taxonomy information (the GCA id itself is not descriptive). To achieve that, 
# it connects the NCBI database using the "Entrez" package and constructs the 
# table row for easier manipulation in further steps.
################################################################################

                                                                                           
#Author           : Agata Kilar                                                
#Email            : 242679@muni.cz  

#Lastly modified  : 1st December 2022

################################################################################
################# BEFORE RUNNING THE SCRIPT ####################################
################################################################################

# Install all required packages:
suppressMessages(require(tidyverse))
suppressMessages(require(devtools))
suppressMessages(require(rentrez))
suppressMessages(require(openxlsx))
suppressMessages(require(rvest))


# For Rscript - passing arguments from bash to R
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("Please provide the list of inputs!", call.=FALSE)
}

################################################################################
##################### SETUP VARIABLES ##########################################
################################################################################

INPUT_DIR = args[1]
OUTPUT_DIR = args[2]



################################################################################
#######################   FUNCTIONS    #########################################
################################################################################

tax_taxid <- function(id) {
  
  test <- entrez_search(db="assembly", term=id, retmax=1)
  list <- entrez_summary(db="assembly", id=test$ids) 
  taxid <- list$taxid

  return(taxid)
}

taxonomy <- function(taxid) {
  # Takes tax_id (char) and returns 8 columns row (tibble) - Let's say almost works... ;)
  
  Tt <- entrez_search(db="taxonomy", term=paste0(taxid, "[uid]"))
  tax_rec <- entrez_fetch(db="taxonomy", id=Tt$ids, rettype="xml", parsed=TRUE)
  tax_list <- XML::xmlToList(tax_rec)
  
  ScientificName <- tax_list$Taxon$ScientificName
  tll <- tax_list$Taxon$LineageEx
  
  superkingdom = c()
  kingdom = c()
  phylum = c()
  class = c()
  order = c()
  family = c()
  genus = c()
  
  for (i in 1:length(tll)) {
    
    if(tll[[i]]$Rank == "superkingdom") { superkingdom <- tll[[i]]$ScientificName } else if(tll[[i]]$Rank == "kingdom") { kingdom <- tll[[i]]$ScientificName
    } else if(tll[[i]]$Rank == "phylum") { phylum <- tll[[i]]$ScientificName } else if(tll[[i]]$Rank == "class") { class <- tll[[i]]$ScientificName
        } else if(tll[[i]]$Rank == "order") { order <- tll[[i]]$ScientificName } else if(tll[[i]]$Rank == "family") {family <- tll[[i]]$ScientificName
          } else if(tll[[i]]$Rank == "genus") { genus <- tll[[i]]$ScientificName }
  }
  
  tax_row <- tibble(  superkingdom = ifelse(is.null(superkingdom) == T, NA, superkingdom),
                      kingdom = ifelse(is.null(kingdom) == T, NA, kingdom),
                      phylum = ifelse(is.null(phylum) == T, NA, phylum),
                      class = ifelse(is.null(class) == T, NA, class),
                      order = ifelse(is.null(order) == T, NA, order),
                      family = ifelse(is.null(family) == T, NA, family),
                      genus = ifelse(is.null(genus) == T, NA, genus),
                      ScientificName = ifelse(is.null(ScientificName) == T, NA, ScientificName),
                      GCA = ID)
  return(tax_row)
  
}

fixname <- function(ScientificName) {
  
  ScientificName <- gsub(" ", "_", ScientificName) %>% str_split_fixed("_", 3)
  ScientificName <- paste0(ScientificName[1], "_", ScientificName[2])
  
}


################################################################################
#######################   MAIN    ##############################################
################################################################################

ID <- as.vector(str_match(INPUT_DIR, "GCA_[0-9]{9}.[0-9]"))


while (length(ID) > 0) {

  tryCatch(
  
  { tax_row <- taxonomy(tax_taxid(ID)) %>% 
    mutate(ScientificName = fixname(ScientificName),
           GCA = ID)
  
  write.csv(tax_row, OUTPUT_DIR)
  
  ID = c() 
  
   },
  
  error = function(cond) { Sys.sleep(1) }
  
  )
}


