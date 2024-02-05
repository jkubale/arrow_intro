advan <- open_dataset("data/advan_mp_Monthly_Patterns_Foot_Traffic-588-DATE_RANGE_START-2021-08-01.csv", format="csv", read_options = list(block_size = 2048576L))


advan_samp <- advan|>
  mutate(date_end = as_date(DATE_RANGE_END))|>
  filter(DATE_RANGE_END <= "2021-08-31 20:00:00")|>
  select(DATE_RANGE_END, date_end)|>
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

