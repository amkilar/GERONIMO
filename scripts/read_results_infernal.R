
############################  LOADING PACKAGES  ############################ 
library(tidyverse)


###########################   FUNCTIONS   ###########################

extract_basics <- function(row) {
  
  ### Function is receiving a row of data and extracting columns: "ID", gc", "score", "evalue", "inc", "model", "GCA"
  dane <- row %>%                                                         
    select(ID, gc, score, evalue, inc, mdl_from, mdl_to, strand, seq_from, seq_to) %>%  ##################### HERE I CHANGE -----> ADD strand, seq_from, seq_to #################################################
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
                                    skip = ile_hit))
  
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
  
  
  column_pattern = suppressWarnings(read_csv(file)) %>% 
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

# read_input <- function(file) {
#   
#   input_file = read_fwf(file, 
#                         fwf_cols( "ID" = 20,
#                                   "accession" = 10,
#                                   "query_name" = 21,
#                                   "accession2" = 10,
#                                   "mdl" = 5,
#                                   "mdl_from" = 8,
#                                   "mdl_to" = 9,
#                                   "seq_from" = 9,
#                                   "seq_to" = 9,
#                                   "strand" = 8,
#                                   "trunc" = 5,
#                                   "pass" = 6,
#                                   "gc" = 4,
#                                   "bias" = 6,
#                                   "score" = 7,
#                                   "evalue" = 10,
#                                   "inc" = 3,
#                                   "descr" = 21),
#                         col_types = cols(
#                           "ID" = col_character(),
#                           "accession" = col_character(),
#                           "query_name" = col_character(),
#                           "accession2" = col_character(),
#                           "mdl" = col_character(),
#                           "mdl_from" = col_integer(),
#                           "mdl_to" = col_integer(),
#                           "seq_from" = col_integer(),
#                           "seq_to" = col_integer(),
#                           "strand" = col_character(),
#                           "trunc" = col_character(),
#                           "pass" = col_integer(),
#                           "gc" = col_double(),
#                           "bias" = col_double(),
#                           "score" = col_double(),
#                           "evalue" = col_double(),
#                           "inc" = col_character(),
#                           "descr" = col_character()), skip = 2)
#   
#   return(input_file)
# }

# input_file = read_fwf(file, 
#                       fwf_cols( "ID" = cp[1]+1,
#                                 "accession" = cp[2]+1,
#                                 "query_name" = cp[3]+1,
#                                 "accession2" = cp[4]+1,
#                                 "mdl" = cp[5]+1,
#                                 "mdl_from" = cp[6]+1,
#                                 "mdl_to" = cp[7]+1,
#                                 "seq_from" = cp[8]+1,
#                                 "seq_to" = cp[9]+1,
#                                 "strand" = cp[10]+1,
#                                 "trunc" = cp[11]+1,
#                                 "pass" = cp[12]+1,
#                                 "gc" = cp[13]+15,
#                                 "bias" = cp[14]+1,
#                                 "score" = cp[15]+1,
#                                 "evalue" = cp[16]+1,
#                                 "inc" = cp[17]+1,
#                                 "descr" = cp[18]+1),


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

# do_manualnie <- function(file) {
#   ### Saving problamatic alignment to the file
#   manualnie <- append(manualnie, file)
#   
#   ### Copying files .csv and -alignment to folder manual_fill
#   files_to_copy <- c(file, paste0(name, "-alignment"))
#   file.copy(files_to_copy, manual_fill)
# }

###########################   DIRECTORIES   ###########################

### SERVER
setwd("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/nfs4/home/agata/infernal_insects/results/221020/")

manual_fill <- ("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/nfs4/home/agata/infernal_insects/results/manual_fill/")
results <- ("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/nfs4/home/agata/infernal_insects/results/221020/")
labels_dir <- ("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/nfs4/home/agata/infernal_insects/database/220801_Pucciniomycotina_tax.csv")

###########################   VARIABLES   ###########################
tabela <- tribble()   ### define the main output of the script (big table)
manualnie <- vector()
temp_tibble <- tribble()

############################  LOOP OVER THE FOLDERS  ############################  
dirs = list.dirs(path = ".", full.names = TRUE, recursive = FALSE)     ### make a list of available directories


### GO OVER THE FOLDERS 
for (folder in dirs) {
  
  setwd(folder)     ### go inside the folder
  
  files <- list.files( pattern = ".csv")    ### make a list of files in the folder
  
  ############################  LOOP OVER THE .CSV FILES  ############################  
  for (file in files) {
    
    
    # file = "result_chalcidoidea3_vs_GCA_000503995.1_CerSol_1.0_genomic.csv"
    
    temp_tibble <- tribble()
    test <- tribble()
    entry <- tribble()
    files_to_copy <- vector()
    EXIT <- FALSE
    
    print(paste0("Entering loop for: ", file))
    
    ### Extracting GCA and model from name of the current file
    parts = unlist(strsplit(file, "_"))
    name = str_remove(file, ".csv")      # allow read the alignment file 
    align_name = paste0(name, "-alignment")
    model = parts[2]
    
    GCA <- tail(parts, -3) 
    GCA <- paste0(GCA[1], "_", GCA[2])
    #GCA <- paste(GCA, collapse = "_")
    #GCA <- gsub(".fasta.csv", "", GCA)
    
    
    ############################  LOADING result_MODEL_vs_GCA.csv FILE ############################  
    
    empty_csv <- suppressWarnings(read_csv(file, show_col_types = FALSE)) %>% nrow()
    
    if (empty_csv > 0) {
      
      input_file = read_input(file)
      
      ########################  CHECK WHETHER ANY ALIGNMENT IN THE FILE & CHOOSE STRATEGY  ######################## 
      ### Check whether present significant hits ("!")
      entry <- input_file %>%
        pull(var = inc) 
      
      
      ### Condition when more than 1 HIT
      if ( "!" %in% entry ) {
        
        
        ### Preparing row for HIT output; as result row contains: "gc", "score", "evalue", "inc", "model_seq", "sec_struct", "align_score", "align_seq", "model", "GCA", "label" - filled with values   
        print(paste0("! - ", file))
        
        row <- filter(input_file, inc == "!" )
        
        ### Detremining how with number of hits that dealing with
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
        
        print(paste0("NO HITS - ", file))
        
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
    
  }   ### END OF THE FILES LOOP
  
  setwd("../")      ### go up to the main folder
  
  #model <- tabela %>% pull(model) %>% unique()
  
  #write_csv(tabela, paste0("../part_output_table_", model, ".csv"))
  
  #tabela <- tribble()
  
}   ### END OF THE FOLDERS LOOP


############################  SAVE NAMES OF FILES THAT NEED TO BE FILLED MANUALLY ###########################


write_delim(as.data.frame(manualnie), paste0(manual_fill, "fill_manually.txt"), delim = "/n")



############################  READ BACK THE TABLES TO ADD TAXONOMY   ###########################

#setwd("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/nfs4/home/agata/infernal_insects/results/")

#parts <- list.files(path = ".", pattern = "part_output")


#tabela <- tribble()

#for (part in parts) {

#  part <- read.csv(part) %>% filter(label == "HIT" & suma > 0)

#  tabela <- rbind(tabela, part)

#}

#tabela <- as_tibble(tabela)

############################  SAVE NAMES OF FILES THAT NEED TO BE FILLED MANUALLY ###########################
labels <- read_csv(paste0(labels_dir, "220801_Hymenoptera_taxonomy_representatives.csv"))

labels <- read_csv(labels_dir)

############################  JOINING TABLE AND LABELS, ORDERING  #################### 
### 
wynik <- tabela %>% 
  left_join(labels, by = "GCA")

###########################   SAVING RESULTS TO .CSV FILE #################
write_csv(wynik, paste0(results, "/221020_output_table_pucci.csv"))

filtered <- wynik %>% 
  filter(label == "HIT" & suma > 0 )

write_csv(filtered, paste0(results, "/221020_output_table_pucci_filtered.csv"))

setwd("/run/user/1000/gvfs/sftp:host=storage-brno1-cerit.metacentrum.cz/nfs4/home/agata/infernal_insects/results/220801_hymenoptera/")
for_plot <- read_csv("220801_ output_table_Hymenoptera_filtered.csv")

for_plot <- filtered

models <- for_plot %>% pull(model) %>% unique()


for (mod in models) {
  
  plot <- for_plot %>% 
    filter(model == mod) %>% 
    group_by(family) %>% 
    summarise(sum_family = n()) %>% 
    ungroup() %>% 
    
    ggplot(aes(x = family, y = sum_family, fill = family)) +
    geom_col() + 
    #facet_grid(model ~ ., scales = "free", space = "free") +
    #ylim(c(0,100)) +
    labs(y = "Number of hits in the family", title = paste0("Pucci representatives - 20/10/2022         for model: ", mod)) +
    theme(axis.text.x = element_text(size = 10, angle = 45, vjust = 1, hjust=1))
  
  
  ggsave(paste0("221020_", mod, "_pucci.png"), plot = plot, device = "png")
  
}


###########################################################################################################################################

for_plot <- filtered %>% filter(evalue < 1 )

plot <- for_plot %>% 
  filter(model == mod) %>% 
  group_by(family) %>% 
  summarise(sum_family = n()) %>% 
  ungroup() %>% 
  
  ggplot(aes(x = family, y = sum_family, fill = family)) +
  geom_col() + 
  #facet_grid(model ~ ., scales = "free", space = "free") +
  #ylim(c(0,100)) +
  labs(y = "Number of hits in the family", title = paste0("Hymenoptera representatives - 17/08/2022         for model: ", mod)) +
  theme(axis.text.x = element_text(size = 10, angle = 45, vjust = 1, hjust=1))


ggsave(paste0("220817_", mod, "_hymenoptera_MAYBE_less_1.png"), plot = plot, device = "png")

write_csv(for_plot, paste0(results, "/220817_ output_table_filtered_MAYBE_less_1.csv"))
