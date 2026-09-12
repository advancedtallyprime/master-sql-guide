# Chapter 30 — The Master MySQL Production Cheat Sheet

Developers, data engineers, aur database administrators ke liye ek compact, comprehensive syntax reference.

---

### DATABASE COMMANDS
* **`CREATE DATABASE`**: UTF-8 character encoding ke saath ek naya database catalog create karta hai.
  ```sql
  CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
  ```
* **`DROP DATABASE`**: Ek database aur uski saari tables ko permanently destroy kar deta hai.
  ```sql
  DROP DATABASE IF EXISTS app_db;
  ```
* **`USE`**: Subsequent queries run karne ke liye active database context select karta hai.
  ```sql
  USE sql_mastery;
  ```
* **`SHOW DATABASES`**: MySQL instance par present saare databases ki list show karta hai.
  ```sql
  SHOW DATABASES;
  ```

---

### TABLE COMMANDS
* **`CREATE TABLE`**: Columns aur constraints ke saath ek nayi table schema create karta hai.
  ```sql
  CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL);
  ```
* **`DROP TABLE`**: Ek table aur uske data pages ko permanently delete kar deta hai.
  ```sql
  DROP TABLE IF EXISTS users;
  ```
* **`TRUNCATE TABLE`**: Table ke saare data pages ko deallocate karta hai aur auto-increment counter reset kar deta hai.
  ```sql
  TRUNCATE TABLE users;
  ```
* **`DESCRIBE` / `DESC`**: Column types, nullability, keys, aur default values display karta hai.
  ```sql
  DESCRIBE employees;
  ```
* **`SHOW CREATE TABLE`**: Table create karne ke liye use hui exact SQL DDL statement display karta hai.
  ```sql
  SHOW CREATE TABLE employees;
  ```

---

### CRUD OPERATIONS
* **`INSERT INTO`**: Table mein ek ya multiple rows insert karta hai.
  ```sql
  INSERT INTO departments (department_name, location) VALUES ('DevOps', 'London');
  ```
* **`INSERT ... ON DUPLICATE KEY UPDATE`**: Row ko upsert karta hai; agar key conflict ho toh existing values update karta hai.
  ```sql
  INSERT INTO products (product_id, stock_quantity) VALUES (1, 5) ON DUPLICATE KEY UPDATE stock_quantity = stock_quantity + 5;
  ```
* **`SELECT`**: Ek ya multiple tables se rows aur columns retrieve karta hai.
  ```sql
  SELECT employee_id, first_name, salary FROM employees;
  ```
* **`UPDATE`**: Filter condition ke basis par existing table rows ko modify karta hai.
  ```sql
  UPDATE employees SET salary = salary * 1.05 WHERE department_id = 1;
  ```
* **`DELETE FROM`**: Condition match karne wali rows ko remove karta hai aur triggers fire karta hai.
  ```sql
  DELETE FROM orders WHERE status = 'Cancelled' AND order_date < '2023-01-01';
  ```

---

### FILTERING & LOGICAL OPERATORS
* **`WHERE`**: Grouping ya aggregation se pehle raw rows ko filter karta hai.
  ```sql
  SELECT * FROM products WHERE unit_price > 100.00;
  ```
* **`AND`**: Sirf tabhi true return karta hai jab dono conditions true hon.
  ```sql
  SELECT * FROM employees WHERE department_id = 1 AND salary > 100000;
  ```
* **`OR`**: Agar koi bhi ek condition true ho toh true return karta hai.
  ```sql
  SELECT * FROM customers WHERE country = 'USA' OR country = 'Germany';
  ```
* **`NOT`**: Kisi condition ki truth value ko invert/reverse karta hai.
  ```sql
  SELECT * FROM products WHERE NOT (stock_quantity = 0);
  ```
* **`LIKE`**: Wildcards (`%` zero ya zyada chars ke liye, `_` ek single char ke liye) ka use karke pattern match karta hai.
  ```sql
  SELECT * FROM customers WHERE email LIKE '%@gmail.com';
  ```
* **`IN`**: Check karta hai ki koi value di gayi list ya subquery mein exist karti hai ya nahi.
  ```sql
  SELECT * FROM customers WHERE country IN ('USA', 'Germany', 'Japan');
  ```
* **`BETWEEN`**: Inclusive continuous range ke andar values ko filter karta hai.
  ```sql
  SELECT * FROM orders WHERE order_date BETWEEN '2023-08-01' AND '2023-08-31';
  ```
* **`IS NULL` / `IS NOT NULL`**: Test karta hai ki column value missing hai ya present hai.
  ```sql
  SELECT * FROM customers WHERE phone IS NULL;
  ```
* **`<=>` (NULL-Safe Equality)**: Do values ko compare karta hai aur true return karta hai agar dono NULL hon.
  ```sql
  SELECT * FROM employees WHERE manager_id <=> NULL;
  ```

---

### SORTING & PAGINATION
* **`ORDER BY`**: Results ko ascending (`ASC`) ya descending (`DESC`) order mein sort karta hai.
  ```sql
  SELECT * FROM employees ORDER BY salary DESC, last_name ASC;
  ```
* **`LIMIT`**: Return hone wali rows ki maximum sankhya restrict karta hai.
  ```sql
  SELECT * FROM products ORDER BY unit_price DESC LIMIT 5;
  ```
* **`LIMIT offset, count`**: Shuru ki `offset` rows skip karke `count` rows return karta hai.
  ```sql
  SELECT * FROM products ORDER BY product_id ASC LIMIT 10 OFFSET 20;
  ```
* **`DISTINCT`**: Result set se identical duplicate rows ko remove karta hai.
  ```sql
  SELECT DISTINCT country FROM customers;
  ```

---

### GROUPING & AGGREGATION
* **`GROUP BY`**: Matching values wali rows ko summary buckets mein group karta hai.
  ```sql
  SELECT department_id, COUNT(*), AVG(salary) FROM employees GROUP BY department_id;
  ```
* **`HAVING`**: `GROUP BY` phase ke baad aggregated groups ko filter karta hai.
  ```sql
  SELECT department_id, AVG(salary) FROM employees GROUP BY department_id HAVING AVG(salary) > 90000;
  ```
* **`WITH ROLLUP`**: Grouping dimensions across hierarchical subtotals aur grand totals compute karta hai.
  ```sql
  SELECT department_id, SUM(salary) FROM employees GROUP BY department_id WITH ROLLUP;
  ```
* **`GROUP_CONCAT()`**: Har group ki non-null values ko concatenate karke ek single string banata hai.
  ```sql
  SELECT department_id, GROUP_CONCAT(first_name SEPARATOR ', ') FROM employees GROUP BY department_id;
  ```

---

### RELATIONAL JOINS
* **`INNER JOIN`**: Dono tables mein matching values wale records return karta hai.
  ```sql
  SELECT e.first_name, d.department_name FROM employees e INNER JOIN departments d ON e.department_id = d.department_id;
  ```
* **`LEFT JOIN`**: Left table ki saari rows aur right table ki matched rows return karta hai.
  ```sql
  SELECT c.first_name, o.order_id FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;
  ```
* **`RIGHT JOIN`**: Right table ki saari rows aur left table ki matched rows return karta hai.
  ```sql
  SELECT d.department_name, e.first_name FROM employees e RIGHT JOIN departments d ON e.department_id = d.department_id;
  ```
* **`CROSS JOIN`**: Do tables ka Cartesian product compute karta hai.
  ```sql
  SELECT p.product_name, c.city FROM products p CROSS JOIN customers c;
  ```
* **`Self JOIN`**: Table ko apne hi saath alag aliases ke through join karta hai.
  ```sql
  SELECT e.first_name AS worker, m.first_name AS manager FROM employees e LEFT JOIN employees m ON e.manager_id = m.employee_id;
  ```
* **`FULL OUTER JOIN` (Emulation)**: `LEFT JOIN` aur `RIGHT JOIN` ko `UNION` ke saath combine karta hai.
  ```sql
  SELECT * FROM tableA a LEFT JOIN tableB b ON a.id = b.id UNION SELECT * FROM tableA a RIGHT JOIN tableB b ON a.id = b.id;
  ```

---

### SET OPERATIONS
* **`UNION`**: Query results ko vertically merge karta hai aur duplicates eliminate karta hai.
  ```sql
  SELECT city FROM customers UNION SELECT city FROM suppliers;
  ```
* **`UNION ALL`**: Duplicates remove kiye bina query results ko vertically merge karta hai.
  ```sql
  SELECT city FROM customers UNION ALL SELECT city FROM suppliers;
  ```

---

### SUBQUERIES & COMMON TABLE EXPRESSIONS (CTEs)
* **Scalar Subquery**: Inner query jo ek single 1x1 scalar value return karti hai.
  ```sql
  SELECT * FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);
  ```
* **Multi-Row Subquery**: Inner query jo values ka ek column return karti hai.
  ```sql
  SELECT * FROM products WHERE category_id IN (SELECT category_id FROM categories WHERE category_name LIKE '%Office%');
  ```
* **`EXISTS`**: Subquery ke andar rows ki existence test karta hai.
  ```sql
  SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
  ```
* **CTE (`WITH ...`)**: Query scope ke liye ek temporary named result set define karta hai.
  ```sql
  WITH RegionalSales AS (SELECT country, SUM(total_amount) AS revenue FROM orders o JOIN customers c ON o.customer_id = c.customer_id GROUP BY country)
  SELECT * FROM RegionalSales WHERE revenue > 2000;
  ```
* **Recursive CTE**: Hierarchies aur sequences ko recursively traverse karta hai.
  ```sql
  WITH RECURSIVE Seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM Seq WHERE n < 10) SELECT * FROM Seq;
  ```

---

### AGGREGATE FUNCTIONS
* **`COUNT(*)`**: Rows ki total sankhya return karta hai.
  ```sql
  SELECT COUNT(*) FROM orders;
  ```
* **`SUM()`**: Non-null values ka total sum calculate karta hai.
  ```sql
  SELECT SUM(total_amount) FROM orders;
  ```
* **`AVG()`**: Mathematical mean calculate karta hai, NULLs ko ignore karte hue.
  ```sql
  SELECT AVG(salary) FROM employees;
  ```
* **`MIN()` / `MAX()`**: Sabse chhoti ya sabse badi non-null value return karta hai.
  ```sql
  SELECT MIN(unit_price), MAX(unit_price) FROM products;
  ```

---

### STRING FUNCTIONS
* **`CONCAT()`**: Multiple strings ko ek sath merge karta hai.
  ```sql
  SELECT CONCAT(first_name, ' ', last_name) FROM employees;
  ```
* **`CONCAT_WS()`**: Delimiter ka use karke strings merge karta hai aur NULLs skip karta hai.
  ```sql
  SELECT CONCAT_WS(', ', city, state, country) FROM customers;
  ```
* **`LOWER()` / `UPPER()`**: String ke case ko lowercase ya uppercase mein convert karta hai.
  ```sql
  SELECT LOWER(email), UPPER(country) FROM customers;
  ```
* **`CHAR_LENGTH()`**: String mein characters ki count return karta hai.
  ```sql
  SELECT CHAR_LENGTH(product_name) FROM products;
  ```
* **`SUBSTRING()`**: 1-based index se start karke substring extract karta hai.
  ```sql
  SELECT SUBSTRING(phone, 1, 3) FROM customers;
  ```
* **`TRIM()`**: Leading aur trailing spaces ko strip kar deta hai.
  ```sql
  SELECT TRIM('  clean text  ');
  ```
* **`REPLACE()`**: Substring ke saare occurrences ko replace karta hai.
  ```sql
  SELECT REPLACE('v1.0.0', '1', '2');
  ```
* **`LPAD()` / `RPAD()`**: String ko specified length tak characters se pad karta hai.
  ```sql
  SELECT LPAD('42', 5, '0'); -- '00042'
  ```

---

### DATE & TIME FUNCTIONS
* **`NOW()`**: Statement start hone par current timestamp return karta hai.
  ```sql
  SELECT NOW();
  ```
* **`CURDATE()` / `CURTIME()`**: Current date ya current time return karta hai.
  ```sql
  SELECT CURDATE(), CURTIME();
  ```
* **`DATEDIFF()`**: Do dates ke beech days mein difference return karta hai (`d1 - d2`).
  ```sql
  SELECT DATEDIFF(CURDATE(), '2023-01-01');
  ```
* **`TIMESTAMPDIFF()`**: Specified temporal units (YEAR, MONTH, DAY) mein dates ka difference return karta hai.
  ```sql
  SELECT TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) FROM employees;
  ```
* **`DATE_ADD()` / `DATE_SUB()`**: Temporal intervals ko add ya subtract karta hai.
  ```sql
  SELECT DATE_ADD(CURDATE(), INTERVAL 30 DAY);
  ```
* **`DATE_FORMAT()`**: Date ko custom string pattern mein format karta hai.
  ```sql
  SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y');
  ```

---

### NUMERIC FUNCTIONS
* **`ROUND()`**: Number ko specified decimal places tak round karta hai.
  ```sql
  SELECT ROUND(123.456, 2); -- 123.46
  ```
* **`TRUNCATE()`**: Bina rounding ke decimal places ko cut kar deta hai.
  ```sql
  SELECT TRUNCATE(123.456, 2); -- 123.45
  ```
* **`FLOOR()` / `CEIL()`**: Nearest lower integer ya nearest higher integer par round karta hai.
  ```sql
  SELECT FLOOR(15.9), CEIL(15.1); -- 15, 16
  ```
* **`ABS()`**: Absolute positive value return karta hai.
  ```sql
  SELECT ABS(-50); -- 50
  ```
* **`MOD()`**: Division ka remainder return karta hai.
  ```sql
  SELECT MOD(10, 3); -- 1
  ```
* **`POWER()` / `SQRT()`**: Powers aur square roots compute karta hai.
  ```sql
  SELECT POWER(2, 3), SQRT(144); -- 8, 12
  ```

---

### FLOW CONTROL FUNCTIONS
* **`IF()`**: Simple inline conditional: `IF(test, true_val, false_val)`.
  ```sql
  SELECT IF(salary > 100000, 'Senior', 'Junior') FROM employees;
  ```
* **`IFNULL()`**: Agar expression NULL ho toh fallback value return karta hai.
  ```sql
  SELECT IFNULL(phone, 'N/A') FROM customers;
  ```
* **`COALESCE()`**: List mein se pehli non-NULL expression return karta hai.
  ```sql
  SELECT COALESCE(phone, state, country, 'Unknown') FROM customers;
  ```
* **`NULLIF()`**: Agar dono arguments equal hon toh NULL return karta hai.
  ```sql
  SELECT 100 / NULLIF(divisor, 0);
  ```
* **`CASE`**: Standard multi-branch conditional expression.
  ```sql
  SELECT CASE WHEN points > 500 THEN 'Gold' WHEN points > 200 THEN 'Silver' ELSE 'Bronze' END FROM customers;
  ```

---

### CONSTRAINTS & `ALTER TABLE`
* **`PRIMARY KEY`**: Uniqueness enforce karta hai aur NULLs disallow karta hai.
  ```sql
  ALTER TABLE users ADD PRIMARY KEY (user_id);
  ```
* **`FOREIGN KEY`**: Parent table ko point karke referential integrity enforce karta hai.
  ```sql
  ALTER TABLE orders ADD CONSTRAINT fk_ord_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
  ```
* **`UNIQUE`**: Non-null rows ke across distinct values enforce karta hai.
  ```sql
  ALTER TABLE customers ADD CONSTRAINT uq_email UNIQUE (email);
  ```
* **`CHECK`**: Row values ko boolean condition ke against validate karta hai.
  ```sql
  ALTER TABLE products ADD CONSTRAINT chk_price CHECK (unit_price >= 0);
  ```
* **`NOT NULL`**: Missing values ko disallow karta hai.
  ```sql
  ALTER TABLE employees MODIFY COLUMN email VARCHAR(100) NOT NULL;
  ```
* **`DROP CONSTRAINT`**: Kisi named constraint ko drop karta hai.
  ```sql
  ALTER TABLE orders DROP FOREIGN KEY fk_ord_cust;
  ```

---

### INDEXES & PERFORMANCE
* **`CREATE INDEX`**: Ek ya multiple columns par B+ Tree index build karta hai.
  ```sql
  CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);
  ```
* **`CREATE UNIQUE INDEX`**: Index build karta hai jo saath hi uniqueness bhi enforce karta hai.
  ```sql
  CREATE UNIQUE INDEX uq_supplier_code ON suppliers(supplier_name);
  ```
* **`DROP INDEX`**: Table se kisi index ko remove karta hai.
  ```sql
  DROP INDEX idx_emp_dept_salary ON employees;
  ```
* **`SHOW INDEX`**: Table par currently defined saare indexes display karta hai.
  ```sql
  SHOW INDEX FROM employees;
  ```
* **`EXPLAIN`**: Query execution plan aur index usage display karta hai.
  ```sql
  EXPLAIN SELECT * FROM employees WHERE department_id = 1;
  ```
* **`EXPLAIN ANALYZE`**: Actual execution time aur iterator row counts measure karta hai.
  ```sql
  EXPLAIN ANALYZE SELECT * FROM orders WHERE total_amount > 500;
  ```

---

### VIEWS
* **`CREATE VIEW`**: Query par based ek saved virtual table define karta hai.
  ```sql
  CREATE OR REPLACE VIEW v_active_products AS SELECT * FROM products WHERE is_active = TRUE;
  ```
* **`DROP VIEW`**: View definition ko delete kar deta hai.
  ```sql
  DROP VIEW IF EXISTS v_active_products;
  ```
* **`WITH CHECK OPTION`**: View ke `WHERE` filter ko violate karne wale inserts/updates ko block karta hai.
  ```sql
  CREATE VIEW v_us_cust AS SELECT * FROM customers WHERE country = 'USA' WITH CHECK OPTION;
  ```

---

### TRANSACTIONS & CONCURRENCY
* **`START TRANSACTION`**: Ek explicit atomic transaction block begin karta hai.
  ```sql
  START TRANSACTION;
  ```
* **`COMMIT`**: Transactional modifications ko permanently disk par persist karta hai.
  ```sql
  COMMIT;
  ```
* **`ROLLBACK`**: Active transaction ke dauran kiye gaye saare changes ko revert kar deta hai.
  ```sql
  ROLLBACK;
  ```
* **`SAVEPOINT`**: Ek intermediate rollback checkpoint establish karta hai.
  ```sql
  SAVEPOINT pt1; ROLLBACK TO SAVEPOINT pt1; RELEASE SAVEPOINT pt1;
  ```
* **`SELECT ... FOR UPDATE`**: Matching rows par Exclusive row lock (X-lock) acquire karta hai.
  ```sql
  SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
  ```

---

### STORED PROCEDURES & TRIGGERS
* **`CREATE PROCEDURE`**: Precompiled procedural routine define karta hai.
  ```sql
  DELIMITER //
  CREATE PROCEDURE sp_get_emp(IN p_id INT)
  BEGIN
      SELECT * FROM employees WHERE employee_id = p_id;
  END //
  DELIMITER ;
  ```
* **`CALL`**: Stored procedure ko execute karta hai.
  ```sql
  CALL sp_get_emp(1);
  ```
* **`CREATE TRIGGER`**: Table DML ke saath automated event handler bind karta hai.
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
* **Table Storage Sizes (MB) List Karein**:
  ```sql
  SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb FROM information_schema.TABLES WHERE table_schema = 'sql_mastery';
  ```
* **Database ki Saari Foreign Keys List Karein**:
  ```sql
  SELECT table_name, constraint_name, referenced_table_name FROM information_schema.KEY_COLUMN_USAGE WHERE table_schema = 'sql_mastery' AND referenced_table_name IS NOT NULL;
  ```
* **Active Database Locks Inspect Karein**:
  ```sql
  SELECT * FROM performance_schema.data_locks;
  ```
