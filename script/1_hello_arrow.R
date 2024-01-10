## Part 1: Hello Arrow

## Load packages (if needed)
library(arrow)
library(dplyr)
library(dbplyr)
library(duckdb)
library(stringr)
library(lubridate)
library(palmerpenguins)
library(tictoc)
library(scales)
library(janitor)
library(fs)

nyc_taxi <- open_dataset("data/nyc-taxi-tiny") 
### scans the files in the folder and creates an object `nyc_taxi` containing the metadata

nyc_taxi ### look at metadata

### code below finds first 6 rows of data and pulls them into tibble in R
nyc_taxi %>%
  head()%>%
  collect()

### Look at the five-year trends for number of taxi rides in NYC both in total and for shared trips

nyc_taxi %>%
  filter(year %in% 2017:2021)%>%
  group_by(year)%>%
  summarise(
    all_trips = n(),
    shared_trips = sum(passenger_count > 1, na.rm=T)
  )%>%
  mutate(pct_shared = shared_trips/all_trips*100)%>%
  collect()

## Practice problems
### 1 - Calculate the total number of rides for every month in 2019.

nyc_taxi%>%
  filter(year==2019)%>%
  group_by(month)%>%
  summarise(num_rides = n())%>%
  arrange(month)%>%
  collect()

### 2 - For each month in 2019, find the distance traveled by the longest recorded taxi 
### ride that month and sort the results in month order.
nyc_taxi%>%
  filter(year == 2019)%>%
  group_by(month)%>%
  summarise(max_distance = max(trip_distance, na.rm=T))%>%
  arrange(month)%>%
  collect()



