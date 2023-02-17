
# Invoke required libraries
library(survey)
library(foreign)
library(haven)
library(viridis)
library(tidyverse)
library(MEPS)

# Set options to deal with lonely psu
options(survey.lonely.psu='adjust')

# Read in data from FYC file --------------------------------------------------

# fyc20 = read_MEPS(year = 2020, type = "FYC") # 2020 FYC
fyc19 = read_MEPS(year = 2019, type = "FYC") # 2019 FYC
# fyc18 = read_MEPS(year = 2018, type = "FYC") # 2018 FYC

# Identify SSCs - follow instructions in section 3.5 to create one family per record, but 
# consolidate tibbles within each record to have individual-level details.

count_family_size <- function(df) {
  # First get list of PIDs
  pid_list <- df %>% 
    distinct(PID) %>% 
    nrow()
}

identify_same_sex_spouses <- function(df) {
  # Join PIDs table onto itself by SPOUIDs to determine spousal match-ups at the PID level
  # Then you can identify if the "left hand" and "right hand" sexes match.
  
  pid_list <- df %>% 
    distinct(PID, SEX, SPOUIDYY)
  
  pid_join <- pid_list %>% 
    inner_join(pid_list, by=c("PID"="SPOUIDYY")) %>% 
    mutate(sex_of_spouse = SEX.y,
           same_sex_lgl = SEX.x == SEX.y) %>% 
    select(PID, sex_of_spouse, same_sex_lgl)
  
  pid_join
}

count_married_individuals <- function(df) {
  pid_list <- df %>% 
    filter(MARRYYYX == 1) %>% 
    distinct(PID) %>% 
    nrow()
}

count_married_individuals_in_ssc <- function(df) {
  count <- df %>% 
    filter(same_sex_lgl == T) %>% 
    nrow()
}

# fyc20x  <- fyc20 %>% 
#   select(DUID, PID, DUPERSID, SEX, AGE20X, VARSTR, VARPSU, PERWT20F, MARRY20X, SPOUID20, FAMIDYR, FAMWT20F, FAMRFPYR) %>% 
#   filter(FAMWT20F > 0) %>%      # Per instruction in section 3.5
#   mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>% # Per instruction in section 3.5
#   rename(PERWTYYF=PERWT20F,
#          MARRYYYX=MARRY20X,
#          SPOUIDYY=SPOUID20,
#          FAMWTYYF=FAMWT20F,
#          AGEYYX=AGE20X) %>% 
#   group_by(DUIDFAMY) %>%  
#   tidyr::nest() %>% 
#   ungroup() %>% 
#   mutate(family_size = purrr::map_int(data, count_family_size)) %>% 
#   mutate(married_individuals = purrr::map_int(data, count_married_individuals)) %>% 
#   mutate(spouse_matrix = purrr::map(data, identify_same_sex_spouses)) %>% 
#   mutate(married_individuals_in_ssc = purrr::map_int(spouse_matrix, count_married_individuals_in_ssc))

fyc19x  <- fyc19 %>% 
  select(DUID, PID, DUPERSID, SEX, AGELAST, INSCOV19, REGION19, RACETHX, POVCAT19, TOTEXP19, VARSTR, VARPSU, PERWT19F, MARRY19X, SPOUID19, FAMIDYR, FAMWT19F, FAMRFPYR) %>% 
  filter(FAMWT19F > 0) %>%      # Per instruction in section 3.5
  mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>% # Per instruction in section 3.5
  rename(PERWTYYF=PERWT19F,
         MARRYYYX=MARRY19X,
         SPOUIDYY=SPOUID19,
         FAMWTYYF=FAMWT19F,
         AGEYYX=AGELAST,
         REGIONYY=REGION19,
         INSCOVYY=INSCOV19,
         TOTEXPYY=TOTEXP19,
         POVCATYY=POVCAT19) %>% 
  group_by(DUIDFAMY) %>%  
  tidyr::nest() %>% 
  mutate(family_size = purrr::map_int(data, count_family_size)) %>% 
  mutate(married_individuals = purrr::map_int(data, count_married_individuals)) %>% 
  mutate(spouse_matrix = purrr::map(data, identify_same_sex_spouses)) %>% 
  mutate(married_individuals_in_ssc = purrr::map_int(spouse_matrix, count_married_individuals_in_ssc))

# fyc18x  <- fyc18 %>% 
#   select(DUID, PID, DUPERSID, SEX, AGE18X, VARSTR, VARPSU, PERWT18F, MARRY18X, SPOUID18, FAMIDYR, FAMWT18F, FAMRFPYR) %>% 
#   filter(FAMWT18F > 0) %>%      # Per instruction in section 3.5
#   mutate(DUIDFAMY = stringr::str_c(DUID, FAMIDYR)) %>% # Per instruction in section 3.5
#   rename(PERWTYYF=PERWT18F,
#          MARRYYYX=MARRY18X,
#          SPOUIDYY=SPOUID18,
#          FAMWTYYF=FAMWT18F,
#          AGEYYX=AGE18X) %>% 
#   group_by(DUIDFAMY) %>%  
#   tidyr::nest() %>% 
#   mutate(family_size = purrr::map_int(data, count_family_size)) %>% 
#   mutate(married_individuals = purrr::map_int(data, count_married_individuals)) %>% 
#   mutate(spouse_matrix = purrr::map(data, identify_same_sex_spouses)) %>% 
#   mutate(married_individuals_in_ssc = purrr::map_int(spouse_matrix, count_married_individuals_in_ssc))

# We might need to pool to meet the threshold of n = 60 as described here in "Precision Guidelines"
# https://meps.ahrq.gov/survey_comp/precision_guidelines.shtml

# table(fyc18x$married_individuals_in_ssc)
table(fyc19x$married_individuals_in_ssc)
# table(fyc20x$married_individuals_in_ssc) 

fyc19x_flat <- fyc19x %>% 
  mutate(final_data = purrr::map2(data, spouse_matrix, ~ .x %>% left_join(.y, by=c("PID"="PID")))) %>% 
  select(-data, -spouse_matrix) %>% 
  group_by(DUIDFAMY, family_size, married_individuals, married_individuals_in_ssc) %>% 
  tidyr::unnest(final_data) %>% 
  ungroup() %>% 
  tidyr::replace_na(list(same_sex_lgl=F)) %>% 
  filter(AGEYYX > 0) %>% 
  filter(MARRYYYX == 1 & !is.na(sex_of_spouse)) %>% 
  mutate(unwt_persons = 1) %>% 
  mutate(AGE_GRP_2 = if_else(AGEYYX >= 65, "65+", "Under 65")) %>% 
  mutate(AGE_GRP_5 = case_when(AGEYYX < 5 ~ "Under 5",
                               AGEYYX >= 5 & AGEYYX <= 17 ~ "5 - 17",
                               AGEYYX >= 18 & AGEYYX <= 44 ~ "18 - 44",
                               AGEYYX >= 45 & AGEYYX <= 64 ~ "45 - 64",
                               AGEYYX >= 65 ~ "65+",
                               T ~ as.character(AGEYYX))) %>%
  mutate(INSCOV_DSC = case_when(INSCOVYY == 1 ~ "Any Private",
                                INSCOVYY == 2 ~ "Public Only",
                                INSCOVYY == 3 ~ "Uninsured",
                                T ~ as.character(INSCOVYY))) %>% 
  mutate(UNINS_FLG = case_when(INSCOVYY == 3 ~ "Uninsured",
                               INSCOVYY != 3 ~ "Insured",
                               T ~ as.character(INSCOVYY))) %>% 
  mutate(REG_DSC = case_when(REGIONYY == -1 ~ "Inapplicable",
                             REGIONYY == 1 ~ "Northeast",
                             REGIONYY == 2 ~ "Midwest",
                             REGIONYY == 3 ~ "South",
                             REGIONYY == 4 ~ "West",
                             T ~ as.character(REGIONYY))) %>% 
  mutate(RACE_DSC = case_when(RACETHX == 1 ~ "Hispanic",
                              RACETHX == 2 ~ "Non-Hispanic White Only",
                              RACETHX == 3 ~ "Non-Hispanic Black Only",
                              RACETHX == 4 ~ "Non-Hispanic Asian Only",
                              RACETHX == 5 ~ "Non-Hispanic Other Race or Multiple Race",
                              T ~ as.character(RACETHX))) %>% 
  mutate(POVCAT_DSC = case_when(POVCATYY == 1 ~ "Poor / Negative",
                                POVCATYY == 2 ~ "Near Poor",
                                POVCATYY == 3 ~ "Low Income",
                                POVCATYY == 4 ~ "Middle Income",
                                POVCATYY == 5 ~ "High Income",
                                T ~ as.character(POVCATYY))) %>% 
  mutate(HAS_EXP = if_else(TOTEXPYY > 0, "Had Healthcare Expenses", "Did Not Have Healthcare Expenses")) %>% 
  mutate(SEX_DSC = if_else(SEX == 1, "Male", if_else(SEX == 2, "Female", "Unknown"))) %>% 
  mutate(SSC_DSC = if_else(same_sex_lgl == T, "Individuals in Same-Sex Marriages", "Individuals Not in Same-Sex Marriages"))

# Define the survey design

mepsdsgn = svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~PERWTYYF,
  data = fyc19x_flat,
  nest = TRUE)

fyc19x_age_sex <- svyby(~unwt_persons, by = ~AGE_GRP_5 + SEX_DSC + SSC_DSC, FUN = svytotal, design = mepsdsgn) 

# visualize these demos to make sure we're comparing apples-to-apples

fyc19x_demo_gg1 <- fyc19x_age_sex %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = SEX_DSC,
                       y = unwt_persons)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=unwt_persons-se, ymax=unwt_persons+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ SSC_DSC, ncol = 2, scales="free_y", labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Number of Married Individuals by Marriage Classification and Sex",
       x = "Age Grouping",
       y = "Estimate of Individuals (Survey Weighted)",
       fill = "Sex",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") 

fyc19x_demo_gg1

fyc19x_age_sex_exp <- svyby(~TOTEXPYY, by = ~AGE_GRP_5 + SEX_DSC + SSC_DSC, FUN = svymean, design = mepsdsgn) 

fyc19x_demo_gg1e <- fyc19x_age_sex_exp %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = SEX_DSC,
                       y = TOTEXPYY)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=TOTEXPYY-se, ymax=TOTEXPYY+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::dollar) +
  facet_wrap(~ SSC_DSC, ncol = 2, labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Healthcare Expenditures by Marriage Classification and Sex",
       x = "Age Grouping",
       y = "Individual Healthcare Spend (Survey Weighted)",
       fill = "Sex",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") 

fyc19x_demo_gg1e

fyc19x_age_cov <- svyby(~unwt_persons, by = ~AGE_GRP_5 + INSCOV_DSC + SSC_DSC, FUN = svytotal, design = mepsdsgn) 

fyc19x_demo_gg2 <- fyc19x_age_cov %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = INSCOV_DSC,
                       y = unwt_persons)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=unwt_persons-se, ymax=unwt_persons+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ SSC_DSC, ncol = 2, scales="free_y", labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Number of Married Individuals by Marriage Classification and Health Plan Coverage",
       x = "Age Grouping",
       y = "Estimate of Individuals (Survey Weighted)",
       fill = "Health Plan Coverage",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") 

fyc19x_demo_gg2

fyc19x_age_cov_exp <- svyby(~TOTEXPYY, by = ~AGE_GRP_5 + INSCOV_DSC + SSC_DSC, FUN = svymean, design = mepsdsgn) 

fyc19x_demo_gg2e <- fyc19x_age_cov_exp %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = INSCOV_DSC,
                       y = TOTEXPYY)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=TOTEXPYY-se, ymax=TOTEXPYY+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ SSC_DSC, ncol = 2, labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Healthcare Expenditures by Marriage Classification and Health Plan Coverage",
       x = "Age Grouping",
       y = "Individual Healthcare Spend (Survey Weighted)",
       fill = "Health Plan Coverage",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") 

fyc19x_demo_gg2e

fyc19x_age_race <- svyby(~unwt_persons, by = ~AGE_GRP_5 + RACE_DSC + SSC_DSC, FUN = svytotal, design = mepsdsgn) 

fyc19x_demo_gg3 <- fyc19x_age_race %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = RACE_DSC,
                       y = unwt_persons)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=unwt_persons-se, ymax=unwt_persons+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ SSC_DSC, ncol = 2, scales="free_y", labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Number of Married Individuals by Marriage Classification and Race, Ethnicity",
       x = "Age Grouping",
       y = "Estimate of Individuals (Survey Weighted)",
       fill = "Race and Ethnicity",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") +
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 3))

fyc19x_demo_gg3

fyc19x_age_race_exp <- svyby(~TOTEXPYY, by = ~AGE_GRP_5 + RACE_DSC + SSC_DSC, FUN = svymean, design = mepsdsgn) 

fyc19x_demo_gg3e <- fyc19x_age_race_exp %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = RACE_DSC,
                       y = TOTEXPYY)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=TOTEXPYY-se, ymax=TOTEXPYY+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::dollar) +
  facet_wrap(~ SSC_DSC, ncol = 2, labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Healthcare Expenditures by Marriage Classification and Race, Ethnicity",
       x = "Age Grouping",
       y = "Individual Healthcare Spend (Survey Weighted)",
       fill = "Race and Ethnicity",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") +
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 3))

fyc19x_demo_gg3e

fyc19x_age_povcat <- svyby(~unwt_persons, by = ~AGE_GRP_5 + POVCAT_DSC + SSC_DSC, FUN = svytotal, design = mepsdsgn) 


fyc19x_demo_gg4 <- fyc19x_age_povcat %>% 
  mutate(povcat_ordered = fct_relevel(POVCAT_DSC, "High Income", "Middle Income", "Low Income", "Near Poor", "Poor / Negative")) %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = povcat_ordered,
                       y = unwt_persons)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=unwt_persons-se, ymax=unwt_persons+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  facet_wrap(~ SSC_DSC, ncol = 2, scales="free_y", labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Number of Married Individuals by Marriage Classification and Income",
       x = "Age Grouping",
       y = "Estimate of Individuals (Survey Weighted)",
       fill = "Income Level",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") +
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 3))

fyc19x_demo_gg4

fyc19x_age_povcat_exp <- svyby(~TOTEXPYY, by = ~AGE_GRP_5 + POVCAT_DSC + SSC_DSC, FUN = svymean, design = mepsdsgn) 

fyc19x_demo_gg4e <- fyc19x_age_povcat_exp %>% 
  mutate(povcat_ordered = fct_relevel(POVCAT_DSC, "High Income", "Middle Income", "Low Income", "Near Poor", "Poor / Negative")) %>% 
  ggplot(mapping = aes(x = AGE_GRP_5,
                       fill = povcat_ordered,
                       y = TOTEXPYY)) +
  scale_fill_viridis(discrete=T, begin=0.5, end = 1) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=TOTEXPYY-se, ymax=TOTEXPYY+se), width=.2,
                position=position_dodge(.9)) +
  theme_bw() +
  scale_y_continuous(labels = scales::dollar) +
  facet_wrap(~ SSC_DSC, ncol = 2, labeller = label_wrap_gen(width = 18, multi_line = TRUE)) +
  labs(title="Estimated Healthcare Expenditures by Marriage Classification and Income",
       x = "Age Grouping",
       y = "Individual Healthcare Spend (Survey Weighted)",
       fill = "Income Level",
       caption = "MEPS 2019 Full Year Consolidated Data File\n(https://meps.ahrq.gov/)") +
  theme(legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 3))

fyc19x_demo_gg4e


## Regressions
library(jtools)
mepsdsgn2 = svydesign(
  id = ~VARPSU,
  strata = ~VARSTR,
  weights = ~PERWTYYF,
  data = fyc19x_flat,
  nest = TRUE)

foo <- svyglm(TOTEXPYY ~ AGEYYX + as.factor(SEX) + as.factor(RACETHX) 
       + as.factor(REGIONYY) + as.factor(same_sex_lgl), design=mepsdsgn2) 

foo %>% summ


