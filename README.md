Social Determinants of Health… and Wealth?
================
C. Seth Lester, ASA
(<a href="mailto:cslester@gmail.com">cslester@gmail.com</a>)<br>
14 February 2023

*The following paper is a submission in reply to the [Society of
Actuaries’ Call for
Papers](https://www.soa.org/research/opportunities/call-for-papers-list/)
under the heading “[Aging and Retirement Issues for LGBTQ+ People –
Second
Invitation](https://www.soa.org/research/opportunities/call-for-essay-aging-retire-lgbtq/)”.*

# Health and Wealth Are Heavily Socially Determined

For many years, people who identify as LGBTQ+ have endured
discrimination from a wide variety of sources, such as from laws and
regulations at all levels of government, or as a result of the ebb and
flow of occupational attitudes over time, and even from members in our
own community.

For some LGBTQ+-identifying subpopulations, the level of discrimination
we face in society is rapidly waning; for others, such as transgender
individuals, there are still impactful and endemic stigmas in play which
act as a barrier to these individuals from living full and rewarding
lives. Barriers such as these have likely inhibited the ability of many
people who identify as LGBTQ+ from enjoying the same protections of our
social safety net – such as healthcare and retirement security systems –
that are enjoyed by non-LGBTQ+-identifying people.

It is difficult today for analysts to credibly estimate how
retirement-related outcomes differ between LGBTQ+ and non-LGBTQ+
populations, or how to quantify the disparities of outcomes among
intersectional subpopulations that exist today within LGBTQ+
communities. One primary reason motivating this difficulty stems from
the lack of available data that can help guide our policymaking
apparatus towards better regulations and protections for members of our
society who are more likely to be marginalized, stigmatized, or
disadvantaged by systemic factors. This includes LGBTQ+ people, of
course, but heavily intersects with people of color, women, religious
minorities, immigrants, disabled individuals, and countless other
populations of interest that comprise the greater whole of the nation.

In the healthcare space, there is ample energy surrounding the important
work being done by organizations, both private and public, to better
understand the impacts of what are known as Social Determinants of
Health – “the conditions in the environments where people are born,
live, learn, work, play, worship, and age that affect a wide range of
health, functioning, and quality-of-life outcomes and risks” (definition
lifted from the [US Dept. of Health and Human
Services](https://health.gov/healthypeople/priority-areas/social-determinants-health).

Social Determinants of Health (SDoH) can provide strong causal evidence
for why certain subpopulations of our society are marginalized or
disadvantaged by systemic factors. Consequently, population health
professionals and actuaries alike have an interest in better
understanding the relationships between SDoH and access to quality
healthcare that is both affordable and can be sustainably provided by
the care delivery system.

It is therefore reasonable to suspect that disparities in
retirement-related outcomes between LGBTQ+ and non-LGBTQ+ populations
are also highly dependent upon many of the same Social Determinants of
Health (SDoH) factors that heavily influence healthcare outcomes,
experiences, and costs.

In order to investigate this idea, I set out to explore the
publicly-available [Medical Expenditure Panel
Survey](https://meps.ahrq.gov/mepsweb/) (MEPS) datasets to determine if
there were useful data available for distilling connections between
retirement-related outcomes, many of which depend extensively on
healthcare outcomes, and the lived socioeconomic experiences often
encountered by LGBTQ+ individuals.

# About MEPS

The Medical Expenditure Panel Survey has been administered since 1996,
and according the [Agency for Healthcare Research and
Quality](https://www.ahrq.gov/) (AHRQ), which is the government agency
at MEPS’ helm, MEPS is a collection of “data on the specific health
services that Americans use, how frequently they use them, the cost of
these services, and how they are paid for, as well as data on the cost,
scope, and breadth of health insurance held by and available to U.S.
workers” ([Survey Background, MEPS
Homepage](https://meps.ahrq.gov/mepsweb/about_meps/survey_back.jsp)).

On the [MEPS Github page](https://github.com/HHS-AHRQ/MEPS), you’ll find
several excellent code examples written in both SAS and R which I used
to familiarize myself with the layout of the data. Furthermore, the MEPS
staff regularly conducts well-crafted online training seminars.

As MEPS is a survey and therefore the data is either self-reported or
imputed, there are some situations in which you’ll find the data isn’t
perfect. And furthermore, MEPS provides [some basic ground
rules](https://meps.ahrq.gov/survey_comp/precision_guidelines.shtml)
about making inferences with the data, which include restrictions and
guidance concerning how much you are permitted to slice and dice the
data before your unweighted sample of respondents is too small. I
discuss this guidance further in a subsequent section.

# My Approach: MEPS and LGBTQ+ Individuals

The MEPS questionnaire is broad and comprehensive, and includes
questions ranging from basic demography facts to employment status, food
stamp usage, diagnoses of key chronic conditions, who pays for the
respondent’s insurance, what medications they filled, medical procedures
they received, even down to the ethnicity of their providers.

However, one question that is glaringly absent from the panel survey
questionnaire is any mention of the respondent’s LGBTQ+ identity. There
are very good reasons to suspect adding these questions would impose
unnecessary sample biases.

At any rate, because MEPS does provide a way to identify respondents in
the survey who are spouses of one another, and because MEPS provides the
self-reported sex of each respondent, one can use this approach to
create a dataset of all married respondents, and then easily label which
are in same-sex marriages and which are not in same-sex marriages.

The R code that performs this analysis and prepares the data
visualizations that follow is available on my personal Github site (the
repository and content which you are currently reading).

# Caveats and Housekeeping

In the following infographics, I have used the 2019 datasets available
on the MEPS website. Note that these are actual populations estimates
based on the weighted survey design, so the population counts and dollar
amounts below are intended to be representative of the US population, in
context.

Next, please take care to note that MEPS recommends [not displaying
estimates of any kind with a RSE (relative standard error) of .5 or
higher](https://meps.ahrq.gov/survey_comp/precision_guidelines.shtml)
due to the high degree of sampling error. Therefore, in the following
images, take care to note that error bars extending more than 50% into
the shaded bar should not be taken at face value. Conversely, error bars
extending no more than 30% into the shaded bar can be regarded as
sufficiently precise.

Finally, I want to reiterate that while the distinction between sex and
gender is not lost on me (in particular in the context of analyzing
causal connections between SDoH and healthcare outcomes), I must point
out that the variable called “SEX” in the data is indeed, according to
the MEPS handbook, intended to express the respondent’s gender. The
handbook also points out that sometimes this value is assigned based on
the name of the respondent or based on the relationship to other
respondents in the same family or dwelling unit, which is obviously not
ideal.

For consistency’s sake, I continue to refer to the variable in the
context of sex and not gender in the visualizations below. This also
means it is possible that some of these “same-sex” and “non-same-sex”
couples could potentially include transgender individuals, but I will
proceed with the materiality assumption that this does not occur in the
data very frequently.

# Exploring the Demographic Composition of Same-Sex Marriages in the US

In the following infographics, I attempt to better understand the
demographic composition of individuals in same-sex marriages by
exploring the relationships between age, sex, income level, race, and
insurance coverage status between the same-sex and non-same-sex marriage
cohorts.

![](README_files/figure-gfm/Demographic_Plots-1.png)<!-- -->![](README_files/figure-gfm/Demographic_Plots-2.png)<!-- -->![](README_files/figure-gfm/Demographic_Plots-3.png)<!-- -->![](README_files/figure-gfm/Demographic_Plots-4.png)<!-- -->

One finding I took away from these visualization exercises that was
surprising to me is that marriage by race/ethnicity appears to be
proportionally similar between same-sex and different-sex marriages,
with the exception of Hispanic and non-Hispanic Asian groups, where
there appears to be less adoption of same-sex marriages in the 18-65 age
ranges in these race and ethnicity groupings. This could potentially
could indicate a greater deal of social acceptance of same-sex marriages
among non-Hispanic white populations.

This is an important point of discussion as it illustrates the need for
researchers and policymakers to better understand the idea of
intersectionality within the many subpopulations within LGBTQ+ groups.
As marriage tends to confer financial security and stabilization
benefits, to both participants in the couple, then it follows that
LGBTQ+ individuals who are white are more likely to access these
benefits than their non-white LGBTQ+ counterparts, which can contribute
to additional disparities along racial lines which are fully contained
within the LGBTQ+ population.

# Visualizing Total Healthcare Expenditures

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

![](README_files/figure-gfm/Expenditure_Plots-1.png)<!-- -->![](README_files/figure-gfm/Expenditure_Plots-2.png)<!-- -->![](README_files/figure-gfm/Expenditure_Plots-3.png)<!-- -->![](README_files/figure-gfm/Expenditure_Plots-4.png)<!-- -->

# Drug Costs are a Large Part of Healthcare Costs for Seniors

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

# Healthcare Expenditures Broken out by Presence of Chronic Conditions

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

![](README_files/figure-gfm/Exp_Chronic_Cond-1.png)<!-- -->![](README_files/figure-gfm/Exp_Chronic_Cond-2.png)<!-- -->

The two charts above present a comparison that show differences in
individual healthcare expenditures amongst individuals who have been
diagnosed with potentially high-cost chronic conditions. Due to the fact
that further stratifying the data presents an obligation to display a
wider error bar on the plots, I have tried to minimally stratify the
data to yield plots with error bars that allow the reader to access
meaningful conclusions about disparities explored.

In the first comparison of married individuals with and without chronic
conditions that can lead to potentially high-cost chronic conditions, it
is difficult to discern any meaningful difference between the magnitude
of individual healthcare expenditures incurred between married
invidivudals in same-sex marriages and married individuals not in
same-sex marriages. This visualization does seem to hint at what is
already known about the desparities in healthcare costs between members
with chronic conditions such as diabetes, hypertension, or
hyperlipidemia.

The second comparison is presented in order to show that there is likely
a statistically significant disparity in individual healthcare spend
across race and ethnicity distinctions, when broken out across age
groups as well as chronic disease status. Naturally, the statistical
significance depends on the analyst’s selection of p-value threshold,
but it is fairly uncontroversial to state that non-Hispanic white
individuals tend to have a greater individual healthcare spend spend
than individuals who identify as other than non-Hispanic white. The
reasons for this disparity, whether due to systemic issues inhibiting
access to healthcare services for some populations or some other reason
are the subject of ample research initiatives and not further discussed
here.

However it is important to note, again, that when exploring disparities
in access to preventative healthcare services across LGBTQ+ and
non-LGBTQ+ populations, an intersectional lens is required. Owing to the
small sample size of individuals in same-sex marriages in the MEPS data,
it is difficult to explore the issue further without veering into the
realm of “data torture.”

# Family Size Can Impact Healthcare Outcomes for Seniors

One feature that can drive the total cost of care at the individual
level is family size. Larger families within the same dwelling unit can
help take care of one another when sick, coordinate transportation to
and from sites where healthcare is provided, manage childcare duties so
that adults are able to arrange for healthcare services, and so on.
Several studies have shown a linkage between medication adherence and
family size, particularly among families in low-income socioeconmic
strata.

For a number of reasons not discussed further here, the family size of
families that include individuals within same-sex marriages is likely to
be smaller than that of their counterparts in marriages not regarded as
same-sex. As such, it is worth exploring how family size can impact the
total individual healthcare spend across age groups.

![](README_files/figure-gfm/Exp_Vs_FamSize-1.png)<!-- -->

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
