# combine some dataframes, adding columns where needed, and summarize
# used to get total usage by PI across multiple years from iLab report tables

# a summary table from iLab with extraneous rows removed
# read other data similarly
X2020_ <- read_csv("Downloads/OneDrive_1_5-18-2023/01012020_12312020_charges_report_filtered_7952663093.xls")

# One table is part of a year, so project the yearly total based on the first 4 months
# first create a new column to hold the partial-year total
X2023_4mo <- mutate(X2023_4mo, PartTotal = Total)
#  In order to summarize, we need the projected yearly total to be called "Total" as in the other tables
X2023_4mo <- mutate(X2023_4mo, Total = PartTotal * 3)

# after reading all the tables, Combine the 3 dataframes
X21to23 <- bind_rows(X2023_4mo, X2022, X2021)

# save the merged data
write_csv(X21to23, "2021-23.csv")

# group and summarize by lab
YrSumm <- X21to23 %>% group_by(Lab) %>% summarize(TotalUse = sum(Total))
# double-check our total is correct
grand <- sum(YrSumm$TotalUse)

# save the summary
write_csv(YrSumm, "Summary2021-23.csv")