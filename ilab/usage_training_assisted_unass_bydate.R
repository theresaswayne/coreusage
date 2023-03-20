# usage_training_assisted_nonass_bydate.R
# From iLab usage table, calculates:
# -- calculates hours of assisted, training,  and non-assisted hours, and fraction of total, grouping by date
# Theresa Swayne, updated 2020

require(tidyverse)
require(lubridate)

# Import data  ------
# Must be a "source_data" CSV file from iLab

datafile <- file.choose() # opens a file chooser window
usage <- read_csv(file.path(datafile)) # errors result, but seems ok

# eliminate lenses 
usage_nolenses <- dplyr::filter(usage, !grepl("Lenses", `Charge Name`))

# eliminate TC hood hours
usage_nolenses_notc <- dplyr::filter(usage_nolenses, !grepl("Tissue culture hood", `Charge Name`))


# Assisted vs Non-assisted ----------------------------------------

# clean up categories and group by assistance type
# NB it is possible to find out the different categories in Usage Type using unique()
# 1 is image processing/programming service

usage_cleanAssist <- dplyr::filter(usage_nolenses_notc, grepl("Assisted|1", `Usage Type`)) %>%
  mutate(CleanUsageType = "Assisted_Service")

usage_cleanTrain <- dplyr::filter(usage_nolenses_notc, grepl("Training", `Usage Type`)) %>%
  mutate(CleanUsageType = "Training")

usage_cleanNonass <- dplyr::filter(usage_nolenses_notc, grepl("Unassisted|Independent", `Usage Type`)) %>%
  mutate(CleanUsageType = "Unassisted_Independent")

usage_cleanMerged <- rbind(usage_cleanAssist, usage_cleanTrain, usage_cleanNonass)

# format the purchase date (date of use) as an R date
usage_cleanMerged$PurchaseDate <- as.Date(usage_cleanMerged$`Purchase Date`)

# summarise by month
usage_summ <- group_by(usage_cleanMerged, 
                       Month=floor_date(PurchaseDate, "month"), 
                       UsageType = CleanUsageType, .add = TRUE) %>% 
  summarize(Usage = sum(Quantity))  %>%  arrange(UsageType)

write_csv(usage_summ, "~/Desktop/summary.csv")
