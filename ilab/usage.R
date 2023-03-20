# usage.R
# From iLab usage table, calculates:
# -- assisted vs. non-assisted hours, and fraction of total
# -- HICCC vs. non-HICCC hours and number of labs, and fraction of total
# Theresa Swayne

require(tidyverse)

# Import data  ------
# Must be a "source_data" CSV file from iLab

datafile <- file.choose() # opens a file chooser window
usage <- read_csv(file.path(datafile)) # errors result, but seems ok

# Optional filter by date ----------------------------------------------------------
#usage <- filter(usage, `Completion Date` > "2018-03-01")


# Assisted vs Non-assisted ----------------------------------------

# Calculate hours for different Usage Types
hrs_assist <- dplyr::filter(usage, grepl("Assisted|Training|1", `Usage Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

hrs_unass <- dplyr::filter(usage, grepl("Unassisted|Independent", `Usage Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

# Collect total hours by usage type
usage_type <- c("Assisted/Service", "Non-Assisted")
hours <- c(hrs_assist, hrs_unass)

hrs_assist_summ <- cbind(`Usage Type` = usage_type, Hours = hours) %>%
  as.data.frame(stringsAsFactors = FALSE)

# Calculate fraction of time assisted/non-assisted

hrs_assist_summ$Hours <- as.numeric(as.character(hrs_assist_summ$Hours)) # force R to see the hours as numeric

hrs_assist_summ <- mutate(hrs_assist_summ, 
                   Fraction = round((Hours / sum(Hours)), 2))


# HICCC vs non-HICCC  -------------------------------------------------

# eliminate lenses from this calculation

# TODO: eliminate TC hood

eqpt_service_usage <- dplyr::filter(usage, !grepl("Lenses", `Charge Name`))

# Find total hours of HICCC use 

hrs_HICCC <- dplyr::filter(eqpt_service_usage, grepl("Cancer Center Member", `Price Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

# Find number of HICCC labs

appts_HICCC <- dplyr::filter(eqpt_service_usage, grepl("Cancer Center Member", `Price Type`)) %>%
  dplyr::select(`Customer Lab`)

appts_HICCC$`Customer Lab` <- factor(appts_HICCC$`Customer Lab`)
users_HICCC <- nlevels(appts_HICCC$`Customer Lab`)

# Find total hours of non-HICCC use 

hrs_NonHICCC <- dplyr::filter(eqpt_service_usage, grepl("Dept of Pathology|Internal - Columbia|External - Academic", `Price Type`)) %>%
  dplyr::select(Quantity) %>%
  sum()

# Find number of non-HICCC labs

appts_NonHICCC <- dplyr::filter(eqpt_service_usage, grepl("Dept of Pathology|Internal - Columbia|External - Academic", `Price Type`)) %>%
  dplyr::select(`Customer Lab`)

appts_NonHICCC$`Customer Lab` <- factor(appts_NonHICCC$`Customer Lab`)
users_NonHICCC <- nlevels(appts_NonHICCC$`Customer Lab`)

# Collect data in a table
price_type <- c("HICCC", "Non-HICCC")
hoursCC <- c(hrs_HICCC, hrs_NonHICCC)
usersCC <- c(users_HICCC, users_NonHICCC)

hrs_cc_summ <- cbind(`Price Type` = price_type, Hours = hoursCC, Labs = usersCC) %>%
  as.data.frame(stringsAsFactors = FALSE)

hrs_cc_summ$Hours <- as.numeric(as.character(hrs_cc_summ$Hours)) # force R to see the hours as numeric

hrs_cc_summ <- mutate(hrs_cc_summ, 
                   HrsFraction = round((Hours / sum(Hours)), 2))

hrs_cc_summ$Labs <- as.numeric(as.character(hrs_cc_summ$Labs)) # force R to see the labs as numeric

hrs_cc_summ <- mutate(hrs_cc_summ, 
                      LabsFraction = round((Labs / sum(Labs)), 2))

#TODO: Add total hours as a row in the summary tables
#TODO: Write summary as CSV (using source filename as a base name)
