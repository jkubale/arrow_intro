library(tictoc)
library(arrow)
library(dplyr)
library(lubridate)
library(stringr)

advan <- open_dataset("data/advan_mp_Monthly_Patterns_Foot_Traffic-588-DATE_RANGE_START-2021-08-01.csv", format="csv", read_options = list(block_size = 2048576L))


advan_samp <- advan|>
  mutate(date_end = as_date(DATE_RANGE_END, tz ="UTC"),
         date_end2 = with_tz(as_datetime(DATE_RANGE_END), tz="UTC"))|>
  filter(DATE_RANGE_END <= "2021-08-31 20:00:00")|>
  select(DATE_RANGE_END, date_end, date_end2)|>
  # mutate(date_end1 = force_tz(DATE_RANGE_END, tzone="UTC"),
  #   date_end = as_datetime(date_end1),
  #   date_end3 = as_date(date_end))|>
  # select(date_end, date_end1, date_end3, DATE_RANGE_END)|>
  collect()

# could filter with date time and then use force tz to set timezone to UTC
# still odd that R is changing it to current timezone 

table()
advan_samp$test <- force_tz(advan_samp$DATE_RANGE_END, tzone="UTC")

head(advan_samp)
tz(advan_samp$test)
tz(advan_samp$DATE_RANGE_END)

# filter file list to only include pre pandemic then open and filter by state

full_list <- data.frame(file = list.files("data"))
pre_list <- full_list |>
  mutate(keep = case_when(
    str_detect(file, "2019")~1,
    T~0
  ))|>
  filter(keep==1)|>
  select(-keep)|>
  mutate(filepath = paste0("data/",file))|>
  select(-file)

files2019 <- as.list(pre_list)
names(files2019) <- NULL
files2019v2 <- unlist(files2019[1])

translate <- schema(
  STORE_ID = float64()
)
# , partitioning = schema(STORE_ID = float64())
advan2019 <- open_dataset(files2019v2, format="csv",  read_options = list(block_size = 2048576L))
advan2019$STORE_ID
chk <- read.csv("data/advan_mp_Monthly_Patterns_Foot_Traffic-0-DATE_RANGE_START-2019-01-01.csv")
# chk2 <- chk[12,]
subsetAdvan <- advan2019 |> 
  select(-c(OPENED_ON, CLOSED_ON, PHONE_NUMBER))|>
  filter(REGION == "WI")

tic()
wi_dat2019 <- collect(subsetAdvan)
toc()