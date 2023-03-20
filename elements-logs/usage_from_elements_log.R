# usage_from_elements_log.R
# determining microscope usage from Nikon NIS Elements log files

# To use:
# 1. Run the script. When prompted, open a single NIS log file
# 2. The script will output data: 
#   Log start, end, elapsed; 
#   idle time (above a certain minimum time) start, end, elapsed; 
#   files saved with time and path

# ---- Setup ----
library(readr)
library(tidyverse)

# ---- Prompt for a log file ----
logfile <- file.choose()

# logdata is the original data from the disk
# We supply a generic column name
logdata <- read_delim(logfile,
                      delim = "\t", escape_double = FALSE,
                      locale = locale(encoding = "ISO-8859-1"),
                      col_names = c("Log"), trim_ws = FALSE)
# encoding ascii gives invalid multibyte sequence

# ---- Create a column for the date and time

# logtable is the version that we will process
logtable <- logdata
logtable <- mutate(logtable, Time = substring(Log, 1, 23), bef)
