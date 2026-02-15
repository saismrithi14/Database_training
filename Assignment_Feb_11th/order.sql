-- Create Schema
CREATE SCHEMA order_schema;

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

 