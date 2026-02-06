-- Database Exploration
SELECT * FROM INFORMATION_SCHEMA.TABLES
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

--Table exploration
SELECT * FROM dbo.dim_customers
SELECT * FROM dbo.dim_products
SELECT * FROM dbo.fact_sales


--Explore all countries our customers come from
SELECT DISTINCT Country  FROM dbo.dim_customers

-- Explore all categories "The major Divisions"
SELECT DISTINCT Category, subcategory, product_name FROM dbo.dim_products

--Date exploration
--Find the date of first and last order & How many years of sales available
SELECT
MIN(Order_date) as First_Order_date, 
MAX(Order_date) as Last_Order_date,
DATEDIFF( year, MIN(Order_date),MAX(Order_date)) as Order_Range
from dbo.fact_sales

-- Find the Youngest and Oldest customers with age
SELECT
MIN(birthdate) as Oldest_customers,
DATEDIFF( year, MIN(birthdate),GETDATE()) as Oldest_age,
MAX(birthdate) as Youngest_customers,
DATEDIFF( year, MAX(birthdate),GETDATE()) as Order_Range
FROM Dbo.dim_customers

--Find the total sales
SELECT SUM(sales_amount) AS Total_sales
FROM DBO.fact_sales

--Find how many items are sold
SELECT SUM(quantity)AS Total_quantity
FROM DBO.fact_sales

-- Find avg selling price
SELECT AVG(price) as Avg_price 
FROM DBO.fact_sales

--Find the total no.of Orders
SELECT COUNT(DISTINCT order_number) AS Total_orders
FROM DBO.fact_sales

--Find the total no.of products
SELECT COUNT(product_name)
FROM DBO.dim_products

--Find the total no.of Customers
SELECT COUNT(customer_id)
FROM DBO.dim_customers

-- Total no.of customers that has plced order
SELECT COUNT(DISTINCT customer_key)
FROM DBO.fact_sales

-- Generate a report  that shows all key matrics of the bussiness
SELECT 'Total sales' as MEASURE_NAME ,SUM(sales_amount) AS MEASURE_VALUE FROM DBO.fact_sales
UNION all
SELECT 'Toatal Quantity ' , SUM(quantity) FROM DBO.fact_sales
UNION all
SELECT 'AVG Price ', SUM(price) FROM DBO.fact_sales
UNION all
SELECT 'Total no.of Orders', COUNT(DISTINCT order_number) FROM DBO.fact_sales
UNION all
SELECT 'Total no. of Products',COUNT(product_name) FROM DBO.dim_products
UNION all
SELECT 'Total no.of Customers', COUNT(customer_id) FROM DBO.dim_customers

-- Magnitude Analysis--
--Find the total no.of Customers by Countries
SELECT COUNT(customer_id), country FROM DBO.dim_customers
group by country ORDER BY COUNT(customer_id)

--Find the total customers by Gender
SELECT COUNT(customer_id),gender FROM DBO.dim_customers
group by gender ORDER BY COUNT(customer_id)

-- Find total products by category
SELECT COUNT(product_key) total_products,category FROM DBO.dim_products
group by category

--what is avg costs in each category
SELECT AVG(cost) avg_cost,category FROM DBO.dim_products
group by category

--what is the total revenue generated FOR EACH CATEGORY
SELECT SUM(S.sales_amount) Total_revenue, P.category FROM DBO.dim_products P
LEFT JOIN DBO.fact_sales S ON P.product_key = S.product_key
group by category ORDER BY Total_revenue

-- Find total revenue genereated by each customers
SELECT C.customer_key,SUM(S.sales_amount) Total_revenue FROM DBO.fact_sales S
LEFT JOIN DBO.dim_customers C ON C.customer_key = S.customer_key
group by C.customer_key ORDER BY SUM(S.sales_amount) Desc

-- what is the distrubution of sold items across the countries
SELECT C.country,SUM(S.quantity) Total_solditems FROM DBO.fact_sales S
LEFT JOIN DBO.dim_customers C ON C.customer_key = S.customer_key
group by C.country ORDER BY SUM(S.quantity) Desc

-- which 5 products generate the highest revenue
SELECT TOP 5 P.product_name, SUM(sales_amount) total_revenue FROM DBO.fact_sales S JOIN DBO.dim_products P
ON P.product_key = S.product_key group by product_name order by SUM(sales_amount) DESC

-- What are the 5 worst performing Producs in terms of sale
SELECT TOP 5 P.product_name, SUM(sales_amount) total_revenue FROM DBO.fact_sales S JOIN DBO.dim_products P
ON P.product_key = S.product_key group by product_name order by SUM(sales_amount)

-- find the top 10 customers who have generated the highest revenue and 3 customers with fewest ordder place
SELECT TOP 10 C.customer_KEY, SUM(sales_amount) total_revenue FROM DBO.fact_sales S JOIN DBO.dim_customerS  C
ON C.customer_KEY = S.customer_keY GROUP BY C.customer_KEY order by SUM(sales_amount) DESC

SELECT TOP 3 C.customer_KEY, COUNT(DISTINCT order_number) total_ORDER FROM DBO.fact_sales S JOIN DBO.dim_customerS  C
ON C.customer_KEY = S.customer_keY GROUP BY C.customer_KEY order by COUNT(order_number)

-- CHANGE OVER TIME
-- Analyze sales performance over time
SELECT
	DATEPART(Year,order_date) Order_month,
	DATENAME(MONTH,order_date) Order_month,
	SUM(sales_amount) Total_sales,
	SUM(quantity) toatal_quantity,
	COUNT(DISTINCT customer_key) Total_customers
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(Year,order_date), DATENAME(MONTH,order_date)
ORDER BY DATEPART(Year,order_date), DATENAME(MONTH,order_date)
--

SELECT
	CONCAT(DATENAME(MONTH,order_date),' ' ,DATEPART(Year,order_date)) Order_month,
	SUM(sales_amount) Total_sales,
	SUM(quantity) toatal_quantity,
	COUNT(DISTINCT customer_key) Total_customers
FROM dbo.fact_sales
WHERE order_date IS NOT NULL
GROUP BY CONCAT(DATENAME(MONTH,order_date),' ' ,DATEPART(Year,order_date))
ORDER BY CONCAT(DATENAME(MONTH,order_date),' ' ,DATEPART(Year,order_date))

-- CUMULATIVe ANALYSIS
--Running Total of sales and MOVING AVG over MONTH
SELECT 
	Order_month,
	total_sales,
	SUM(Total_sales) OVER(ORDER BY order_month) RUNNING_TOTAL,
	AVG(AVG_price) OVER(ORDER BY order_month) Moving_AVG
From
(SELECT
	DATETRUNC(MONTH, order_date) Order_month,
	SUM(sales_amount) Total_sales,
	AVG(Price) AVG_price
FROM dbo.fact_sales
WHERE ORDER_DATE IS NOT NULL
GROUP By DATETRUNC(MONTH, order_date)) RTS

--Running Total of sales AND Moving AVG over year
SELECT 
	Order_Year,
	total_sales,
	SUM(Total_sales) OVER(ORDER BY order_Year) RUNNING_TOTAL,
	AVG(AVG_price) OVER(ORDER BY order_year) Moving_AVG

From
(SELECT
	DATETRUNC(YEAR, order_date) Order_Year,
	SUM(sales_amount) Total_sales,
	AVG(Price) AVG_price
FROM dbo.fact_sales
WHERE ORDER_DATE IS NOT NULL
GROUP By DATETRUNC(Year, order_date)) RTS

-- Performance Aalysis
--Analyse the Yearly Performance of Products By comparing each products sales to both its avg sales performance of product & Previous years sales
With CTE_Yearly_Product_sales
AS
(SELECT Year(S.order_date) Order_year, p.product_name, SUM(S.sales_amount) Current_sales
FROM dbo.fact_sales S LEFT JOIN DBO.dim_products P
ON s.product_key = P.product_key
WHERE s.order_date is not null
group By Year(S.order_date), p.product_name)

SELECt
	Order_year,
	product_name,
	Current_sales,
	AVG(Current_sales) Over(Partition by product_name) AVG_sales,
	Current_sales - AVG(Current_sales) Over(Partition by product_name) Diff_avg,
	CASE WHEN Current_sales - AVG(Current_sales) Over(Partition by product_name) > 0 THEN 'ABOVE AVG'
		WHEN Current_sales - AVG(Current_sales) Over(Partition by product_name) <0 THEN 'BELOW AVG'
		ELSE'AVG'
    END CHANGE_AVG,
	LAG(current_sales) Over(partition by product_name order by order_year DESC)Previous_yr_sales,
	Current_sales - LAG(current_sales) Over(partition by product_name order by order_year DESC ) DIFF_PRE_YR_sales,
	CASE WHEN Current_sales - LAG(current_sales) Over(partition by product_name order by order_year DESC ) > 0 THEN 'Increase'
		WHEN Current_sales - LAG(current_sales) Over(partition by product_name order by order_year DESC ) <0 THEN 'Decrease '
		ELSE'No cahnge'
    END Pre_YR_Change
From CTE_Yearly_Product_sales
order by product_name,Order_year

-- Proportion Analysis
--Which Category contributes the most to overall sale
WITH CTE_Category_Sales
as(
SELECT
Category,
SUM( sales_amount) Total_sales
from dbo.fact_sales S left join dbo.dim_products p
ON s.product_key= P.product_key
group by category)

Select category, Total_sales,
SUM(total_sales) Over() overall_sales,
Round((CAST(Total_sales as float)/SUM(total_sales) Over())*100,2) AS Percentage_OF_Sales
from CTE_Category_Sales

--Data Segmentation
-- Segment Product into cost Range and count how many products fall into eacg segment
SELECT Cost_range,
	  COUNT(Product_key) Total_products
FROM
(SELECT product_key, product_name, cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 and 500 THEN '100-500'
	 WHEN cost BETWEEN 500 and 1000 THEN '500-1000'
	 WHEN cost BETWEEN 1000 and 2000 THEN '1000-2000'
	 ELSE 'Above 2000'
END Cost_range
FROM dbo.dim_products) As Product_segment
GROUP BY Cost_range
ORDER BY Total_products desc

/*-- Group CUstomers into 3 segments based on their spending behaviour:
    : VIP at least 12 month of history and spending more than 5000
	: REGULAR at least 12 month of history and spending 5000 or less
	:NEW lifespan less thn 12 months
	find total no. of customers by each group */

WITH CTE_Customer_spending
AS
(SELECT C.customer_key,
	   SUM(S.sales_amount) Total_spending,
	   MIN(order_date) as First_order,
	   MAX(order_date)as Last_order,
	   DATEDIFF (MONTH, MIN(order_date),MAX(order_date)) as Lifespan
FROM dbo.fact_sales S  LEFT JOIN DBO.dim_customers C
ON C.customer_key = S.customer_key
group by  C.customer_key)

select CUSTomer_seg,
count(customer_key) as Total_customers
from(	
Select 
		customer_key,
		Total_spending,
		Lifespan,
	CASE WHEN Lifespan >12 and Total_spending >5000 Then 'VIP'
		 WHEN Lifespan <12 and Total_spending <=5000 Then 'Regular'
		 Else 'NEW'
	end Customer_seg
From CTE_Customer_spending) CUSTOMER_SEGMENT
group by Customer_seg 
Order by Total_customers desc



/*

**CUSTOMER REPORT**

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend

*/

CREATE VIEW DBO.V_report_customers AS
--CTE 1
WITH base_query AS(
--1) Base Query: Retrieves core columns from tables

SELECT s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) age
FROM dbo.fact_sales S
LEFT JOIN dbo.dim_customers c
ON c.customer_key = s.customer_key
WHERE order_date IS NOT NULL),

-- CTE 2
 customer_aggregation AS (
--2) Customer Aggregations: Summarizes key metrics at the customer level

SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE 
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products
lifespan,

-- Compuate average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Compuate average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation

 
 SELECT customer_segment,
 COUNT(customer_key) as Total_customers,
 SUM(Total_sales) Total_sale
 from dbo.report_customers
 group by customer_segment


 /*

**Product Report**

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue

*/

CREATE VIEW V_report_products AS
--CTE1
WITH FIRST_QUERY AS (
--1) Base Query: Retrieves core columns from fact_sales and dim_products
    SELECT
	    S.order_number,
        S.order_date,
		S.customer_key,
        s.sales_amount,
        S.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM dbo.fact_sales S
    LEFT JOIN dbo.dim_products P
        ON S.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),
--CTE2
product_aggregations AS (

--2) Product Aggregations: Summarizes key metrics at the product level
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM FIRST_QUERY

GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

  --3) Final Query: Combines all product results into one output
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,

	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations 

Select* from V_report_products