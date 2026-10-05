# EdTech Marketing & Enrolment Analytics

A SQL-based business analytics project exploring how an EdTech company can use interconnected marketing, customer and enrolment data to understand **acquisition performance, conversion behaviour, programme demand and marketing efficiency**.

The project uses a relational data model and SQL analysis to transform multiple business datasets into decision-ready insights and reusable views for Power BI reporting.

> **Note:** This is a portfolio project built using synthetic data. It does not contain data from a real education provider or its customers.

---

## Business Problem

An EdTech business may generate customer data across several stages of the acquisition journey — from marketing campaigns and leads to customer interactions, enrolments and payments.

Analysing these datasets separately makes it difficult to understand the complete customer journey.

This project brings those sources together to answer questions such as:

- Which acquisition channels generate the most leads and enrolments?
- How effectively are leads converting into customers?
- Which programmes attract the strongest demand?
- Which customer segments perform differently?
- How efficiently is marketing spend being converted into enrolments?
- Which campaigns and channels generate the strongest commercial return?

---

## Data Model

The project contains six interconnected business datasets:

| Dataset | Purpose |
|---|---|
| `campaigns` | Marketing campaign and acquisition information |
| `leads` | Prospective customer records |
| `interactions` | Customer engagement and interaction activity |
| `programmes` | Available education programmes |
| `enrolments` | Lead-to-programme enrolment records |
| `payments` | Payment and revenue information |

The dataset includes:

- **20,000 leads**
- **35,249 interactions**
- **1,712 enrolments**

The data was synthetically generated to simulate a multi-stage EdTech customer journey.

---

## Analytical Workflow

```text
Synthetic Business Data
        │
        ▼
Relational Database
        │
        ▼
Data Quality &
Referential Integrity
        │
        ▼
SQL Business Analysis
        │
        ├── Acquisition & Conversion
        ├── Programme Performance
        ├── Customer Segmentation
        ├── Revenue Analysis
        └── Marketing Efficiency
        │
        ▼
Reusable SQL Views
        │
        ▼
Power BI Reporting
```

---

## Database & Data Quality

The six datasets are structured as a relational model connecting marketing activity with customer behaviour, enrolments and financial outcomes.

Before performing the business analysis, SQL checks were created to assess:

- Missing and invalid values
- Duplicate records
- Key relationships
- Referential integrity
- Consistency between interconnected datasets

This helps ensure that downstream KPIs are calculated from reliable data.

---

## Business Analysis

### Acquisition & Conversion

The analysis examines the customer acquisition funnel from initial lead generation through to enrolment.

This supports comparison of:

- Acquisition channels
- Lead volumes
- Enrolment volumes
- Conversion rates
- Campaign performance

The objective is to distinguish channels that simply generate traffic from those that generate customers.

### Programme Performance

Programme-level analysis is used to understand differences in customer demand and commercial performance across the product portfolio.

This provides a basis for identifying programmes with stronger or weaker enrolment performance.

### Customer Segmentation

Lead and enrolment data are analysed across customer characteristics to identify differences in acquisition and conversion behaviour.

This enables performance to be examined beyond aggregate company-level KPIs.

### Revenue & Marketing Efficiency

Marketing performance is evaluated using commercial metrics including:

- Cost per Lead (CPL)
- Cost per Enrolment (CPE)
- Conversion Rate
- Revenue
- Return on Investment (ROI)

These metrics help connect marketing activity with downstream commercial outcomes rather than evaluating campaigns only by lead volume.

---

## Power BI Reporting

Reusable SQL views are prepared in:

`sql/04_powerbi_views.sql`

These views provide reporting-ready outputs for analysing areas such as:

- Acquisition performance
- Conversion funnels
- Programme performance
- Customer segments
- Marketing efficiency
- Revenue and ROI

**Power BI dashboard development is currently in progress.**

Once completed, the dashboard will provide an interactive reporting layer over the SQL analysis.

---

## Tech Stack

| Area | Technology |
|---|---|
| Querying & Analysis | SQL |
| Database Design | Relational Data Modelling |
| Data Generation | Python |
| Data Preparation | Pandas |
| Data Quality | SQL validation & integrity checks |
| Business Analytics | Funnel, KPI, Marketing & ROI Analysis |
| Visualisation | Power BI *(in development)* |

---

## Repository Structure

```text
edtech-analysis/
│
├── README.md
│
├── data/
│   ├── 01_generate_synthetic_data.ipynb
│   ├── campaigns.csv
│   ├── enrolments.csv
│   ├── interactions.csv
│   ├── leads.csv
│   ├── payments.csv
│   └── programmes.csv
│
└── sql/
    ├── 01_database_schema.sql
    ├── 02_data_quality_checks.sql
    ├── 03_analysis.sql
    └── 04_powerbi_views.sql
```

---

## Project Scope

This project was developed as a **portfolio case study using synthetic data**.

The objective was to demonstrate how relational business data can be transformed into useful commercial analysis through:

**data modelling → data-quality validation → SQL analysis → KPI development → reporting**

The project focuses on translating interconnected customer and marketing data into insights that can support acquisition, programme and marketing decisions.
