# ✈️ Airline Flight Operations Analytics \| End-to-End Data Engineering Project

An end-to-end **Data Engineering and Analytics Project** built using
**Azure Databricks Free Edition, Lakeflow Spark Declarative Pipelines,
SQL, and Medallion Architecture**.

This project transforms raw airline flight operational data into clean,
validated, and business-ready analytical datasets through a Bronze,
Silver, and Gold data pipeline. It covers automated ingestion,
deduplication, business-rule validation, data quality monitoring,
analytical aggregations, and interactive Databricks AI/BI Dashboards.

------------------------------------------------------------------------

## 📌 Table of Contents

1.  [Business Problem](#1-business-problem)
2.  [Project Objectives](#2-project-objectives)
3.  [Project Architecture](#3-project-architecture)
4.  [Pipeline Workflow](#4-pipeline-workflow)
5.  [Technology Stack](#5-technology-stack)
6.  [Dataset Overview](#6-dataset-overview)
7.  [Repository Structure](#7-repository-structure)
8.  [Medallion Architecture
    Implementation](#8-medallion-architecture-implementation)
9.  [Data Cleaning and Quality
    Rules](#9-data-cleaning-and-quality-rules)
10. [Data Quality Reconciliation](#10-data-quality-reconciliation)
11. [Gold Layer -- Business
    Analytics](#11-gold-layer--business-analytics)
12. [Dashboard Overview](#12-dashboard-overview)
    -   [Page 1 -- Executive Overview](#page-1--executive-overview)
    -   [Page 2 -- Airline Performance](#page-2--airline-performance)
    -   [Page 3 -- Route & Delay
        Intelligence](#page-3--route--delay-intelligence)
    -   [Page 4 -- Data Quality & Pipeline
        Monitoring](#page-4--data-quality--pipeline-monitoring)
13. [Key Business Insights](#13-key-business-insights)
14. [How to Run the Project](#14-how-to-run-the-project)
15. [Project Outcomes](#15-project-outcomes)
16. [Key Learnings](#16-key-learnings)
17. [Future Enhancements](#17-future-enhancements)
18. [Author](#18-author)

------------------------------------------------------------------------

## 1. Business Problem

Airline operations generate large volumes of data about flights,
airlines, passengers, routes, ticket revenue, fuel costs, and delays.
Raw operational datasets can contain duplicate records, inconsistent
text formats, and invalid business values.

These data quality issues can affect reporting accuracy and make it
difficult for airline management to evaluate operational performance.

**Solution:** Build an end-to-end data engineering pipeline in Azure
Databricks to ingest, clean, validate, transform, and aggregate airline
flight data into reliable datasets for business intelligence and
decision-making.

------------------------------------------------------------------------

## 2. Project Objectives

-   Build an end-to-end data engineering pipeline using Azure
    Databricks.
-   Implement Medallion Architecture (Bronze → Silver → Gold).
-   Ingest raw CSV data using Databricks Auto Loader.
-   Implement transformations using Lakeflow Spark Declarative Pipelines
    and SQL.
-   Identify and remove duplicate flight records.
-   Standardize text fields and validate business rules.
-   Separate clean records from invalid unique records.
-   Develop Gold-layer analytical materialized views.
-   Implement data quality monitoring and record reconciliation.
-   Build interactive dashboards to analyze airline operations and
    performance.

------------------------------------------------------------------------

## 3. Project Architecture

The project follows **Medallion Architecture**, organizing data
processing into three layers.

**Overall Data Flow:**

`Raw CSV → Bronze → Silver → Gold → Databricks AI/BI Dashboard`

![Medallion
Architecture](Assets/architecture/medallion_architecture_and_reconciliation.png)

### Architecture Components

  -----------------------------------------------------------------------
  Layer                   Purpose                 Implementation
  ----------------------- ----------------------- -----------------------
  Bronze                  Raw data ingestion      Auto Loader and
                                                  Streaming Table

  Silver                  Deduplication,          SQL transformations and
                          cleaning, and           Materialized Views
                          validation              

  Gold                    Business-level          SQL Materialized Views
                          aggregations            

  Dashboard               Data visualization and  Databricks AI/BI
                          analysis                Dashboards
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 4. Pipeline Workflow

The pipeline automates the movement of data from the source CSV file
through the three Medallion layers.

![Databricks Pipeline Graph](Assets/Pipeline_graph/Pipeline.png)

### Pipeline Components

  ------------------------------------------------------------------------------
  Pipeline Object                Type                    Description
  ------------------------------ ----------------------- -----------------------
  `bronze_airline_flights`       Streaming Table         Ingests raw airline
                                                         flight data

  `silver_flights_clean`         Materialized View       Stores deduplicated,
                                                         valid records

  `silver_flights_rejected`      Materialized View       Stores invalid unique
                                                         records with rejection
                                                         reasons

  `gold_monthly_flight_trends`   Materialized View       Monthly flight and
                                                         revenue trends

  `gold_airline_performance`     Materialized View       Airline-level
                                                         performance analysis

  `gold_route_performance`       Materialized View       Route-level performance
                                                         analysis

  `gold_delay_analysis`          Materialized View       Flight delay analysis

  `gold_data_quality`            Materialized View       Data quality and
                                                         reconciliation metrics
  ------------------------------------------------------------------------------

------------------------------------------------------------------------

## 5. Technology Stack

  Category               Technology
  ---------------------- --------------------------------------
  Cloud Platform         Azure Databricks Free Edition
  Data Engineering       Lakeflow Spark Declarative Pipelines
  Programming Language   SQL
  Data Architecture      Medallion Architecture
  Data Ingestion         Databricks Auto Loader
  Storage Format         Delta Lake
  Data Governance        Unity Catalog
  Data Storage           Unity Catalog Volumes
  Data Processing        Databricks SQL
  Visualization          Databricks AI/BI Dashboards
  Version Control        Git and GitHub

------------------------------------------------------------------------

## 6. Dataset Overview

**Dataset:** `airline_flights_raw.csv`

The dataset contains airline flight operational information, including:

-   Flight identifiers and airline details.
-   Aircraft information and seat capacity.
-   Flight dates and departure information.
-   Origin and destination cities.
-   Flight distance.
-   Passenger counts.
-   Average ticket fare and ticket revenue.
-   Fuel costs.
-   Flight delay duration and delay reasons.

**Source:** CSV file stored in a Databricks Unity Catalog Volume.

------------------------------------------------------------------------

## 7. Repository Structure

``` text
Airline_Flight_Operations_Analytics/
│
├── Assets/
│   ├── Pipeline_graph/
│   │   └── Pipeline.png
│   │
│   ├── architecture/
│   │   ├── medallion_architecture_and_reconciliation.png
│   │   └── silver_cleaning_steps.png
│   │
│   └── Dashboard/
│       ├── Executive_Overview.png
│       ├── Airline_Performance.png
│       ├── Route_&_Delay_Intelligence.png
│       └── Data_Quality_&_Pipeline_Monitoring.png
│
├── Data/
│   └── airline_flights_raw.csv
│
├── Docs/
│   └── Airline Flight Operations Documentation
│
├── ETL_Pipeline/
│   ├── Bronze_transformation.sql
│   ├── Silver_transformation.sql
│   ├── Gold_transformation.sql
│   └── Readme.md
│
└── Readme.md
```

> GitHub paths are case-sensitive. The image paths above use the folder
> names `Pipeline_graph`, `architecture`, and `Dashboard`.

------------------------------------------------------------------------

## 8. Medallion Architecture Implementation

### 🥉 8.1 Bronze Layer -- Raw Data Ingestion

**Table:** `bronze_airline_flights`

The Bronze layer captures raw airline flight records from the CSV source
using Databricks Auto Loader.

**Operations performed:**

-   Ingest CSV data using Auto Loader.
-   Create a streaming table.
-   Preserve the ingested source records.
-   Capture source file information.
-   Record ingestion timestamps.

**Output:** `bronze_airline_flights`

### 🥈 8.2 Silver Layer -- Deduplication and Validation

The Silver layer separates valid unique records from invalid unique
records.

**Output views:**

-   `silver_flights_clean`
-   `silver_flights_rejected`

**Operations performed:**

1.  Rank records by `flight_id` and retain the latest record.
2.  Remove duplicate flight records from the unique-record processing
    set.
3.  Standardize text fields using `TRIM()`.
4.  Validate passenger count against seat capacity.
5.  Validate average fare values.
6.  Store valid unique records in the clean view.
7.  Store invalid unique records with rejection reasons in the rejected
    view.

![Silver Cleaning Steps](Assets/architecture/silver_cleaning_steps.png)

### 🥇 8.3 Gold Layer -- Business Analytics

The Gold layer contains aggregated, business-ready datasets created from
the Silver and Bronze layers.

  -----------------------------------------------------------------------
  View                                Purpose
  ----------------------------------- -----------------------------------
  `gold_monthly_flight_trends`        Monthly flight, passenger, revenue,
                                      and delay trends

  `gold_airline_performance`          Airline-wise operational and
                                      financial performance

  `gold_route_performance`            Route-wise flight and passenger
                                      analysis

  `gold_delay_analysis`               Delay category and delay pattern
                                      analysis

  `gold_data_quality`                 Data quality metrics and
                                      Bronze-to-Silver reconciliation
  -----------------------------------------------------------------------

These views provide the datasets used by the dashboard.

------------------------------------------------------------------------

## 9. Data Cleaning and Quality Rules

The current Silver validation logic applies the following rejection
conditions to deduplicated records:

  -----------------------------------------------------------------------
  Data Quality Check                  Rule
  ----------------------------------- -----------------------------------
  Passenger capacity                  Reject when passengers exceed seat
                                      capacity

  Negative passenger count            Reject when passengers are below
                                      zero

  Negative average fare               Reject when average fare is below
                                      zero

  Duplicate flight ID                 Keep the latest record and count
                                      older occurrences separately
  -----------------------------------------------------------------------

Text fields selected for display are standardized using `TRIM()`.

### Flight Delay Categorization

The Gold delay analysis groups flights using these rules:

  Condition                      Category
  ------------------------------ -------------
  Delay \< 0 minutes             Early
  Delay from 0 to 15 minutes     On Time
  Delay \> 15 and ≤ 60 minutes   Minor Delay
  Delay \> 60 minutes            Major Delay

------------------------------------------------------------------------

## 10. Data Quality Reconciliation

The project reconciles every Bronze record into one of three mutually
exclusive groups:

**Reconciliation Formula:**

``` text
Bronze Records = Clean Records + Rejected Unique Records + Duplicate Records Removed
```

### Updated Project Results

  Metric                                 Records
  ------------------------------------ ---------
  Bronze Records                           1,365
  Unique Records after deduplication       1,340
  Clean Records                            1,321
  Rejected Unique Records                     19
  Duplicate Records Removed                   25
  Reconciled Records                       1,365
  Reconciliation Difference                    0

**Reconciliation Check:**

``` text
1,365 = 1,321 + 19 + 25
```

### Data Quality Summary

-   Total Bronze records: **1,365**
-   Clean unique records: **1,321**
-   Rejected unique records: **19**
-   Duplicate records removed: **25**
-   Acceptance percentage (clean / Bronze): **96.78%**
-   Rejection percentage (rejected / Bronze): **1.39%**
-   Duplicate percentage (duplicates / Bronze): **1.83%**
-   Reconciliation difference: **0**

**Reconciliation Status: PASSED**

> Duplicate records are counted separately from rejected unique records.
> They are not included in the 19 rejected records. Percentages use the
> total Bronze record count as the denominator and may not add to
> exactly 100% due to rounding.

------------------------------------------------------------------------

## 11. Gold Layer -- Business Analytics

The Gold layer supports the following business analysis requirements.

### Monthly Flight Trends

-   Monthly flight volume.
-   Monthly passenger trends.
-   Ticket revenue and fuel cost trends.
-   Average flight delay.
-   Delayed flight counts.

### Airline Performance

-   Total flights by airline.
-   Passenger volume by airline.
-   Ticket revenue by airline.
-   Revenue after fuel cost.
-   Average delay by airline.
-   Delayed flight counts by airline.

### Route Performance

-   Origin-destination route analysis.
-   Flight volume by route.
-   Passenger volume by route.
-   Route-wise ticket revenue and fuel cost.
-   Average route distance.
-   Average delay by route.

### Flight Delay Analysis

-   Early, on-time, minor-delay, and major-delay flights.
-   Flight counts by delay category.
-   Average delay by airline.
-   Passenger volume by delay category.

### Data Quality Monitoring

-   Bronze, clean, and rejected record counts.
-   Duplicate record monitoring.
-   Acceptance and rejection percentages.
-   Reconciled record count.
-   Reconciliation difference.

------------------------------------------------------------------------

## 12. Dashboard Overview

The project includes **four Databricks AI/BI Dashboard pages** for
operational and business analysis.

### Page 1 -- Executive Overview

![Executive Overview](Assets/Dashboard/Executive_Overview.png)

Provides a high-level view of airline operations, including:

-   Total flights and passengers.
-   Total ticket revenue.
-   Fuel cost and revenue after fuel cost.
-   Average flight delay.
-   Monthly flight trends.
-   Monthly revenue trends.
-   Airline flight distribution.
-   Monthly delayed flights.

### Page 2 -- Airline Performance

![Airline Performance](Assets/Dashboard/Airline_Performance.png)

Compares the operational and financial performance of the airlines.

Key metrics include:

-   Flights by airline.
-   Passenger volume by airline.
-   Ticket revenue by airline.
-   Revenue after fuel cost.
-   Average delay by airline.
-   Airline performance comparison.

### Page 3 -- Route & Delay Intelligence

![Route and Delay
Intelligence](Assets/Dashboard/Route_&_Delay_Intelligence.png)

Analyzes route demand and flight delay patterns.

Key metrics include:

-   Total origin-destination routes.
-   Top routes by flight volume.
-   Flights by delay category.
-   Delay category distribution.
-   Top routes by ticket revenue.
-   Average delay by airline.
-   Route performance details.

### Page 4 -- Data Quality & Pipeline Monitoring

![Data Quality and Pipeline
Monitoring](Assets/Dashboard/Data_Quality_&_Pipeline_Monitoring.png)

Monitors the reliability and reconciliation of the data pipeline.

Key metrics include:

-   Bronze records: **1,365**
-   Clean records: **1,321**
-   Rejected unique records: **19**
-   Duplicate records removed: **25**
-   Acceptance percentage: **96.78%**
-   Rejection percentage: **1.39%**
-   Reconciliation difference: **0**
-   Clean, rejected, and duplicate record distribution.

------------------------------------------------------------------------

## 13. Key Business Insights

The Gold views and AI/BI dashboards support analysis of:

-   Airline-wise flight and passenger volumes.
-   Ticket revenue, fuel costs, and revenue after fuel cost.
-   Monthly changes in flight operations and revenue.
-   High-volume and high-revenue routes.
-   Delay patterns across airlines and routes.
-   Data quality, rejected records, and duplicate records.

> Refresh and query the Gold materialized views before publishing exact
> business totals (such as total passengers, revenue, leading airline,
> average delay, and route count). Those values depend on the current
> clean dataset and should be taken from the latest pipeline results
> rather than carried forward from an earlier run.

------------------------------------------------------------------------

## 14. How to Run the Project

### Step 1 -- Set Up Databricks

-   Open Azure Databricks Free Edition.
-   Create the required Unity Catalog resources.
-   Create a catalog, schema, and volume for the project.

### Step 2 -- Upload the Dataset

Upload `airline_flights_raw.csv` into the appropriate Unity Catalog
Volume.

### Step 3 -- Execute the Bronze Transformation

-   Open Lakeflow Spark Declarative Pipelines.
-   Add the Bronze SQL transformation.
-   Configure the source volume path.
-   Run the pipeline.
-   Verify the `bronze_airline_flights` streaming table.

### Step 4 -- Execute the Silver Transformations

-   Add the Silver SQL transformations.
-   Configure the Bronze source.
-   Run the pipeline.
-   Verify `silver_flights_clean` and `silver_flights_rejected`.
-   Confirm that duplicate records are counted separately from rejected
    unique records.

### Step 5 -- Execute the Gold Transformations

-   Add the Gold SQL transformations.
-   Configure the Silver and Bronze dependencies.
-   Run the pipeline.
-   Verify all five Gold materialized views.

### Step 6 -- Perform Data Quality Validation

Validate the Bronze, clean, rejected, and duplicate record counts.

Confirm that:

``` text
Bronze = Clean + Rejected + Duplicates
Reconciliation Difference = 0
```

### Step 7 -- Create or Refresh the AI/BI Dashboard

-   Use the Gold materialized views as dashboard datasets.
-   Create or refresh the four analytical pages.
-   Verify KPI cards, charts, and filters.
-   Publish the updated dashboard.

------------------------------------------------------------------------

## 15. Project Outcomes

-   Ingested raw airline data using Databricks Auto Loader.
-   Implemented Bronze, Silver, and Gold data layers.
-   Developed SQL-based cleaning and transformation workflows.
-   Implemented duplicate detection and business-rule validation.
-   Separated clean and rejected unique records.
-   Created five Gold analytical materialized views.
-   Implemented data quality monitoring and record reconciliation.
-   Developed four interactive dashboard pages.
-   Converted raw operational data into business-ready analytical
    datasets.

------------------------------------------------------------------------

## 16. Key Learnings

-   Understanding and implementing Medallion Architecture.
-   Working with Azure Databricks Free Edition.
-   Using Lakeflow Spark Declarative Pipelines.
-   Implementing Auto Loader for data ingestion.
-   Writing SQL transformations for data engineering.
-   Working with streaming tables and materialized views.
-   Managing data using Unity Catalog and Delta Lake.
-   Implementing data cleaning and business-rule validation.
-   Building data quality checks and reconciliation logic.
-   Developing interactive Databricks AI/BI Dashboards.
-   Managing project files and version control using GitHub.

------------------------------------------------------------------------

## 17. Future Enhancements

-   Implement incremental processing for larger datasets.
-   Introduce predictive flight delay analysis.
-   Add flight cancellation analytics.
-   Develop advanced airline performance metrics.
-   Implement automated pipeline monitoring and alerting.
-   Integrate additional airline operational datasets.
-   Extend historical trend analysis.

------------------------------------------------------------------------

## 18. Author

**Yagnapriya P**

GitHub: [@yagnapriya24](https://github.com/yagnapriya24)

**Project Repository:** [Airline Flight Operations
Analytics](https://github.com/yagnapriya24/Data_Engineering_Projects/tree/main/Airline_Flight_Operations_Analytics)

------------------------------------------------------------------------

⭐ If you find this project useful, consider giving the repository a
star!

**Thank you for exploring my Airline Flight Operations Analytics
project!**
