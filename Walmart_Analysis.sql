CREATE DATABASE walmart_db;
USE walmart_db;
SHOW TABLES;
SHOW DATABASES;
USE walmart_db;

SELECT COUNT(*) FROM walmart;
SELECT * FROM walmart LIMIT 10;

SELECT * FROM walmart;
SELECT COUNT(*) FROM walmart;

SELECT DISTINCT payment_method FROM walmart;

SELECT payment_method,COUNT(*)
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

-- Q.1 Find different payment methods and number of transactions, no of qty sold
SELECT payment_method,COUNT(*) as no_payments ,SUM(quantity) as no_qts_sold
FROM walmart
GROUP BY payment_method;

-- Q.2 Identify the highest-rated category in each branch, displaying the branch,category, AVG rating
SELECT *
FROM
(
	SELECT 
		branch,
        category, 
        AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranking
	FROM walmart
	GROUP BY branch,category
)AS ranked_categories
WHERE ranking = 1;

-- Q.3 Identify the busiest day for each branch on the number of transactions
SELECT * FROM walmart;  

SELECT *
FROM
	(SELECT 
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
		COUNT(*) as no_of_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranking 
	 FROM walmart  
     GROUP BY branch, day_name
     ) AS ranked_data
WHERE ranking = 1;     

-- Q.4 Calculate the total qyuantity of items sold per payment method. List payment_method and total_quantity.
SELECT
	payment_method,
    -- COUNT(*) as no_payments
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method; 

-- Q.5 Determine the average, minimum, and maximum rating of products for each city.
-- List the city, average_rating, min_rating, amd max_rating

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY city,category;   

-- Q.6 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart
GROUP BY category;    

-- Q.7 Determine the most common payment method for each branch. Display branch and the preferred_payment_method.

WITH cte
AS
( SELECT 
	 branch,
     payment_method,
     COUNT(*) as total_trans,
     RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
 FROM walmart
 GROUP BY branch, payment_method
)    
 SELECT * FROM cte
 WHERE ranking = 1;
 
 -- Q.8 Categorize sales into 3 groups MORNING, AFTERNOON, EVENING
 -- Find out each of the shift and the number of invoices
	 
SELECT   
  branch, 
  CASE    
    WHEN HOUR(time) < 12 THEN 'Morning'         
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'         
    ELSE 'Evening'  
  END AS day_time,     
  COUNT(*) AS total_transactions
FROM walmart 
GROUP BY branch, day_time 
ORDER BY branch, total_transactions DESC;

-- Q.9 Identify 5 branch with highest decrease ratio in revenue compared to last year
-- (current year 20233 and last year 2022)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;