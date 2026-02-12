
# 📊 SQL_EDA_PROJECT – Retail Sales

## 📌 Project Overview
This project performs Exploratory Data Analysis (EDA) on a retail sales dataset using SQL Server (SSMS).  
The analysis covers data exploration, aggregation, segment-level insights, and business-focused metrics to understand sales trends, customer behavior, and product performance.

> ⚠ **Note:** This was completed as a guided project, but all SQL queries were written and understood independently as part of learning and practice.

---

## 🛠 Tools Used
- SQL Server Management Studio (SSMS)
- T-SQL (Structured Query Language)


---

## 📂 Dataset Description
The dataset used in this project includes multiple tables representing retail sales information, such as:
- `fact_sales`: Transaction-level sales records
- `dim_customers`: Customer attributes
- `dim_products`: Product attributes

The analysis explores key business questions like total sales, customer distribution, product performance, and time-based sales trends.

---

## 🧹 Data Exploration & Cleaning
Key steps performed:
- Explored database metadata (`INFORMATION_SCHEMA.TABLES` / `COLUMNS`)
- Examined table structures and sample rows
- Investigated duplicate IDs and confirmed validity of sales transactions
- Checked for and interpreted NULLs and invalid data values

---

## 🔎 Key Analysis Sections (Business Questions Answered)

### 📈 Overall Sales Metrics
- Total sales amount
- Total quantity sold
- Average selling price
- Total number of orders, customers, and products

### 🧮 Customer & Regional Analysis
- Customer count by country
- Customer count by gender
- Total sales and quantity by country
- Top customers by revenue

### 🧾 Product Performance
- Total products by category
- Average cost by category
- Revenue contribution by category
- Top performing vs least performing products

### ⏱ Sales Over Time
- Yearly and monthly sales trends
- Recency and lifecycle measures

### 📊 Cumulative & Advanced Metrics
- Running totals and moving average of sales
- Year-over-year performance comparisons
- Revenue relative to historical averages

### 📌 Customer Segmentation
- Segmented customers based on lifespan and total spending:
  - VIP
  - Regular
  - New

---

## 💡 Key Findings & Insights
- Sales distribution varies significantly by region and country.
- Certain product categories generate disproportionately high revenue.
- Customer segmentation revealed distinct spending patterns among segments.
- Time-series analysis showed specific sales growth patterns year-over-year.
- Cumulative and moving average metrics provided insights into trend sustainability.



- Further segmentation and cohort analysis

