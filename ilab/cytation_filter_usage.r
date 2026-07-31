# R script to calculate filter usage from iLab form data

# Setup -------
require(tidyverse)
require(stringr)


# ---- Prompt for a data file ----
# no message will be displayed. Choose one of the files in the folder
selectedFile <- file.choose()


require (stringr, tidyverse)

form <- read_csv(selectedFile, locale = locale(encoding = "latin1"), na = c("", "N/A"))

# Get the relevant data
filt <- form$`Filter cubes`
filt_clean <- na.omit(filt)

Cy5<- sum(str_count(filt_clean, pattern = "Cy5"))
LaserAF<- sum(str_count(filt_clean, pattern = "LaserAF"))
RFP<- sum(str_count(filt_clean, pattern = "RFP"))
Texas <- sum(str_count(filt_clean, pattern = "TxRed"))
GFP <- sum(str_count(filt_clean, pattern = "GFP"))
DAPI <- sum(str_count(filt_clean, pattern = "DAPI"))
