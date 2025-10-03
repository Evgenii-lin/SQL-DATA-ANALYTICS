CREATE TABLE IF NOT EXISTS sales_data(
	customer_key INT NOT NULL AUTO_INCREMENT,
    order_date DATE,
	sale_amount INT,
	days INT,
	product_key INT,
	customer_age INT,
	last_order DATE
);

CREATE TABLE IF NOT EXISTS products(
	product_key INT NOT NULL AUTO_INCREMENT,
	product_name STRING,
	cost INT
);

CREATE TABLE IF NOT EXISTS categories(
	product_key INT NOT NULL AUTO_INCREMENT,
	category STRING,
	total_sales INT
);

CREATE TABLE IF NOT EXISTS customers(
	customer_key INT NOT NULL AUTO_INCREMENT,
	age INT,
	gender STRING
);

INSERT INTO sales_data(order_date,sale_amount,days,product_key,customer_age,last_order) VALUES

('15.09.2025',4500,5,1,26,'15.09.2025'),
('15.09.2025',5000,8,1,26,'15.09.2025'),
('15.09.2025',7000,9,1,27,'15.09.2025'),
('15.09.2025',7500,4,2,27,'16.09.2025'),
('15.09.2025',7130,3,4,27,'16.09.2025'),
('15.09.2025',7640,13,3,28,'16.09.2025'),
('15.09.2025',4570,5,5,28,'17.09.2025'),
('17.09.2025',3270,4,5,32,'17.09.2025'),
('17.09.2025',7890,16,4,35,'19.09.2025'),
('17.09.2025',7890,16,4,35,'19.09.2025'),
('16.09.2025',4560,22,1,29,'16.05.2024'),
('17.05.2024',2150,22,1,29,'16.05.2024'),
('18.05.2024',3478,17,3,35,'18.05.2024'),
('19.05.2024',8723,11,3,36,'19.05.2024'),
('20.05.2024',7902,18,3,38,'20.05.2024'),
('11.03.2023',5689,12,4,28,'11.03.2023'),
('12.03.2023',9870,15,4,30,'12.03.2023'),
('13.03.2023',3289,10,4,26,'13.03.2023'),
('14.03.2023',3260,16,5,25,'14.03.2023'),
('15.03.2023',2790,10,5,24,'15.03.2023'),
('10.01.2022',3480,12,4,24,'10.01.2022'),
('11.01.2022',3970,17,5,23,'11.01.2022'),
('12.01.2022',4170,18,5,23,'12.01.2022'),
('13.01.2022',2650,5,4,21,'13.01.2022'),
('14.01.2022',2150,6,5,21,'14.01.2022');


INSERT INTO products(product_name, cost) VALUES

('BMW',2500),
('Audi',2410),
('Toyta',3700),
('Chevrolet',3800),
('Mitsubishi',3200);


INSERT INTO categories(category, total_sales) VALUES

('sedan',5700),
('Sport car',6100),
('Minivan',7430),
('suv',6540),
('Sport car',7890);


INSERT INTO customers(age, gender) VALUES

(26,'M'),
(26,'M'),
(27,'M'),
(27,'F'),
(27,'F'),
(28,'F'),
(28,'M'),
(32,'F'),
(35,'M'),
(41,'M');



-- Find total sales by year

SELECT
DATE_PART('year', order_date)
SUM(sales_amount) as total_sales
COUNT(DISTINCT customer_key) as total_customer,
SUM(days) as total_days
FROM 
sales_data
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('year', order_date)
ORDER BY DATE_PART('year', order_date)

-- Calculate the total sales per month

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,    
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price     
FROM
(                                                                    
SELECT
DATE_PART('month', order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM sales_data
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('month', order_date)
ORDER BY DATE_PART('month', order_date)
) t

-- Analyze the yearly performance of products by comparing each products sales to 
-- both its average sales performance and the previous years sales

WITH yearly_product_sales AS (                        

SELECT 
DATE_PART('year', order_date) AS order_year,
product_name,
SUM(sales_amount)  AS current_sales
FROM sales_data AS s
LEFT JOIN products AS p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY
DATE_PART('year', s.order_date),
p.product_name
)

SELECT
order_year,
product_name,
current_sales, 
AVG(current_sales) OVER (PARTITION BY product_name)  As avg_sales                  
current_sales - AVG(current_sales) OVER (PARTITION By product_name) AS diff_avg                              										    
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
     WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
     ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITOON BY product_name ORDER BY order_year) previous_year,                                          
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS difference_prev_year                   
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name BY order_year) > 0 THEN 'Increase'                   
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name BY order_year) < 0 THEN 'Decrease'
     ELSE 'No change'
END previous_year
FROM yearly_product_sales                                                                                                       
ORDDER BY product_name, order_year


-- Analyze how an individual part is performing compared to the overall,
-- allowing us to understand which category has the greatest impact on the buisness

WITH category_sales AS (
SELECT
category,
SUM(sales_amount) total_sales
FROM sales_data AS s
LEFT JOIN categories AS c
ON c.product_key = s.product_key
GROUP BY category) t

SELECT                                                
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND(total_sales AS FLOAT / SUM(total_sales) OVER () ) *100, 2), '%') AS precentage_of_total
FROM categories
ORDER BY total_sales DESC

-- Segment products into cost ranges and count how many products fall into each segment

WITH product_segments AS (
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 5000 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
FROM products)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM products_segments
GROUP BY cost_range
ORDER BY total_products DESC

-- Group customers into three segments

WITH customer_spending AS (                       
SELECT 
c.customer_key
SUM(s.sales_amount) AS total_spending,
s.order_date,
MIN(order_date) AS first_order
FROM sales_data AS last_order,
DATEDIFF (month, MIN(order_date), AMX(order_date)) AS lifespan
LEFT JOIN customers AS c
ON s.customer_key = c.customer_key
)

SELECT                             
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan > 12 AND total spending > 5000 THEN 'VIP'
     WHEN lifespan > 12 AND total spending <= 5000 THEN 'Regular'
     ELSE 'New'
END customer_segment
FROM customer_spending              

 
SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
    SELECT
    customer_key,
    CASE WHEN lifespan > 12 AND total spending > 5000 THEN 'VIP'
         WHEN lifespan > 12 AND total spending <= 5000 THEN 'Regular'
         ELSE 'New'
    END customer_segment
    FROM customer_spending ) t
GROUP BY customer_segment
ORDER BY total_customers DESC
)

-- Consolidate key customer metrics and behaviors

WITH base_query AS(
SELECT
s.order_number
s.product_key
s.order_date
s.sales_amount
s.days
c.customer_key,
c.gender
c.age
FROM sales_data AS s
LEFT JOIN customers AS c
ON c.customer_key=s.customer_key
)


SELECT
customer_key,
customer_number,
customer_gender,
customer_age
COUNT(DISTINCT order_number) AS total_orders,
SUM(slaes_amount) AS total_sales,
SUM(days) AS total_days,
COUNT(DISTINCT product_key) AS total_products
AMX(order_date) AS last_order_date
FROM base_query
GROUP BY
customer_key,
customer_number,
customer_gender,
customer_age



SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age< 20 THEN 'Under 20'
     WHEN age between 20 and 29 THEN '20-29'
     WHEN age between 30 and 39 THEN '30-39'
     WHEN age between 40 and 49 THEN '40-49'
ELSE '50 and above'
CASE 
         WHEN lifespan > 12 AND total spending > 5000 THEN 'VIP'
         WHEN lifespan > 12 AND total spending <= 5000 THEN 'Regular'
         ELSE 'New'
END AS customer_segment,
total_orders,
total_sales,
total_days,
last_order_date,
lifespan
FROM customer_aggregation
