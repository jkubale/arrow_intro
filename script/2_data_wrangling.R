### Data Wrangling with Arrow

## Load packages 
## Load packages
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

## Load data to arrow
nyc_taxi <- open_dataset("data/nyc-taxi-tiny") 

## Create shared_rides query
shared_rides <- nyc_taxi %>%
  filter(year %in% 2017:2021)%>%
  group_by(year)%>%
  summarise(
    all_trips = n(),
    shared_trips = sum(passenger_count > 1, na.rm=T)
  )%>%
  mutate(pct_shared = shared_trips/all_trips*100)%>%
  collect()

## Collect shared_rides query and track time
tic()
collect(shared_rides)
toc()

## Explore limitations of arrow
millions <- function(x) x/10^6

shared_rides %>%
  mutate(
    all_trips = millions(all_trips),
    shared_trips = millions(shared_trips)
  )%>%
  collect()

### can apply a function(s) on each variable, but using more recent dplyr functions 
### like across won't work

shared_rides%>%
  mutate_at(c("all_trips", "shared_trips"), millions)%>%
  collect()

## mutate_at works now!

shared_rides%>%
  mutate(across(c("all_trips", "shared_trips"), millions))%>%
  collect()

## so does across!

### When dplyr functions are not supported and the table you want to use the functions on
### is small you can collect() first and then use the dplyr functions in R rather than arrow 

shared_rides%>%
  collect()%>%
  mutate(across(c("all_trips", "shared_trips"), millions))

## another example
shared_rides%>%
  collect()%>%
  mutate(across(c(ends_with("trips")), millions))

nyc_taxi_zones <- "data/taxi_zone_lookup.csv"%>%
  read_csv_arrow()%>%
  clean_names()

nyc_taxi_zones

nyc_taxi_zones_arrow <- arrow_table(nyc_taxi_zones)
nyc_taxi_zones_arrow

## String manipulation 
### use stringR to create abbreviations of variables as example
nyc_taxi_zones %>%
  mutate(
    abbr_zone = zone%>%
      str_remove_all("['aeiou' ]")%>%
      str_remove_all("/.*"),
    abbr_zone_len = str_length(abbr_zone))%>%
  select(zone, abbr_zone, abbr_zone_len)%>%
  arrange(desc(abbr_zone_len))

## do same operations but with arrow table
nyc_taxi_zones_arrow %>%
  mutate(
    abbr_zone = zone%>%
      str_remove_all("['aeiou' ]")%>%
      str_remove_all("/.*"),
    abbr_zone_len = str_length(abbr_zone))%>%
  select(zone, abbr_zone, abbr_zone_len)%>%
  arrange(desc(abbr_zone_len))%>%
  collect()

### compare with modified code from workshop to see if any differences in results
nyc_taxi_zones_arrow %>% 
  mutate(
    abbr_zone = zone %>% 
      str_replace_all("[aeiou' ]", "") %>%
      str_replace_all("/.*", "")
  ) %>%
  mutate(
    abbr_zone_len = str_length(abbr_zone)
  ) %>%
  select(zone, abbr_zone, abbr_zone_len) %>%
  arrange(desc(abbr_zone_len)) %>%
  collect()

### don't appear to be any differences - may be due to updates in arrow package

## Exercises
### 3. In the main example I read the data into R before moving it to Arrow. 
### The read_csv_arrow() function allows you to read the data directly from a 
### CSV file to an Arrow table, by setting as_data_frame = FALSE. See if you can 
### recreate the entire pipeline without ever loading the data into an R data frame.

read_csv_arrow("data/taxi_zone_lookup.csv")%>%
  clean_names()%>%
  mutate(
    abbr_zone = zone%>%
      str_remove_all("['aeiou' ]")%>%
      str_remove_all("/.*"),
    abbr_zone_len = str_length(abbr_zone))%>%
  select(zone, abbr_zone, abbr_zone_len)%>%
  arrange(desc(abbr_zone_len))%>%
  collect()
## many (so far all) of the examples about functions not supported/recofnized by arrow no longer apply

## Date/time support in arrow
nyc_taxi%>%
  filter(
    year == 2022,
    month == 1
  )%>%
  mutate(
    day = day(pickup_datetime),
    weekday = wday(pickup_datetime, label=T),
    hour = hour(pickup_datetime),
    minute = minute(pickup_datetime),
    second = second(pickup_datetime)
  )%>%
  # filter(
  #   hour == 3,
  #   minute == 14,
  #   second == 15
  # )%>% ## commented these lines as subsetted taxi data returns no results if left in
  select(
    pickup_datetime, year, month, day, weekday
  )%>%
  collect()
