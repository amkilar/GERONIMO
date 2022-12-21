#!/usr/bin/env Rscript
#
#
################################################################################
################################################################################
################################################################################
#
#                       make_table_plots
#
################################################################################
# The script modifies the summary table by adding columns names and exportx it
# in excel-friendly format. Additionally plots visualising hits distribution across
# taxonomy families and heatmap with specific results are created.
################################################################################


#Author           : Agata Kilar                                                
#Email            : 242679@muni.cz  

#Lastly modified  : 21st December 2022

################################################################################
################# BEFORE RUNNING THE SCRIPT ####################################
################################################################################

# Install all required packages:
suppressMessages(require(tidyverse))
suppressMessages(require(openxlsx))

# For Rscript - passing arguments from bash to R
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("Please provide the list of inputs!", call.=FALSE)
}

################################################################################
##################### SETUP VARIABLES ##########################################
################################################################################

RAW_TABLE = args[1]

setwd("~/Desktop/GERONIMO/GERONIMO/")

################################################################################
#######################   MAIN    ##############################################
################################################################################

raw_table <- read_csv(RAW_TABLE,
                      col_names = c("model","GCA_id","organism_name","family","label","number","e_value","extended_genomic_region","infernal_hit","seondary_structure","HIT_ID","phylum","class","order"),
                      show_col_types = FALSE) %>% 
  arrange(model, GCA_id, e_value)



###########    WRITE RESULTS TO XLSX FILE   ####################################

### Make excel file (models divided into worksheets)
wb <- createWorkbook()
model_list <- raw_table %>% pull(model) %>% unique()

for (model in model_list){
  
  model_file <- raw_table %>% 
    filter(model == model)
  
  addWorksheet(wb, model)
  writeData(wb, model, model_file, startRow = 1, startCol = 1)
  
}

saveWorkbook(wb, file = "./results/summary_table_models.xlsx", overwrite = TRUE)


###########    MAKE PLOT WITH HITS DISTRIBUTION   ##############################

raw_table %>% 
  filter(label == "HIT" & number == 1) %>% 
  select(model, GCA_id, family) %>% 
  group_by(family, model) %>% 
  summarize(sum = n(), na.rm=T) %>% 
  ggplot(aes(x = family, y = sum, fill = model)) +
  geom_bar(stat="identity") +
  labs(y = "Number of hits in the family", x = "",
       title = "Hits distribution across taxonomy families",
       caption = "Obtained with Geronimo") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 11, angle = -30, vjust = 1, hjust=0),
        plot.title=element_text(face = "bold", size = 12)) +
  scale_fill_discrete(name="Models:")

ggsave("./results/plots/Hits_distribution_across_families.png", bg = "white")



###########    MAKE HEATMAP PLOT WITH HITS DISTRIBUTION   ######################

evalue_treshold <- 0.05

raw_table %>% 
  select(model, GCA_id, organism_name, family, e_value) %>% 
  mutate(label = paste0(organism_name, " (", GCA_id, ")")) %>% 
  group_by(model, GCA_id, label, family) %>% 
  summarise(fill = min(e_value, na.rm = TRUE)) %>% 
  
  ggplot(aes(x = model, y = label, fill = fill)) +
    geom_tile() +
  
    facet_grid(cols = vars(model), rows = vars(family), scale = "free", space = "free") +
    
    theme_minimal() +
      theme(axis.text.y = element_text(size = 10),
            strip.text.y = element_text(angle=0, size = 12),
            strip.text.x = element_text(size = 12),
            legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            plot.title=element_text(face = "bold", size = 12)) +
      
    labs(title = "Hits distribution in genomes",
         caption = "Obtained with Geronimo") +
    
    scale_fill_gradient(low = "#ba5370", high = "#f4e2d8", na.value = "#7A918D")
  
  
ggsave("./results/plots/Hits_distribution_heatmap.png", bg = "white")  




