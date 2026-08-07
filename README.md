# Olist-Brazilian-ECommerce-Data-Analysis-90K-Rows
End-to-end ETL data analysis project using Python, SQL Server, and Power BI on the Olist Brazilian E-Commerce dataset. Covers multi-table data cleaning, feature engineering, business queries with JOINs, and an interactive dashboard.

# Olist Brazilian E-Commerce Data Analysis

End-to-end data analysis project using Python, SQL Server, and Power BI on the Olist Brazilian E-Commerce dataset. Covers multi-table data cleaning, feature engineering, business queries with JOINs, and an interactive dashboard.

---

## Tools Used

- **Python / pandas** — data cleaning, feature engineering, and ETL
- **SQL Server** — data storage and business queries
- **Power BI** — data modeling and interactive dashboard

---

## Dataset

- **Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Tables:** 5 CSV files
- **Delivered orders analyzed:** 90,000+
- **Period covered:** 2016 – 2018

---

## Project Pipeline

```
Raw CSVs → Python/pandas → SQL Server → Power BI
```

### 1. Python / pandas
- Loaded 5 separate CSV files and inspected each for nulls and data types
- Fixed data types — converted 7 date columns to `datetime64`, ensured numeric columns were `float64`/`int64`
- Handled nulls per table:
  - Dropped orders without approval date or delivery date
  - Filled missing product categories with `'unknown'`
  - Filled missing review comments with empty string (normal — most reviews have no comment)
- Merged Portuguese category names with English translation table
- Feature engineering:
  - `delivery_days` — days between purchase and delivery
  - `is_late` — 1 if delivered after estimated date, 0 if on time
  - `order_year` / `order_month` — extracted from purchase timestamp
  - `revenue` — price + freight value per item

### 2. SQL Server
- Loaded 5 clean tables into `OlistDB`
- Wrote 7 business queries using JOINs, GROUP BY, HAVING, CAST, and CASE WHEN

### 3. Power BI
- Connected directly to SQL Server
- Built relationships between 5 tables in Model View
- Created interactive 2-page dashboard

---

## SQL Business Questions

**1. Total revenue by product category**
```sql
SELECT
    product_category_name_english,
    ROUND(SUM(revenue), 2) AS SumOfCategory
FROM olist_items_clean
    JOIN olist_products_clean
    ON olist_items_clean.product_id = olist_products_clean.product_id
GROUP BY product_category_name_english
ORDER BY SUM(revenue) DESC
```

**2. Top 10 states by number of orders**
```sql
SELECT TOP 10
    customer_state,
    COUNT(order_id) AS NumberOfOrders
FROM olist_orders_cleaned
    JOIN olist_customers_clean
    ON olist_orders_cleaned.customer_id = olist_customers_clean.customer_id
GROUP BY customer_state
ORDER BY COUNT(order_id) DESC
```

**3. Average review score by product category**
```sql
SELECT
    product_category_name_english,
    ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS AverageScore
FROM olist_reviews_clean
    JOIN olist_items_clean
    ON olist_reviews_clean.order_id = olist_items_clean.order_id
    JOIN olist_products_clean
    ON olist_items_clean.product_id = olist_products_clean.product_id
GROUP BY product_category_name_english
ORDER BY ROUND(AVG(CAST(review_score AS FLOAT)), 2) DESC
```

**4. Monthly order trend for 2017**
```sql
SELECT
    CASE order_month
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS Month,
    COUNT(order_id) AS NumberOfOrdersPerMonth
FROM olist_orders_cleaned
WHERE order_year = 2017
GROUP BY order_month
ORDER BY order_month
```

**5. Percentage of orders delivered late**
```sql
SELECT
    COUNT(*) AS TotalOrders,
    SUM(CAST(is_late AS INT)) AS LateOrders,
    ROUND(CAST(SUM(CAST(is_late AS INT)) AS FLOAT) / COUNT(*) * 100, 2) AS LatePercentage
FROM olist_orders_cleaned
```

**6. Top 10 cities by revenue**
```sql
SELECT TOP 10
    customer_city,
    FORMAT(ROUND(SUM(revenue), 2), 'N2') AS TotalRevenue
FROM olist_items_clean
    JOIN olist_orders_cleaned
    ON olist_items_clean.order_id = olist_orders_cleaned.order_id
    JOIN olist_customers_clean
    ON olist_orders_cleaned.customer_id = olist_customers_clean.customer_id
GROUP BY customer_city
ORDER BY SUM(revenue) DESC
```

**7. Average delivery days by state**
```sql
SELECT
    customer_state,
    CAST(ROUND(AVG(delivery_days), 0) AS INT) AS AverageDeliveryDays
FROM olist_orders_cleaned
    JOIN olist_customers_clean
    ON olist_orders_cleaned.customer_id = olist_customers_clean.customer_id
GROUP BY customer_state
ORDER BY AVG(delivery_days) ASC
```

---

## Key Findings

- **health_beauty** was the top revenue category at over 1.4M
- **São Paulo** had the highest revenue of any city at 38.85% of top 10 city revenue
- **8.11%** of orders were delivered late
- **RR (Roraima)** had the slowest average delivery days — expected given its remote location in northern Brazil
- **SP (São Paulo)** had the fastest delivery — proximity to major distribution centers
- **cds_dvds_musicals** had the highest average review score — niche categories tend to have more intentional buyers
- Monthly orders showed consistent growth from 2016 to late 2017 before a sharp drop in late months

---

## Dashboard Preview

![Dashboard](images/dashboard_preview.png)

---

## Repository Structure

```
Olist_Data_Analysis/
│
├── data/
│   ├── olist_orders_clean.csv
│   ├── olist_items_clean.csv
│   ├── olist_customers_clean.csv
│   ├── olist_products_clean.csv
│   └── olist_reviews_clean.csv
│
├── notebooks/
│   └── olist_cleaning.ipynb
│
├── sql/
│   └── olist_queries.sql
│
├── powerbi/
│   └── olist_dashboard.pbix
│
├── images/
│   └── dashboard_preview.png
│
└── README.md
```

---

## Notes

> The Power BI file connects to a local SQL Server instance (`OlistDB`).
> To use it locally, import the CSV files from the `/data` folder into your own
> SQL Server instance, or connect Power BI directly to the CSV files.
