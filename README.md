Healthcare Experiences of Elderly LGBTQ+ Individuals in the US: A Visual
Analysis Using Medical Expenditure Panel Survey (MEPS) Data
================
C. Seth Lester, ASA, MAAA
([Seth.Lester@milliman.com](mailto:seth.lester@milliman.com)) <br>
6 July 2023

*The following paper is a submission in reply to the [Society of
Actuaries’ Call for
Papers](https://www.soa.org/research/opportunities/call-for-papers-list/)
under the heading “[Aging and Retirement Issues for LGBTQ+ People –
Second
Invitation](https://www.soa.org/research/opportunities/call-for-essay-aging-retire-lgbtq/)”.*

# Background and Purpose

For some LGBTQ+-identifying subpopulations, the level of discrimination
we face in society is rapidly decreasing; for others, such as
transgender individuals, there are still impactful and endemic stigmas
in play which act as a barrier to living full and rewarding lives.
Barriers such as these have potentially inhibited the ability of many
people who identify as LGBTQ+ from enjoying the same protections of our
social safety net – such as healthcare and retirement security systems –
that are enjoyed by non-LGBTQ+-identifying people.

It is difficult today for analysts to credibly estimate how
retirement-related outcomes differ between LGBTQ+ and non-LGBTQ+
populations, or how to quantify the disparities of outcomes among
intersectional subpopulations that exist today within LGBTQ+
communities. One key reason for this difficulty is the lack of available
data that can help guide our policymaking apparatus towards better
regulations and protections for members of our society who are more
likely to be marginalized, stigmatized, or disadvantaged by systemic
factors. This includes LGBTQ+ people, of course, but heavily intersects
with people of color, women, religious minorities, immigrants, disabled
individuals, and countless other populations of interest within the
United States.

In the healthcare space, there is ample energy surrounding the important
work being done by organizations, both private and public, to better
understand the impacts of what are known as Social Determinants of
Health – “the conditions in the environments where people are born,
live, learn, work, play, worship, and age that affect a wide range of
health, functioning, and quality-of-life outcomes and risks” (as defined
by the [US Dept. of Health and Human
Services](https://health.gov/healthypeople/priority-areas/social-determinants-health)).

Social Determinants of Health (SDoH) can provide strong causal evidence
for how certain subpopulations of our society disproportionately
experience poor health outcomes . Consequently, population health
professionals and actuaries alike have an interest in better
understanding the relationships between SDoH and access to quality
healthcare that is both affordable and can be sustainably provided by
the care delivery system.

It is therefore reasonable to suspect that disparities in
retirement-related outcomes between LGBTQ+ and non-LGBTQ+ populations
are also highly dependent upon many of the same Social Determinants of
Health (SDoH) factors that heavily influence healthcare outcomes,
experiences, and costs.

In order to investigate this idea, I set out to explore the publicly
available [Medical Expenditure Panel
Survey](https://meps.ahrq.gov/mepsweb/) (MEPS) public data files to
determine if there are useful data available for distilling connections
between retirement-related outcomes, many of which depend extensively on
healthcare outcomes and lived socioeconomic experiences, which may be
very different for LGBTQ+ individuals.

In order to investigate this idea, I set out to explore the
publicly-available (MEPS) datasets to determine if there were useful
data available for distilling connections between retirement-related
outcomes, many of which depend extensively on healthcare outcomes, and
the lived socioeconomic experiences often encountered by LGBTQ+
individuals.

## About MEPS

MEPS has been administered since 1996, and according the [Agency for
Healthcare Research and Quality](https://www.ahrq.gov/) (AHRQ), which is
the government agency at MEPS’s helm, MEPS is a collection of “data on
the specific health services that Americans use, how frequently they use
them, the cost of these services, and how they are paid for, as well as
data on the cost, scope, and breadth of health insurance held by and
available to U.S. workers” ([Survey Background, MEPS
Homepage](https://meps.ahrq.gov/mepsweb/about_meps/survey_back.jsp)).

For those individuals seeking to learn more about how to conduct
analyses using MEPS data, you can find code examples written in both SAS
and R on the [MEPS Github page](https://github.com/HHS-AHRQ/MEPS).
Furthermore, the MEPS staff regularly conducts online training seminars.

As MEPS is a survey and therefore the data is either self-reported or
imputed, there are some situations in which individuals using this data
might want to perform additional quality checks. An example of quality
checking could consist of checking the count of individuals with a
non-null value for spouse ID (metadata not generated by the respondent)
against the count of individuals who indicated in response to a survey
question that they are married (data provided by the respondent).

Additionally, MEPS provides [statistical precision
guidelines](https://meps.ahrq.gov/survey_comp/precision_guidelines.shtml)
about making inferences with the data, which include restrictions and
guidance concerning minimum sample size and acceptable error rates. I
discuss this guidance further in a subsequent section.

## LGBTQ+ Individuals and MEPS Data

The MEPS questionnaire includes questions ranging from basic demography
facts to employment status, food stamp usage, diagnoses of key chronic
conditions, whether the respondent has a commercially or
government-administered health-plan, what medications they filled,
medical procedures they received, even down to the race or ethnicity of
their providers.

However, one piece of information that is glaringly absent from the
survey responses or imputed data is any mention of whether the
respondent identifies as LGBTQ+.

However, since it is possible to use the survey metadata to identify
respondents who are spouses of one another, and because MEPS provides
the self-reported gender of each respondent within each family unit and
household, this approach can be used to create a data set of all married
respondents, and furthermore, a label indicating which married
respondents are in same-gender marriages, which serves as a proxy
indicator of LGBTQ+ identity for the purposes of this analysis.

The R code that performs this analysis and prepares the data tables
visualizations that follow is available on [my personal Github
site](https://github.com/bentwheel/lgbtq-retirement-meps-analysis).

# Data and Methodology

Since the LGBTQ+-identifying population in the United States is a
relatively small subset of the overall US population, MEPS data PUFs
(Public Use Files) from surveys representative of years between 2014 and
2019 (see table below) have been pooled together to produce the data
visualizations and tables within this essay. The purpose of pooling
these PUFs is to create a final table that is sufficiently large to meet
MEPS’ [statistical precision
guidelines](https://meps.ahrq.gov/survey_comp/precision_guidelines.shtml)
for making inferences about population-level estimates of key statistics
relevant to the healthcare experiences of individuals in the US who are
(a) in same-gender marriages and (b) above the age of 65.

All MEPS Full Year Consolidated data PUFs listed in the following table
contain variables pertaining to survey administration, income,
person-level conditions, health status, disability days, quality of
care, employment, health insurance, and person-level medical care use
and expenditures.

| Data File                                                                                                                                                       | Description                                                                                                                                                                                                |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [2019 Full Year Consolidated Data File](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-216)                            | This file consists of MEPS survey data obtained in Rounds 3, 4, and 5 of Panel 23 and Rounds 1, 2, and 3 of Panel 24, the rounds for the MEPS panels covering calendar year 2019.                          |
| [2018 Full Year Consolidated Data File](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-209)                            | This file consists of MEPS survey data obtained in Rounds 3, 4, and 5 of Panel 22 and Rounds 1, 2, and 3 of Panel 23, the rounds for the MEPS panels covering calendar year 2018.                          |
| [2017 Full Year Consolidated Data File](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-201)                            | This file consists of MEPS survey data obtained in Rounds 3, 4, and 5 of Panel 21 and Rounds 1, 2, and 3 of Panel 22, the rounds for the MEPS panels covering calendar year 2017.                          |
| [2016 Full Year Consolidated Data File](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-192)                            | This file consists of MEPS survey data obtained in Rounds 3, 4, and 5 of Panel 20 and Rounds 1, 2, and 3 of Panel 21, the rounds for the MEPS panels covering calendar year 2016.                          |
| [2015 Full Year Consolidated Data File](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-181)                            | This file consists of MEPS survey data obtained in Rounds 3, 4, and 5 of Panel 19 and Rounds 1, 2, and 3 of Panel 20, the rounds for the MEPS panels covering calendar year 2015.                          |
| [2014 Full Year Consolidated Data File](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-171)                            | This file consists of MEPS survey data obtained in Rounds 3, 4, and 5 of Panel 18 and Rounds 1, 2, and 3 of Panel 19, the rounds for the MEPS panels covering calendar year 2014.                          |
| [MEPS 1996-2020 Pooled Linkage File for Common Variance Structure](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-036) | This HC-036 file contains the proper variance structure to use when making estimates from MEPS data that have been pooled over multiple years and where one or more years are from 1996-2001 or 2019-2020. |

## Identifying Individuals in Same-Gender Marriages in the MEPS Public Use Files

As specified earlier, there is no LGBTQ+ indicator in the MEPS survey
questions that are administered to respondents. Therefore, in this
essay, we will make the simplifying assumption that individuals in
same-gender marriages are members of the US subpopulation identifying as
LGBTQ+.

Below is an image consisting of several examples of actual records in
the 2019 MEPS Full Year Consolidated PUF to highlight how the data
elements within MEPS PUFs are used to determine individuals who are in
same-gender marriages.

<div class="figure" style="text-align: center">

<img src="Example_Table.png" alt="Fig. 1: Example Records in the 2019 MEPS PUFs"  />
<p class="caption">
Fig. 1: Example Records in the 2019 MEPS PUFs
</p>

</div>

There are many shortcomings to this approach, as this approach will fail
to identify certain individual respondents who may identify as LGBTQ+,
such as:

- Any male-identifying individual who is married to a female-identifying
  individual, in cases where at least one of the spouses identifies as
  LGBTQ+; and,
- All unmarried persons who identify as LGBQT+.

However, this approach will succeed in identifying the following
individual respondents:

- Any LGBTQ+-identifying individual married to a any other
  LGBTQ+-identifying individual, in cases where both spouses identify as
  the same binary gender.

While this approach does fail to identify large subgroups within the
broader LGBQT+ population in the United States, we can still use this
approach to determine if there are substantial differences in the
underlying demography, patient experiences, or incurred expenses between
some LGBQT+ subpopulations and otherwise-similar non-LGBQT+
subpopulations within the US.

In this essay, we will consider and even see some evidence supporting
the possibility that marriage (or cohabitation, more generally) have a
confounding influence on some of the population-level estimates of
measurements of interest (e.g., annual healthcare expenditures,
emergency room utilization, etc.). Therefore, most data visualizations
and data tables in this essay will present findings comparing key
population-level estimates between married individuals in same-gender
marriages against married individuals not in same-gender marriages in
order to control for the potential confounding effect of marriage or
cohabitation.

## MEPS Precision Guidelines for Population-Level Estimates

In most cases, the MEPS precision guidelines referenced earlier require
that any mean, count, ratio, etc. of categorical indicators (such as
race, gender, etc.) or numeric variables (such as “total healthcare
expenditures”) computed for any subpopulation in the MEPS data adhere to
two restrictions:

1.  The underlying sample data from which the estimates are derived
    should consist of at least 60 sampling units (in our case,
    individual respondents).
2.  The relative standard error (RSE) corresponding to any estimate of a
    statistic of interest, such as a mean, count, or ratio, must
    absolutely not exceed 0.5. If so, it should not be displayed.
    Furthermore, if the RSE of the corresponding population-level
    estimate exceeds 0.3, it must be called out in any charts or tables
    as potentially spurious. Relative standard error can be computed as
    $$ RSE = \frac{Std. Err}{Estimate} $$ and is displayed as a
    percentage in the data tables in [Appendix
    A](#appendix-a-data-tables) for all population-level estimates
    computed in this essay.

<div class="figure" style="text-align: center">

<img src="README_files/figure-gfm/count_individ_in_sample_unwt_nopool_plot-1.png" alt="Fig 2: Counts of Individuals in Sample Before Pooling Across Years"  />
<p class="caption">
Fig 2: Counts of Individuals in Sample Before Pooling Across Years
</p>

</div>

In the data visualization above, the minimum sample threshold required
by the MEPS precision standards guidelines is denoted by a dashed red
line.

Additionally, there should also be some concern about the statistical
validity of population-level estimates that are computed by applying
weights to very small cross-sectional subsets of the MEPS respondent
data, especially when the subpopulation of interest (in our case, LGBTQ+
individuals over age 65) was sampled across demographic strata (e.g.,
race, gender, etc.) that have little to do with the demographic subset
we are attempting to study in this essay.

As a validation exercise, we will compute population-level estimates of
total counts of individuals in same-gender marriages below, and then
compare these results to estimates of total counts of individuals in
same-gender marriages drawn from survey data not related to MEPS. In the
following table, we can see the computed population-level estimates for
the total number of married individuals within the United States, broken
out by MEPS survey year.

<img src="README_files/figure-gfm/count_individ_in_sample_wt_nopool-1.png" style="display: block; margin: auto;" />

## Evaluating Visualizations of Population-level Estimates

Please note that each of the solid bars in the data visualizations
within this essay extend upwards from the x-axis to the survey-weighted
estimate of the statistic of interest for the entire US population
(generally an estimate of the mean, unless otherwise specified). The
error bars accompanying each solid bar represent the upper and lower
bounds of the 95% confidence interval around the corresponding
population-level estimate.

In lay terms, you can imagine each solid bar as representing the “true”
population measure, but because this chart is presenting an *estimate*
of the “true” population measure based on survey data, you should
interpret the bar to be “fuzzy” in length but still “almost certainly”
(95%) contained within the boundaries of the error bars. In other words,
we are confident at a 95% level that the “true” population-level measure
of interest, if we were able to survey the entire US population, falls
somewhere in between the two extreme points of the associated error bar.

## Validating Population-level Estimates

As you inspect the data visualizations in this essay, please refer to
the accompanying data table for the respective visualizations in
[Appendix A](#appendix-a-data-tables) for additional information about
the estimates or their variability and statistical validity. Throughout
the course of this essay, I will take every opportunity to
cross-reference population-level estimates derived from MEPS data
against available 3rd-party data sources in order to provide some level
of external validation.

Let us take for example the data from 2016, which represents the US
population one year after the landmark Supreme Court decision in
*Obergefell v. Hodges* that effectively legalized same-gender marriages
across the US. Same-gender marriages were already legal in several, but
not all, US geographies at the time. In the visualization and
accompanying data table above, we see that the population-level estimate
of the number of individuals ages 18 - 64 in same-gender marriages in
the US is centered at 982,877 with a 95% confidence interval spanning
from 666,223 to 1,299,532. The corresponding estimate for individuals in
same-gender marriages ages 65 and up is 167,152, and is marked as
potentially spurious due to a high RSE (relative standard error),
largely as a result of small sample cardinality for this particular
subpopulation.

One external source we can use to externally validate this estimate is
the [American Community
Survey](https://www.census.gov/programs-surveys/acs) for the same year
(2016), which places an [estimated count of individuals living in
“Same-Sex Married Couple
Households”](https://www.census.gov/content/dam/Census/library/publications/2021/demo/p70-167.pdf)
(p. 22) at around 1,000,000 individuals, with slightly more female
individuals comprising this total than males.

Also note that, for each year of MEPS data, the 95% confidence interval
around the population-level estimates of the total number married
individuals *not* in same-gender marriages is far smaller than it is for
the estimate of the count of individuals in same-gender marriages, due
to the fact that the latter subpopulation is sampled far less frequently
in the underlying data than the former. In fact, in some years, the
representative sample is so small for same-gender married individuals
over age 65 that the computed lower bound of the 95% confidence interval
extends into negative territory, which is nonsensical. Avoiding this
kind of nonsensical presentation of statistical variability around an
estimate derived from MEPS data is the primary reasoning given by MEPS
for imposing the RSE restriction in their statistical precision
guidelines.

Displaying nonsensical error bars on the following visualization is done
for explanatory purposes only. Going forward, subsequent data
visualizations in this essay will be constructed by suppressing any and
all subgroups in which the standard error of the population-level
estimate exceeds the 50% RSE threshold specified in the MEPS statistical
precision guidelines (denoted in corresponding data tables by the symbol
“†”).

<img src="README_files/figure-gfm/count_individ_in_sample_unwt_pool-1.png" style="display: block; margin: auto;" />

## Population-level Estimates After Pooling MEPS Data Years

Since our aim is to compare the experiences or healthcare expenses
between LGBQT+ subpopulations and non-LGBQT+ subpopulations with a focus
on individuals age 65 and up, we will not be able to meet the basic MEPS
precision guidelines described above without pooling across multiple
years. This is due to the fact that any single-year MEPS file lacks the
required number of respondents (*n* \>= 60) who are age 65 and up and in
same-gender marriages.

MEPS prescribes a methodology for pooling across multiple data years
within [the documentation for the Pooled Linkage
PUF](https://meps.ahrq.gov/data_stats/download_data/pufs/h036/h36u20doc.shtml).
This PUF contains survey weights and variances at the sampling unit and
demographic stratum level that enables pooling across multiple years.

Once pooling from 2014 - 2019 is completed, we can see that both age
groups in the same-gender marriage subpopulation meet the minimum sample
size of 60 required by the MEPS statistical precision guidelines (*n* =
435 for the 18 - 64 age band, *n* = 62 for the over 65 age band).
However, even with over 60 respondents, we are likely to encounter a
good deal of variability around the estimates of measurements for the
subpopulations of which these respondents are representative.

<img src="README_files/figure-gfm/count_individ_in_sample_wt_pool-1.png" style="display: block; margin: auto;" />

## External Validation of Estimates Computed Using Pooled MEPS Data

When using the pooled 2014 - 2019 data to compute population-level
estimates, we arrive at an estimate of 1,051,043 total individuals in
same-gender marriages within the US, arrived at simply adding the
estimated totals for each subgroup (900,950 for the “18 to 64” age band,
plus 150,093 for the “65 and over” band).

To determine the 95% confidence interval around this estimate, we can
simply take the square root of the sum of squared confidence interval
radii given for each subgroup’s estimate,
$\sqrt{ (1.959964 * 90,969)^2 + (1.959964 * 39,229)^2 }$, to arrive at a
the 95% confidence interval radius for our combined estimate of the
total number of same-gender marriages within the US. The 95% confidence
interval around this estimate spans from 856,875 to 1,245,211.

Once again, we can compare these estimates to the [findings from the
American Community Survey for
2019](https://www.census.gov/content/dam/Census/library/publications/2021/acs/acsbr-005.pdf)
which reports the total estimated count of same-sex married individuals
at 1,136,220 (two times the number of same-sex married couples
*households* reported in Table 1, on page 2), which falls relatively
close to the center of the 95% confidence interval around our
population-level estimate for the same statistic.

<img src="README_files/figure-gfm/marriage_class_and_gender-1.png" style="display: block; margin: auto;" />

<img src="README_files/figure-gfm/marriage_class_and_plan_coverage-1.png" style="display: block; margin: auto;" />

<img src="README_files/figure-gfm/marriage_class_and_race_ethnicity-1.png" style="display: block; margin: auto;" />

<img src="README_files/figure-gfm/marriage_class_and_income-1.png" style="display: block; margin: auto;" />

One finding I took away from these visualization exercises that was
surprising to me is that marriage by race/ethnicity appears to be
proportionally similar between same-gender and different-gender
marriages, with the exception of Hispanic and non-Hispanic Asian groups,
where there appears to be less adoption of same-sex marriages in the
18-65 age ranges in these race and ethnicity groupings. This could
potentially indicate a greater deal of social acceptance of same-sex
marriages among non-Hispanic white populations.

This is an important point of discussion as it illustrates the need for
researchers and policymakers to better understand the idea of
intersectionality within the many subpopulations within LGBTQ+ groups.
As marriage tends to confer financial security and stabilization
benefits, to both participants in the couple, then it follows that
LGBTQ+ individuals who are white are more likely to access these
benefits than their non-white LGBTQ+ counterparts, which can contribute
to additional disparities along racial lines which are fully contained
within the LGBTQ+ population.

# Visualizing Differences in Healthcare Experiences for LGBTQ+ Subpopulations

It is also the case that LGBTQ+ individuals can possess unique
healthcare needs or face different barriers to access to healthcare,
both of which can move the needle on the cost of healthcare –
particularly in retirement, in which individuals are more likely to face
one or more costly chronic conditions such as heart disease, diabetes,
or asthma.

To better determine if there are relationships between these demographic
factors and the cost of care – particularly for older age groups, I
prepared the following series of visualizations below that examine the
average individual expenditures broken out on the same demographic
features as the visualizations above.

## Emergency Room Utilization and Average Inpatient Length of Stay

lorem ipsum

Unmarried individuals are displayed to show a known benefit from
cohabitation.

“Impact of marital status on outcomes in hospitalized patients. Evidence
from an academic medical center”
<https://pubmed.ncbi.nlm.nih.gov/7503606/> “In additional analyses,
multivariable models estimated that hospital charges and length of stay
were 5% and 8% higher (P \< .001), respectively, for unmarried than for
married patients.”

“Marriage Status Predicts Hospital Outcomes Following Orthopedic Trauma”
<https://doi.org/10.1177/2151459319898648>

Validation Against:
<https://www.kff.org/other/state-indicator/emergency-room-visits-by-ownership/>

<img src="README_files/figure-gfm/er_util_marriage_class-1.png" style="display: block; margin: auto;" />

lorem ipsum
<https://www.kff.org/other/state-indicator/inpatient-days-by-ownership/?currentTimeframe=0&sortModel=%7B%22colId%22:%22Location%22,%22sort%22:%22asc%22%7D>

Reported on HCA earnings call - an important financial metric!

<img src="README_files/figure-gfm/inpatient_los_marriage_class-1.png" style="display: block; margin: auto;" />

## Drug Costs are a Large Part of Healthcare Costs for Seniors

In the 2022 Inflation Reduction Act signed into law by President Biden,
[several reforms to the Medicare Part D
program](https://www.milliman.com/en/insight/inflation-reduction-act-health-plans-and-part-d-sponsors-need-to-know)
are set to be implemented in the coming years. While the overall bill
was passed on a party-line vote, the legislated Part D reforms reflect a
genuinely bipartisan perception of political urgency around reducing the
cost burden of access to low-cost and lifesaving pharmaceutical
therapies for seniors, many of whom are living with one or more chronic
and behavioral health conditions.

A substantial portion of the total medical expenditures incurred by
individuals in retirement are attributable to pharmacy spend, as we are
able to see in the visualizations of total healthcare spend above, which
include breakout estimates of total individual healthcare spend as well
as RX spend alone. Across most socioeconomic strata, racial/ethnicity
boundaries, and other demographic classifiers, individuals age 65 and up
appear to spend more money on pharmaceutical therapies than their
younger counterparts who are in their working years of adulthood.

<img src="README_files/figure-gfm/exp_marriage_class-1.png" style="display: block; margin: auto;" />

lorem ipsum drug utilization

<img src="README_files/figure-gfm/rx_util_marriage_class-1.png" style="display: block; margin: auto;" />

validated against:
<https://www.kff.org/health-costs/state-indicator/retail-rx-drugs-per-capita/>

## Prevalence of Chronic Conditions

Senior citizens often make use of low-cost generic medications to manage
their chronic health conditions such as diabetes, hyperlipidemia (high
cholesterol), or hypertension (high blood pressure). Some examples of
very common drugs include non-insulin blood glucose reducing agents like
[metformin](https://mor.nlm.nih.gov/RxNav/search?searchBy=String&searchTerm=metformin)
used for treating Type 2 Diabetes, statins like
[atorvastatin](https://mor.nlm.nih.gov/RxNav/search?searchBy=String&searchTerm=atorvastatin)
(brand name “Lipitor”) used for treating high cholesterol, or ACE
inhibitors like
[lisinopril](https://mor.nlm.nih.gov/RxNav/search?searchBy=String&searchTerm=lisinopril)
(brand names “Prinivil” or “Zestril”) to treat hypertension.

Type 2 diabetes, high cholesterol, and hypertension are three of the
leading causes of many other high-cost and potentially avoidable medical
complications. Therefore, if senior citizens are able to manage these
conditions with regular visits to their primary care providers and by
adherence to low-cost drug therapies such as the drugs discussed above,
then seniors are less likely to incur potentially avoidable medical
costs down the line, which can ultimately help safeguard their their
financial security and well-being in retirement.

<img src="README_files/figure-gfm/chronic_cond_marriage_class-1.png" style="display: block; margin: auto;" />

## Family Size Can Impact Healthcare Outcomes for Seniors

One feature that can drive the total cost of care at the individual
level is family size. Larger families within the same dwelling unit can
help take care of one another when sick, coordinate transportation to
and from sites where healthcare is provided, manage childcare duties so
that adults are able to arrange for healthcare services, and so on.
Several studies have shown a linkage between medication adherence and
family size, particularly among families in low-income socioeconomic
strata.

“Older Adults’ Social Relationships and Health Care Utilization: A
Systematic Review” <https://pubmed.ncbi.nlm.nih.gov/29470115/>

For a number of reasons not discussed further here, the family size of
families that include individuals within same-sex marriages is likely to
be smaller than that of their counterparts in marriages not regarded as
same-sex. As such, it is worth exploring how family size can impact the
total individual healthcare spend across age groups.

<img src="README_files/figure-gfm/exp_vs_famsize-1.png" style="display: block; margin: auto;" />

# Conclusion

Due to the lack of data currently available that describes the
healthcare experiences specific to LGBTQ+ populations, we must continue
to be creative about how we source information that helps build policy
and products to better strengthen the lives of LGBTQ+ individuals who
are currently enjoying retirement, as well as those who will be retiring
soon.

While we’ve only just skimmed the surface of what MEPS has to offer,
MEPS provides an excellent cross section of data collected in a
well-designed survey framework that can aid key decision makers as they
go about analyzing the impacts that Social Determinants of Health have
on retirement-related outcomes.

Some examples of other potentially interesting variables in the context
of examining retirement-related outcomes alongside the ones I’ve shown
in this paper include:

    MILDIF31        DIFFICULTY WALKING A MILE - RD 3/1 
    MIAGED          AGE OF DIAGNOSIS-HEART ATTACK(MI) 
    WHTLGSPK        WHAT LANGUAGE SPOKEN OTHER THAN ENGLISH 
    DDNWRK19        # DAYS MISSED WORK DUE TO ILL/INJ 2019 
    ADRESP42        SAQ 12 MOS: DR SHOWED RESPECT 
    PROBPY42        FAMILY HAVING PROB PAYING MEDICAL BILLS 

And while the particular method I’ve demonstrated in this paper for
identifying LGBTQ+ individuals and experiences certainly does have its
flaws, we have to do the best we can with the information we have – and
publicly available data on the needs of LGBTQ+ individuals at or near
retirement age is, at times, frustratingly scarce.

Finally, this sort of work encourages discussions that broaden our
understanding of how systemic disparities act with intersectionality
among other groups and subpopulations. And while understanding the
concept of intersectionality is one thing, being able to quantify the
result of intersectional disparate outcomes, even if the data isn’t
perfect, is entirely more useful.

# Appendix A: Data Tables

<img src="tables/tbl1.png" style="display: block; margin: auto;" /><img src="tables/tbl2.png" style="display: block; margin: auto;" /><img src="tables/tbl3.png" style="display: block; margin: auto;" /><img src="tables/tbl4.png" style="display: block; margin: auto;" /><img src="tables/tbl5.png" style="display: block; margin: auto;" /><img src="tables/tbl6.png" style="display: block; margin: auto;" /><img src="tables/tbl7.png" style="display: block; margin: auto;" /><img src="tables/tbl8.png" style="display: block; margin: auto;" /><img src="tables/tbl9.png" style="display: block; margin: auto;" /><img src="tables/tbl10.png" style="display: block; margin: auto;" /><img src="tables/tbl11.png" style="display: block; margin: auto;" /><img src="tables/tbl12.png" style="display: block; margin: auto;" />
