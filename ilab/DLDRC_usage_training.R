# commands to help calculate # users trained by lab
# not intended to be run as a script

require(tidyverse)

# obtain data
df <- df_2425

# useful: what are the different usage types in the table?
usageTypes <- unique(df$`Usage Type`)
usageTypes

# group data by lab and usage type (training, etc)
# put more important params first
df <- df %>% group_by( `Customer Lab`,`Customer Name`)

# table of all trained users and total hours
training_summ <- df %>%
  filter(`Usage Type` == "Training") %>%
  summarise(Training_Hours = sum(Quantity))

# assisted table
assist_summ <- df %>%
  filter(`Usage Type` == "Assisted"|`Usage Type` == "Assisted Use") %>%
  summarise(Assisted_Hours = sum(Quantity))

# combined table
assist_training_summ <- df %>%
  filter(`Usage Type` == "Assisted"|`Usage Type` == "Assisted Use"|`Usage Type` == "Training") %>%
  summarise(Assisted_Training_Hours = sum(Quantity))
# set working directory and update file names before doing this
write_csv(training_summ, "24-25 training summary.csv")
write_csv(assist_summ, "24-25 assisted use summary.csv")
write_csv(assist_training_summ, "24-25 assisted and training summary.csv")

