
CREATE SCHEMA olist;

-- DROP TABLES if needed --
DROP TABLE olist.olist_customers_dataset;
DROP TABLE olist.olist_orders_dataset;
DROP TABLE olist.olist_products_dataset;
DROP TABLE olist.olist_order_items_dataset;

--CREATING TABLES --
CREATE TABLE olist.olist_customers_dataset(
customer_id VARCHAR(50) PRIMARY KEY,
customer_unique_id VARCHAR(75),
customer_zip_code_prefix INT,
customer_city VARCHAR(100),
customer_state VARCHAR(2)
);

CREATE TABLE olist.olist_orders_dataset(
order_id VARCHAR(50) PRIMARY KEY,
customer_id VARCHAR(50),
order_status VARCHAR(50),
order_purchase_timestamp TIMESTAMP,
order_approved_at TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP,

FOREIGN KEY(customer_id) REFERENCES olist.olist_customers_dataset(customer_id)
);

CREATE TABLE olist.olist_products_dataset
(
 product_id VARCHAR(50) PRIMARY KEY,
 product_category_name VARCHAR(75),
 product_name_length INT,
 product_description_length INT,
 product_photos_qty INT,
 product_weight_g INT,
 product_length_cm INT,
 product_height_cm INT,
 product_width_cm INT
);

CREATE TABLE olist.olist_order_items_dataset
(
	order_id VARCHAR(80),
	order_item_id INT,
	product_id VARCHAR(50),
	seller_id VARCHAR(75),
	shipping_limit_date TIMESTAMP,
	price NUMERIC(10,2),
	freight_value NUMERIC(10,2),

	FOREIGN KEY(order_id) REFERENCES olist.olist_orders_dataset(order_id),
	FOREIGN KEY(product_id) REFERENCES olist.olist_products_dataset
);

SELECT * FROM olist.olist_customers_dataset;
SELECT * FROM olist.olist_orders_dataset;
SELECT * FROM olist.olist_products_dataset;
SELECT * FROM olist.olist_order_items_dataset;

--Query 1--
WITH customer_order AS(
SELECT oo.order_id, oo.customer_id, oo.order_approved_at, oc.customer_state FROM
olist.olist_customers_dataset oc
JOIN olist.olist_orders_dataset oo
ON oc.customer_id = oo.customer_id
),

--Next is to filter orders which have only been approved ON 2017 Nov and Dec
desired_year AS
(
SELECT * FROM customer_order
WHERE order_approved_at >= '2017-11-01' AND order_approved_at < '2018-01-01'

),

monthly_orders AS(
SELECT customer_state, SUM(CASE WHEN EXTRACT(MONTH FROM order_approved_at) = 11 THEN 1 ELSE 0 END) AS nov_count,
SUM(CASE WHEN EXTRACT(MONTH FROM order_approved_at) = 12 THEN 1 ELSE 0 END) AS dec_count
FROM desired_year
GROUP BY customer_state
),

final_states AS(
SELECT customer_state
FROM monthly_orders
WHERE dec_count > nov_count * 1.05
),


/*
Now we need to find the top 3 categories for each state 
*/

category_tables AS(
SELECT p.product_category_name, oi.price, oc.customer_state FROM olist.olist_order_items_dataset oi
JOIN olist.olist_orders_dataset o
ON oi.order_id = o.order_id
JOIN olist.olist_products_dataset p
ON oi.product_id = p.product_id
JOIN olist.olist_customers_dataset oc
ON oc.customer_id = o.customer_id
JOIN final_states f
ON oc.customer_state = f.customer_state
),

group_states AS(
SELECT product_category_name, customer_state, SUM(price) AS total_revenue
FROM category_tables
GROUP BY product_category_name, customer_state
),

ranked_group_states AS(
SELECT product_category_name, customer_state, total_revenue,
DENSE_RANK() OVER(PARTITION BY customer_state ORDER BY total_revenue DESC) as rnk
FROM group_states
)

SELECT * FROM ranked_group_states
WHERE rnk <= 3

--Query 2--
/*
Our first step for this query is to join the customer table and the orders table
*/
WITH customer_order_join AS(
SELECT oc.customer_id, oc.customer_unique_id, oo.order_id FROM  olist.olist_customers_dataset oc
JOIN olist.olist_orders_dataset oo
ON oc.customer_id = oo.customer_id
),

high_value_customers AS(
SELECT customer_unique_id, COUNT(DISTINCT order_id) AS distinct_order
FROM customer_order_join
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) >= 2
),
/*
Now I want to find the first order_date for each high level customer_unique_id so I
will be joining the customer table with the order and then group by customer
unique_id to get the MIN(order_date)
So I need to join the customer table and the order table and then join that with
the high 
*/

/*
Group 1 focus is on high value customers
*/

high_value_customer_order_ranked AS(
SELECT oc.customer_unique_id, oo.order_id, oo.order_purchase_timestamp,
ROW_NUMBER() OVER(PARTITION BY oc.customer_unique_id ORDER BY oo.order_purchase_timestamp) As rn
FROM  olist.olist_customers_dataset oc
JOIN olist.olist_orders_dataset oo
ON oc.customer_id = oo.customer_id
JOIN high_value_customers hv
ON hv.customer_unique_id = oc.customer_unique_id
),

high_value_customer_first_ranked AS(
SELECT * FROM high_value_customer_order_ranked
WHERE rn = 1
),

top_products_in_high_value_customer AS(
SELECT hv.customer_unique_id, hv.order_id, oo.price, op.product_category_name FROM 
high_value_customer_first_ranked hv
JOIN olist.olist_order_items_dataset oo
ON hv.order_id = oo.order_id
JOIN olist.olist_products_dataset op
ON oo.product_id = op.product_id
)


SELECT 
    product_category_name,
    COUNT(*) AS category_count
FROM top_products_in_high_value_customer
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY category_count DESC
LIMIT 3;


--Low level customers now --
WITH customer_order_order_items_join AS(
SELECT oc.customer_unique_id, oo.order_id, oi.price
FROM olist.olist_customers_dataset oc
JOIN olist.olist_orders_dataset oo
ON oc.customer_id = oo.customer_id
JOIN olist.olist_order_items_dataset oi
ON oo.order_id = oi.order_id
),

low_value_customers AS(
SELECT customer_unique_id, COUNT(DISTINCT order_id) AS distinct_order,
SUM(price) AS total_price
FROM customer_order_order_items_join
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) = 1 AND SUM(price) <= 100
),

low_customer_orders AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp
  FROM low_value_customers lv
  JOIN olist.olist_customers_dataset c
    ON c.customer_unique_id = lv.customer_unique_id
  JOIN olist.olist_orders_dataset o
    ON o.customer_id = c.customer_id
),

first_order_low AS (
  SELECT
    customer_unique_id,
    order_id,
    order_purchase_timestamp,
    ROW_NUMBER() OVER (
      PARTITION BY customer_unique_id
      ORDER BY order_purchase_timestamp, order_id
    ) AS rn
  FROM low_customer_orders
),

first_order_low_exact AS (
  SELECT customer_unique_id, order_id
  FROM first_order_low
  WHERE rn = 1
),

first_order_categories_low AS (
  SELECT
    f.customer_unique_id,
    p.product_category_name,
    oi.price,
    oi.freight_value
  FROM first_order_low_exact f
  JOIN olist.olist_order_items_dataset oi
    ON oi.order_id = f.order_id
  JOIN olist.olist_products_dataset p
    ON p.product_id = oi.product_id
  WHERE p.product_category_name IS NOT NULL
)

SELECT
  product_category_name,
  COUNT(DISTINCT customer_unique_id) AS customer_count
FROM first_order_categories_low
GROUP BY product_category_name
ORDER BY customer_count DESC, product_category_name
LIMIT 3;
