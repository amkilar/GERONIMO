#!/usr/bin/env Rscript
#
#
################################################################################
################################################################################
################################################################################
#
#                         read_results_infernal
#
################################################################################
# The script reads the raw infernal output files and translates them to
# summary table. The files reading bases on the space number specified by Infernal 
# developers and mine experience. In the summary table you can find information 
# regarding the number of significant hits, possible hit or no hits found by Infernal
# in a particular genome. Possible significant hits are extracted from the alignment
# file and present in the summary table. At the end the taxonomy information is added.
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

FILE = args[1]
TAXONOMY <- args[2]
OUTPUT <- args[3]
# what about manual?


#FILE = "results/raw_infernal/bombus/GCA_022817605.1_ASM2281760v1_genomic/result_bombus_vs_GCA_022817605.1_ASM2281760v1_genomic.csv"
#TAXONOMY <- "taxonomy/GCA_022817605.1_ASM2281760v1_genomic.taxonomy.row.csv"
#OUTPUT <- "results/infernal/bombus/GCA_022817605.1_ASM2281760v1_genomic.csv"

################################################################################
#######################   FUNCTIONS    #########################################
################################################################################

extract_basics <- function(row) {
  
  ### Function is receiving a row of data and extracting columns: "ID", gc", "score", "evalue", "inc", "model", "GCA"
  dane <- row %>%                                                         
    select(ID, gc, score, evalue, inc, mdl_from, mdl_to, strand, seq_from, seq_to) %>%
    mutate(model = model, GCA = GCA)  %>%
    mutate(number = seq(1:nrow(row)), 
           suma = rep(nrow(row), nrow(row)))
  
  inc <- pull(dane, var = inc) 
  
  ### create if that will give the right label
  
  label <- c()
  for (elem in inc) {
    
    if ( is.na(elem) == TRUE ) {
      label <- "NO HIT"
    } else if ( ( elem == "?" ) == TRUE ) {
      label <- "MAYBE" 
    } else if ( ( elem == "!" ) == TRUE ) {
      label <- "HIT" 
    }
    
  }
  
  dane <- mutate(dane, label = label)
  
  return(dane)
}

add_alignment <- function() {
  
  
  width_len = determine_widith(align_name)
  
  
  ### Loading alignment file
  align = suppressWarnings(read_fwf(align_name, 
                                    fwf_cols( ID = width_len[[1]],                                 
                                              alignment = width_len[[2]]),
                                    skip_empty_rows = TRUE,
                                    skip = ile_hit,
                                    show_col_types = FALSE) )
  
  ### Tibble with aligments and scores 
  alignment <- align %>% 
    drop_na() %>% 
    filter(!grepl('#=GC', ID) & !grepl('//', ID) & !grepl('#=GS', ID)) %>% 
    mutate( test = ifelse( str_detect(ID, "#=GR") == TRUE, "align_score", "align_seq") ) %>% 
    mutate(ID = gsub("#=GR ", "", ID ) ) %>%   ### remove matching pattern
    mutate(ID = gsub(' [A-z ]*', '', ID)) %>%  ### remove everything after a space
    pivot_wider(names_from = test, values_from = alignment) %>% 
    mutate( ID = gsub('/.*', '', ID),          ### remove everything after a /
            number = seq(1:nrow(row)) )    
  
  scores_sec_str <- align %>% 
    filter(grepl('#=GC', ID) & !grepl('//', ID) ) %>% 
    pivot_wider(names_from = ID, values_from = alignment) %>% 
    rename('model_seq' = '#=GC RF', 'sec_struct' = '#=GC SS_cons') %>% 
    slice(rep(1:n(), each=ile_hit))
  
  
  alignment$model_seq <- scores_sec_str$model_seq
  alignment$sec_struct  <- scores_sec_str$sec_struct
  
  return(alignment)
  
}

ordering <- function(final_row) {
  
  ### Ordering columns in the same order 
  final_row <- final_row %>%
    select(model, GCA, gc, score, evalue, label, number, suma, mdl_from, ID, seq_from, seq_to, align_seq, model_seq, sec_struct )
  
  return(final_row)
}

add_blank <- function(final_row) {
  final_row <- final_row %>%
    mutate(model_seq = NA, sec_struct = NA, align_score = NA, align_seq = NA,
           mdl_from = NA, mdl_to = NA)
  
  return(final_row)
}

read_input <- function(file) {
  
  
  column_pattern = suppressWarnings(read_csv(file, show_col_types = FALSE)) %>% 
    slice(1) %>% 
    pull()
  
  
  column_pattern <- gsub('#', '', column_pattern) 
  
  column_pattern <- strsplit(column_pattern, " ")
  
  column_pattern <- unlist(column_pattern)
  
  column_pattern <- lapply(column_pattern, nchar)
  
  cp <- unlist(column_pattern)
  
  
  input_file = suppressWarnings(read_fwf(file, 
                                         fwf_cols( "ID" = cp[1]+1,
                                                   "accession" = cp[2]+1,
                                                   "query_name" = cp[3]+1,
                                                   "accession2" = cp[4]+1,
                                                   "mdl" = cp[5]+1,
                                                   "mdl_from" = cp[6]+1,
                                                   "mdl_to" = cp[7]+1,
                                                   "seq_from" = cp[8]+1,
                                                   "seq_to" = cp[9]+1,
                                                   "strand" = cp[10]+1,
                                                   "trunc" = cp[11]+1,
                                                   "pass" = cp[12]+1,
                                                   "gc" = cp[13]+1,
                                                   "bias" = cp[14]+1,
                                                   "score" = cp[15]+1,
                                                   "evalue" = cp[16]+1,
                                                   "inc" = cp[17]+1,
                                                   "descr" = cp[18]+1),
                                         col_types = cols(
                                           "ID" = col_character(),
                                           "accession" = col_character(),
                                           "query_name" = col_character(),
                                           "accession2" = col_character(),
                                           "mdl" = col_character(),
                                           "mdl_from" = col_integer(),
                                           "mdl_to" = col_integer(),
                                           "seq_from" = col_integer(),
                                           "seq_to" = col_integer(),
                                           "strand" = col_character(),
                                           "trunc" = col_character(),
                                           "pass" = col_integer(),
                                           "gc" = col_double(),
                                           "bias" = col_double(),
                                           "score" = col_double(),
                                           "evalue" = col_double(),
                                           "inc" = col_character(),
                                           "descr" = col_character()), skip = 2))
  
  return(input_file)
}

determine_widith <- function(align_name) {
  con = file(align_name, "r")
  width_of_column = 0
  len = 0
  
  while ( TRUE ) {
    line = readLines(con, n = 1)
    line
    
    ### Check whether pattern is present in current line, if yes, read its positions and check whether the value is bigger than previosly read
    if ( str_detect(line, " PP ") == TRUE ) {
      positions = str_locate(line, " PP ")
      
      if ( ( last(positions) > width_of_column ) == TRUE ) {
        width_of_column = last(positions)
      } 
    } 
    
    #Alternative finding the length of line
    if ( grepl("^[[:alpha:]]", line) == TRUE ) {
      
      fraza <- line %>%
        strsplit(" ") %>%
        unlist() 
      
      width <- str_length(fraza[1]) + length(fraza[-c(1,length(fraza))])+1
      
    }
    
    
    ### Check the length of the longest line
    if ( ( str_length(line) > len ) == TRUE ) {
      len  = str_length(line)
    }
    
    ### When detect the end of the file (from pattern) - break the loop)
    if ( startsWith(line, "//")  == TRUE ) {
      break
    }
    
  }
  
  close(con)
  
  if ( width_of_column == 0 ) {
    
    width_of_column <- width
    
  }
  
  width_len = list(width_of_column, len)
  
  return( width_len )
}

################################################################################
##############################   MAIN    #######################################
################################################################################

file <- FILE

############################   VARIABLES   #####################################
tabela <- tribble()   ### define the main output of the script (big table)
manualnie <- vector()
temp_tibble <- tribble()

test <- tribble()
entry <- tribble()
files_to_copy <- vector()
EXIT <- FALSE

########################### INFERNAL READING  ##################################
    

    ### Extracting GCA and model from name of the current file
    file_name <- unlist(strsplit(file, "/")) %>% tail(1) 
    model <- paste0("cov_model_", unlist(strsplit(file_name, "_"))[[2]])
    GCA <- paste0("GCA_", unlist(strsplit(file_name, "_"))[[5]])
      
    name = str_remove(file, ".csv")
    align_name = paste0(name, "-alignment")

    
    ############################  LOADING result_MODEL_vs_GCA.csv FILE ############################  
    
    empty_csv <- suppressWarnings(read_csv(file, show_col_types = FALSE)) %>% nrow()
    
    if (empty_csv > 0) {
      
      input_file = suppressWarnings(read_input(file))
      
      ########################  CHECK WHETHER ANY ALIGNMENT IN THE FILE & CHOOSE STRATEGY  ######################## 
      ### Check whether present significant hits ("!")
      entry <- input_file %>%
        pull(var = inc) 
      
      
      ### Condition when more than 1 HIT
      if ( "!" %in% entry ) {
        
        
        ### Preparing row for HIT output; as result row contains: "gc", "score", "evalue", "in c", "model_seq", "sec_struct", "align_score", "align_seq", "model", "GCA", "label" - filled with values   
        row <- filter(input_file, inc == "!" )
        
        ### Determining how with number of hits that dealing with
        ile_hit = nrow(row)
        
        ### Extracting important columns
        dane <- extract_basics(row)
        
        ## Adding alignment
        tryCatch(
          {
            ### Try part
            alignment <<- add_alignment()
          },
          error = function(cond) {
            
            manualnie <<- append(manualnie, file)
            
            ### Copying files .csv and -alignment to folder manual_fill
            files_to_copy <- c(file, paste0(name, "-alignment"))
            file.copy(files_to_copy, manual_fill)
            
            EXIT <<- TRUE
          } ) 
        
        if ( EXIT == FALSE ) {
          
          ############################ JOINING TOGETHER DATA AND ALIGNMENT ############################
          
          
          ### Merging together
          final_row_exl <- dane %>%
            left_join(alignment, by = c("ID", "number"), copy = FALSE) 
          
          ### Ordering
          final_row_exl <- ordering(final_row_exl)
          
          ### Joining temp_tibble across the conditions
          temp_tibble <- temp_tibble %>% 
            bind_rows(final_row_exl)
          
          ### Cleaning variables
          row <- tibble()
          final_row <- tibble()
          
        }
      } 
      
      ########################  PREPARE ROW FOR MAYBE DATA & CREATE EMPTY COLUMNS FOR ALIGNMENT  ########################  
      
      if ( "?" %in% entry ) {
        
        row <- filter(input_file, inc == "?" )
        
        ### Extracting important columns
        final_row <- extract_basics(row)
        
        ### Adding blank columns for alingnemt
        final_row <- add_blank(final_row) 
        
        ### Ordering
        final_row_que <- ordering(final_row)
        
        ### Joining temp_tibble across the conditions
        temp_tibble <- temp_tibble %>%
          bind_rows(final_row_que)
        
        ### Cleaning variables
        row <- tibble()
        final_row <- tibble()
        
      } 
      
      ########################  PREPARE ROW FOR NO HIT DATA & CREATE EMPTY COLUMNS FOR ALIGNMENT  ########################  
      ### Preparing row for NO HIT output; as result row contains: "gc", "score", "evalue", "inc", "model_seq", "sec_struct", "align_score", "align_seq" - filled with NA, "model", "GCA", "label" - filled with values
      
      ### When entry vector do not contain "!" neither "?"
      if  ( !( "!" %in% entry | "?" %in% entry ) == TRUE ) { 
      
        
        ### Fill the row with NA and mutate for model and GCA
        row <- input_file %>% 
          filter(row_number() == 1L)
        
        ### Extracting important columns
        dane <- extract_basics(row)
        
        ### Adding blank columns for alingnemt
        final_row <- add_blank(dane) %>% 
          mutate(ID = NA)
        
        ### Ordering
        final_row_no <- ordering(final_row)
        
        ### Joining temp_tibble across the conditions
        temp_tibble <- temp_tibble %>%
          bind_rows(final_row_no)
        
        ### Cleaning variables
        row <- tibble()
        final_row <- tibble()
        
      } 
      
      
      ############################ EXTENDIin  NG TABLE WITH final_row FROM INPUT FILES  ############################
      
      if ("MAYBE" %in% temp_tibble$label) {    
        
        if ("HIT" %in% temp_tibble$label) {
          # when MAYBE & HIT
          test <- temp_tibble %>%
            add_row(model = model, GCA = GCA, label = "NO HIT", number = 0, suma = 0, .before = 1) 
        } else {
          # when MAYBE
          test <- temp_tibble %>%
            add_row(model = model, GCA = GCA, label = "NO HIT", number = 0, suma = 0, .before = 1)  %>% 
            add_row(model = model, GCA = GCA, label = "HIT", number = 0, suma = 0, .before = 1)
        }
        
      } else if ("HIT" %in% temp_tibble$label ) {
        # when HIT
        test <- temp_tibble %>%
          add_row(model = model, GCA = GCA, label = "NO HIT", number = 0, suma = 0, .before = 1)  %>% 
          add_row(model = model, GCA = GCA, label = "MAYBE", number = 0, suma = 0, .before = 1)
        
      } else {
        # when NO HIT
        test <- temp_tibble %>%
          add_row(model = model, GCA = GCA, label = "HIT", number = 0, suma = 0) %>% 
          add_row(model = model, GCA = GCA, label = "MAYBE", number = 0, suma = 0)
      }
      
      tabela <- tabela %>% bind_rows(test)
      
    } else { manualnie <<- append(manualnie, file) }
    


############  SAVE NAMES OF FILES THAT NEED TO BE FILLED MANUALLY ##############

#write_delim(as.data.frame(manualnie), paste0(manual_fill, "fill_manually.txt"), delim = "/n")


###################  JOINING TABLE AND LABELS, ORDERING  #######################
labels <- suppressMessages(read_csv(TAXONOMY, show_col_types = FALSE)) %>% select(-(...1))
    
wynik <- tabela %>% 
  left_join(labels, by = "GCA")

######################   SAVING RESULTS TO .CSV FILE ###########################

write_csv(wynik, OUTPUT)
























