# SQL-DATA-ANALYTICS
Analyze data tables with SQL and build bronze, silver, golden layer to understand customer behavior

TABLE SALES_DATA:
This table contains information about customers sales, who rent a car

sales_data with fields: customer_key(INT), order_date(DATE), sale_amount(INT), days(INT), product_key(INt), customer_age(INT), last_order(DATE)

TABLE PRODUCTS:
This table contains information about rented cars

products with fields: product_key(INT), product_name(STRING), cost(INT)

TABLE CATEGORIES:
This table contains information about type of car to rent

categories with fields: product_key(INT), category(STRING), total_sales(INT)

TABLE CUSTOMERS:
This table contains information about social information: age and gender of a customer

customers with fields: customer_key(INT), age(INT), gender(STRING)








