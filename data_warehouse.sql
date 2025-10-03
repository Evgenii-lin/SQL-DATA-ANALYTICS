-- BRONZE LAYER
-- This layer contains a rough, unfiltered data.

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





-- timestamps to help us understand how fast data is transformed
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

set @start_time = GETDATE();
set @end_time = GETDATE();

-- SILVER LAYER
-- This layer filteres bougus data(doublicates, incorrect string, etc...)

SELECT

customer_key,
COUNT(*)
FROM sales_data
GROUP BY customer_key
HAVING COUNT(*) > 1 OR customer_key IS NULL

SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY order_date DESC) as flag_last
FROM sales_data
)t WHERE flag_last != 1 

  
SELECT product_name
FROM products
WHERE product_name != TRIM(product_name)

SELECT
product_key,
TRIM(product_name) AS product_name

SELECT
customer_key,
age,
CASE WHEN UPPER(TRIM(gender)) = 'M' THEN 'Male'
     WHEN UPPER(TRIM(gender)) = 'F' THEN 'Female'
     ELSE 'n/a'
END gender


CASE WHEN UPPER(TRIM(category)) = 'S' THEN 'Sedan'
     WHEN UPPER(TRIM(category)) = 'SC' THEN 'Sport Car'
     WHEN UPPER(TRIM(category)) = 'Mini' THEN 'Minivan'
     ELSE 'n/a'
END category

  
SELECT
customer_key,
CAST (order_date AS DATE) AS prd_start_dt,
LEAD(order_date) OVER(PARTITION BY customer_key ORDER BY order_date) AS prd_end_date_test
FROM sales_data

SELECT
customer_key,
order_date
WHERE order_date > GETDATE() OR order_date < '2016-03-15';


WITH sales_query AS(
SELECT
sales_amount,
sales_days
FROM sales_data AS s
LEFT JOIN products AS p
WHERE s.product_key = p.product_key
)

SELECT 
sales_amount,
sales_days,
cost
FROM sales_query
WHERE sales_amount != sales_days * cost
OR sales_amount IS NULL OR sales_days IS NULL OR cost IS NULL
ORDER BY sales_amount,sales_days,cost

-- GOLD LAYER
-- This layer contains a buisness data to present.

SELECT DISTINCT
customer_key,
order_date,
sales_amount,
days,
product_key,
customer_age,
last_order,
CASE WHEN c.gender !='n/a' THEN c.gender
     ELSE COALESCE(c.gender, 'n/a')
FROM sales_Data AS s
LEFT JOIN products AS p
ON s.product_key = p.product_key
LEFT JOIN customers AS c
ON s.customer_key = c.customer_key

