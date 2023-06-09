# cytation_time_calc_batch.R
# R script to calculate active scan time from Cytation data audit trail
# Theresa Swayne, 2022
# Reads a folder of TXT files generated by the Data Audit Trail in Gen5
# Note -- include only the audit trail. No procedure summary or other info.
# Date and time use the default Gen5 format "10/1/2021 2:49:43 PM"

# ---- Setup ----

require(tidyverse) # for reading and parsing, lead/lag
require(tcltk) # for file choosing

# ---- User chooses the input folder ----

logfolder <- tk_choose.dir(default = "", caption = "OPEN the folder with log data") # prompt user

# Get a list of files in the folder

files <- dir(logfolder, pattern = "*.txt") 

# Read the data -- parsing errors may be shown but data should be read ok.

mergedDataWithNames <- tibble(filename = files) %>% # column 1 = file names
  mutate(file_contents =
           map(filename,          # column 2 = all the data in the file
               ~ read_csv(file.path(logfolder, .),
                          col_types = cols(Comment = col_character(), 
                                           Date = col_datetime(format = "%m/%d/%Y %H:%M:%S %p")), 
                          skip = 2)))


# make the list into a flat file -- each row contains its source filename

logdata <- unnest(mergedDataWithNames, cols=c(file_contents)) 

# ---- Find start and end times ----

# remove lines representing duplication of the same read, 
# which are present in multiple files
logdata_unique <- distinct(logdata, Date, .keep_all = TRUE)

# create a column representing the Experiment base name
# obtained from the audit trail filename after ignoring the 14 characters in the timestamp
logdata_unique <- logdata_unique %>% 
  mutate(Expt = substring(filename, 15))

# remove unnecessary lines -- keep only the times when reads are started and completed 
start_endTimes <- logdata_unique %>% 
  filter(grepl("started|completed", Event))

# sort by time of actual read (Date)
arrange(start_endTimes, Date, filename, Expt)

# save only the completion times that have a started read immediately before
endTimes <- filter(start_endTimes, 
       (Event == "Plate read successfully completed" & lag(Event) == "Plate read started")) %>%
  mutate(Read = row_number()) # this column will help us match start and end times

# save only the start times that have a completed read immediately after
startTimes <- filter(start_endTimes, 
                     (Event == "Plate read started" & lead(Event) == "Plate read successfully completed")) %>%
  mutate(Read = row_number())

scanTimesRaw <- full_join(startTimes, endTimes, by = "Read")

# identify start and end times, and remove duplicate columns
scanTimes <- scanTimesRaw %>%
  mutate(Filename = filename.x, 
         User = User.x, 
         Start = Date.x, 
         End = Date.y,
         Expt = Expt.x) %>% 
  select(Filename, User, Start, End, Expt)

# ---- Calculate elapsed time ----

scanTimes <- scanTimes %>% 
  mutate(elapsedTime = difftime(End, Start, units = "hours"))

# sort just before grouping and summarizing
scanTimes <- scanTimes %>% 
  arrange(Expt, Start)

# calculate total per experiment (plate)
scanTimeTotal <-  scanTimes %>%
  group_by(Expt) %>%
  summarise(TotalHours = sum(elapsedTime)) 

# ---- Output ----

# save results in the parent of the log directory 

parentName <- basename(dirname(logfolder)) # name of the log directory without higher levels
parentDir <- dirname(logfolder) # parent of the log directory

outputFile = paste(Sys.Date(), basename(logfolder), "_times.csv") 
write_csv(scanTimes,file.path(parentDir, outputFile))

outputFileTotal = paste(Sys.Date(), basename(logfolder), "_totals.csv")
write_csv(scanTimeTotal,file.path(parentDir, outputFileTotal))
