
# Hotel Booking Analytics | Medallion Data Engineering Project

A complete end-to-end Data Engineering project built using **Databricks, Lakeflow Spark Declarative Pipelines, Databricks SQL, Unity Catalog, and Databricks AI/BI Dashboards**.

This project transforms raw hotel booking data into clean, reliable, business-ready analytics using the Medallion Architecture (Bronze, Silver, and Gold).

---

## 1. Project Overview

The hotel group receives booking information through a CSV export. However, the raw dataset contains several data quality issues, including duplicate bookings, inconsistent text formatting, missing values, invalid stay dates, and negative room rates.

The objective of this project is to build a repeatable data pipeline that:

- Ingests raw hotel booking data into Databricks.
- Preserves the original data in the Bronze layer.
- Cleans and validates records in the Silver layer.
- Separates invalid records into a rejected table.
- Creates business-ready analytical tables in the Gold layer.
- Performs data quality checks and reconciliation.
- Visualizes business insights using Databricks AI/BI Dashboards.

## 2. Project Architecture

The project follows the Medallion Architecture.

![Medallion Architecture](assests/Medallion_Architecture.png)

### Data Flow

```text
Raw CSV Dataset
      |
      v
Unity Catalog Volume
      |
      v
+---------------------------+
|       BRONZE LAYER        |
|                           |
|  bronze_hotel_bookings    |
|  Raw data ingestion       |
+---------------------------+
      |
      v
+---------------------------+
|       SILVER LAYER        |
|                           |
|  silver_bookings_clean    |
|  silver_bookings_rejected |
|                           |
|  Cleaning and validation  |
+---------------------------+
      |
      v
+--------------------------------------+
|              GOLD LAYER              |
|                                      |
|  gold_monthly_bookings               |
|  gold_hotel_summary                  |
|  gold_room_type_summary              |
|  gold_channel_summary                |
|  gold_data_quality                   |
|                                      |
|  Business aggregations and metrics   |
+--------------------------------------+
      |
      v
+---------------------------+
|   DATABRICKS AI/BI        |
|       DASHBOARDS          |
|                           |
|   Executive Overview     |
|   Hotel Performance      |
|   Data Quality           |
+---------------------------+
```

## 3. Dataset Overview

**Dataset:** `hotel_bookings_raw.csv`

- Total source records: 1,316
- Number of columns: 20
- Dataset type: Synthetic hotel booking dataset
- Data period: January–December 2025
- Source format: CSV

The dataset contains information about:

| Category | Attributes |
|---|---|
| Booking | booking_id, guest_id, booking_status, booking_channel |
| Dates | booking_date, check_in_date, check_out_date, nights |
| Hotel | hotel_name, city, region |
| Room | room_type, guests, meal_plan |
| Financial | room_rate, total_amount, discount_amount |
| Payment | payment_method, payment_status |
| Rating | guest_rating |

### Data Quality Issues

The source dataset contains:

- Duplicate booking records.
- Extra spaces and inconsistent capitalization.
- Missing city, booking channel, guest ID, nights, and total amount.
- Check-out dates on or before check-in dates.
- Negative room rates.

## 4. Technology Stack

| Technology | Purpose |
|---|---|
| Databricks | Data Engineering platform |
| Apache Spark | Distributed data processing |
| Spark SQL | Data transformation and aggregation |
| Lakeflow Spark Declarative Pipelines | Pipeline orchestration |
| Unity Catalog | Data governance and storage management |
| Databricks AI/BI Dashboards | Business intelligence and visualization |
| CSV | Source dataset |
| GitHub | Project version control and documentation |

## 5. Medallion Architecture Implementation

### Bronze Layer – Raw Data Ingestion

**Table:** `bronze_hotel_bookings`

The raw CSV dataset is ingested from a Unity Catalog Volume using a Lakeflow streaming table.

Operations performed:

- Loaded the original CSV records.
- Preserved the source data.
- Captured the source filename.
- Added the ingestion timestamp.
- Identified duplicate booking IDs.

**Result:**
- Total Bronze records: 1,316
- Unique booking IDs: 1,290
- Duplicate records: 26

![Bronze Layer Pipeline](assests/Bronze_Layer_Pipeline.png)

### Silver Layer – Data Cleaning and Validation

The Silver layer contains two tables.

**1. `silver_bookings_clean`**

Data cleaning operations:

- Removed duplicate booking records using `ROW_NUMBER()`.
- Removed unnecessary spaces using `TRIM()`.
- Standardized text capitalization using `INITCAP()`.
- Replaced missing city and booking channel values with `Unknown`.
- Replaced missing nights using `DATEDIFF()`.
- Recalculated missing total amounts.
- Replaced missing discount amounts with zero.
- Retained valid completed and cancelled bookings.

**2. `silver_bookings_rejected`**

Invalid records are separated and stored with rejection reasons.

Validation rules:

- Check-out date must be later than check-in date.
- Room rate must not be negative.

**Silver Layer Results:**

| Metric | Records |
|---|---:|
| Bronze records | 1,316 |
| Clean bookings | 1,269 |
| Rejected records | 21 |
| Duplicate records removed | 26 |

![Silver Layer Pipeline](assests/Silver_Layer_Pipeline.png)

#### Silver Cleaning Workflow

![Silver Cleaning Steps](assests/Silver_Cleaning_Steps.png)

### Gold Layer – Business Analytics

The Gold layer contains five analytical tables created using SQL aggregations.

| Gold Table | Purpose |
|---|---|
| `gold_monthly_bookings` | Monthly booking and revenue analysis |
| `gold_hotel_summary` | Hotel, city, and regional performance |
| `gold_room_type_summary` | Room-type revenue and guest rating analysis |
| `gold_channel_summary` | Booking channel and cancellation analysis |
| `gold_data_quality` | Data quality metrics and reconciliation |

![Gold Layer Pipeline](assests/Gold_Layer_Pipeline.png)

#### Business Metrics

The following business calculations are used:

**Number of Nights**

```sql
DATEDIFF(check_out_date, check_in_date)
```

**Total Amount**

```sql
nights * room_rate
```

**Net Revenue**

```sql
total_amount - discount_amount
```

Net revenue is calculated only for completed bookings.

**Room Nights**

```sql
SUM(nights)
```

Room nights include completed bookings only.

**Average Daily Rate (ADR)**

```sql
net_revenue / room_nights
```

Cancelled bookings are retained in the Silver layer but excluded from Gold revenue and room-night calculations.

## 6. Data Quality and Reconciliation

Data quality checks are performed using `gold_data_quality`.

### Data Quality Results

| Data Quality Metric | Count |
|---|---:|
| Bronze Rows | 1,316 |
| Unique Bookings | 1,290 |
| Duplicate Rows | 26 |
| Clean Rows | 1,269 |
| Rejected Rows | 21 |
| Invalid Date Rows | 12 |
| Negative Rate Rows | 9 |
| Missing City Rows | 11 |
| Missing Channel Rows | 13 |
| Missing Guest ID Rows | 9 |
| Missing Nights Rows | 27 |
| Missing Amount Rows | 17 |

### Reconciliation Check

The project verifies that every Bronze record is accounted for as a clean record, rejected record, or removed duplicate.

```text
Bronze Rows = Clean Rows + Rejected Rows + Duplicate Rows

1,316 = 1,269 + 21 + 26

Reconciliation Status: PASSED
```

<details>
<summary>Data quality validation SQL</summary>

```sql
SELECT *
FROM hotel_booking_analytics.default.gold_data_quality;
```

</details>

## 7. Business Analysis Results

### Overall Business Performance

| Metric | Result |
|---|---:|
| Total Bookings | 1,269 |
| Cancelled Bookings | 186 |
| Completed Bookings | 1,083 |
| Room Nights | 3,107 |
| Net Revenue | ₹1,50,54,596.50 |

### Booking Channel Analysis

| Booking Channel | Bookings | Cancelled | Cancellation Rate |
|---|---:|---:|---:|
| Website | 449 | 71 | 15.81% |
| Mobile App | 451 | 69 | 15.30% |
| Travel Agent | 266 | 37 | 13.91% |
| Walk In | 90 | 8 | 8.89% |
| Unknown | 13 | 1 | 7.69% |

### Room Type Analysis

| Room Type | Bookings | Room Nights | Net Revenue |
|---|---:|---:|---:|
| Deluxe | 386 | 969 | ₹48,53,210 |
| Standard | 526 | 1,292 | ₹39,93,533 |
| Family Room | 238 | 581 | ₹35,33,089 |
| Suite | 119 | 265 | ₹26,74,764.50 |

## 8. Databricks AI/BI Dashboard

The final Gold tables are used to build an interactive dashboard in Databricks AI/BI.

The dashboard contains three pages.

### Page 1 – Overview

Provides an executive summary of hotel booking performance.

Key metrics:
- Total Bookings
- Net Revenue
- Room Nights
- Cancelled Bookings

Visualizations:
- Monthly Net Revenue Trend
- Net Revenue by City
- Net Revenue by Room Type
- Booking Status Distribution

![Overview Dashboard](dashboard/Overview.png)

### Page 2 – Hotels, Rooms & Channels

Provides detailed business performance analysis.

Visualizations:
- Net Revenue by Hotel
- Hotel Performance Details
- Room Type Revenue Analysis
- Average Guest Rating by Room Type
- Cancellation Rate by Booking Channel
- Revenue by Booking Channel

![Hotels, Rooms and Channels Dashboard](<dashboard/Hotels_Rooms&Channels.png>)

### Page 3 – Data Quality

Provides visibility into data quality and pipeline reconciliation.

Key metrics:
- Bronze Records
- Clean Bookings
- Rejected Records
- Duplicate Records
- Missing Values
- Invalid Dates
- Negative Room Rates
- Reconciliation Status

![Data Quality Dashboard](dashboard/Data_Quality.png)

## 9. GitHub Project Structure

```text
Hotel_Booking_Analytics_Project/
│
├── ETL_Pipeline/
│   ├── Bronze_transformation.sql
│   ├── Silver_transformation.sql
│   └── Gold_transformation.sql
│
├── assets/
│   ├── Bronze_Layer_Pipeline.png
│   ├── Gold_Layer_Pipeline.png
│   ├── Medallion_Architecture.png
│   ├── Silver_Cleaning_Steps.png
│   └── Silver_Layer_Pipeline.png
│
├── dashboard/
│   ├── Data_Quality.png
│   ├── Hotels_Rooms&Channels.png
│   └── Overview.png
│
├── data/
│   └── hotel_bookings_raw.csv
│
├── docs/
│   └── Hotel_Booking_Medallion_Data_Engineering_Project.pdf
│
└── README.md
```

## 10. Project Setup and Execution

### Prerequisites

- Databricks workspace.
- Unity Catalog access.
- Permission to create catalogs, schemas, volumes, and pipelines.
- Lakeflow Spark Declarative Pipelines support.

### Step 1 – Create Catalog, Schema and Volume

The project uses the following Unity Catalog configuration:

```sql
CREATE CATALOG IF NOT EXISTS hotel_booking_analytics;

CREATE SCHEMA IF NOT EXISTS
hotel_booking_analytics.default;

CREATE VOLUME IF NOT EXISTS
hotel_booking_analytics.default.hotel_bookings;
```

### Step 2 – Upload Dataset

Upload `hotel_bookings_raw.csv` into the Unity Catalog Volume.

Volume path:

```text
/Volumes/hotel_booking_analytics/default/hotel_bookings/
```

### Step 3 – Configure Lakeflow Pipeline

Create a Lakeflow Spark Declarative Pipeline and configure its default catalog and schema.

Add the following SQL transformation files:

```text
Bronze_transformation.sql
Silver_transformation.sql
Gold_transformation.sql
```

### Step 4 – Run the Pipeline

Execute the pipeline to create and refresh the Bronze, Silver, and Gold tables.

### Step 5 – Validate Gold Tables

Run SQL queries to verify the row counts, business metrics, and reconciliation status.

### Step 6 – Create Dashboard

Open Databricks AI/BI Dashboards, add the five Gold tables from Unity Catalog, and create the three dashboard pages.

## 11. Key Learnings

Through this project, I gained practical experience in:

- Implementing Medallion Architecture.
- Building SQL-based ETL pipelines in Databricks.
- Ingesting CSV files using Unity Catalog Volumes.
- Working with Lakeflow Spark Declarative Pipelines.
- Cleaning and validating structured datasets.
- Handling duplicate and rejected records.
- Creating analytical Gold-layer tables.
- Implementing data quality checks and reconciliation.
- Developing interactive AI/BI dashboards.
- Translating business requirements into analytical metrics.

## 12. Conclusion

This project demonstrates an end-to-end Data Engineering workflow, transforming a raw hotel booking dataset into trusted analytical data using Databricks.

The implementation establishes a repeatable pipeline across Bronze, Silver, and Gold layers, maintains data quality through validation and reconciliation, and delivers business insights through Databricks AI/BI Dashboards.

**Final Outcome:** 1,316 raw records processed, 1,269 clean bookings retained, 21 invalid records rejected, 26 duplicates removed, and all 1,316 records successfully reconciled.

---

**Project Domain:** Hotel Booking Analytics  
**Architecture:** Medallion Architecture  
**Platform:** Databricks  
**Pipeline:** Lakeflow Spark Declarative Pipelines  
**Language:** SQL  
**Dashboard:** Databricks AI/BI

