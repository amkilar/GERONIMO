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
                      col_names = c("model","GCA_id","organism_name","family","label","number","e_value","extended_genomic_region","infernal_hit","seondary_structure","HIT_ID","phylum","class","order"),
                      show_col_types = FALSE) %>% 
  arrange(model, GCA_id, e_value)


suppressMessages(write.xlsx(raw_table, file = "./results/summary_table.xlsx", overwrite = TRUE))


###########    WRITE RESULTS TO XLSX FILE   ####################################

### Make excel file (models divided into worksheets)
wb <- createWorkbook()
model_list <- raw_table %>% pull(model) %>% unique()

for (model_it in model_list){
  
  model_file <- raw_table %>% 
    filter(model == model_it)
  
  addWorksheet(wb, model_it)
  writeData(wb, model_it, model_file, startRow = 1, startCol = 1)
  
}

suppressMessages(saveWorkbook(wb, file = "./results/summary_table_models.xlsx", overwrite = TRUE))


###########    MAKE PLOT WITH HITS DISTRIBUTION   ##############################
total_genomes <- raw_table %>% select(family, GCA_id) %>% distinct() %>% group_by(family) %>% count(family)

raw_table %>% 
  select(model, GCA_id, family, label, number) %>% 
  filter(number == 1)  %>% 
  pivot_wider(names_from = label, values_from = number) %>% 
  mutate_at(c("MAYBE", "HIT", "NO HIT"),  ~coalesce(.,0)) %>% 
  mutate(`NO HIT` = ifelse(MAYBE == 1, 1, `NO HIT`),
         `NO HIT` = ifelse(HIT == 1, 0, `NO HIT`)) %>% 
  select(-MAYBE) %>% distinct() %>% group_by(model, family) %>% summarise(model, family, n = sum(HIT), m = sum(`NO HIT`)) %>% 
  select(-m) %>% distinct() %>% 
  ggplot(aes(x = family, y = n, fill = model)) +
  geom_bar(stat = "identity", position = position_dodge2(preserve = "single", padding = 0) ) +
  
  facet_grid(cols = vars(family), scale = "free", space = "free") +
  
  geom_hline(data = total_genomes, aes(yintercept = n + 0.25), colour = "black", size = 1 ) +
  
  labs(y = "Number of significant hits in the family", x = "",
       title = "Significant hits distribution across taxonomy families",
       caption = "Obtained with Geronimo") +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 11, angle = -30, vjust = 1, hjust=0),
        plot.title=element_text(face = "bold", size = 16), 
        strip.text.x = element_blank()) +
  scale_fill_discrete(name="Models:")


suppressMessages(ggsave("./results/plots/Hits_distribution_across_families.png", bg = "white",  width = 15, height = 10, dpi = 400, units = "in", device = "png"))


###########    MAKE HEATMAP PLOT WITH HITS DISTRIBUTION   ######################

evalue_treshold <- 0.05

for_plot <- raw_table %>% 
  select(model, GCA_id, organism_name, family, e_value) %>% 
  mutate(label = paste0(organism_name, " (", GCA_id, ")")) %>% 
  group_by(model, GCA_id, label, family) %>% 
  summarise(fill = suppressWarnings(min(e_value, na.rm = TRUE))) 


# extracting minimum and maximal e-value for scale adjustment
eval <- for_plot %>% pull(fill)
eval <- eval[!is.na(eval) & !is.infinite(eval)]

min <- min(eval, na.rm = TRUE)
max <- max(eval, na.rm = TRUE)

breaks_scale <- c(signif(min, digits = 3), signif(max, digits = 2))


for_plot %>% ggplot(aes(x = model, y = label, fill = fill )) +
  geom_tile() +
  
  facet_grid(cols = vars(model), rows = vars(family), scale = "free", space = "free") +
  
  theme_minimal() +
  theme(axis.ticks.x=element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_text(size = 10),
        axis.text.x = element_text(size = 11, angle = -30, vjust = 1, hjust=0),
        strip.text.y = element_text(angle=0, size = 12),
        strip.text.x = element_blank(),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 12),
        plot.title=element_text(face = "bold", size = 16) ) +
  
  labs(title = "Hits distribution in genomes across families",
       caption = "Obtained with Geronimo") +
  
  scale_fill_gradient(name = "Significance", low = "#ba5370", high = "#f4e2d8", na.value = "#7A918D",
                      limits = c(min, max), breaks = breaks_scale ) 


suppressMessages(ggsave("./results/plots/Hits_distribution_heatmap.png", bg = "white", width = 10, height = 20, dpi = 300, units = "in", device = "png"))







