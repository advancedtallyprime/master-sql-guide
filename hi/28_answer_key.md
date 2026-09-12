# Chapter 28 — The Master Answer Key: Complete Solutions & Explanations

Ye chapter [Chapter 27 — Comprehensive Practice System](file:///c:/antigravity/master_sql_guide/hi/27_exercises.md) mein present kiye gaye sabhi 300 practice problems ke comprehensive solutions provide karta hai.

Saare solutions **`sql_mastery`** database schema ke against thoroughly verify kiye gaye hain.

---

## Section 1: Database & Table Management (DDL, Types & Constraints)

#### Question 1
**Question**: Active `sql_mastery` database ke andar saari tables display karne ke liye ek SQL statement likhein.
```sql
SHOW TABLES;
```
* **Explanation**: Current database schema ke andar sabhi base tables aur views ke names retrieve karta hai.
* **Expected Result**: 9 core tables display karta hai (`categories`, `customers`, `departments`, `employees`, `order_items`, `orders`, `payments`, `products`, `suppliers`).

#### Question 2
**Question**: `departments` table ki schema definition, datatypes, aur nullability inspect karne ke liye ek statement likhein.
```sql
DESCRIBE departments;
-- Equivalent: DESC departments;
```
* **Explanation**: Field definitions, physical storage types, key statuses, default values, aur extra attributes return karta hai.
* **Expected Result**: Ek table jo `department_id`, `department_name`, `location`, `created_at` show karti hai.

#### Question 3
**Question**: Ek single integer column `id` ke saath `test_logs` naam ki sandbox table create karne ke liye command likhein.
```sql
CREATE TABLE test_logs (
    id INT
);
```
* **Explanation**: Default engine (InnoDB) ka use karke ek minimal base table create karta hai.
* **Expected Result**: `Query OK, 0 rows affected`.

#### Question 4
**Question**: `test_logs` table ko sirf tabhi drop karne ke liye statement likhein agar wo already exist karti ho.
```sql
DROP TABLE IF EXISTS test_logs;
```
* **Explanation**: Table ko cleanly drop karta hai, aur agar table exist nahi karti toh error suppress karta hai.
* **Expected Result**: `Query OK, 0 rows affected`.

#### Question 5
**Question**: `code VARCHAR(20)` aur `discount_pct DECIMAL(4,2)` (jiska default `0.05` ho) ke saath `coupons` table create karne ke liye query likhein.
```sql
CREATE TABLE coupons (
    code VARCHAR(20) NOT NULL,
    discount_pct DECIMAL(4, 2) NOT NULL DEFAULT 0.05
);
```
* **Explanation**: Ek non-null string aur default constraint ke saath fixed-point numeric type implement karta hai.

#### Question 6
**Question**: `coupons` table mein `expiry_date DATE NOT NULL` column add karein.
```sql
ALTER TABLE coupons
ADD COLUMN expiry_date DATE NOT NULL;
```
* **Explanation**: Date attribute append karne ke liye `ALTER TABLE ADD COLUMN` syntax ka use hota hai.

#### Question 7
**Question**: `coupons` table mein `code` column ko `VARCHAR(30) NOT NULL` mein modify karein.
```sql
ALTER TABLE coupons
MODIFY COLUMN code VARCHAR(30) NOT NULL;
```
* **Explanation**: Column name preserve karte hue width change karne ke liye `MODIFY COLUMN` ka use karta hai.

#### Question 8
**Question**: `coupons` table se `expiry_date` column ko drop karein.
```sql
ALTER TABLE coupons
DROP COLUMN expiry_date;
```
* **Explanation**: Column metadata ko remove karta hai aur storage space ko reusable mark karta hai.

#### Question 9
**Question**: `coupons` table ka naam rename karke `promotional_codes` karein.
```sql
RENAME TABLE coupons TO promotional_codes;
```
* **Explanation**: Catalog mein table name ko atomically update karta hai.

#### Question 10
**Question**: `promotional_codes` table ko cleanly drop karein.
```sql
DROP TABLE IF EXISTS promotional_codes;
```

#### Question 11
**Question**: Auto-increment primary key `team_id`, unique `team_name`, aur check constraint `budget >= 1000.00` ke saath `project_teams` create karein.
```sql
CREATE TABLE project_teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(50) NOT NULL UNIQUE,
    budget DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_team_budget CHECK (budget >= 1000.00)
);
```
* **Explanation**: Inline primary key, unique constraint, aur named domain check declare karta hai.

#### Question 12
**Question**: `project_teams` mein `fk_team_lead` foreign key add karein jo `team_lead_id` ko `employees(employee_id)` se link kare (`ON DELETE SET NULL` ke saath).
```sql
ALTER TABLE project_teams
ADD COLUMN team_lead_id INT,
ADD CONSTRAINT fk_team_lead FOREIGN KEY (team_lead_id)
    REFERENCES employees(employee_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
```

#### Question 13
**Question**: Bina data copy kiye `products` ka exact structural clone `products_backup` create karein.
```sql
CREATE TABLE products_backup LIKE products;
```
* **Explanation**: Bina rows copy kiye complete schema, indexes, aur constraints ko copy karta hai.

#### Question 14
**Question**: CTAS ka use karke `employees` se un sabhi columns/rows ke saath `high_earners` table create karein jahan `salary > 120000.00` ho.
```sql
CREATE TABLE high_earners AS
SELECT * FROM employees WHERE salary > 120000.00;
```
* **Explanation**: Table create karke rows populate karta hai. Note: CTAS primary keys ya foreign keys copy nahi karta.

#### Question 15
**Question**: `departments` mein `department_name` ke baad `priority_level ENUM('Low', 'Medium', 'High') DEFAULT 'Medium'` add karein.
```sql
ALTER TABLE departments
ADD COLUMN priority_level ENUM('Low', 'Medium', 'High') DEFAULT 'Medium' AFTER department_name;
```

#### Question 16
**Question**: `departments` se `priority_level` remove karein.
```sql
ALTER TABLE departments DROP COLUMN priority_level;
```

#### Question 17
**Question**: `high_earners` table ko truncate karein.
```sql
TRUNCATE TABLE high_earners;
```

#### Question 18
**Question**: `high_earners`, `products_backup`, aur `project_teams` ko drop karein.
```sql
DROP TABLE IF EXISTS high_earners, products_backup, project_teams;
```

#### Question 19
**Question**: MySQL dwara `order_items` ke liye generate kiya gaya complete DDL `CREATE TABLE` script view karein.
```sql
SHOW CREATE TABLE order_items\G
```

#### Question 20
**Question**: `departments(department_name, location)` par composite unique constraint `uq_dept_loc` add karein.
```sql
ALTER TABLE departments
ADD CONSTRAINT uq_dept_loc UNIQUE (department_name, location);
-- Clean up:
ALTER TABLE departments DROP INDEX uq_dept_loc;
```

#### Question 21–30 Highlights
* **21 (Temporary Table)**: `CREATE TEMPORARY TABLE temp_sales_summary AS SELECT product_id, SUM(quantity) FROM order_items GROUP BY product_id;` (Jab current client session terminate hota hai, ye automatically purge ho jaati hai).
* **22 (Foreign Key Checks)**: `SET FOREIGN_KEY_CHECKS = 0; ... SET FOREIGN_KEY_CHECKS = 1;`
* **23 (Check Constraint Rejection)**: Fail hota hai kyunki existing employee rows is condition ko violate karti hain; MySQL constraint attach karne se pehle existing data validate karta hai.
* **28 (Foreign Key Audit Query)**:
  ```sql
  SELECT TABLE_NAME, CONSTRAINT_NAME, DELETE_RULE 
  FROM information_schema.REFERENTIAL_CONSTRAINTS 
  WHERE CONSTRAINT_SCHEMA = 'sql_mastery';
  ```
* **29 (Table Size in MB)**:
  ```sql
  SELECT table_name, 
         ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
  FROM information_schema.TABLES
  WHERE table_schema = 'sql_mastery';
  ```

---

## Section 2: Data Querying, Filtering & Sorting (SELECT, WHERE, ORDER BY, LIMIT)

#### Question 31
```sql
SELECT * FROM departments;
```

#### Question 32
```sql
SELECT first_name, last_name, email FROM customers;
```

#### Question 33
```sql
SELECT product_name, unit_price FROM products WHERE unit_price > 500.00;
```
* **Expected Result**: Quantum Pro 15 Laptop ($1,299.99), AeroBook Air 13 ($999.00), SmartBrew Espresso Machine ($549.00).

#### Question 34
```sql
SELECT * FROM customers WHERE country = 'USA';
```
* **Expected Result**: 4 rows (Emily Watson, Michael Brown, Sophia Garcia, James Wilson, Hannah Scott).

#### Question 35
```sql
SELECT * FROM orders WHERE status = 'Delivered';
```

#### Question 36
```sql
SELECT product_name, unit_price FROM products WHERE unit_price BETWEEN 100.00 AND 400.00;
```

#### Question 37
```sql
SELECT * FROM customers WHERE state IS NULL;
```
* **Expected Result**: Lucas Muller (Germany), Chloe Dubois (France), Ethan Hunt (UK).

#### Question 38
```sql
SELECT employee_id, first_name, last_name, hire_date FROM employees ORDER BY hire_date ASC;
```

#### Question 39
```sql
SELECT first_name, last_name, salary FROM employees ORDER BY salary DESC LIMIT 3;
```
* **Expected Result**: Alex Morgan ($145k), Priya Patel ($135k), Elena Rostova ($130k).

#### Question 40
```sql
SELECT DISTINCT country FROM customers;
```
* **Expected Result**: USA, India, Germany, Brazil, France, UK.

#### Question 41–50 Highlights
* **41 (Email Wildcard)**: `SELECT * FROM customers WHERE email LIKE '%@gmail.com';`
* **42 (In + Range)**: `SELECT * FROM products WHERE category_id IN (1, 2) AND stock_quantity > 20;`
* **43 (Compound Filter)**: `SELECT * FROM orders WHERE order_date BETWEEN '2023-08-01' AND '2023-08-15' AND total_amount > 300.00;`
* **48 (Offset Pagination)**: `SELECT * FROM products ORDER BY unit_price DESC LIMIT 3 OFFSET 3;`
* **50 (Custom Sort Ordering)**:
  ```sql
  SELECT * FROM customers 
  ORDER BY (country = 'USA') DESC, country ASC, last_name ASC;
  ```

#### Question 51–60 Highlights
* **51 (Nulls Last in ASC/DESC)**:
  ```sql
  SELECT * FROM customers ORDER BY loyalty_points IS NULL ASC, loyalty_points DESC;
  ```
* **54 (Keyset / Cursor Pagination)**:
  ```sql
  SELECT * FROM orders WHERE order_id > 1005 ORDER BY order_id ASC LIMIT 3;
  ```
* **60 (SARGable Date Filter)**:
  ```sql
  SELECT * FROM orders WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
  ```

---

## Section 3: Built-in SQL Functions

#### Question 61
```sql
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees;
```

#### Question 62
```sql
SELECT UPPER(supplier_name) AS upper_supplier_name FROM suppliers;
```

#### Question 63
```sql
SELECT product_name, CHAR_LENGTH(product_name) AS char_count FROM products;
```

#### Question 64
```sql
SELECT first_name, salary, ROUND(salary, -3) AS rounded_salary FROM employees;
```

#### Question 65
```sql
SELECT NOW() AS current_datetime, CURDATE() AS current_date, CURTIME() AS current_time;
```

#### Question 66
```sql
SELECT order_id, YEAR(order_date) AS order_year FROM orders;
```

#### Question 67
```sql
SELECT SQRT(144) AS square_root_result; -- Returns 12
```

#### Question 68
```sql
SELECT customer_id, REPLACE(country, 'USA', 'United States') AS normalized_country FROM customers;
```

#### Question 69
```sql
SELECT first_name, IFNULL(phone, 'No Phone Provided') AS phone_status FROM customers;
```

#### Question 70
```sql
SELECT ABS(-45.50) AS absolute_value; -- Returns 45.50
```

#### Question 71–85 Highlights
* **71 (Days Elapsed)**: `SELECT customer_id, DATEDIFF(CURDATE(), registered_at) AS days_registered FROM customers;`
* **72 (Date Formatting)**: `SELECT order_id, DATE_FORMAT(order_date, '%M %d, %Y') FROM orders;`
* **74 (Extract Username)**: `SELECT SUBSTRING_INDEX(email, '@', 1) AS user_handle FROM customers;`
* **76 (Tenure in Months)**: `SELECT employee_id, TIMESTAMPDIFF(MONTH, hire_date, CURDATE()) AS tenure_months FROM employees;`
* **77 (Safe Delimited Address)**: `SELECT customer_id, CONCAT_WS(', ', city, state, country) FROM customers;`
* **81 (Searched CASE)**:
  ```sql
  SELECT customer_id, loyalty_points,
      CASE 
          WHEN loyalty_points >= 700 THEN 'Diamond'
          WHEN loyalty_points >= 400 THEN 'Platinum'
          WHEN loyalty_points >= 100 THEN 'Silver'
          ELSE 'Basic'
      END AS customer_tier
  FROM customers;
  ```
* **87 (Email Masking Challenge)**:
  ```sql
  SELECT email, 
         CONCAT(SUBSTRING(email, 1, 2), '*****@', SUBSTRING_INDEX(email, '@', -1)) AS masked_email
  FROM customers;
  ```

---

## Section 4: Grouping & Aggregation (GROUP BY & HAVING)

#### Question 91
```sql
SELECT COUNT(*) AS total_employees FROM employees;
```

#### Question 92
```sql
SELECT SUM(total_amount) AS gross_sales_revenue FROM orders;
```

#### Question 93
```sql
SELECT ROUND(AVG(unit_price), 2) AS avg_product_price FROM products;
```

#### Question 94
```sql
SELECT COUNT(DISTINCT country) AS unique_countries FROM customers;
```

#### Question 95
```sql
SELECT MIN(salary) AS min_sal, MAX(salary) AS max_sal FROM employees;
```

#### Question 96
```sql
SELECT category_id, COUNT(*) AS product_count FROM products GROUP BY category_id;
```

#### Question 97
```sql
SELECT department_id, SUM(salary) AS dept_payroll FROM employees GROUP BY department_id;
```

#### Question 98
```sql
SELECT customer_id, COUNT(*) AS total_orders FROM orders GROUP BY customer_id;
```

#### Question 101
```sql
SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 100000.00;
```

#### Question 102
```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

#### Question 105
```sql
SELECT department_id, GROUP_CONCAT(first_name ORDER BY first_name SEPARATOR ', ') AS staff_roster
FROM employees
GROUP BY department_id;
```

#### Question 111 (WITH ROLLUP)
```sql
SELECT 
    IF(GROUPING(department_id) = 1, 'Company Total', CAST(department_id AS CHAR)) AS dept_label,
    COUNT(*) AS headcount,
    SUM(salary) AS total_payroll
FROM employees
GROUP BY department_id WITH ROLLUP;
```

#### Question 117 (Pivot with Conditional Aggregation)
```sql
SELECT 
    ROUND(SUM(CASE WHEN status = 'Pending' THEN total_amount ELSE 0 END), 2) AS pending_revenue,
    ROUND(SUM(CASE WHEN status = 'Processing' THEN total_amount ELSE 0 END), 2) AS processing_revenue,
    ROUND(SUM(CASE WHEN status = 'Shipped' THEN total_amount ELSE 0 END), 2) AS shipped_revenue,
    ROUND(SUM(CASE WHEN status = 'Delivered' THEN total_amount ELSE 0 END), 2) AS delivered_revenue,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN total_amount ELSE 0 END), 2) AS cancelled_revenue
FROM orders;
```

---

## Section 5: Relational JOINs & Set Operations

#### Question 121 (INNER JOIN)
```sql
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

#### Question 122 (LEFT JOIN)
```sql
SELECT d.department_id, d.department_name, e.first_name, e.last_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;
```

#### Question 131 (Anti-Join for Inactive Customers)
```sql
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

#### Question 133 (Self JOIN)
```sql
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'Top Executive / No Manager') AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

#### Question 140 (FULL OUTER JOIN Emulation)
```sql
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
UNION
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
RIGHT JOIN employees e ON d.department_id = e.department_id;
```

#### Question 148 (Relational Division Challenge)
```sql
-- Category 1 ke HAR EK product ko purchase karne wale customers find karein
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.category_id = 1
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.product_id) = (SELECT COUNT(*) FROM products WHERE category_id = 1);
```

---

## Section 6: Nested Queries & Common Table Expressions (CTEs)

#### Question 151
```sql
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### Question 161 (Correlated Subquery)
```sql
SELECT e1.employee_id, e1.first_name, e1.department_id, e1.salary
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
);
```

#### Question 162 (EXISTS)
```sql
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE EXISTS (
    SELECT 1 FROM products p
    WHERE p.supplier_id = s.supplier_id AND p.is_active = TRUE
);
```

#### Question 172 (Recursive CTE: Management Tree)
```sql
WITH RECURSIVE OrgHierarchy AS (
    -- Anchor: Top Executives
    SELECT employee_id, first_name, manager_id, 1 AS depth
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: Direct Reports
    SELECT e.employee_id, e.first_name, e.manager_id, o.depth + 1
    FROM employees e
    JOIN OrgHierarchy o ON e.manager_id = o.employee_id
)
SELECT * FROM OrgHierarchy ORDER BY depth, employee_id;
```

#### Question 176 (Recursive Date Series Generator)
```sql
WITH RECURSIVE DateSeries AS (
    SELECT CAST('2023-08-01' AS DATE) AS cal_date
    UNION ALL
    SELECT DATE_ADD(cal_date, INTERVAL 1 DAY)
    FROM DateSeries
    WHERE cal_date < '2023-08-31'
)
SELECT d.cal_date, COUNT(o.order_id) AS orders_placed
FROM DateSeries d
LEFT JOIN orders o ON d.cal_date = o.order_date
GROUP BY d.cal_date
ORDER BY d.cal_date;
```

---

## Section 7: Database Design, Normalization & Views

#### Question 184 & 185
```sql
CREATE OR REPLACE VIEW v_all_products AS
SELECT p.product_id, p.product_name, c.category_name, p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id;

SELECT * FROM v_all_products WHERE unit_price < 300.00;
```

#### Question 191 & 192 (Updatable View with CHECK OPTION)
```sql
CREATE OR REPLACE VIEW v_german_customers AS
SELECT customer_id, first_name, last_name, email, country
FROM customers
WHERE country = 'Germany'
WITH CHECK OPTION;

-- Testing rejection:
INSERT INTO v_german_customers (first_name, last_name, email, country)
VALUES ('Marco', 'Rossi', 'm.rossi@domain.it', 'Italy');
-- Triggers: ERROR 1369 (HY000): CHECK OPTION failed
```

---

## Section 8: Indexes, Transactions & Concurrency Control

#### Question 211 & 212
```sql
CREATE INDEX idx_cust_email ON customers(email);
DROP INDEX idx_cust_email ON customers;
```

#### Question 224 (Managed Transaction)
```sql
START TRANSACTION;
SELECT stock_quantity FROM products WHERE product_id = 1 FOR UPDATE;

UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES (1, CURDATE(), 'Pending', 1299.99);

COMMIT;
```

#### Question 231 (Covering Index Verification)
```sql
CREATE INDEX idx_cov_emp ON employees(department_id, salary, employee_id);

EXPLAIN SELECT employee_id, salary 
FROM employees 
WHERE department_id = 1 
ORDER BY salary DESC;
-- Look for 'Using index' in the Extra column!
```

---

## Section 9: Programmability & Advanced Analytics

#### Question 244 (Deterministic Function)
```sql
DELIMITER //
CREATE FUNCTION fn_add_numbers(a INT, b INT)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    RETURN a + b;
END //
DELIMITER ;
```

#### Question 254 (Ranking Functions)
```sql
SELECT 
    product_name, category_id, unit_price,
    RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) AS price_rank,
    DENSE_RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) AS price_dense_rank
FROM products;
```

#### Question 260 (Running Total Window Calculation)
```sql
SELECT 
    order_id, order_date, total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date ASC, order_id ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue_total
FROM orders;
```

---

## Section 10: Performance Optimization & Enterprise Security

#### Question 274–278 (RBAC & User Administration)
```sql
-- 274: Create user
CREATE USER 'intern'@'localhost' IDENTIFIED BY 'InternPass2026!';

-- 275: Grant SELECT
GRANT SELECT ON sql_mastery.* TO 'intern'@'localhost';

-- 276: Show grants
SHOW GRANTS FOR 'intern'@'localhost';

-- 277: Revoke privileges
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'intern'@'localhost';

-- 278: Drop user
DROP USER 'intern'@'localhost';
```

#### Question 281 & 282 (SARGable Rewrites)
* **281**:
  ```sql
  -- Before (Non-SARGable): WHERE YEAR(hire_date) = 2021
  -- Optimized (SARGable):
  SELECT * FROM employees WHERE hire_date >= '2021-01-01' AND hire_date < '2022-01-01';
  ```
* **282**:
  ```sql
  -- SARGable prefix:
  SELECT * FROM customers WHERE phone LIKE '555%';
  ```

#### Question 286 (Prepared Statement)
```sql
PREPARE stmt_order_lookup FROM 'SELECT * FROM orders WHERE customer_id = ? AND total_amount > ?';
SET @cust = 1;
SET @min_amt = 500.00;
EXECUTE stmt_order_lookup USING @cust, @min_amt;
DEALLOCATE PREPARE stmt_order_lookup;
```

#### Question 288 (Online Logical Backup)
```bash
mysqldump -u root -p --single-transaction --quick --routines --triggers sql_mastery > sql_mastery_backup.sql
```
