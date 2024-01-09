### Set up


## Install packages
install.packages(c("arrow", "duckdb", "janitor", "tictoc"))

install.packages(c("ggrepl", "sf")) # ggrepl not available for R version 4.3.2

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

## Look at data
nyc_taxi <- open_dataset("data/nyc-taxi-tiny") # load small version of dataset

nrow(nyc_taxi) # 1,672,513 rows compared to 1.7 billion in full

zone_counts <- nyc_taxi %>%
  count(dropoff_location_id) %>% 
  arrange(desc(n)) %>%
  collect() 

zone_counts

