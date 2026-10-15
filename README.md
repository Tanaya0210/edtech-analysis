# EdTech Marketing & Enrolment Analytics

An independent, end-to-end analytics case study built with **PostgreSQL, SQL and Power BI**, using a **simulated** EdTech dataset.

> **Please note: all data in this project is synthetic.** The dataset was generated with Python for this case study. It does not come from, and does not describe, any real company, student or campaign. Every figure in this repository, including leads, enrolments, revenue and marketing spend, is simulated and must not be read as real business performance.

---

## Project Origin

This project started from a real experience: I took part in a pay-to-participate internship. Instead of leaving it as just an experience, I used it as a starting point for something I could build on as an analyst.

This is **not** an investigation of any company or programme. It is a self-initiated project in which I asked:

> *"If an EdTech company had hired me as an analyst, what would they expect me to investigate, analyse and deliver?"*

I then designed a realistic business scenario, built the data and database myself, and worked through the analysis as if responding to a genuine assignment. I was not employed or commissioned by any EdTech company for this work.

---

## The Business Scenario (Hypothetical)

A fictional EdTech organisation attracts prospective students through several acquisition channels, engages them through calls, emails, brochures and webinars, and tries to convert them into paying learners on five programmes.

The business needs to understand where leads come from, which channels actually convert them, whether marketing spend is being used well, and where the enrolment strategy could improve.

### Business questions

1. How effectively are leads converting into enrolments?
2. Which acquisition channels generate the highest conversion rates?
3. Which programmes attract and convert the most prospective students?
4. Which customer segments show the strongest conversion?
5. How efficiently is marketing spend generating leads and enrolments?
6. What return does attributable marketing spend generate?
7. Does engagement frequency relate to conversion?
8. Are particular interaction types associated with higher conversion?
9. How long does it typically take for a lead to enrol?
10. Where are the biggest drop-offs in the conversion funnel?

---

## Tools

- **Python (pandas, NumPy)**: generation of the synthetic dataset (`python/01_generate_synthetic_data.ipynb`)
- **PostgreSQL 17 / pgAdmin 4**: relational database, validation and analysis
- **SQL**: joins, aggregations, CTEs, conditional aggregation, `FILTER`, `PERCENTILE_CONT`, views
- **Power BI**: three-page interactive dashboard
- **GitHub**: documentation and version control

---

## Dataset

Six related tables were generated, loaded into PostgreSQL and connected through primary and foreign keys.

| Table | Rows | Description |
|---|---:|---|
| `programmes` | 5 | Programme catalogue, price and duration |
| `campaigns` | 40 | Marketing campaigns, channel, spend, impressions and clicks |
| `leads` | 20,000 | Prospective students and acquisition details |
| `interactions` | 35,249 | Lead engagement activities |
| `enrolments` | 1,712 | Programme enrolments and completion status |
| `payments` | 1,712 | Payment amounts, status and refunds |

Leads were created between January 2024 and December 2025. Enrolments run to early February 2026, so the final month is incomplete.

![ERD](images/edtech_analytics_ERD.png)

### How the data was generated

The data is random but not patternless. The generator sets channel-level conversion probabilities (Referral 15%, University Partnership 12%, LinkedIn 7%, Google Ads 6%, Meta Ads 5%) and gives interaction type, interaction count and age group no direct effect on conversion. Channel differences in the results therefore reflect how the data was built. The purpose of the project is to demonstrate the analytical process, not to claim discoveries about real student behaviour.

Only LinkedIn, Google Ads and Meta Ads leads are linked to a `campaign_id`. Referral and University Partnership leads have no campaign link (see [Limitations](#limitations-and-assumptions)).

---

## Data Quality Validation

Before analysis, the database was checked for:

- **Primary keys:** no duplicate IDs in any table
- **Referential integrity:** no orphan records across all six relationships
- **Missing values:** none in the critical fields tested
- **Logical consistency:** no enrolments before lead creation, no payments before enrolment, no negative or zero payment amounts
- **Categorical consistency:** no spelling variants or unexpected categories
- **Range checks:** no negative spend, clicks above impressions, end dates before start dates, or invalid prices, durations or refunds

Checks are in `sql/02_data_quality_checks.sql`. Because the data is synthetic and generated cleanly, these checks mainly demonstrate validation method rather than uncovering real-world data problems.

---

## SQL Analysis

`sql/03_analysis.sql` covers:

- **Channel performance:** leads, enrolments and conversion by acquisition channel
- **Programme performance:** conversion by programme of interest
- **Customer segments:** conversion by age group, education level and employment status
- **Marketing efficiency:** cost per lead and cost per enrolment
- **Marketing ROI:** attributed revenue against campaign spend, `(Revenue − Spend) / Spend × 100`
- **Engagement:** conversion by interaction count and interaction type
- **Conversion speed:** average and median days from lead creation to enrolment
- **Funnel:** Leads → Engaged Leads → Enrolments → Successful Payments → Completed Programmes

`sql/04_powerbi_views.sql` creates nine reusable views (`vw_executive_kpis`, `vw_funnel_summary`, `vw_channel_performance`, `vw_programme_performance`, `vw_marketing_roi`, `vw_customer_segments`, `vw_engagement_performance`, `vw_interaction_performance`, `vw_conversion_speed`) so that Power BI consumes prepared analytical datasets.

---

## Power BI Dashboard

A three-page interactive dashboard, organised around the questions a stakeholder would ask.

| Page | Focus |
|---|---|
| **1. Executive Overview** | Leads, enrolments, conversion rate, revenue, marketing spend, attributed revenue, ROI, cost per enrolment, monthly cohort conversion and enrolment trend |
| **2. Marketing & Acquisition Performance** | Leads and conversion rate by channel, campaign spend, clicks, impressions, CTR and CPC, revenue per enrolment by programme |
| **3. Lead Behaviour & Conversion Analytics** | Conversion by age group, engagement frequency and interaction type, average days to enrolment, engaged leads, conversion outcomes |

<!-- Add screenshots here, e.g. ![Executive Overview](images/page1_executive_overview.png) -->

---

## Key Results (Simulated Data)

| Metric | Value |
|---|---:|
| Total leads | 20,000 |
| Total enrolments | 1,712 |
| Lead conversion rate | 8.56% |
| Total revenue (successful payments) | £766,565 |
| Total campaign spend | £117,122.99 |
| Revenue per enrolment | £447.76 |
| Average days from lead to enrolment | 22.8 |
| Successful payments | 1,535 |
| Completed programmes | 1,108 |

### What the analysis shows

- **Channel quality differs from lead volume.** LinkedIn generates the most leads (6,010) but converts at 7.59%. Referral (13.30%) and University Partnership (11.66%) convert at roughly twice the rate of Google Ads (5.98%) and Meta Ads (5.74%).
- **Business Analytics** has the highest programme-level conversion (8.96%) and **Data Analytics** the lowest (7.77%), though the spread is narrow.
- **Engagement shows limited differentiation.** Leads with no interactions convert lowest (7.63%); leads with one or more interactions convert between about 8.2% and 8.9%, with no consistent increase as interactions rise. Conversion rates across the four interaction types sit within a narrow band of roughly 8.5% to 8.8%.
- **Age group differences are small**, ranging from 8.07% (31+) to 9.15% (26–30).
- **Funnel:** 17,038 leads had at least one interaction; 226 leads enrolled with none.

---

## Limitations and Assumptions

- **Marketing ROI uses attributed revenue only.** The headline ROI of **248.13%** is calculated as attributed revenue (£407,735) against total campaign spend (£117,123). Referral and University Partnership leads are not linked to campaigns, so their revenue (£358,830, 809 enrolments) is not attributed, while their campaign spend (£53,097) is still included. In `vw_marketing_roi` these two channels therefore show −100% ROI, which reflects the attribution gap rather than genuine performance.
- **Paid channels only:** for the three trackable paid channels (Google Ads, LinkedIn, Meta Ads), spend of £64,026 against attributed revenue of £407,735 gives an ROI of about 537%. Within these, Google Ads shows the highest ROI (about 1,177%), but this should be treated with caution because it rests on small spend and a simulated dataset.
- **Cost per enrolment (£68.41)** divides all spend by all 1,712 enrolments. Using only the 903 attributed enrolments it would be about £129.70.
- **Enrolments include refunded and failed payments.** Conversion counts every enrolment; revenue counts successful payments only.
- **Advertising metrics are not realistic.** Campaign click-through rates are far above real-world norms, and impressions and clicks are shown for Referral and University Partnership campaigns. These come from the data generator.
- **Overlapping interaction types.** A lead can have several interaction types, so interaction-type groups are not mutually exclusive.
- **Incomplete final period.** February 2026 contains only a few days of enrolments, and the earliest and latest months are also affected by the date range of the data.
- **Synthetic data.** Findings illustrate analytical method and should not be generalised to real organisations.

---

## What an Analyst Might Explore Next

These are questions this analysis raises, not conclusions:

- Whether the referral and university partnership channels could be scaled, and what tracking would be needed to attribute their spend and revenue.
- Why LinkedIn produces high lead volume but lower conversion than the two best channels.
- How marketing budget could be assessed using conversion efficiency and ROI together, rather than lead volume alone.
- Whether follow-up and nurture timing could be shaped around the typical 23-day lead-to-enrolment window.
- Where drop-off between enrolment, successful payment and completion is greatest (1,712 enrolments, 1,535 successful payments, 1,108 completed programmes).

---

## Repository Structure

```text
edtech-analytics/
├── README.md
├── python/
│   └── 01_generate_synthetic_data.ipynb
├── csv/
│   ├── programmes.csv
│   ├── campaigns.csv
│   ├── leads.csv
│   ├── interactions.csv
│   ├── enrolments.csv
│   └── payments.csv
├── sql/
│   ├── 01_database_schema.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_analysis.sql
│   └── 04_powerbi_views.sql
├── images/
│   └── edtech_analytics_ERD.png
└── powerbi/
    └── edtech_analytics_dashboard.pbix
```

## How to Reproduce

1. Run `python/01_generate_synthetic_data.ipynb` to regenerate the CSV files, or use the files in `csv/`.
2. Create the tables with `sql/01_database_schema.sql` and load the CSVs.
3. Run `sql/02_data_quality_checks.sql` and `sql/03_analysis.sql`.
4. Run `sql/04_powerbi_views.sql` and connect Power BI to the views.

---

## Disclaimer

This is a personal portfolio project. The business scenario, dataset and all results are simulated, and the project is not affiliated with any company.
