# Chapter 30 — The Master MySQL Production Cheat Sheet

A compact, comprehensive syntax reference for developers, data engineers, and database administrators.

---

### DATABASE COMMANDS
* **`CREATE DATABASE`**: Creates a new database catalog with UTF-8 character encoding.
  ```sql
  CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
  ```
* **`DROP DATABASE`**: Permanently destroys a database and all its tables.
  ```sql
  DROP DATABASE IF EXISTS app_db;
  ```
* **`USE`**: Selects the active database context for subsequent queries.
  ```sql
  USE sql_mastery;
  ```
* **`SHOW DATABASES`**: Lists all databases present on the MySQL instance.
  ```sql
  SHOW DATABASES;
  ```

---

### TABLE COMMANDS
* **`CREATE TABLE`**: Creates a new table schema with columns and constraints.
  ```sql
  CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL);
  ```
* **`DROP TABLE`**: Permanently deletes a table and its data pages.
  ```sql
  DROP TABLE IF EXISTS users;
  ```
* **`TRUNCATE TABLE`**: Deallocates all table data pages and resets auto-increment counters.
  ```sql
  TRUNCATE TABLE users;
  ```
* **`DESCRIBE` / `DESC`**: Displays column types, nullability, keys, and defaults.
  ```sql
  DESCRIBE employees;
  ```
* **`SHOW CREATE TABLE`**: Displays the exact SQL DDL statement used to create the table.
  ```sql
  SHOW CREATE TABLE employees;
  ```

---

### CRUD OPERATIONS
* **`INSERT INTO`**: Inserts one or more rows into a table.
  ```sql
  INSERT INTO departments (department_name, location) VALUES ('DevOps', 'London');
  ```
* **`INSERT ... ON DUPLICATE KEY UPDATE`**: Upserts a row, updating values if a key conflicts.
  ```sql
  INSERT INTO products (product_id, stock_quantity) VALUES (1, 5) ON DUPLICATE KEY UPDATE stock_quantity = stock_quantity + 5;
  ```
* **`SELECT`**: Retrieves rows and columns from one or more tables.
  ```sql
  SELECT employee_id, first_name, salary FROM employees;
  ```
* **`UPDATE`**: Modifies existing table rows based on a filter condition.
  ```sql
  UPDATE employees SET salary = salary * 1.05 WHERE department_id = 1;
  ```
* **`DELETE FROM`**: Removes rows matching a condition while firing triggers.
  ```sql
  DELETE FROM orders WHERE status = 'Cancelled' AND order_date < '2023-01-01';
  ```

---

### FILTERING & LOGICAL OPERATORS
* **`WHERE`**: Filters rows before grouping or aggregation.
  ```sql
  SELECT * FROM products WHERE unit_price > 100.00;
  ```
* **`AND`**: Returns true only if both conditions are true.
  ```sql
  SELECT * FROM employees WHERE department_id = 1 AND salary > 100000;
  ```
* **`OR`**: Returns true if either condition is true.
  ```sql
  SELECT * FROM customers WHERE country = 'USA' OR country = 'Germany';
  ```
* **`NOT`**: Reverses the truth value of a condition.
  ```sql
  SELECT * FROM products WHERE NOT (stock_quantity = 0);
  ```
* **`LIKE`**: Performs pattern matching using wildcards (`%` for 0+ chars, `_` for 1 char).
  ```sql
  SELECT * FROM customers WHERE email LIKE '%@gmail.com';
  ```
* **`IN`**: Checks if a value matches any item in an enumerated list or subquery.
  ```sql
  SELECT * FROM customers WHERE country IN ('USA', 'Germany', 'Japan');
  ```
* **`BETWEEN`**: Filters values within an inclusive continuous range.
  ```sql
  SELECT * FROM orders WHERE order_date BETWEEN '2023-08-01' AND '2023-08-31';
  ```
* **`IS NULL` / `IS NOT NULL`**: Tests whether a column value is missing.
  ```sql
  SELECT * FROM customers WHERE phone IS NULL;
  ```
* **`<=>` (NULL-Safe Equality)**: Compares two values returning true if both are NULL.
  ```sql
  SELECT * FROM employees WHERE manager_id <=> NULL;
  ```

---

### SORTING & PAGINATION
* **`ORDER BY`**: Sorts results in ascending (`ASC`) or descending (`DESC`) order.
  ```sql
  SELECT * FROM employees ORDER BY salary DESC, last_name ASC;
  ```
* **`LIMIT`**: Restricts the maximum number of rows returned.
  ```sql
  SELECT * FROM products ORDER BY unit_price DESC LIMIT 5;
  ```
* **`LIMIT offset, count`**: Skips `offset` rows and returns up to `count` rows.
  ```sql
  SELECT * FROM products ORDER BY product_id ASC LIMIT 10 OFFSET 20;
  ```
* **`DISTINCT`**: Deduplicates identical rows from the result set.
  ```sql
  SELECT DISTINCT country FROM customers;
  ```

---

### GROUPING & AGGREGATION
* **`GROUP BY`**: Groups rows with identical values into summary buckets.
  ```sql
  SELECT department_id, COUNT(*), AVG(salary) FROM employees GROUP BY department_id;
  ```
* **`HAVING`**: Filters aggregated groups after the `GROUP BY` phase.
  ```sql
  SELECT department_id, AVG(salary) FROM employees GROUP BY department_id HAVING AVG(salary) > 90000;
  ```
* **`WITH ROLLUP`**: Computes hierarchical subtotals and grand totals across grouping dimensions.
  ```sql
  SELECT department_id, SUM(salary) FROM employees GROUP BY department_id WITH ROLLUP;
  ```
* **`GROUP_CONCAT()`**: Concatenates non-null values from each group into a single string.
  ```sql
  SELECT department_id, GROUP_CONCAT(first_name SEPARATOR ', ') FROM employees GROUP BY department_id;
  ```

---

### RELATIONAL JOINS
* **`INNER JOIN`**: Returns records with matching values in both tables.
  ```sql
  SELECT e.first_name, d.department_name FROM employees e INNER JOIN departments d ON e.department_id = d.department_id;
  ```
* **`LEFT JOIN`**: Returns all rows from the left table and matched rows from the right table.
  ```sql
  SELECT c.first_name, o.order_id FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;
  ```
* **`RIGHT JOIN`**: Returns all rows from the right table and matched rows from the left table.
  ```sql
  SELECT d.department_name, e.first_name FROM employees e RIGHT JOIN departments d ON e.department_id = d.department_id;
  ```
* **`CROSS JOIN`**: Computes the Cartesian product of two tables.
  ```sql
  SELECT p.product_name, c.city FROM products p CROSS JOIN customers c;
  ```
* **`Self JOIN`**: Joins a table to itself using distinct aliases.
  ```sql
  SELECT e.first_name AS worker, m.first_name AS manager FROM employees e LEFT JOIN employees m ON e.manager_id = m.employee_id;
  ```
* **`FULL OUTER JOIN` (Emulation)**: Combines a `LEFT JOIN` and a `RIGHT JOIN` with `UNION`.
  ```sql
  SELECT * FROM tableA a LEFT JOIN tableB b ON a.id = b.id UNION SELECT * FROM tableA a RIGHT JOIN tableB b ON a.id = b.id;
  ```

---

### SET OPERATIONS
* **`UNION`**: Merges query results vertically, eliminating duplicate rows.
  ```sql
  SELECT city FROM customers UNION SELECT city FROM suppliers;
  ```
* **`UNION ALL`**: Merges query results vertically without removing duplicates.
  ```sql
  SELECT city FROM customers UNION ALL SELECT city FROM suppliers;
  ```

---

### SUBQUERIES & COMMON TABLE EXPRESSIONS (CTEs)
* **Scalar Subquery**: Inner query returning a single 1x1 value.
  ```sql
  SELECT * FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);
  ```
* **Multi-Row Subquery**: Inner query returning a column of values.
  ```sql
  SELECT * FROM products WHERE category_id IN (SELECT category_id FROM categories WHERE category_name LIKE '%Office%');
  ```
* **`EXISTS`**: Tests for the existence of rows in a subquery.
  ```sql
  SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
  ```
* **CTE (`WITH ...`)**: Defines a temporary named result set for the query scope.
  ```sql
  WITH RegionalSales AS (SELECT country, SUM(total_amount) AS revenue FROM orders o JOIN customers c ON o.customer_id = c.customer_id GROUP BY country)
  SELECT * FROM RegionalSales WHERE revenue > 2000;
  ```
* **Recursive CTE**: Recursively traverses hierarchies and sequences.
  ```sql
  WITH RECURSIVE Seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM Seq WHERE n < 10) SELECT * FROM Seq;
  ```

---

### AGGREGATE FUNCTIONS
* **`COUNT(*)`**: Returns the total number of rows.
  ```sql
  SELECT COUNT(*) FROM orders;
  ```
* **`SUM()`**: Calculates the total sum of non-null values.
  ```sql
  SELECT SUM(total_amount) FROM orders;
  ```
* **`AVG()`**: Calculates the mathematical mean, ignoring NULLs.
  ```sql
  SELECT AVG(salary) FROM employees;
  ```
* **`MIN()` / `MAX()`**: Returns the smallest or largest non-null value.
  ```sql
  SELECT MIN(unit_price), MAX(unit_price) FROM products;
  ```

---

### STRING FUNCTIONS
* **`CONCAT()`**: Merges multiple strings into one.
  ```sql
  SELECT CONCAT(first_name, ' ', last_name) FROM employees;
  ```
* **`CONCAT_WS()`**: Merges strings using a delimiter, skipping NULLs.
  ```sql
  SELECT CONCAT_WS(', ', city, state, country) FROM customers;
  ```
* **`LOWER()` / `UPPER()`**: Converts string case.
  ```sql
  SELECT LOWER(email), UPPER(country) FROM customers;
  ```
* **`CHAR_LENGTH()`**: Counts characters in a string.
  ```sql
  SELECT CHAR_LENGTH(product_name) FROM products;
  ```
* **`SUBSTRING()`**: Extracts a substring starting at a 1-based index.
  ```sql
  SELECT SUBSTRING(phone, 1, 3) FROM customers;
  ```
* **`TRIM()`**: Strips leading and trailing spaces.
  ```sql
  SELECT TRIM('  clean text  ');
  ```
* **`REPLACE()`**: Replaces all occurrences of a substring.
  ```sql
  SELECT REPLACE('v1.0.0', '1', '2');
  ```
* **`LPAD()` / `RPAD()`**: Pads string with characters to a specified length.
  ```sql
  SELECT LPAD('42', 5, '0'); -- '00042'
  ```

---

### DATE & TIME FUNCTIONS
* **`NOW()`**: Returns current timestamp at statement start.
  ```sql
  SELECT NOW();
  ```
* **`CURDATE()` / `CURTIME()`**: Returns current date or time.
  ```sql
  SELECT CURDATE(), CURTIME();
  ```
* **`DATEDIFF()`**: Returns difference in days between two dates (`d1 - d2`).
  ```sql
  SELECT DATEDIFF(CURDATE(), '2023-01-01');
  ```
* **`TIMESTAMPDIFF()`**: Returns difference between dates in specified temporal units.
  ```sql
  SELECT TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) FROM employees;
  ```
* **`DATE_ADD()` / `DATE_SUB()`**: Adds or subtracts temporal intervals.
  ```sql
  SELECT DATE_ADD(CURDATE(), INTERVAL 30 DAY);
  ```
* **`DATE_FORMAT()`**: Formats a date into a custom string pattern.
  ```sql
  SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y');
  ```

---

### NUMERIC FUNCTIONS
* **`ROUND()`**: Rounds a number to specified decimal places.
  ```sql
  SELECT ROUND(123.456, 2); -- 123.46
  ```
* **`TRUNCATE()`**: Chops off decimal places without rounding.
  ```sql
  SELECT TRUNCATE(123.456, 2); -- 123.45
  ```
* **`FLOOR()` / `CEIL()`**: Rounds down to nearest integer or up to nearest integer.
  ```sql
  SELECT FLOOR(15.9), CEIL(15.1); -- 15, 16
  ```
* **`ABS()`**: Returns the absolute positive value.
  ```sql
  SELECT ABS(-50); -- 50
  ```
* **`MOD()`**: Returns the remainder of division.
  ```sql
  SELECT MOD(10, 3); -- 1
  ```
* **`POWER()` / `SQRT()`**: Computes powers and square roots.
  ```sql
  SELECT POWER(2, 3), SQRT(144); -- 8, 12
  ```

---

### FLOW CONTROL FUNCTIONS
* **`IF()`**: Simple inline conditional: `IF(test, true_val, false_val)`.
  ```sql
  SELECT IF(salary > 100000, 'Senior', 'Junior') FROM employees;
  ```
* **`IFNULL()`**: Returns fallback value if expression is NULL.
  ```sql
  SELECT IFNULL(phone, 'N/A') FROM customers;
  ```
* **`COALESCE()`**: Returns first non-NULL expression from a list.
  ```sql
  SELECT COALESCE(phone, state, country, 'Unknown') FROM customers;
  ```
* **`NULLIF()`**: Returns NULL if both arguments are equal.
  ```sql
  SELECT 100 / NULLIF(divisor, 0);
  ```
* **`CASE`**: Standard multi-branch conditional expression.
  ```sql
  SELECT CASE WHEN points > 500 THEN 'Gold' WHEN points > 200 THEN 'Silver' ELSE 'Bronze' END FROM customers;
  ```

---

### CONSTRAINTS & `ALTER TABLE`
* **`PRIMARY KEY`**: Enforces uniqueness and disallows NULLs.
  ```sql
  ALTER TABLE users ADD PRIMARY KEY (user_id);
  ```
* **`FOREIGN KEY`**: Enforces referential integrity pointing to a parent table.
  ```sql
  ALTER TABLE orders ADD CONSTRAINT fk_ord_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
  ```
* **`UNIQUE`**: Enforces distinct values across non-null rows.
  ```sql
  ALTER TABLE customers ADD CONSTRAINT uq_email UNIQUE (email);
  ```
* **`CHECK`**: Validates row values against a boolean condition.
  ```sql
  ALTER TABLE products ADD CONSTRAINT chk_price CHECK (unit_price >= 0);
  ```
* **`NOT NULL`**: Disallows missing values.
  ```sql
  ALTER TABLE employees MODIFY COLUMN email VARCHAR(100) NOT NULL;
  ```
* **`DROP CONSTRAINT`**: Drops a named constraint.
  ```sql
  ALTER TABLE orders DROP FOREIGN KEY fk_ord_cust;
  ```

---

### INDEXES & PERFORMANCE
* **`CREATE INDEX`**: Builds a B+ Tree index on one or more columns.
  ```sql
  CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);
  ```
* **`CREATE UNIQUE INDEX`**: Builds an index that also enforces uniqueness.
  ```sql
  CREATE UNIQUE INDEX uq_supplier_code ON suppliers(supplier_name);
  ```
* **`DROP INDEX`**: Removes an index from a table.
  ```sql
  DROP INDEX idx_emp_dept_salary ON employees;
  ```
* **`SHOW INDEX`**: Displays all indexes on a table.
  ```sql
  SHOW INDEX FROM employees;
  ```
* **`EXPLAIN`**: Displays the query execution plan and index usage.
  ```sql
  EXPLAIN SELECT * FROM employees WHERE department_id = 1;
  ```
* **`EXPLAIN ANALYZE`**: Measures actual execution time and iterator row counts.
  ```sql
  EXPLAIN ANALYZE SELECT * FROM orders WHERE total_amount > 500;
  ```

---

### VIEWS
* **`CREATE VIEW`**: Defines a saved virtual table based on a query.
  ```sql
  CREATE OR REPLACE VIEW v_active_products AS SELECT * FROM products WHERE is_active = TRUE;
  ```
* **`DROP VIEW`**: Deletes a view definition.
  ```sql
  DROP VIEW IF EXISTS v_active_products;
  ```
* **`WITH CHECK OPTION`**: Blocks inserts/updates through the view that violate its `WHERE` filter.
  ```sql
  CREATE VIEW v_us_cust AS SELECT * FROM customers WHERE country = 'USA' WITH CHECK OPTION;
  ```

---

### TRANSACTIONS & CONCURRENCY
* **`START TRANSACTION`**: Begins an explicit atomic transaction block.
  ```sql
  START TRANSACTION;
  ```
* **`COMMIT`**: Permanently persists transactional modifications to disk.
  ```sql
  COMMIT;
  ```
* **`ROLLBACK`**: Reverts all modifications made during the active transaction.
  ```sql
  ROLLBACK;
  ```
* **`SAVEPOINT`**: Establishes an intermediate rollback point.
  ```sql
  SAVEPOINT pt1; ROLLBACK TO SAVEPOINT pt1; RELEASE SAVEPOINT pt1;
  ```
* **`SELECT ... FOR UPDATE`**: Acquires an exclusive row lock (X-lock) on matching rows.
  ```sql
  SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
  ```

---

### STORED PROCEDURES & TRIGGERS
* **`CREATE PROCEDURE`**: Defines a precompiled procedural routine.
  ```sql
  DELIMITER //
  CREATE PROCEDURE sp_get_emp(IN p_id INT)
  BEGIN
      SELECT * FROM employees WHERE employee_id = p_id;
  END //
  DELIMITER ;
  ```
* **`CALL`**: Executes a stored procedure.
  ```sql
  CALL sp_get_emp(1);
  ```
* **`CREATE TRIGGER`**: Binds an automated event handler to table DML.
  ```sql
  DELIMITER //
  CREATE TRIGGER trg_emp_audit AFTER UPDATE ON employees
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (emp_id, old_sal, new_sal) VALUES (OLD.employee_id, OLD.salary, NEW.salary);
  END //
  DELIMITER ;
  ```

---

### USEFUL `information_schema` QUERIES
* **List Table Storage Sizes (MB)**:
  ```sql
  SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb FROM information_schema.TABLES WHERE table_schema = 'sql_mastery';
  ```
* **List All Foreign Keys in a Database**:
  ```sql
  SELECT table_name, constraint_name, referenced_table_name FROM information_schema.KEY_COLUMN_USAGE WHERE table_schema = 'sql_mastery' AND referenced_table_name IS NOT NULL;
  ```
* **Inspect Active Database Locks**:
  ```sql
  SELECT * FROM performance_schema.data_locks;
  ```
