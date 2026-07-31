# commands to help calculate # users trained by lab
# not intended to be run as a script

require(tidyverse)

dataName = "26-27"

# assumes a dataframe df containing iLab usage data (as "source data")

# check what are the different usage types in the table
usageTypes <- unique(df$`Usage Type`)
usageTypes

# group data by lab and usage type (training, etc)
# put more important params first
df <- df %>% group_by( `Customer Lab`,`Customer Name`)

# Use `summarise(.groups = "drop_last")` to silence this message.
# Use `summarise(.by = c(Customer Lab, Customer Name))` for per-operation grouping
# instead.

# table of all users trained and total hours
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
write_csv(training_summ, paste0(dataName, "_training summary.csv"))
write_csv(assist_summ, paste0(dataName, "_assisted use summary.csv"))
write_csv(assist_training_summ, paste0(dataName, "_assisted and training summary.csv"))

