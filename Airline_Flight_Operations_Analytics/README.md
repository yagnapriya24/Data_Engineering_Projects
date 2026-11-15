# ✈️ Airline Flight Operations Analytics | End-to-End Data Engineering Project

An end-to-end **Data Engineering and Analytics Project** built using **Azure Databricks Free Edition, Lakeflow Spark Declarative Pipelines, SQL, and Medallion Architecture**.

This project demonstrates how raw airline flight operational data can be transformed into clean, validated, and business-ready analytical datasets using a structured Bronze, Silver, and Gold data pipeline.

The project covers automated data ingestion, data cleaning, deduplication, business rule validation, data quality monitoring, analytical aggregations, and interactive dashboards using **Databricks AI/BI Dashboards**.

---

## 📌 Table of Contents

1. Business Problem
2. Project Objectives
3. Project Architecture
4. Pipeline Workflow
5. Technology Stack
6. Dataset Overview
7. Repository Structure
8. Medallion Architecture Implementation
9. Data Cleaning and Quality Rules
10. Data Quality Reconciliation
11. Gold Layer – Business Analytics
12. Dashboard Overview
13. Key Business Insights
14. How to Run the Project
15. Project Outcomes
16. Key Learnings
17. Future Enhancements
18. Author

---

## 1. Business Problem

Airline operations generate large amounts of data related to flights, airlines, passengers, routes, ticket revenue, fuel costs, and flight delays.

However, raw operational datasets may contain duplicate records, missing values, inconsistent text formats, and invalid business information.

These data quality issues can affect reporting accuracy and make it difficult for airline management to evaluate operational performance.

**Solution:**

Develop an end-to-end data engineering pipeline using Azure Databricks to ingest, clean, validate, transform, and aggregate airline flight data into reliable datasets for business intelligence and decision-making.

---

## 2. Project Objectives

- Build an end-to-end data engineering pipeline using Azure Databricks.
- Implement the Medallion Architecture (Bronze → Silver → Gold).
- Ingest raw CSV data using Databricks Auto Loader.
- Implement transformations using Lakeflow Spark Declarative Pipelines and SQL.
- Remove duplicate records and standardize inconsistent data.
- Handle missing values and validate business rules.
- Separate clean and rejected records.
- Develop Gold-layer analytical materialized views.
- Implement data quality monitoring and record reconciliation.
- Build interactive dashboards to analyze airline operations and performance.

---

## 3. Project Architecture

The project follows the **Medallion Architecture**, which organizes data processing into three layers.

**Overall Data Flow:**

`Raw CSV → Bronze → Silver → Gold → AI/BI Dashboard`

![Medallion Architecture](Assets/architecture/medallion_architecture_and_reconciliation.png)

### Architecture Components

| Layer | Purpose | Implementation |
|---|---|---|
| Bronze | Raw data ingestion | Auto Loader and Streaming Table |
| Silver | Data cleaning and validation | SQL transformations and Materialized Views |
| Gold | Business-level aggregations | SQL Materialized Views |
| Dashboard | Data visualization | Databricks AI/BI Dashboards |

---

## 4. Pipeline Workflow

The pipeline automates the movement of data from the source CSV file through the three Medallion layers.

![Databricks Pipeline Graph](Assets/Pipeline_graph/Pipeline.png)

### Pipeline Components

| Pipeline Object | Type | Description |
|---|---|---|
| `bronze_airline_flights` | Streaming Table | Ingests raw airline flight data |
| `silver_flights_clean` | Materialized View | Stores cleaned and validated records |
| `silver_flights_rejected` | Materialized View | Stores records that fail validation |
| `gold_monthly_flight_trends` | Materialized View | Monthly flight trends |
| `gold_airline_performance` | Materialized View | Airline performance analysis |
| `gold_route_performance` | Materialized View | Route-level performance |
| `gold_delay_analysis` | Materialized View | Flight delay analysis |
| `gold_data_quality` | Materialized View | Data quality and reconciliation metrics |

---

## 5. Technology Stack

| Category | Technology |
|---|---|
| Cloud Platform | Azure Databricks Free Edition |
| Data Engineering | Lakeflow Spark Declarative Pipelines |
| Programming Language | SQL |
| Data Architecture | Medallion Architecture |
| Data Ingestion | Databricks Auto Loader |
| Storage Format | Delta Lake |
| Data Governance | Unity Catalog |
| Data Storage | Unity Catalog Volumes |
| Data Processing | Databricks SQL |
| Visualization | Databricks AI/BI Dashboards |
| Version Control | Git and GitHub |

---

## 6. Dataset Overview

**Dataset Name:** `airline_flights_raw.csv`

The project uses an airline flight operations dataset containing information related to:

- Flight details and airline information.
- Aircraft details and seat capacity.
- Flight dates and departure information.
- Origin and destination cities.
- Flight distance.
- Passenger count.
- Ticket fare and revenue.
- Fuel costs.
- Flight delay duration and delay reasons.

**Source:** CSV file stored in a Databricks Unity Catalog Volume.

---

## 7. Repository Structure

```text
Airline_Flight_Operations_Analytics/
│
├── Assets/
│   │
│   ├── Pipeline_graph/
│   │   └── Pipeline.png
│   │
│   ├── architecture/
│   │   ├── medallion_architecture_and_reconciliation.png
│   │   └── silver_cleaning_steps.png
│   │
│   └── dashboard/
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

---

## 8. Medallion Architecture Implementation

### 🥉 8.1 Bronze Layer – Raw Data Ingestion

**Table:** `bronze_airline_flights`

The Bronze layer captures raw airline flight records from the CSV source using Databricks Auto Loader.

**Operations performed:**

- Ingest CSV data using Auto Loader.
- Create a streaming table.
- Preserve the original source data.
- Capture source file information.
- Record ingestion timestamps.

**Output:** `bronze_airline_flights`

### 🥈 8.2 Silver Layer – Data Cleaning and Validation

The Silver layer transforms raw Bronze data into reliable datasets by applying cleaning and validation operations.

**Output Tables:**
- `silver_flights_clean`
- `silver_flights_rejected`

**Operations performed:**

1. Remove duplicate flight records.
2. Standardize text using `TRIM()` and `INITCAP()`.
3. Handle missing and inconsistent values.
4. Apply appropriate data transformations.
5. Validate passenger count and seat capacity.
6. Validate fare values.
7. Categorize flight delays.
8. Separate invalid records into the rejected dataset.

**Silver Layer Cleaning Workflow:**

![Silver Cleaning Steps](Assets/architecture/silver_cleaning_steps.png)

### 🥇 8.3 Gold Layer – Business Analytics

The Gold layer contains aggregated and business-ready datasets created from the Silver and Bronze layers.

**Gold Materialized Views:**

| View | Purpose |
|---|---|
| gold_monthly_flight_trends | Monthly flight and revenue trends |
| gold_airline_performance | Airline-wise operational and financial performance |
| gold_route_performance | Route-wise flight and passenger analysis |
| gold_delay_analysis | Delay category and delay pattern analysis |
| gold_data_quality | Data quality metrics and record reconciliation |

These datasets serve as the foundation for the final dashboards.

---

## 9. Data Cleaning and Quality Rules

The Silver layer applies multiple data quality checks to improve the reliability of the dataset.

| Data Quality Check | Transformation |
|---|---|
| Duplicate Records | Identify and remove duplicate flights |
| Text Standardization | Apply TRIM and INITCAP |
| Missing Values | Handle blanks and NULL values |
| Passenger Validation | Check passenger count against seat capacity |
| Fare Validation | Identify invalid negative fare values |
| Delay Calculation | Derive delay using departure timestamps when applicable |
| Delay Categorization | Classify flights into delay categories |
| Rejected Records | Separate records that fail validation |

### Flight Delay Categorization

| Condition | Category |
|---|---|
| Delay ≤ 15 minutes | On Time |
| Delay > 15 and ≤ 60 minutes | Minor Delay |
| Delay > 60 minutes | Major Delay |

---

## 10. Data Quality Reconciliation

A reconciliation process is implemented to verify that all Bronze records are accounted for in the Silver layer.

**Reconciliation Formula:**

```text
Bronze Records = Clean Records + Rejected Records
```

### Actual Project Results

| Metric | Records |
|---|---:|
| Bronze Records | 1,365 |
| Clean Records | 1,294 |
| Rejected Records | 71 |
| Duplicate Records Identified | 25 |
| Reconciliation Difference | 0 |

**Reconciliation Check:**

```text
1,365 = 1,294 + 71
```

The 25 duplicate records are identified within the rejected-record subset and are not additional records in the reconciliation calculation.

<details>
<summary><strong>Data Quality Summary</strong></summary>

- Total Bronze records: 1,365
- Accepted clean records: 1,294
- Rejected records: 71
- Duplicate records identified: 25
- Acceptance percentage: 94.80%
- Rejection percentage: 5.20%
- Reconciliation difference: 0

</details>

**Reconciliation Status: PASSED**

---

## 11. Gold Layer – Business Analytics

The Gold layer supports the following business analysis requirements.

### Monthly Flight Trends

- Monthly flight volume.
- Monthly passenger trends.
- Ticket revenue analysis.
- Flight delay trends.

### Airline Performance

- Total flights by airline.
- Passenger volume by airline.
- Ticket revenue comparison.
- Revenue after fuel cost.
- Average delay by airline.

### Route Performance

- Total routes.
- Top routes by flight volume.
- Route-wise ticket revenue.
- Passenger distribution.
- Average route distance.
- Route-level delay analysis.

### Flight Delay Analysis

- Early, on-time, minor-delay, and major-delay flights.
- Delay category distribution.
- Average delay by airline.
- Delay patterns across routes.

### Data Quality Monitoring

- Bronze and Silver record counts.
- Clean and rejected record comparison.
- Duplicate record monitoring.
- Acceptance and rejection percentages.
- Record reconciliation.

---

## 12. Dashboard Overview

The project includes **four Databricks AI/BI Dashboard pages** to provide operational and business insights.

### Page 1 – Executive Overview

![Executive Overview](Assets/Dashboard/Executive_Overview.png)

Provides an overall view of airline operations, including:

- Total flights and passengers.
- Total ticket revenue.
- Fuel cost and revenue after fuel cost.
- Average flight delay.
- Monthly flight trends.
- Monthly revenue trends.
- Airline flight distribution.
- Monthly delayed flights.

### Page 2 – Airline Performance

![Airline Performance](Assets/Dashboard/Airline_Performance.png)

Focuses on comparing the operational and financial performance of five airlines.

Key metrics include:

- Flights by airline.
- Passenger volume by airline.
- Ticket revenue by airline.
- Revenue after fuel cost.
- Average delay by airline.
- Airline performance comparison.

### Page 3 – Route & Delay Intelligence

![Route and Delay Intelligence](Assets/Dashboard/Route_&_Delay_Intelligence.png)

Provides detailed analysis of route demand and flight delay patterns.

Key metrics include:

- Total origin-destination routes.
- Top 10 routes by flight volume.
- Flights by delay category.
- Delay category distribution.
- Top 10 routes by ticket revenue.
- Average delay by airline.
- Route performance details.

### Page 4 – Data Quality & Pipeline Monitoring

![Data Quality and Pipeline Monitoring](Assets/Dashboard/Data_Quality_&_Pipeline_Monitoring.png)

Monitors the reliability of the data engineering pipeline.

Key metrics include:

- Bronze records.
- Clean records.
- Rejected records.
- Duplicate records.
- Acceptance percentage.
- Rejection percentage.
- Reconciliation difference.
- Clean versus rejected record distribution.

---

## 13. Key Business Insights

Based on the dashboard results:

- The project processes 1,294 clean flight records across five airlines.
- Total passenger volume is 168,397.
- Total ticket revenue is approximately ₹1.16 billion.
- Revenue after fuel cost is ₹823.25 million.
- Sky Jet leads in flight volume with 380 flights.
- The network-wide average flight delay is approximately 25.08 minutes.
- A total of 90 distinct origin-destination routes are analyzed.
- The data quality dashboard reports a 94.80% acceptance rate.
- The Bronze-to-Silver reconciliation difference is zero.

These insights help evaluate airline performance, identify delay patterns, compare route demand, and monitor data reliability.

---

## 14. How to Run the Project

### Step 1 – Set Up Databricks

- Open Azure Databricks Free Edition.
- Create the required Unity Catalog resources.
- Create a catalog, schema, and volume for the project.

### Step 2 – Upload the Dataset

Upload `airline_flights_raw.csv` into the appropriate Unity Catalog Volume.

### Step 3 – Execute the Bronze Transformation

- Open Lakeflow Spark Declarative Pipelines.
- Add the Bronze SQL transformation.
- Configure the source dataset.
- Execute the pipeline.
- Verify the `bronze_airline_flights` streaming table.

### Step 4 – Execute the Silver Transformation

- Add the Silver SQL transformation.
- Configure the Bronze source.
- Execute the pipeline.
- Verify `silver_flights_clean` and `silver_flights_rejected`.

### Step 5 – Execute the Gold Transformation

- Add the Gold SQL transformation.
- Configure the Silver and Bronze dependencies.
- Execute the pipeline.
- Verify all five Gold materialized views.

### Step 6 – Perform Data Quality Validation

Validate the Bronze, clean, rejected, and duplicate record counts.

Verify that the reconciliation difference is zero.

### Step 7 – Create the AI/BI Dashboard

Use the Gold materialized views as dashboard datasets and create the four analytical pages.

---

## 15. Project Outcomes

Through this project, an end-to-end airline data engineering workflow was implemented.

- Successfully ingested raw airline data using Auto Loader.
- Implemented Bronze, Silver, and Gold data layers.
- Developed SQL-based cleaning and transformation workflows.
- Implemented duplicate detection and data validation.
- Separated clean and rejected records.
- Created five Gold analytical materialized views.
- Implemented data quality monitoring and reconciliation.
- Developed four interactive dashboard pages.
- Converted raw operational data into meaningful business insights.

---

## 16. Key Learnings

- Understanding and implementing Medallion Architecture.
- Working with Azure Databricks Free Edition.
- Using Lakeflow Spark Declarative Pipelines.
- Implementing Auto Loader for data ingestion.
- Writing SQL transformations for data engineering.
- Working with streaming tables and materialized views.
- Managing data using Unity Catalog and Delta Lake.
- Implementing data cleaning and validation techniques.
- Building data quality checks and reconciliation logic.
- Developing interactive Databricks AI/BI Dashboards.
- Managing project files and version control using GitHub.

---

## 17. Future Enhancements

- Implement incremental processing for larger datasets.
- Introduce predictive flight delay analysis.
- Add flight cancellation analytics.
- Develop advanced airline performance metrics.
- Implement automated pipeline monitoring and alerting.
- Integrate additional airline operational datasets.
- Extend historical trend analysis.

---

## 18. Author

**Yagnapriya P**

GitHub: [@yagnapriya24](https://github.com/yagnapriya24)

**Project Repository:** [Airline Flight Operations Analytics](https://github.com/yagnapriya24/Data_Engineering_Projects/tree/main/Airline_Flight_Operations_Analytics)

---

⭐ If you find this project useful, consider giving the repository a star!

**Thank you for exploring my Airline Flight Operations Analytics project!**
