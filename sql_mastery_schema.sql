-- =============================================================================
-- MASTER SQL LEARNING GUIDE: UNIFIED PRACTICE DATABASE
-- Database: sql_mastery
-- RDBMS: MySQL 8.0+
-- Description: Realistic enterprise relational database modeling an e-commerce,
--              workforce, inventory, and operations environment.
-- =============================================================================

DROP DATABASE IF EXISTS sql_mastery;
CREATE DATABASE sql_mastery
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE sql_mastery;

-- -----------------------------------------------------------------------------
-- 1. DEPARTMENTS
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. EMPLOYEES (Self-referencing Foreign Key for Managers)
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) DEFAULT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_id INT DEFAULT NULL,
    manager_id INT DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_employee_salary CHECK (salary > 0),
    CONSTRAINT fk_emp_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id)
        REFERENCES employees(employee_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. CATEGORIES
-- -----------------------------------------------------------------------------
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. SUPPLIERS
-- -----------------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100) DEFAULT NULL,
    contact_email VARCHAR(100) NOT NULL UNIQUE,
    contact_phone VARCHAR(20) DEFAULT NULL,
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. PRODUCTS
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_product_price CHECK (unit_price >= 0),
    CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0),
    CONSTRAINT fk_prod_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_prod_supplier FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. CUSTOMERS
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) DEFAULT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) DEFAULT NULL,
    country VARCHAR(50) NOT NULL,
    loyalty_points INT DEFAULT 0,
    registered_at DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_loyalty CHECK (loyalty_points >= 0)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. ORDERS
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    shipping_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_order_total CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. ORDER_ITEMS (Composite relationship & junction)
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0),
    CONSTRAINT chk_item_discount CHECK (discount >= 0.00 AND discount <= 1.00),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9. PAYMENTS
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'PayPal', 'Bank Transfer') NOT NULL,
    payment_status ENUM('Completed', 'Pending', 'Failed', 'Refunded') NOT NULL DEFAULT 'Completed',
    transaction_ref VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =============================================================================
-- SEED DATA
-- =============================================================================

-- Departments
INSERT INTO departments (department_id, department_name, location) VALUES
(1, 'Engineering', 'San Francisco'),
(2, 'Data & Analytics', 'San Francisco'),
(3, 'Sales & Marketing', 'New York'),
(4, 'Supply Chain', 'Chicago'),
(5, 'Human Resources', 'New York'),
(6, 'Customer Experience', 'Austin');

-- Employees (Hierarchical)
INSERT INTO employees (employee_id, first_name, last_name, email, phone, hire_date, salary, department_id, manager_id) VALUES
(1, 'Alex', 'Morgan', 'alex.morgan@company.com', '555-0100', '2019-03-15', 145000.00, 1, NULL),
(2, 'Sarah', 'Chen', 'sarah.chen@company.com', '555-0101', '2020-06-01', 125000.00, 1, 1),
(3, 'Marcus', 'Vance', 'marcus.vance@company.com', '555-0102', '2021-01-15', 98000.00, 1, 2),
(4, 'Priya', 'Patel', 'priya.patel@company.com', '555-0103', '2020-02-10', 135000.00, 2, 1),
(5, 'David', 'Kim', 'david.kim@company.com', '555-0104', '2021-07-20', 92000.00, 2, 4),
(6, 'Elena', 'Rostova', 'elena.rostova@company.com', '555-0105', '2018-11-05', 130000.00, 3, NULL),
(7, 'Liam', 'OConnor', 'liam.oconnor@company.com', '555-0106', '2022-03-01', 78000.00, 3, 6),
(8, 'Jessica', 'Taylor', 'jessica.taylor@company.com', '555-0107', '2019-08-12', 110000.00, 4, NULL),
(9, 'Carlos', 'Mendoza', 'carlos.mendoza@company.com', '555-0108', '2021-10-01', 72000.00, 4, 8),
(10, 'Fatima', 'Al-Mansoor', 'fatima.mansoor@company.com', '555-0109', '2022-05-18', 85000.00, 5, NULL);

-- Categories
INSERT INTO categories (category_id, category_name, description) VALUES
(1, 'Electronics', 'Personal computers, smartphones, and consumer gadgets'),
(2, 'Home Appliances', 'Kitchen tools, vacuum cleaners, and smart home appliances'),
(3, 'Office Supplies', 'Ergonomic chairs, desks, stationery, and organizational items'),
(4, 'Books & Media', 'Technical literature, programming books, and audio gear'),
(5, 'Fitness & Outdoors', 'Sporting equipment, wearables, and apparel');

-- Suppliers
INSERT INTO suppliers (supplier_id, supplier_name, contact_name, contact_email, contact_phone, country, city) VALUES
(1, 'Apex Tech Supply', 'Robert Hansen', 'robert@apextech.com', '555-0201', 'USA', 'Seattle'),
(2, 'Nippon Component Corp', 'Kenji Sato', 'sato@nipponcomp.jp', '555-0202', 'Japan', 'Tokyo'),
(3, 'EuroSmart Manufacturing', 'Greta Weber', 'weber@eurosmart.de', '555-0203', 'Germany', 'Munich'),
(4, 'Shenzhen Precision Ltd', 'Wei Zhang', 'zhang@szprecision.cn', '555-0204', 'China', 'Shenzhen'),
(5, 'Nordic Timber & Metal', 'Astrid Lind', 'lind@nordictm.se', '555-0205', 'Sweden', 'Stockholm');

-- Products
INSERT INTO products (product_id, product_name, category_id, supplier_id, unit_price, stock_quantity, reorder_level, is_active) VALUES
(1, 'Quantum Pro 15 Laptop', 1, 1, 1299.99, 45, 10, TRUE),
(2, 'AeroBook Air 13', 1, 1, 999.00, 60, 15, TRUE),
(3, 'TrueSound ANC Headphones', 1, 2, 249.50, 120, 20, TRUE),
(4, 'UltraVision 4K 27in Monitor', 1, 4, 389.00, 30, 10, TRUE),
(5, 'SmartBrew Espresso Machine', 2, 3, 549.00, 25, 8, TRUE),
(6, 'RoboClean Vacuum X7', 2, 3, 399.99, 40, 10, TRUE),
(7, 'ErgoComfort Office Chair', 3, 5, 329.00, 50, 12, TRUE),
(8, 'Standing Desk Motorized 60in', 3, 5, 499.00, 18, 5, TRUE),
(9, 'Mastering Database Design Book', 4, 1, 49.99, 150, 25, TRUE),
(10, 'PulseTrack Fitness Smartwatch', 5, 2, 179.99, 85, 20, TRUE);

-- Customers
INSERT INTO customers (customer_id, first_name, last_name, email, phone, city, state, country, loyalty_points, registered_at) VALUES
(1, 'Emily', 'Watson', 'emily.watson@gmail.com', '555-0301', 'San Francisco', 'CA', 'USA', 420, '2021-03-10'),
(2, 'Michael', 'Brown', 'mbrown@yahoo.com', '555-0302', 'Austin', 'TX', 'USA', 180, '2021-05-22'),
(3, 'Sophia', 'Garcia', 'sophia.g@outlook.com', '555-0303', 'Miami', 'FL', 'USA', 750, '2020-08-14'),
(4, 'James', 'Wilson', 'jwilson@corp.org', '555-0304', 'Chicago', 'IL', 'USA', 90, '2022-01-05'),
(5, 'Aisha', 'Khan', 'aisha.khan@domain.in', '555-0305', 'Bengaluru', 'KA', 'India', 610, '2021-09-18'),
(6, 'Lucas', 'Muller', 'l.muller@web.de', '555-0306', 'Berlin', NULL, 'Germany', 310, '2022-04-30'),
(7, 'Hannah', 'Scott', 'hannah.scott@gmail.com', '555-0307', 'Seattle', 'WA', 'USA', 50, '2023-01-11'),
(8, 'Mateo', 'Silva', 'mateo.silva@uol.com.br', '555-0308', 'Sao Paulo', 'SP', 'Brazil', 290, '2022-07-09'),
(9, 'Chloe', 'Dubois', 'chloe.dubois@orange.fr', '555-0309', 'Lyon', NULL, 'France', 480, '2021-11-25'),
(10, 'Ethan', 'Hunt', 'ethan.hunt@imf.org', '555-0310', 'London', NULL, 'UK', 940, '2020-04-12');

-- Orders
INSERT INTO orders (order_id, customer_id, order_date, status, shipping_fee, total_amount) VALUES
(1001, 1, '2023-08-01', 'Delivered', 15.00, 1564.49),
(1002, 3, '2023-08-03', 'Delivered', 0.00, 389.00),
(1003, 2, '2023-08-10', 'Delivered', 12.00, 261.50),
(1004, 5, '2023-08-15', 'Delivered', 25.00, 1424.98),
(1005, 4, '2023-08-20', 'Shipped', 20.00, 519.00),
(1006, 1, '2023-09-02', 'Delivered', 0.00, 549.00),
(1007, 7, '2023-09-05', 'Cancelled', 10.00, 49.99),
(1008, 10, '2023-09-12', 'Processing', 15.00, 1248.50),
(1009, 6, '2023-09-18', 'Delivered', 30.00, 429.99),
(1010, 8, '2023-09-22', 'Pending', 15.00, 344.00);

-- Order Items
INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1001, 1, 1, 1299.99, 0.00),
(2, 1001, 3, 1, 249.50, 0.00),
(3, 1002, 4, 1, 389.00, 0.00),
(4, 1003, 3, 1, 249.50, 0.00),
(5, 1004, 1, 1, 1299.99, 0.05),
(6, 1004, 9, 3, 49.99, 0.10),
(7, 1005, 8, 1, 499.00, 0.00),
(8, 1006, 5, 1, 549.00, 0.00),
(9, 1007, 9, 1, 49.99, 0.00),
(10, 1008, 2, 1, 999.00, 0.00),
(11, 1008, 3, 1, 249.50, 0.05),
(12, 1009, 6, 1, 399.99, 0.00),
(13, 1010, 7, 1, 329.00, 0.00);

-- Payments
INSERT INTO payments (payment_id, order_id, payment_date, amount, payment_method, payment_status, transaction_ref) VALUES
(501, 1001, '2023-08-01', 1564.49, 'Credit Card', 'Completed', 'TXN-99881122'),
(502, 1002, '2023-08-03', 389.00, 'PayPal', 'Completed', 'TXN-99881123'),
(503, 1003, '2023-08-10', 261.50, 'Debit Card', 'Completed', 'TXN-99881124'),
(504, 1004, '2023-08-15', 1424.98, 'UPI', 'Completed', 'TXN-99881125'),
(505, 1005, '2023-08-20', 519.00, 'Credit Card', 'Completed', 'TXN-99881126'),
(506, 1006, '2023-09-02', 549.00, 'Credit Card', 'Completed', 'TXN-99881127'),
(507, 1007, '2023-09-05', 49.99, 'Credit Card', 'Refunded', 'TXN-99881128'),
(508, 1008, '2023-09-12', 1248.50, 'Bank Transfer', 'Completed', 'TXN-99881129'),
(509, 1009, '2023-09-18', 429.99, 'PayPal', 'Completed', 'TXN-99881130');
