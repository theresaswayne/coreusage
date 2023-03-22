# usage_from_elements_log.R
# determining microscope usage from Nikon NIS Elements log files

# To use:
# 1. Run the script. When prompted, open a single NIS log file.
# 2. Planned output: 
#   Start, end, elapsed time of entire log; 
#   Start, end, elapsed time of all idle times (above a certain minimum time) ; 
#   List of Files saved with time and path name

# ---- Setup ----
library(readr)
library(tidyverse)

# ---- Prompt for a log file ----
# no message will be displayed
logfile <- file.choose() 

# Read the data from the file into 1 column called Log
# Pretend the file is tab-delimited to keep from dividing the lines
# Encoding ISO-8859-1 is most successful choice so far
# Encoding with default settings or ASCII produces "invalid mulibyte sequence" error,
# apparently due to multibyte characters in the file
logdata <- read_delim(logfile,
                      delim = "\t", escape_double = FALSE,
                      locale = locale(encoding = "ISO-8859-1"),
                      col_names = c("Log"), trim_ws = FALSE)

# ---- Parse the date and time  ----
# All processing is done on a copy of the data: logtable
logtable <- logdata
# Create a new column containing the date-timestamp
logtable <- mutate(logtable, Time = substring(Log, 1, 23)) # YYYY-MM-DD HH:MM:SS.SSS
# Interpret the date and time
# translate the column into POSIXct time format
# "OS" format preserves milliseconds
logtable$TimeParsed <- as.POSIXct(logtable$Time, format = '%Y-%m-%d %H:%M:%OS')

# Test whether time is accurately interpreted by measuring elapsed time
# double brackets retrieve values rather than 1x1 tibbles
testtime <- as.numeric(difftime(logtable[[2,3]], logtable[[1,3]], units = "secs"))
# in fact this works on the time column as is but what the heck, we'll parse it anyway
testtime <- as.numeric(difftime(logtable[[2,2]], logtable[[1,2]], units = "secs"))

# ---- Calculate elapsed time for entire log ----

totalTime <- as.numeric(difftime(logtable$TimeParsed[nrow(logtable)],logtable$TimeParsed[1]), units = "mins")
print(paste('Total time elapsed was',
            totalTime,
            'minutes',
            sep = ' '))

# ---- Find rows where interesting things happened ----

saveTimes <- filter(logtable, grepl("save", Log))
# note -- includes many events that are not saving files 
# -- need to refine the search text 

print(paste('There were',
            nrow(saveTimes),
            'events with Save in the log.',
            sep = ' '))
# ---- Print or save results ----
print(paste('Total time elapsed was',
            totalTime,
            'minutes',
            sep = ' '))

print(paste('There were',
            nrow(saveTimes),
            'events with Save in the log.',
            sep = ' '))

# sample code for saviing
# logName <- basename(logfile) # name of the file without higher levels
# parentDir <- dirname(logfile) # parent of the logfile
# outputFile = paste(Sys.Date(), logName, "_total.csv") # spaces will be inserted
# write_csv(scanTimeTotal,file.path(parentDir, outputFile))


