# usage_training_assisted_nonass.R
# From iLab usage table, calculates:
# -- calculates hours of assisted, training,  and non-assisted hours, and fraction of total
# Theresa Swayne, updated 2020

require(tidyverse)

# Import data  ------
# Must be a "source_data" CSV file from iLab

datafile <- file.choose() # opens a file chooser window
usage <- read_csv(file.path(datafile)) # errors result, but seems ok

# eliminate lenses 
usage_nolenses <- dplyr::filter(usage, !grepl("Lenses", `Charge Name`))

# eliminate TC hood hours
usage_nolenses_notc <- dplyr::filter(usage_nolenses, !grepl("Tissue culture hood", `Charge Name`))

# Optional filter by date ----------------------------------------------------------
#usage <- filter(usage, `Completion Date` > "2018-03-01")


# Assisted vs Non-assisted ----------------------------------------

# Calculate hours for different Usage Types

# NB it is possible to find out the different categories in Usage Type using unique()

# 1 is image processing/programming service
hrs_assist <- dplyr::filter(usage_nolenses_notc, grepl("Assisted|1", `Usage Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

hrs_train <- dplyr::filter(usage_nolenses_notc, grepl("Assisted|Training|1", `Usage Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

hrs_nonass <- dplyr::filter(usage_nolenses_notc, grepl("Unassisted|Independent", `Usage Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

# Collect total hours by usage type
usage_type <- c("Assisted/Service", "Training", "Non-Assisted")
hours <- c(hrs_assist, hrs_train, hrs_nonass)

hrs_assist_summ <- cbind(`Usage Type` = usage_type, Hours = hours) %>%
  as.data.frame(stringsAsFactors = FALSE)

# Calculate fraction of time assisted/non-assisted

hrs_assist_summ$Hours <- as.numeric(as.character(hrs_assist_summ$Hours)) # force R to see the hours as numeric

hrs_assist_summ <- mutate(hrs_assist_summ, 
                   Fraction = round((Hours / sum(Hours)), 2))


#TODO: Add total hours as a row in the summary tables
#TODO: Write summary as CSV (using source filename as a base name)
