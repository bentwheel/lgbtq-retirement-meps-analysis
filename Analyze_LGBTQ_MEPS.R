# This R Script is only intended to be called from the 'README.Rmd' Preprocessing Chunk and not intended to run on a standalone basis.

# Set options to deal with lonely PSUs. A PSU is a Primary Sampling Unit. Primary Sampling Units are divided among several sampling strata. The MEPS survey design package provides appropriate sampling weights for each strata in order for each sampling unit to be reweighted in proportion to the POI (Population of Interest - in this case ,the entire US).

# In some cases, our analysis might necessitate drilling down to very small subpopulations, which will whittle down the membership of some strata to 1 or fewer members. In this case, we might encounter some strata with a single member - a "lonely PSU" - at which point the Survey package will error out when computing the sample variance to determine the standard error for a particular statistic (mean, total sum, etc.) in our analyses. Setting this option will adjust the data in the single-PSU stratum so that it is centered at the entire sample mean instead of the particular stratum mean, which tends to be a more conservative computation of the variance and has the effect of contributing to a wider standard error estimate for any statistic of interest in the analysis.

# In short, the following line will conservatively recenter certain data points so that a standard error for statistics of interest (mean, total sum, etc.) are computable for all strata - even those containing a single PSU, with the tradeoff of a larger (and more conservative) magnitude of standard error.

# An excellent article that goes into more detail about this process (and expresses some concern about the magnitude of overconservatism that R's survey package employs in recentering the lonely PSU mean) can be read here:
# https://www.practicalsignificance.com/posts/bugs-with-singleton-strata/

options(survey.lonely.psu='adjust')

# The following lines of code make use of the custom MEPS R package developed by the MEPS staff. This package is not on CRAN and must be downloaded via Github using the "devtools" package, which is done in the "Initial_Setup" chunk of code in the 'README.Rmd' markdown file.

# Due to the desire to have statistically meaningful results on display in later sections of this analysis, I have decided to pull MEPS data files spanning the full years 2014 through 2019. Ideally I would have also pulled 2020, but since this project consists of an analysis of differences in healthcare spending patterns between demographic groups, and since these same spending patterns are likely to have been influenced by varying degrees regional differences in public attitudes/lockdowns/"pent-up" utilization patterns/etc. during the height of the pandemic, 2020 year data was not included.

# Download the 2019 Full Year Consolidated Data File
# https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-216
fyc19 = MEPS::read_MEPS(year = 2019, type = "FYC")

# Download the 2018 Full Year Consolidated Data File
# https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-209
fyc18 = MEPS::read_MEPS(year = 2018, type = "FYC")

# Download the 2017 Full Year Consolidated Data File
# https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-201
fyc17 = MEPS::read_MEPS(year = 2017, type = "FYC")

# Download the 2016 Full Year Consolidated Data File
# https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-192
fyc16 = MEPS::read_MEPS(year = 2016, type = "FYC")

# Download the 2015 Full Year Consolidated Data File
# https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-181
fyc15 = MEPS::read_MEPS(year = 2015, type = "FYC")

# Download the 2014 Full Year Consolidated Data File
# https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-171
fyc14 = MEPS::read_MEPS(year = 2014, type = "FYC")

# From the MEPS website at https://meps.ahrq.gov/mepsweb/data_stats/download_data_files.jsp:

# "The pooled linkage file contains the standardized variance strata and PSU variables for a pooled analysis of multiple years of MEPS data. The pooled replicates file contains 128 half sample indicators needed to calculate standard errors using balanced repeated replication (BRR) method either for a single year analysis or a pooled analysis of multiple years of MEPS data."
linkage = MEPS::read_MEPS(type = "Pooled linkage")

# Next, we will define some custom functions. These functions will be explained in context in subsequent documentation below at the time they are invoked, but I have provided a brief description now.

# This function takes as input a DUIDFAMY group data table and returns the integer number of rows in that data table. This should be equivalent to the field FAMSIZEYR for any record within that table, and this is tested after each preprocessing step.
count_family_size <- function(df) {
  # First get list of PIDs
  df %>% 
    distinct(PID) %>% 
    nrow()
}

# This function takes as input a DUIDFAMY group data table and returns the corresponding value of the FAMSZEYR column for the one record corresponding to the person designated as the family reference person, identified with the FAMRFPYR flag variable. This is used to perform a data quality check which validates that the count of family size calculated for each DUIDFAMY group by the previously-defined function is consistent with the family size reported for that DUIDFAMY group in the FAMSZEYR column.
check_family_size <- function(df) {
  # Retain only DUIDFAMY reference person
  (df %>% 
     filter(FAMRFPYR == 1))$FAMSZEYR
}

# This function takes as input a DUIDFAMY group data table and returns a data table that is the result of an inner join of the input data table onto itself, merging Person ID (PID) on the left-hand input table by equality to Spouse Person ID (SPOUIDYY) on the right-hand input table, and also merging on marriage status (left-hand and right-hand) by equality (to ensure that the analysis contains only married, cohabiting individuals). The output data table contains three fields: the PIDs of the married individuals that meet the inner join conditions, their genders, and a logical variable flag that is 1 if their genders are the same.
identify_same_gender_spouses <- function(df) {
  df %>% 
    select(PID, SEX, SPOUIDYY, MARRYYYX) %>% 
    inner_join(df %>% select(PID, SEX, SPOUIDYY, MARRYYYX),
               by=c("PID"="SPOUIDYY", "MARRYYYX"="MARRYYYX")) %>% 
    mutate(gender_of_spouse = SEX.y,
           same_gender_lgl = SEX.x == SEX.y) %>% 
    select(PID, gender_of_spouse, same_gender_lgl)
}

# This function takes as input a DUIDFAMY group data table and returns a count of the number of married individuals within that DUIDFAMY. It is used as a data quality check.
count_married_individuals <- function(df) {
  pid_list <- df %>% 
    filter(MARRYYYX == 1) %>% 
    distinct(PID) %>% 
    nrow()
}

# This function takes as input a DUIDFAMY group data table and returns a count of the number of married individuals within that DUIDFAMY who are in a same-gender marriage.
count_married_individuals_in_sgm <- function(df) {
  count <- df %>% 
    filter(same_gender_lgl == T) %>% 
    nrow()
}

# First, we must do some preprocessing with the MEPS FYC files we have downloaded. The following block of code performs the following steps for the 2019 FYC file.

fyc19_by_dufam  <- fyc19 %>% 
  # 1. Subsets only relevant columns out of the over roughly 1500 columns available.
  select(DUID, PID, DUPERSID, PANEL, SEX, AGELAST, INSCOV19, REGION19, RACETHX, POVCAT19, RXEXP19, TOTEXP19, TOTSLF19, ERTOT19, IPNGTD19, HHTOTD19, RXTOT19, VARSTR, VARPSU, PERWT19F, MARRY19X, SPOUID19, FAMIDYR, FAMWT19F, FAMRFPYR, FAMSZEYR, PROBPY42, HIBPDX, CHOLDX, DIABDX_M18) %>% 
  # 2. As we will be pooling the FYC 2019 and 2018 files, we wish to rename fields with a '19' to a more general (e.g., 'YY') label. We will do the same with 2018 fields with names that include '18', 2017 fields with names that include '17', etc. Note that the field DIABDX_M18 contains responses to a survey question which is only administered to respondents aged 18 or over, so this field is renamed entirely for the sake of convenience and the '18' has nothing to do with the year 2018. This is also likewise true for the field PROBPY42. Finally, since we will be losing information about what year the column contains, we will add a row that identifies these rows as coming from the 2019 FYC file.
  rename(PERWTYYF=PERWT19F,
         MARRYYYX=MARRY19X,
         SPOUIDYY=SPOUID19,
         FAMWTYYF=FAMWT19F,
         AGEYYX=AGELAST,
         REGIONYY=REGION19,
         INSCOVYY=INSCOV19,
         TOTEXPYY=TOTEXP19,
         RXEXPYY=RXEXP19,
         TOTSLFYY=TOTSLF19,
         POVCATYY=POVCAT19,
         ERTOTYY=ERTOT19,
         IPNGTDYY=IPNGTD19,
         RXTOTYY=RXTOT19,
         HHTOTDYY=HHTOTD19,
         PROBPYYY=PROBPY42,
         DIABDX=DIABDX_M18) %>% 
  mutate(MEPS_DATA_YEAR = 2019) %>% 
  # 3. Per section 3.5.2 of the MEPS FYC 2019 documentation manual linked above, a family consists of two or more persons living together in the same household who are related by blood, marriage, or adoption. As we want to use same-gender marriage as a loose proxy means for identifying same-gender individuals, we're going to first make sure we isolate our cohort of individuals to those who are part of a family unit, as defined by MEPS, which will include almost all married, cohabiting survey respondents. This requires that we perform the following steps:
  #     a. Restrict records to FAMWT19F (now renamed to FAMWTYYF) to positive nonzero weights only.
  filter(FAMWTYYF > 0) %>%
  #     b. Concatenate DUID (Dwelling Unit ID) and FAMIDYR (eligible members of eligible annualized families within a single Dwelling Unit ID) into a single variable known as DUIDFAMY.
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>% 
  # 4. Next we will group by this new variable and use the "nest" function to create a dataset of datasets, so that the resulting dataset will contain a single unique DUIDFAMY value in one column and the second column will consist of a table of all the individual PSUs which are members of that combination of Dwelling Unit ID and Family ID
  group_by(MEPS_DATA_YEAR, DUIDFAMY) %>%  
  tidyr::nest()

# DQC (Data Quality Check): Per the 2019 FYC documentation file Table 3.3, we should expect the above code to construct a data table that has 11,924 records.
nrow(fyc19_by_dufam) == 11924L

# We will now perform the same steps of preprocessing for the 2014 - 2018 files in descending order.
fyc18_by_dufam  <- fyc18 %>% 
  select(DUID, PID, DUPERSID, PANEL, SEX, AGELAST, INSCOV18, REGION18, RACETHX, POVCAT18, RXEXP18, TOTEXP18, TOTSLF18, ERTOT18, IPNGTD18, HHTOTD18, RXTOT18, VARSTR, VARPSU, PERWT18F, MARRY18X, SPOUID18, FAMIDYR, FAMWT18F, FAMRFPYR, FAMSZEYR, PROBPY42, HIBPDX, CHOLDX, DIABDX_M18) %>% 
  rename(PERWTYYF=PERWT18F,
         MARRYYYX=MARRY18X,
         SPOUIDYY=SPOUID18,
         FAMWTYYF=FAMWT18F,
         AGEYYX=AGELAST,
         REGIONYY=REGION18,
         INSCOVYY=INSCOV18,
         TOTEXPYY=TOTEXP18,
         RXEXPYY=RXEXP18,
         TOTSLFYY=TOTSLF18,
         POVCATYY=POVCAT18,
         ERTOTYY=ERTOT18,
         IPNGTDYY=IPNGTD18,
         RXTOTYY=RXTOT18,
         HHTOTDYY=HHTOTD18,
         PROBPYYY=PROBPY42,
         DIABDX=DIABDX_M18) %>% 
  mutate(MEPS_DATA_YEAR = 2018) %>% 
  filter(FAMWTYYF > 0) %>%      
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>%
  group_by(MEPS_DATA_YEAR, DUIDFAMY) %>%  
  tidyr::nest() 

# DQC: Per the 2018 FYC documentation file Table 3.3, we should expect the above code to construct a data table that has 12,475 records.
nrow(fyc18_by_dufam) == 12475L

fyc17_by_dufam  <- fyc17 %>% 
  select(DUID, PID, DUPERSID, PANEL, SEX, AGELAST, INSCOV17, REGION17, RACETHX, POVCAT17, RXEXP17, TOTEXP17, TOTSLF17, ERTOT17, IPNGTD17, HHTOTD17, RXTOT17, VARSTR, VARPSU, PERWT17F, MARRY17X, SPOUID17, FAMIDYR, FAMWT17F, FAMRFPYR, FAMSZEYR, PROBPY42, HIBPDX, CHOLDX, DIABDX) %>% 
  rename(PERWTYYF=PERWT17F,
         MARRYYYX=MARRY17X,
         SPOUIDYY=SPOUID17,
         FAMWTYYF=FAMWT17F,
         AGEYYX=AGELAST,
         REGIONYY=REGION17,
         INSCOVYY=INSCOV17,
         TOTEXPYY=TOTEXP17,
         RXEXPYY=RXEXP17,
         TOTSLFYY=TOTSLF17,
         POVCATYY=POVCAT17,
         ERTOTYY=ERTOT17,
         IPNGTDYY=IPNGTD17,
         RXTOTYY=RXTOT17,
         HHTOTDYY=HHTOTD17,
         PROBPYYY=PROBPY42) %>% 
  mutate(MEPS_DATA_YEAR = 2017) %>% 
  filter(FAMWTYYF > 0) %>%      
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>%
  group_by(MEPS_DATA_YEAR, DUIDFAMY) %>%  
  tidyr::nest()

# DQC: Per the 2017 FYC documentation file Table 3.3, we should expect the above code to construct a data table that has 12,756 records.
nrow(fyc17_by_dufam) == 12756L

fyc16_by_dufam  <- fyc16 %>% 
  select(DUID, PID, DUPERSID, PANEL, SEX, AGELAST, INSCOV16, REGION16, RACETHX, POVCAT16, RXEXP16, TOTEXP16, TOTSLF16, ERTOT16, IPNGTD16, HHTOTD16, RXTOT16, VARSTR, VARPSU, PERWT16F, MARRY16X, SPOUID16, FAMIDYR, FAMWT16F, FAMRFPYR, FAMSZEYR, PROBPY42, HIBPDX, CHOLDX, DIABDX) %>% 
  rename(PERWTYYF=PERWT16F,
         MARRYYYX=MARRY16X,
         SPOUIDYY=SPOUID16,
         FAMWTYYF=FAMWT16F,
         AGEYYX=AGELAST,
         REGIONYY=REGION16,
         INSCOVYY=INSCOV16,
         TOTEXPYY=TOTEXP16,
         RXEXPYY=RXEXP16,
         TOTSLFYY=TOTSLF16,
         POVCATYY=POVCAT16,
         ERTOTYY=ERTOT16,
         IPNGTDYY=IPNGTD16,
         RXTOTYY=RXTOT16,
         HHTOTDYY=HHTOTD16,
         PROBPYYY=PROBPY42) %>% 
  mutate(MEPS_DATA_YEAR = 2016) %>% 
  filter(FAMWTYYF > 0) %>%      
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>%
  group_by(MEPS_DATA_YEAR, DUIDFAMY) %>%  
  tidyr::nest()

# DQC: Per the 2016 FYC documentation file Table 3.3, we should expect the above code to construct a data table that has 13,587 records.
nrow(fyc16_by_dufam) == 13587L

fyc15_by_dufam  <- fyc15 %>% 
  select(DUID, PID, DUPERSID, PANEL, SEX, AGELAST, INSCOV15, REGION15, RACETHX, POVCAT15, RXEXP15, TOTEXP15, TOTSLF15, ERTOT15, IPNGTD15, HHTOTD15, RXTOT15, VARSTR, VARPSU, PERWT15F, MARRY15X, SPOUID15, FAMIDYR, FAMWT15F, FAMRFPYR, FAMSZEYR, PROBPY42, HIBPDX, CHOLDX, DIABDX) %>% 
  rename(PERWTYYF=PERWT15F,
         MARRYYYX=MARRY15X,
         SPOUIDYY=SPOUID15,
         FAMWTYYF=FAMWT15F,
         AGEYYX=AGELAST,
         REGIONYY=REGION15,
         INSCOVYY=INSCOV15,
         TOTEXPYY=TOTEXP15,
         RXEXPYY=RXEXP15,
         TOTSLFYY=TOTSLF15,
         POVCATYY=POVCAT15,
         ERTOTYY=ERTOT15,
         IPNGTDYY=IPNGTD15,
         RXTOTYY=RXTOT15,
         HHTOTDYY=HHTOTD15,
         PROBPYYY=PROBPY42) %>% 
  mutate(MEPS_DATA_YEAR = 2015) %>% 
  filter(FAMWTYYF > 0) %>%      
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>%
  group_by(MEPS_DATA_YEAR, DUIDFAMY) %>%  
  tidyr::nest()

# DQC: Per the 2015 FYC documentation file Table 3.3, we should expect the above code to construct a data table that has 13,800 records.
nrow(fyc15_by_dufam) == 13800L

fyc14_by_dufam  <- fyc14 %>% 
  select(DUID, PID, DUPERSID, PANEL, SEX, AGELAST, INSCOV14, REGION14, RACETHX, POVCAT14, RXEXP14, TOTEXP14, TOTSLF14, ERTOT14, IPNGTD14, HHTOTD14, RXTOT14, VARSTR, VARPSU, PERWT14F, MARRY14X, SPOUID14, FAMIDYR, FAMWT14F, FAMRFPYR, FAMSZEYR, PROBPY42, HIBPDX, CHOLDX, DIABDX) %>% 
  rename(PERWTYYF=PERWT14F,
         MARRYYYX=MARRY14X,
         SPOUIDYY=SPOUID14,
         FAMWTYYF=FAMWT14F,
         AGEYYX=AGELAST,
         REGIONYY=REGION14,
         INSCOVYY=INSCOV14,
         TOTEXPYY=TOTEXP14,
         RXEXPYY=RXEXP14,
         TOTSLFYY=TOTSLF14,
         POVCATYY=POVCAT14,
         ERTOTYY=ERTOT14,
         IPNGTDYY=IPNGTD14,
         RXTOTYY=RXTOT14,
         HHTOTDYY=HHTOTD14,
         PROBPYYY=PROBPY42) %>% 
  mutate(MEPS_DATA_YEAR = 2014) %>% 
  filter(FAMWTYYF > 0) %>%      
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>%
  group_by(MEPS_DATA_YEAR, DUIDFAMY) %>%  
  tidyr::nest()

# DQC: Per the 2014 FYC documentation file Table 3.3, we should expect the above code to construct a data table that has 13,421 records.
nrow(fyc14_by_dufam) == 13421L

# Now we will pool all years by vertically merging our pre-processed annual data files from 2014 - 2019
fyc14_to_19_by_dufam <- fyc19_by_dufam %>% 
  union_all(fyc18_by_dufam) %>% 
  union_all(fyc17_by_dufam) %>% 
  union_all(fyc16_by_dufam) %>% 
  union_all(fyc15_by_dufam) %>% 
  union_all(fyc14_by_dufam)

# Since we can pull any given year's data from this vertically merged data table, we can tidy up by removing now-redundant data tables to save on memory usage.
rm(fyc19_by_dufam)
rm(fyc18_by_dufam)
rm(fyc17_by_dufam)
rm(fyc16_by_dufam)
rm(fyc15_by_dufam)
rm(fyc14_by_dufam)
rm(fyc19)
rm(fyc18)
rm(fyc17)
rm(fyc16)
rm(fyc15)
rm(fyc14)

# Garbage collection / free mem
gc()

# Finally, we will compute some summary statistics on each DUIDFAMY row into new columns, including:
#   1. 'family_size_check': A quality check that computes the number of PSUs within each DUIDFAMY and subtracts that value from the value FAMSZEYR for the unique DUIDFAMY reference person (FAMRFPYR=1). This number should be zero in the vast majority of cases.
#   2. 'married_individuals': A count of married individuals within that DUIDFAMY - in the vast majority of cases, this should be 0 or 2. Other values can exist, such as 1 for a married individual within a family that does not occupy the same Dwelling Unit as their spouse, or 3 for such a person who resides in a Dwelling Unit / Family as another married couple, etc. We will look at a quality check of this.
#   3. 'spouse_matrix': another column containing a dataset consisting of each PID within that DUIDFAMY, their gender, their spouse's gender, and a logical variable indicating whether or not those genders are identical.
#   4. 'married_individuals_in_sgm': a conditional sum variable that sums up all individuals who are both married (using the column described in b, above) and in same-gender marriages (using the column described in c, above) 

# WARNING: This code takes a fair bit of time to run relative to the earlier steps.

# Build 'family_size_count' field
family_size_count <- purrr::map_int(fyc14_to_19_by_dufam$data, count_family_size,
                                    .progress = list(
                                      type="iterator",
                                      format = "{cli::pb_spin} 'family_size_count' (step 1/6) {cli::pb_percent}",
                                      clear=T))
family_size_count <- tibble(family_size_count = family_size_count)
fyc14_to_19_by_dufam <- fyc14_to_19_by_dufam %>% 
  bind_cols(family_size_count)
rm(family_size_count)

# Build 'family_size_check' field
family_size_check <- purrr::map_int(fyc14_to_19_by_dufam$data, check_family_size,
                                    .progress = list(
                                      type="iterator",
                                      format = "{cli::pb_spin} 'family_size_check' (step 2/6) {cli::pb_percent}",
                                      clear=T))
family_size_check <- tibble(family_size_check = family_size_check)
fyc14_to_19_by_dufam <- fyc14_to_19_by_dufam %>% 
  bind_cols(family_size_check) %>% 
  mutate(family_size_check = family_size_check - family_size_count)
rm(family_size_check)

# Build 'spouse_matrix' field
spouse_matrix <- purrr::map(fyc14_to_19_by_dufam$data, identify_same_gender_spouses,
                            .progress = list(
                              type="iterator",
                              format = "{cli::pb_spin} 'identify_same_gender_spouses' (step 3/6) {cli::pb_percent}",
                              clear=T))
spouse_matrix <- tibble(spouse_matrix = spouse_matrix)
fyc14_to_19_by_dufam <- fyc14_to_19_by_dufam %>% 
  bind_cols(spouse_matrix)
rm(spouse_matrix)

# Build 'married_individuals' field
married_individuals <- purrr::map_int(fyc14_to_19_by_dufam$data, count_married_individuals,
                                      .progress = list(
                                        format = "{cli::pb_spin} 'count_married_individuals' (step 4/6) {cli::pb_percent}",
                                        clear=T))
married_individuals <- tibble(married_individuals = married_individuals)
fyc14_to_19_by_dufam <- fyc14_to_19_by_dufam %>% 
  bind_cols(married_individuals)
rm(married_individuals)

# Build 'married_individuals_in_sgm' field
married_individuals_in_sgm <- purrr::map_int(fyc14_to_19_by_dufam$spouse_matrix, count_married_individuals_in_sgm,
                                             .progress = list(
                                               type="iterator",
                                               format = "{cli::pb_spin} 'count_married_individuals_in_sgm' (step 5/6) {cli::pb_percent}",
                                               clear=T))
married_individuals_in_sgm <- tibble(married_individuals_in_sgm = married_individuals_in_sgm)
fyc14_to_19_by_dufam <- fyc14_to_19_by_dufam %>% 
  bind_cols(married_individuals_in_sgm)
rm(married_individuals_in_sgm)

# Build 'final_data' field
# Here, we want to retain all the originally nested data at the individual person level alongside any custom same-gender marriage indicators that we computed in the previous step in one combined nested dataset for each DUFAMYID row in our combined 2014 - 2019 family-level dataset.
final_data <- purrr::map2(fyc14_to_19_by_dufam$data, fyc14_to_19_by_dufam$spouse_matrix, 
                          ~ .x %>% left_join(.y, by=c("PID"="PID")),
                          .progress = list(
                            type="iterator",
                            format = "{cli::pb_spin} 'consolidate final_data' (step 6/6) {cli::pb_percent}",
                            clear=T))
final_data <- tibble(final_data = final_data)
fyc14_to_19_by_dufam <- fyc14_to_19_by_dufam %>% 
  bind_cols(final_data) %>%
  # Next we will delete two dataset columns since they are redundant after the last line, to save on memory.
  select(-data, -spouse_matrix)
rm(final_data)

# We want to explore some one-way frequency tables to make sure these data quality checks are coming in as expected.
# Reported family size minus Count of unique PIDs within each DUIDFAMY - we should expect a value of ZERO for all 64,542 rows, for each DUIDFAMY group.
table(fyc14_to_19_by_dufam$family_size_check)

# Count of married individuals within each DUIDFAMY - expecting the vast majority of responses to be 0 or 2. Responses that are 0 consist of dwelling unit + family unit aggregations with no married persons and 2 are those with two married individuals. In rare cases, a family unit can have a married person who does not cohabit with their spouse, which generates a 1 or perhaps even a 3, if that married person lives in the same dwelling unit + family unit with another married couple that are cohabiting.
table(fyc14_to_19_by_dufam$married_individuals)

# Count of married individuals in Same-gender marriages within each DUIDFAMY - again expecting almost all rows to be 0 or 2, with 2 denoting all records identified as couples married to another PID of the same recorded gender within the same Dwelling Unit + Family Unit ID.
table(fyc14_to_19_by_dufam$married_individuals_in_sgm)

# Finally we will group by all fields which are non-nested dataset columns and call the unnest function, which will unnest the dataset columns and flatten our table so that it is once again at the individual-level of granularity and not the family unit+dwelling unit level.
# WARNING: THis code block (primarily the action of unnesting family-level tables into a flattened individual-level table) takes some time to complete.
fyc14_to_19_by_dufam_flattened <- fyc14_to_19_by_dufam %>%
  group_by(MEPS_DATA_YEAR, DUIDFAMY, family_size_count, family_size_check, married_individuals, married_individuals_in_sgm) %>% 
  tidyr::unnest(final_data) %>% 
  # Ungroup merely undoes the group_by statement called prior to unnesting.
  ungroup()

# DQC: To make sure, we want to know that the `same_gender_lgl` field is populated only for individuals who are listed as MARRIED (MARRYYYX == 1) so we will need to filter on that to remove any respondents in the data file who are cohabiting but in a non-marriage or post-marriage state (e.g., separated, MARRYYYX == 4) before we perform any subsequent analyses down the line.
table((fyc14_to_19_by_dufam_flattened %>% filter(!is.na(same_gender_lgl)))$MARRYYYX, useNA="always")

# At this stage, `fyc14_to_19_by_dufam_flattened` is a final flattened table with which to do our analysis. We will discuss the sample data using visualizations in the next chunk. Finally we will enrich our data with human-readable labels and factors now so that we can more easily apply these description fields to data visualizations later on.
fyc14_to_19_by_dufam_w_desc <-  fyc14_to_19_by_dufam_flattened %>% 
  # This is a variable to simply provide a sample unit basis to be applied to weighting for when we aggregate and determine counts by demographic cuts.
  mutate(Individuals = 1) %>% 
  # In some cases, respondents do not include age and it cannot be imputed using other data sources. These respondents are coded with a -1 for age. We do not wish to include these responses in our analysis.
  filter(AGEYYX > 0) %>% 
  arrange(MEPS_DATA_YEAR) %>% 
  mutate(MEPS_DATA_YEAR = forcats::fct_inorder(as.character(MEPS_DATA_YEAR))) %>% 
  # Finally we will define some categorical variables for labeling visualizations
  mutate(AGE_GRP_2 = if_else(AGEYYX >= 65, "65 and over", "0 - 64")) %>% 
  mutate(AGE_GRP_3 = case_when(AGEYYX < 18 ~ "Under 18",
                               AGEYYX >= 18 & AGEYYX < 65 ~ "18 - 64",
                               AGEYYX >= 65 ~ "65 and over",
                               T ~ as.character(AGEYYX))) %>%
  mutate(AGE_GRP_5 = case_when(AGEYYX < 5 ~ "Under 5",
                               AGEYYX >= 5 & AGEYYX <= 17 ~ "5 - 17",
                               AGEYYX >= 18 & AGEYYX <= 44 ~ "18 - 44",
                               AGEYYX >= 45 & AGEYYX <= 64 ~ "45 - 64",
                               AGEYYX >= 65 ~ "65 and over",
                               T ~ as.character(AGEYYX))) %>%
  mutate(AGE_GRP_9 = case_when(AGEYYX < 5 ~ "Under 5",
                               AGEYYX >= 5 & AGEYYX <= 17 ~ "5 - 17",
                               AGEYYX >= 18 & AGEYYX <= 29 ~ "18 - 29",
                               AGEYYX >= 30 & AGEYYX <= 39 ~ "30 - 39",
                               AGEYYX >= 40 & AGEYYX <= 49 ~ "40 - 49",
                               AGEYYX >= 50 & AGEYYX <= 59 ~ "50 - 59",
                               AGEYYX >= 60 & AGEYYX <= 69 ~ "60 - 69",
                               AGEYYX >= 70 & AGEYYX <= 79 ~ "70 - 79",
                               AGEYYX >= 80 ~ "80 and over",
                               T ~ as.character(AGEYYX))) %>%
  arrange(AGEYYX) %>% 
  mutate(AGE_GRP_9 = forcats::fct_inorder(AGE_GRP_9),
         AGE_GRP_5 = forcats::fct_inorder(AGE_GRP_5),
         AGE_GRP_3 = forcats::fct_inorder(AGE_GRP_3),
         AGE_GRP_2 = forcats::fct_inorder(AGE_GRP_2)) %>% 
  mutate(INSCOV_DSC = case_when(INSCOVYY == 1 ~ "Any Private",
                                INSCOVYY == 2 ~ "Public Only",
                                INSCOVYY == 3 ~ "Uninsured",
                                T ~ as.character(INSCOVYY))) %>% 
  mutate(UNINS_FLG_DSC = case_when(INSCOVYY == 3 ~ "Uninsured",
                                   INSCOVYY != 3 ~ "Insured",
                                   T ~ as.character(INSCOVYY))) %>% 
  arrange(INSCOVYY) %>% 
  mutate(INSCOV_DSC = forcats::fct_inorder(INSCOV_DSC),
         UNINS_FLG_DSC = forcats::fct_inorder(UNINS_FLG_DSC)) %>% 
  mutate(REG_DSC = case_when(REGIONYY == -1 ~ "Inapplicable",
                             REGIONYY == 1 ~ "Northeast",
                             REGIONYY == 2 ~ "Midwest",
                             REGIONYY == 3 ~ "South",
                             REGIONYY == 4 ~ "West",
                             T ~ as.character(REGIONYY))) %>% 
  arrange(REGIONYY) %>% 
  mutate(REG_DSC = forcats::fct_inorder(REG_DSC)) %>% 
  mutate(RACE_DSC = case_when(RACETHX == 1 ~ "Hispanic",
                              RACETHX == 2 ~ "Non-Hispanic White Only",
                              RACETHX == 3 ~ "Non-Hispanic Black Only",
                              RACETHX == 4 ~ "Non-Hispanic Asian Only",
                              RACETHX == 5 ~ "Non-Hispanic Other Race or Multiple Race",
                              T ~ as.character(RACETHX))) %>% 
  arrange(RACETHX) %>% 
  mutate(RACE_DSC = forcats::fct_inorder(RACE_DSC)) %>% 
  mutate(POVCAT_DSC = case_when(POVCATYY == 1 ~ "0% to less than 100%",
                                POVCATYY == 2 ~ "100% to less than 125%",
                                POVCATYY == 3 ~ "125% to less than 200%",
                                POVCATYY == 4 ~ "200% to less than 400%",
                                POVCATYY == 5 ~ "400% or more",
                                T ~ as.character(POVCATYY))) %>% 
  arrange(POVCATYY) %>% 
  mutate(POVCAT_DSC = forcats::fct_inorder(POVCAT_DSC)) %>%   
  mutate(HAS_EXP = if_else(TOTEXPYY > 0, "Had Healthcare Expenses", "Did Not Have Healthcare Expenses")) %>% 
  mutate(HAS_EXP = forcats::fct_inorder(HAS_EXP)) %>%   
  mutate(DIABDX_DSC = case_when(DIABDX == 1 ~ "Diagnosed with Diabetes", 
                                DIABDX == 2 ~ "Not Diagnosed with Diabetes", 
                                T ~ "Unknown")) %>% 
  mutate(DIABDX_DSC = forcats::fct_inorder(DIABDX_DSC)) %>%   
  mutate(HIBPDX_DSC = case_when(HIBPDX == 1 ~ "Diagnosed with High Blood Pressure", 
                                HIBPDX == 2 ~ "Not Diagnosed with High Blood Pressure", 
                                T ~ "Unknown")) %>% 
  mutate(HIBPDX_DSC = forcats::fct_inorder(HIBPDX_DSC)) %>%   
  mutate(CHOLDX_DSC = case_when(CHOLDX == 1 ~ "Diagnosed with High Cholesterol", 
                                CHOLDX == 2 ~ "Not Diagnosed with High Cholesterol", 
                                T ~ "Unknown")) %>% 
  mutate(CHOLDX_DSC = forcats::fct_inorder(CHOLDX_DSC)) %>%   
  mutate(SEX_DSC = if_else(SEX == 1, "Male", if_else(SEX == 2, "Female", "Unknown"))) %>% 
  mutate(SEX_DSC = forcats::fct_inorder(SEX_DSC)) %>%   
  mutate(SGM_DSC = case_when(same_gender_lgl == T ~ "Married Individuals in Same-Gender Marriages", 
                             same_gender_lgl == F ~ "Married Individuals Not in Same-Gender Marriages",
                             T ~ "Unmarried Individuals")) %>% 
  arrange(same_gender_lgl) %>% 
  mutate(SGM_DSC = forcats::fct_inorder(SGM_DSC)) %>%   
  mutate(FAMSZEYR_GRP_4 = case_when(FAMSZEYR <= 2 ~ "1 - 2 persons",
                                    FAMSZEYR >= 3 & FAMSZEYR <= 4 ~ "3 - 4 persons",
                                    FAMSZEYR >= 5 & FAMSZEYR <= 6 ~ "5 - 6 persons",
                                    FAMSZEYR >= 7 ~ "7+ persons")) %>% 
  arrange(FAMSZEYR) %>% 
  mutate(FAMSZEYR_GRP_4 = forcats::fct_inorder(FAMSZEYR_GRP_4)) %>% 
  # Divide survey weights by two and store in a new "pooled weight" column so that we can still refer to specific-year-only data if we would like to do so for any particular analysis. Directions to adjust the analytic weight variable (PERWTYYF) by division by 6 (the number of pooled years, 2014 - 2019) are in section 4.0 of the Pooled Linkage file documentation, here:
  # https://meps.ahrq.gov/data_stats/download_data/pufs/h036/h36u20doc.shtml#2
  mutate(POOLWTYY = PERWTYYF / 6)
rm(fyc14_to_19_by_dufam_flattened)

# Join to Pooled Linkages file - this file ensures we are not "double counting" in our weighting in a way that would botch our standard error calculations from panel participants sampled across multiple years. More info on the linkage process can be found at the following URL, in section "3.0 Linking Instructions":
linkage_sub <- linkage %>% 
  select(DUPERSID, PANEL, STRA9620, PSU9620)
rm(linkage)

fyc14_to_19_by_dufam_w_desc_weights <- fyc14_to_19_by_dufam_w_desc %>% 
  left_join(linkage_sub, by = c("DUPERSID", "PANEL"))
rm(fyc14_to_19_by_dufam_w_desc)

# Define the survey design - here we are using the pooled weights which were divided by two, and pooled ID/STRATA variables that were joined into our dataset, from the previous steps.
fyc14_to_19_by_dufam_final_svydsn <- 
  svydesign(id = ~PSU9620,
            strata = ~STRA9620,
            weights = ~POOLWTYY,
            data = fyc14_to_19_by_dufam_w_desc_weights,
            nest = TRUE)

# Now we'll create a tibble of survey designs corresponding by year
fyc14_svydsn_nopool <- 
  svydesign(id = ~VARPSU,
            strata = ~VARSTR,
            weights = ~PERWTYYF,
            data = fyc14_to_19_by_dufam_w_desc_weights %>% filter(MEPS_DATA_YEAR == 2014),
            nest = TRUE)

fyc15_svydsn_nopool <- 
  svydesign(id = ~VARPSU,
            strata = ~VARSTR,
            weights = ~PERWTYYF,
            data = fyc14_to_19_by_dufam_w_desc_weights %>% filter(MEPS_DATA_YEAR == 2015),
            nest = TRUE)

fyc16_svydsn_nopool <- 
  svydesign(id = ~VARPSU,
            strata = ~VARSTR,
            weights = ~PERWTYYF,
            data = fyc14_to_19_by_dufam_w_desc_weights %>% filter(MEPS_DATA_YEAR == 2016),
            nest = TRUE)

fyc17_svydsn_nopool <- 
  svydesign(id = ~VARPSU,
            strata = ~VARSTR,
            weights = ~PERWTYYF,
            data = fyc14_to_19_by_dufam_w_desc_weights %>% filter(MEPS_DATA_YEAR == 2017),
            nest = TRUE)

fyc18_svydsn_nopool <- 
  svydesign(id = ~VARPSU,
            strata = ~VARSTR,
            weights = ~PERWTYYF,
            data = fyc14_to_19_by_dufam_w_desc_weights %>% filter(MEPS_DATA_YEAR == 2018),
            nest = TRUE)

fyc19_svydsn_nopool <- 
  svydesign(id = ~VARPSU,
            strata = ~VARSTR,
            weights = ~PERWTYYF,
            data = fyc14_to_19_by_dufam_w_desc_weights %>% filter(MEPS_DATA_YEAR == 2019),
            nest = TRUE)

# Finally, clean up and save all the work we would like to save.
save(list = ls(all.names = TRUE), file=here::here("meps_lgbtq_data.rda"))
