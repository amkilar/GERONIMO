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
# The script modifies the summary table by adding columns names and export it
# in excel-friendly format. Additionally plots visualizing hits distribution across
# taxonomy families and heat map with specific results are created.
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

options(dplyr.summarise.inform = FALSE)

################################################################################
#######################   MAIN    ##############################################
################################################################################

raw_table <- read_csv(RAW_TABLE,
                      col_names = c("model","GCA_id","organism_name","family","label","number","e_value","extended_genomic_region","HIT_sequence","seondary_consensus","HIT_ID","phylum","class","order"),
                      show_col_types = FALSE) %>% 
  arrange(model, family, phylum, order, class, GCA_id, e_value) %>% 
  select(family, organism_name, GCA_id, model, label, number, e_value, HIT_sequence, HIT_ID, extended_genomic_region, class, order, phylum, seondary_consensus)


suppressMessages(write.xlsx(raw_table, file = "./results/summary_table.xlsx", overwrite = TRUE))


###########    WRITE RESULTS TO XLSX FILE   ####################################

### Make excel file (models divided into worksheets)
wb <- createWorkbook()
model_list <- raw_table %>% pull(model) %>% unique()

for (model_it in model_list){
  
  model_file <- raw_table %>% 
    filter(model == model_it) %>% 
    arrange(family, GCA_id, e_value)
  
  addWorksheet(wb, model_it)
  writeData(wb, model_it, model_file, startRow = 1, startCol = 1)
  
}

suppressMessages(saveWorkbook(wb, file = "./results/summary_table_models.xlsx", overwrite = TRUE))


###########    MAKE PLOT WITH HITS DISTRIBUTION   ##############################
total_genomes <- raw_table %>% select(family, GCA_id) %>% distinct() %>% group_by(family) %>% count(family)

#In case some of column would be empty after filtering for table transformation
full_table_check <- tibble(MAYBE = NA, HIT = NA, 'NO HIT' = NA)

raw_table %>% 
  select(model, GCA_id, family, label, number) %>% 
  filter(number == 1)  %>% 
  pivot_wider(names_from = label, values_from = number) %>% 
  left_join(full_table_check) %>% 
  mutate_at(c("MAYBE", "HIT", "NO HIT"),  ~coalesce(.,0)) %>% 
  mutate(`NO HIT` = ifelse(MAYBE == 1, 1, `NO HIT`),
         `NO HIT` = ifelse(HIT == 1, 0, `NO HIT`)) %>% 
  select(-MAYBE) %>% distinct() %>% group_by(model, family) %>% reframe(model, family, n = sum(HIT), m = sum(`NO HIT`) ) %>% 
  select(-m) %>% distinct() %>% 
  mutate(model = str_remove(model, "cov_model_")) %>%
  
  ggplot(aes(x = family, y = n, fill = model)) +
    geom_bar(stat = "identity", position = position_dodge2(preserve = "single", padding = 0), colour="black" ) +
    
    facet_grid(cols = vars(family), scale = "free", space = "free") +
    
    geom_hline(data = total_genomes, aes(yintercept = n + 0.25), colour = "black", linewidth = 1 ) +
    
    labs(y = "Number of significant hits per family (e_val < 0.01)", x = "",
         title = "Significant hits distribution across taxonomy families",
         caption = "Obtained with GERONIMO") +
    
    theme_minimal() +
    theme(#axis.text.x = element_text(size = 11, angle = -30, face = "italic", vjust = 1, hjust=0),
          axis.text.x = element_text(size = 13, angle = 0, face = "italic", vjust = 0, hjust = 0.5),
          axis.text.y = element_text(size = 11),
          legend.text = element_text(face = "bold", size = 11),
          legend.title = element_text(face = "bold", size = 12),
          plot.title=element_text(face = "bold", size = 16, hjust = 0.5),
          strip.text.x = element_blank()) +

    scale_fill_discrete(name="Models:")


suppressMessages(ggsave("./results/plots/Hits_distribution_across_families.png", bg = "white",  width = 15, height = 10, dpi = 400, units = "in", device = "png"))


###########    MAKE HEATMAP PLOT WITH HITS DISTRIBUTION   ######################

for_plot <- raw_table %>% 
  select(model, GCA_id, organism_name, family, e_value) %>% 
  mutate(label = paste0(organism_name, " (", GCA_id, ")")) %>% 
  group_by(model, GCA_id, label, family) %>% 
  summarise(top_eval = suppressWarnings(min(e_value, na.rm = TRUE))) %>%
  mutate(model = str_remove(model, "cov_model_")) %>%
  mutate(tag = ifelse(top_eval < 0.01, "HIT", ifelse(top_eval > 10, "NO HIT", "MAYBE")) ) %>%
  mutate(tag = ifelse(top_eval < 0.00001, "GREAT HIT", tag))

for_plot %>% ggplot(aes(x = model, y = label, fill = tag)) +
  geom_tile(colour = "white", linewidth = 0.3) +

  facet_grid(cols = vars(model), rows = vars(family), scale = "free", space = "free") +
  
  theme_minimal() +
  theme(axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_text(size = 10),
        axis.text.x = element_text(angle=30, face = "bold", size = 12, hjust = 0.5, vjust = 0.7),
        strip.text.y = element_text(angle=0, size = 12, face = "italic", hjust = 0),
        strip.text.x = element_blank(),
        strip.background = element_rect(fill = "#F0F0F0", linetype = "blank"),
        legend.text = element_text(face = "bold", size = 11),
        legend.title = element_text(face = "bold", size = 12),
        plot.title=element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5)) +
  
  labs(title = "Overview of sequence homology between model and genomes across families",
       #subtitle = "HIT: e-value < 0.01,   MAYBE: 0.01 - 10,   NO HIT: e-value > 10",
       caption = "Obtained with GERONIMO") +
  
  scale_y_discrete(expand=c(0, 0) ) +
  scale_x_discrete(expand=c(0, 0) ) +
  
  scale_fill_manual(name = "Significance [e-value]:",
                    labels = c("HIT:   < 0.00001", "HIT:   0.00001 - 0.01", "MAYBE: 0.01 - 10", "NO HIT:   > 10"),
                    values = c("#585481", "#B8A4C9", "#F5CCD4", "#f2f2f2"))
                    
suppressMessages(ggsave("./results/plots/Hits_distribution_heatmap.png", bg = "white", width = 10, height = 20, dpi = 300, units = "in", device = "png"))

                              
