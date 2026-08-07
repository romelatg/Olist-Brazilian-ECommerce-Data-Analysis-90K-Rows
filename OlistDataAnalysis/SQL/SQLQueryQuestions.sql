SELECT * FROM olist_orders_cleaned
SELECT * FROM olist_items_clean
SELECT * FROM olist_customers_clean
SELECT * FROM olist_products_clean
SELECT * FROM olist_reviews_clean

-- Question 1: Total revenue by product category
SELECT
	product_category_name_english,
	ROUND(SUM(revenue),2) SumOfCategory
FROM olist_items_clean
	JOIN olist_products_clean
	ON olist_items_clean.product_id = olist_products_clean.product_id
GROUP BY product_category_name_english
ORDER BY SUM(revenue) DESC

-- Question 2: Top 10 states by number of orders 
SELECT TOP 10
	customer_state,
	COUNT(order_id) NumberOfOrders
FROM olist_orders_cleaned
	JOIN olist_customers_clean
	ON olist_orders_cleaned.customer_id = olist_customers_clean.customer_id
GROUP BY customer_state
ORDER BY COUNT(order_id) DESC

-- Question 3: Average review score by product category
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
	
-- Question 4: Monthly order trend for 2017
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

-- Question 5: What percentage of orders were delivered late?
SELECT
    COUNT(*) AS TotalOrders,
    SUM(CAST(is_late AS INT)) AS LateOrders,
    ROUND(CAST(SUM(CAST(is_late AS INT)) AS FLOAT) / COUNT(*) * 100, 2) AS LatePercentage
FROM olist_orders_cleaned

-- Question 6: Top 10 cities by revenue
SELECT TOP 10
    customer_city,
    FORMAT(ROUND(SUM(revenue), 2), 'N2') AS TotalRevenue
    --^This returns a string
FROM olist_items_clean
    JOIN olist_orders_cleaned
    ON olist_items_clean.order_id = olist_orders_cleaned.order_id
    JOIN olist_customers_clean
    ON olist_orders_cleaned.customer_id = olist_customers_clean.customer_id
GROUP BY customer_city
ORDER BY SUM(revenue) DESC

-- Question 7: Average delivery days by state
SELECT
    customer_state,
    ROUND(AVG(delivery_days),0) AverageDeliveryDays
FROM olist_orders_cleaned
    JOIN olist_customers_clean
    ON olist_orders_cleaned.customer_id = olist_customers_clean.customer_id
GROUP BY customer_state
ORDER BY AVG(delivery_days) ASC

