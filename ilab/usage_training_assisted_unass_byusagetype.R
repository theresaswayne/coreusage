# usage_training_assisted_nonass_byusagetype.R
# Theresa Swayne, updated 2020

require(tidyverse)
require(lubridate)

# Import data  ------
# Must be a "source_data" CSV file from iLab

datafile <- file.choose() # opens a file chooser window
usage <- read_csv(file.path(datafile)) # errors result, but seems ok

# charge name generally contains the name of the instrument
# usage type generally contains type of usage -- assisted, training, etc. in iLab

cat(c("Grand Total Hours",sum(usage$Quantity)),"\n")

# eliminate data that is either covered by other categories in the table, or not counted in usage ----

# Cytations
usage_noCytation <- dplyr::filter(usage, !grepl("Cytation", `Charge Name`))

# Workstations
usage_noCytnoWS <- dplyr::filter(usage_noCytation, !grepl("Workstation", `Charge Name`))

# Lenses
usage_noCytnoWSnoLens <- dplyr::filter(usage_noCytnoWS, !grepl("Lenses", `Charge Name`))

cat(c("Total Excluding Workstation, Cytation, Lenses",sum(usage_noCytnoWSnoLens$Quantity)),"\n")

#calculate Assisted, Unassisted, Independent for other equipment
usage_EqptTrainAssist <- dplyr::filter(usage_noCytnoWSnoLens, grepl("Assisted|Training", `Usage Type`))
cat(c("Equipment Assist/Train",sum(usage_EqptTrainAssist$Quantity)),"\n")

usage_EqptUnass <- dplyr::filter(usage_noCytnoWSnoLens, grepl("Unassisted", `Usage Type`))
cat(c("Equipment Unass",sum(usage_EqptUnass$Quantity)),"\n")

usage_EqptIndep <- dplyr::filter(usage_noCytnoWSnoLens, grepl("Independent", `Usage Type`))
cat(c("Equipment Indep",sum(usage_EqptIndep$Quantity)),"\n")

# determine other more specific categories ----

# workstation assisted/unassisted
usage_WS <- dplyr::filter(usage, grepl("Workstation", `Charge Name`))
cat(c("Workstations total",sum(usage_WS$Quantity)),"\n")

usage_WS_Ass <- dplyr::filter(usage_WS, grepl("Assisted", `Usage Type`))
cat(c("Workstations Assisted",sum(usage_WS_Ass$Quantity)),"\n")

usage_WS_Unass <- dplyr::filter(usage_WS, grepl("Unassisted", `Usage Type`))
cat(c("Workstations Unassisted",sum(usage_WS_Unass$Quantity)),"\n")

# Img Analysis service/training/programming
usage_IA <- dplyr::filter(usage, grepl("Image Processing", `Charge Name`))
cat(c("Processing/Analysis total",sum(usage_IA$Quantity)),"\n")

# Indigo
usage_Indigo <- dplyr::filter(usage, grepl("Indigo", `Charge Name`))
cat(c("Indigo total",sum(usage_Indigo$Quantity)),"\n")

usage_Indigo_AssistTrain <- dplyr::filter(usage_Indigo, grepl("Assisted|Training", `Usage Type`))
cat(c("Indigo Assist/Train",sum(usage_Indigo_AssistTrain$Quantity)),"\n")

usage_Indigo_Unass <- dplyr::filter(usage_Indigo, grepl("Unassisted", `Usage Type`))
cat(c("Indigo Unassisted",sum(usage_Indigo_Unass$Quantity)),"\n")

usage_Indigo_Indep <- dplyr::filter(usage_Indigo, grepl("Independent", `Usage Type`))
cat(c("Indigo Independent",sum(usage_Indigo_Indep$Quantity)),"\n")

#Violet
#Includes the "Cytation Imaging" service that is used to bill the total scan time 
usage_Violet <- dplyr::filter(usage, grepl("Violet|Cytation Imaging", `Charge Name`))
cat(c("Violet total",sum(usage_Violet$Quantity)),"\n")

usage_Violet_AssistTrain <- dplyr::filter(usage_Violet, grepl("Assisted|Training", `Usage Type`))
cat(c("Violet Assist/Train",sum(usage_Violet_AssistTrain$Quantity)),"\n")

usage_Violet_Indep <- dplyr::filter(usage_Violet, grepl("Unassisted|Independent|1", `Usage Type`))
cat(c("Violet independent",sum(usage_Violet_Indep$Quantity)),"\n")

