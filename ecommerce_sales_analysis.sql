-- ===============================
-- 1. CREATE DATABASE SCHEMA
-- ===============================

-- Create Customers Table
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    signup_date DATE
);

-- Create Products Table
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Create Orders Table
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    order_date DATE,
    total_amount DECIMAL(10,2)
);

-- Create Order Details Table (Many-to-Many Relationship)
CREATE TABLE OrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id),
    product_id INT REFERENCES Products(product_id),
    quantity INT,
    subtotal DECIMAL(10,2)
);

-- ===============================
-- 2. INSERT SAMPLE DATA
-- ===============================

-- Insert Customers
INSERT INTO Customers (first_name, last_name, email, signup_date) VALUES
('Alice', 'Smith', 'alice@example.com', '2024-01-15'),
('Bob', 'Johnson', 'bob@example.com', '2024-02-10'),
('Charlie', 'Brown', 'charlie@example.com', '2024-03-05');

-- Insert Products
INSERT INTO Products (name, category, price) VALUES
('Laptop', 'Electronics', 1200.00),
('Smartphone', 'Electronics', 800.00),
('Headphones', 'Accessories', 150.00);

-- Insert Orders
INSERT INTO Orders (customer_id, order_date, total_amount) VALUES
(1, '2024-03-10', 1350.00),
(2, '2024-03-12', 800.00),
(3, '2024-03-15', 150.00);

-- Insert Order Details
INSERT INTO OrderDetails (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 1, 1200.00),
(1, 3, 1, 150.00),
(2, 2, 1, 800.00),
(3, 3, 1, 150.00);

-- ===============================
-- 3. ANALYTICAL QUERIES
-- ===============================

-- Get total revenue per product category
SELECT p.category, SUM(od.subtotal) AS total_revenue
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Find top 3 customers by total spending
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spent
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 3;

-- ===============================
-- 4. ETL PROCESSING: CUSTOMER REPORT
-- ===============================

-- Create a cleaned customer report table
CREATE TABLE CustomerReport AS
SELECT 
    customer_id, 
    first_name || ' ' || last_name AS full_name,
    email, 
    signup_date, 
    (SELECT COUNT(*) FROM Orders WHERE Orders.customer_id = Customers.customer_id) AS total_orders,
    (SELECT COALESCE(SUM(total_amount), 0) FROM Orders WHERE Orders.customer_id = Customers.customer_id) AS total_spent
FROM Customers;

-- ===============================
-- END OF SCRIPT
-- ===============================
