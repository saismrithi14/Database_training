-- Create Schema
CREATE SCHEMA order_schema;

--Drop Tables if Needed
DROP TABLE order_schema.product;
DROP TABLE order_schema.customer;
DROP TABLE order_schema.status;
DROP TABLE order_schema.orders;
DROP TABLE order_schema.order_items;
DROP TABLE order_schema.order_history;



-- Create Product Table
CREATE TABLE order_schema.product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    stock_quantity INT
);

-- Insert sample data into Product Table
INSERT INTO order_schema.product (product_id, product_name, price, stock_quantity)
VALUES
    (1, 'Laptop', 999.99, 50),
    (2, 'Smartphone', 499.99, 100),
    (3, 'Headphones', 149.99, 200),
    (4, 'Monitor', 199.99, 75);

-- Create Customer Table
CREATE TABLE order_schema.customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(15)
);

-- Insert sample data into Customer Table
INSERT INTO order_schema.customer (customer_id, first_name, last_name, email, phone_number)
VALUES
    (1, 'John', 'Doe', 'john.doe@example.com', '555-1234'),
    (2, 'Jane', 'Smith', 'jane.smith@example.com', '555-5678'),
    (3, 'Emily', 'Jones', 'emily.jones@example.com', '555-8765');

-- Create Status Table
CREATE TABLE order_schema.status (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(50)
);

-- Insert sample data into Status Table
INSERT INTO order_schema.status (status_id, status_name)
VALUES
    (1, 'Shipped'),
    (2, 'Pending'),
    (3, 'Cancelled');

-- Create Orders Table
CREATE TABLE order_schema.orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status_id INT,
    FOREIGN KEY (customer_id) REFERENCES order_schema.customer(customer_id),
    FOREIGN KEY (status_id) REFERENCES order_schema.status(status_id)
);

-- Insert sample data into Orders Table
INSERT INTO order_schema.orders (order_id, customer_id, order_date, total_amount, status_id)
VALUES
    (1, 1, '2025-02-15', 1499.98, 1),
    (2, 2, '2025-02-16', 199.99, 2),
    (3, 3, '2025-02-17', 499.99, 1),
    (4, 1, '2025-02-18', 149.99, 3);

-- Create Order Items Table (New Table for Product-Order Relationship)
CREATE TABLE order_schema.order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES order_schema.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES order_schema.product(product_id)
);

-- Insert sample data into Order Items Table
INSERT INTO order_schema.order_items (order_item_id, order_id, product_id, quantity, price)
VALUES
    (1, 1, 1, 1, 999.99),  -- 1 Laptop in Order 1
    (2, 1, 2, 1, 499.99),  -- 1 Smartphone in Order 1
    (3, 2, 3, 2, 149.99),  -- 2 Headphones in Order 2
    (4, 3, 2, 1, 499.99),  -- 1 Smartphone in Order 3
    (5, 4, 3, 1, 149.99);  -- 1 Headphones in Order 4

-- Create Order History Table
CREATE TABLE order_schema.order_history (
    history_id INT PRIMARY KEY,
    order_id INT,
    status_change_date DATE,
    status_description VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES order_schema.orders(order_id)
);

-- Insert sample data into Order History Table
INSERT INTO order_schema.order_history (history_id, order_id, status_change_date, status_description)
VALUES
    (1, 1, '2025-02-15', 'Order Placed'),
    (2, 1, '2025-02-16', 'Payment Processed'),
    (3, 2, '2025-02-16', 'Order Placed'),
    (4, 3, '2025-02-17', 'Order Placed'),
    (5, 3, '2025-02-18', 'Payment Processed'),
    (6, 4, '2025-02-18', 'Order Placed');

--Finding what each table contains --
SELECT * FROM order_schema.product;
SELECT * FROM order_schema.customer;
SELECT * FROM order_schema.status;
SELECT * FROM order_schema.orders;
SELECT * FROM order_schema.order_items;
SELECT * FROM order_schema.order_history;

--Question 1: Query to retrieve All Orders with Their Customer Details and Current Status --
SELECT o.order_id, o.customer_id, c.first_name, c.last_name, c.email,
c.phone_number, o.order_date, o.total_amount, s.status_name
FROM order_schema.orders o
JOIN order_schema.customer c
ON o.customer_id = c.customer_id
JOIN order_schema.status s
ON s.status_id = o.status_id;

/*
Question 2:
Get the Total Value of Orders 
for a Given Customer in a Specific Time Period 
Since the customer and the time period has not been specified, I choose
customer_id = 1
Specific date: '2025‑02‑15' to '2025‑02‑20'
*/

SELECT customer_id, SUM(total_amount) AS total_amount
FROM order_schema.orders
WHERE customer_id = 1 AND order_date BETWEEN '2025-02-15' AND '2025-02-20'
GROUP BY customer_id

--Question 3: Find the Most Expensive Order by Customer --
SELECT customer_id, MAX(total_amount) AS most_expensive_order
FROM order_schema.orders
GROUP BY customer_id
ORDER BY customer_id

--Question 4: Find the Total Revenue for Each Product Based on Orders --
SELECT oi.product_id, SUM(oi.quantity * oi.price) AS total_amount
FROM order_schema.product p
JOIN order_schema.order_items oi
ON oi.product_id = p.product_id
GROUP BY oi.product_id
ORDER BY oi.product_id;

/*
 Question 5: Write a query to retrieve the order ID, customer ID, and the total amount of each order. If the 
total amount is null, display '0.00' instead. 
*/
SELECT order_id, customer_id,  COALESCE(total_amount,0.00) As total_amount_per_order
FROM order_schema.orders;

/*
Question 6: Retrieve the Order History of a
Specific Customer Along with Product Details 
*/

SELECT oh.history_id, oh.order_id, o.order_date, oh.status_change_date, oh.status_description, oi.quantity, oi.price, p.product_name
FROM order_schema.order_history oh
JOIN order_schema.order_items oi
ON oi.order_id = oh.order_id
JOIN order_schema.product p
ON p.product_id = oi.product_id
JOIN order_schema.orders o
ON o.order_id = oh.order_id
WHERE o.customer_id = 1
ORDER BY o.order_id, oh.status_change_date, p.product_id;

/*
Question 7:
Get the Average Order Value 
Per Customer in the Last 30 Days.
*/

SELECT customer_id, ROUND(AVG(total_amount), 2) As avg_amount_per_customer
FROM order_schema.orders
WHERE order_date >= current_date - INTERVAL '1 MONTH'
GROUP BY customer_id

/*
Question 8:
Get the Top 5 Products with the Highest Number of Orders. 
*/

SELECT p.product_id, p.product_name, COUNT(DISTINCT oi.order_id) AS no_of_orders
FROM order_schema.product p
LEFT JOIN order_schema.order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY no_of_orders DESC, p.product_id ASC

/*
Question 9:
Get the Customers Who Have Not Placed Any Orders in the Last 60 Days  
*/
SELECT c.customer_id, MAX(o.order_date) AS latest_date
FROM order_schema.customer c
LEFT JOIN order_schema.orders o
ON o.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING MAX(o.order_date) IS NULL OR MAX(o.order_date) < current_date - INTERVAL '60 DAYS'

/*
Question 10: List the Orders with Products 
Ordered More Than Once, Sorted by Order Date 
*/

WITH base_table AS(
SELECT oi.order_id, oi.product_id, oi.quantity, oi.price, o.order_date
FROM order_schema.order_items oi
JOIN order_schema.orders o
ON oi.order_id = o.order_id
),

product_table AS(
SELECT order_id, product_id, SUM(quantity) AS count
FROM base_table
GROUP BY order_id, product_id
HAVING SUM(quantity) > 1
)

SELECT p.order_id, p.product_id, p.count, o.order_date
FROM product_table p
JOIn order_schema.orders o
ON o.order_id = p.order_id


/*
Question 11: Retrieve the 
Number of Orders and Total Revenue for Each Status
*/

SELECT status_id, COUNT(DISTINCT order_id) AS order_count, SUM(total_amount) AS revenue
FROM order_schema.orders
GROUP BY status_id

/*
Question 12: Find Customers Who Have Ordered More 
Than a Specific Product (e.g., "Laptop") 
*/
WITH cte AS(
SELECT o.customer_id, oi.order_id, oi.product_id,oi.quantity FROM order_schema.orders o
JOIN order_schema.order_items oi
ON oi.order_id = o.order_id
)
,
many_specific_products AS(
SELECT product_id, customer_id, SUM(quantity) AS total_count
FROM cte
WHERE product_id = 3
GROUP BY product_id, customer_id
HAVING SUM(quantity) > 1
)
SELECT m.customer_id, c.first_name, c.last_name
FROM many_specific_products m
JOIN order_schema.customer c
ON c.customer_id = m.customer_id

/*
 Question 13: Find the Products That Have Never Been Ordered
*/

SELECT p.product_id FROM order_schema.product p
LEFT JOIN order_schema.order_items oi
ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL

/*
Question 14:
 Get the Total Quantity of Products Ordered in the Last 7 Days  
*/

WITH cte AS
(SELECT o.order_id, o.order_date, oi.quantity FROM
order_schema.orders o
JOIN order_schema.order_items oi
ON o.order_id = oi.order_id
WHERE order_date >= current_date - INTERVAL '7 DAYS'
)

SELECT COALESCE(SUM(quantity),0) AS quantity FROM cte

/*
Question 15:
 Create a view named product_details that 
 includes all columns from the product table
*/

CREATE VIEW product_details AS(
SELECT * FROM order_schema.product
)

SELECT * FROM product_details

/*
Question 16:
 Create a view named order_summary that includes the order_id, customer_id, order_date, 
total_amount, and status_name (from the status table) for each order.
*/

CREATE VIEW order_summary AS(
SELECT o.order_id, o.customer_id, o.order_date, o.total_amount, s.status_name
FROM order_schema.orders o
JOIN order_schema.status s
ON o.status_id = s.status_id
)

SELECT * FROM order_summary
