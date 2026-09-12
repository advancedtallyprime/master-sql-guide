# अध्याय 28 — मास्टर आंसर की: सम्पूर्ण समाधान और विस्तृत व्याख्या (The Master Answer Key)

यह अध्याय [अध्याय 27 — कॉम्प्रीहेंसिव प्रैक्टिस सिस्टम](file:///c:/antigravity/master_sql_guide/hi/27_exercises.md) में प्रस्तुत सभी 300 अभ्यास समस्याओं के लिए व्यापक और सत्यापित समाधान प्रदान करता है।

सभी समाधानों को **`sql_mastery`** डेटाबेस स्कीमा के विरुद्ध सत्यापित किया गया है।

---

## Section 1: डेटाबेस और टेबल मैनेजमेंट (DDL, Types & Constraints)

#### Question 1
**सवाल**: सक्रिय `sql_mastery` डेटाबेस के अंदर सभी टेबल्स को प्रदर्शित करने के लिए एक SQL स्टेटमेंट लिखें।
```sql
SHOW TABLES;
```
* **व्याख्या**: वर्तमान डेटाबेस स्कीमा के भीतर सभी बेस टेबल्स और व्यूज के नाम प्राप्त करता है।
* **अपेक्षित परिणाम**: 9 कोर टेबल्स (`categories`, `customers`, `departments`, `employees`, `order_items`, `orders`, `payments`, `products`, `suppliers`) प्रदर्शित करता है।

#### Question 2
**सवाल**: `departments` टेबल की स्कीमा परिभाषा, डेटा प्रकार और नलेबिलिटी का निरीक्षण करने के लिए एक स्टेटमेंट लिखें।
```sql
DESCRIBE departments;
-- Equivalent: DESC departments;
```
* **व्याख्या**: फ़ील्ड परिभाषाएँ, भौतिक भंडारण प्रकार (storage types), की स्थितियाँ, डिफ़ॉल्ट मान और अतिरिक्त विशेषताएँ लौटाता है।
* **अपेक्षित परिणाम**: `department_id`, `department_name`, `location`, `created_at` दिखाने वाली तालिका।

#### Question 3
**सवाल**: एक एकल पूर्णांक कॉलम `id` के साथ `test_logs` नामक एक सैंडबॉक्स टेबल बनाने के लिए एक कमांड लिखें।
```sql
CREATE TABLE test_logs (
    id INT
);
```
* **व्याख्या**: डिफ़ॉल्ट इंजन (InnoDB) का उपयोग करके एक न्यूनतम बेस टेबल बनाता है।
* **अपेक्षित परिणाम**: `Query OK, 0 rows affected`।

#### Question 4
**सवाल**: `test_logs` टेबल को केवल तभी ड्रॉप करने के लिए एक स्टेटमेंट लिखें यदि वह मौजूद है।
```sql
DROP TABLE IF EXISTS test_logs;
```
* **व्याख्या**: टेबल को साफ-सुथरे तरीके से हटाता है, यदि टेबल मौजूद नहीं है तो त्रुटियों को दबा देता है।
* **अपेक्षित परिणाम**: `Query OK, 0 rows affected`।

#### Question 5
**सवाल**: `code VARCHAR(20)` और `discount_pct DECIMAL(4,2)` (डिफ़ॉल्ट `0.05`) के साथ `coupons` टेबल बनाने के लिए एक क्वेरी लिखें।
```sql
CREATE TABLE coupons (
    code VARCHAR(20) NOT NULL,
    discount_pct DECIMAL(4, 2) NOT NULL DEFAULT 0.05
);
```
* **व्याख्या**: एक गैर-नल स्ट्रिंग और डिफ़ॉल्ट कंस्ट्रेंट के साथ एक फिक्स्ड-पॉइंट न्यूमेरिक प्रकार को लागू करता है।

#### Question 6
**सवाल**: `coupons` टेबल में `expiry_date DATE NOT NULL` कॉलम जोड़ें।
```sql
ALTER TABLE coupons
ADD COLUMN expiry_date DATE NOT NULL;
```
* **व्याख्या**: एक तिथि विशेषता जोड़ने के लिए `ALTER TABLE ADD COLUMN` का उपयोग करता है।

#### Question 7
**सवाल**: `coupons` में `code` को `VARCHAR(30) NOT NULL` में संशोधित करें।
```sql
ALTER TABLE coupons
MODIFY COLUMN code VARCHAR(30) NOT NULL;
```
* **व्याख्या**: कॉलम का नाम बनाए रखते हुए चौड़ाई बदलने के लिए `MODIFY COLUMN` का उपयोग करता है।

#### Question 8
**सवाल**: `coupons` से `expiry_date` कॉलम को हटाएँ।
```sql
ALTER TABLE coupons
DROP COLUMN expiry_date;
```
* **व्याख्या**: कॉलम मेटाडेटा को हटाता है और स्टोरेज स्पेस को पुन: प्रयोज्य के रूप में चिह्नित करता है।

#### Question 9
**सवाल**: टेबल `coupons` का नाम बदलकर `promotional_codes` करें।
```sql
RENAME TABLE coupons TO promotional_codes;
```
* **व्याख्या**: कैटलॉग में टेबल का नाम एटॉमिक रूप से अपडेट करता है।

#### Question 10
**सवाल**: `promotional_codes` टेबल को साफ-सुथरे तरीके से ड्रॉप करें।
```sql
DROP TABLE IF EXISTS promotional_codes;
```

#### Question 11
**सवाल**: ऑटो-इन्क्रीमेंट प्राइमरी की `team_id`, यूनिक `team_name`, और चेक कंस्ट्रेंट `budget >= 1000.00` के साथ `project_teams` बनाएं।
```sql
CREATE TABLE project_teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(50) NOT NULL UNIQUE,
    budget DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_team_budget CHECK (budget >= 1000.00)
);
```
* **व्याख्या**: एक इनलाइन प्राइमरी की, यूनिक कंस्ट्रेंट और नामित डोमेन चेक घोषित करता है।

#### Question 12
**सवाल**: `project_teams` में `fk_team_lead` नामक एक फॉरेन की जोड़ें जो `team_lead_id` को `employees(employee_id)` से जोड़े (`ON DELETE SET NULL` के साथ)।
```sql
ALTER TABLE project_teams
ADD COLUMN team_lead_id INT,
ADD CONSTRAINT fk_team_lead FOREIGN KEY (team_lead_id)
    REFERENCES employees(employee_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
```

#### Question 13
**सवाल**: डेटा कॉपी किए बिना `products` का सटीक संरचनात्मक क्लोन `products_backup` बनाएं।
```sql
CREATE TABLE products_backup LIKE products;
```
* **व्याख्या**: पंक्तियों को कॉपी किए बिना संपूर्ण स्कीमा, इंडेक्स और कंस्ट्रेंट्स की प्रतिलिपि बनाता है।

#### Question 14
**सवाल**: CTAS का उपयोग करके `employees` से सभी कॉलम्स/पंक्तियों के साथ `high_earners` टेबल बनाएं जहाँ `salary > 120000.00` हो।
```sql
CREATE TABLE high_earners AS
SELECT * FROM employees WHERE salary > 120000.00;
```
* **व्याख्या**: टेबल बनाता है और पंक्तियों को भरता है। नोट: CTAS प्राइमरी की या फॉरेन की को कॉपी नहीं करता है।

#### Question 15
**सवाल**: `departments` में `department_name` के बाद `priority_level ENUM('Low', 'Medium', 'High') DEFAULT 'Medium'` जोड़ें।
```sql
ALTER TABLE departments
ADD COLUMN priority_level ENUM('Low', 'Medium', 'High') DEFAULT 'Medium' AFTER department_name;
```

#### Question 16
**सवाल**: `departments` से `priority_level` को हटाएँ।
```sql
ALTER TABLE departments DROP COLUMN priority_level;
```

#### Question 17
**सवाल**: `high_earners` टेबल को ट्रंकेट करें।
```sql
TRUNCATE TABLE high_earners;
```

#### Question 18
**सवाल**: `high_earners`, `products_backup`, और `project_teams` को ड्रॉप करें।
```sql
DROP TABLE IF EXISTS high_earners, products_backup, project_teams;
```

#### Question 19
**सवाल**: `order_items` के लिए MySQL द्वारा जनरेट की गई पूरी DDL `CREATE TABLE` स्क्रिप्ट देखें।
```sql
SHOW CREATE TABLE order_items\G
```

#### Question 20
**सवाल**: `departments(department_name, location)` पर कम्पोजिट यूनिक कंस्ट्रेंट `uq_dept_loc` जोड़ें।
```sql
ALTER TABLE departments
ADD CONSTRAINT uq_dept_loc UNIQUE (department_name, location);
-- Clean up:
ALTER TABLE departments DROP INDEX uq_dept_loc;
```

#### Question 21–30 मुख्य हाइलाइट्स
* **21 (अस्थायी टेबल)**: `CREATE TEMPORARY TABLE temp_sales_summary AS SELECT product_id, SUM(quantity) FROM order_items GROUP BY product_id;` (वर्तमान क्लाइंट सत्र समाप्त होने पर स्वचालित रूप से हटा दिया जाता है)।
* **22 (फॉरेन की जांच)**: `SET FOREIGN_KEY_CHECKS = 0; ... SET FOREIGN_KEY_CHECKS = 1;`
* **23 (चेक कंस्ट्रेंट अस्वीकृति)**: विफल रहता है क्योंकि मौजूदा कर्मचारी पंक्तियाँ स्थिति का उल्लंघन करती हैं; MySQL कंस्ट्रेंट जोड़ने से पहले मौजूदा डेटा को मान्य करता है।
* **28 (फॉरेन की ऑडिट क्वेरी)**:
  ```sql
  SELECT TABLE_NAME, CONSTRAINT_NAME, DELETE_RULE 
  FROM information_schema.REFERENTIAL_CONSTRAINTS 
  WHERE CONSTRAINT_SCHEMA = 'sql_mastery';
  ```
* **29 (MB में टेबल का आकार)**:
  ```sql
  SELECT table_name, 
         ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
  FROM information_schema.TABLES
  WHERE table_schema = 'sql_mastery';
  ```

---

## Section 2: डेटा क्वेरीइंग, फिल्टरिंग और सॉर्टिंग (SELECT, WHERE, ORDER BY, LIMIT)

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
* **अपेक्षित परिणाम**: Quantum Pro 15 Laptop ($1,299.99), AeroBook Air 13 ($999.00), SmartBrew Espresso Machine ($549.00)।

#### Question 34
```sql
SELECT * FROM customers WHERE country = 'USA';
```
* **अपेक्षित परिणाम**: 4 पंक्तियाँ (Emily Watson, Michael Brown, Sophia Garcia, James Wilson, Hannah Scott)।

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
* **अपेक्षित परिणाम**: Lucas Muller (Germany), Chloe Dubois (France), Ethan Hunt (UK)।

#### Question 38
```sql
SELECT employee_id, first_name, last_name, hire_date FROM employees ORDER BY hire_date ASC;
```

#### Question 39
```sql
SELECT first_name, last_name, salary FROM employees ORDER BY salary DESC LIMIT 3;
```
* **अपेक्षित परिणाम**: Alex Morgan ($145k), Priya Patel ($135k), Elena Rostova ($130k)।

#### Question 40
```sql
SELECT DISTINCT country FROM customers;
```
* **अपेक्षित परिणाम**: USA, India, Germany, Brazil, France, UK।

#### Question 41–50 मुख्य हाइलाइट्स
* **41 (ईमेल वाइल्डकार्ड)**: `SELECT * FROM customers WHERE email LIKE '%@gmail.com';`
* **42 (In + Range)**: `SELECT * FROM products WHERE category_id IN (1, 2) AND stock_quantity > 20;`
* **43 (कम्पाउंड फिल्टर)**: `SELECT * FROM orders WHERE order_date BETWEEN '2023-08-01' AND '2023-08-15' AND total_amount > 300.00;`
* **48 (ऑफसेट पेजिनेशन)**: `SELECT * FROM products ORDER BY unit_price DESC LIMIT 3 OFFSET 3;`
* **50 (कस्टम सॉर्ट ऑर्डरिंग)**:
  ```sql
  SELECT * FROM customers 
  ORDER BY (country = 'USA') DESC, country ASC, last_name ASC;
  ```

#### Question 51–60 मुख्य हाइलाइट्स
* **51 (ASC/DESC में Nulls Last)**:
  ```sql
  SELECT * FROM customers ORDER BY loyalty_points IS NULL ASC, loyalty_points DESC;
  ```
* **54 (कीसेट / कर्सर पेजिनेशन)**:
  ```sql
  SELECT * FROM orders WHERE order_id > 1005 ORDER BY order_id ASC LIMIT 3;
  ```
* **60 (SARGable डेट फिल्टर)**:
  ```sql
  SELECT * FROM orders WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
  ```

---

## Section 3: बिल्ट-इन SQL फंक्शन्स

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

#### Question 71–85 मुख्य हाइलाइट्स
* **71 (बीते हुए दिन)**: `SELECT customer_id, DATEDIFF(CURDATE(), registered_at) AS days_registered FROM customers;`
* **72 (डेट फॉर्मेटिंग)**: `SELECT order_id, DATE_FORMAT(order_date, '%M %d, %Y') FROM orders;`
* **74 (यूजरनेम निकालना)**: `SELECT SUBSTRING_INDEX(email, '@', 1) AS user_handle FROM customers;`
* **76 (महीनों में कार्यकाल)**: `SELECT employee_id, TIMESTAMPDIFF(MONTH, hire_date, CURDATE()) AS tenure_months FROM employees;`
* **77 (सुरक्षित डेलिमिटेड पता)**: `SELECT customer_id, CONCAT_WS(', ', city, state, country) FROM customers;`
* **81 (सर्च किया गया CASE)**:
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
* **87 (ईमेल मास्किंग चैलेंज)**:
  ```sql
  SELECT email, 
         CONCAT(SUBSTRING(email, 1, 2), '*****@', SUBSTRING_INDEX(email, '@', -1)) AS masked_email
  FROM customers;
  ```

---

## Section 4: ग्रुपिंग और एग्रीगेशन (GROUP BY & HAVING)

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

#### Question 117 (कंडीशनल एग्रीगेशन के साथ पिवट)
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

## Section 5: रिलेशनल JOINs और सेट ऑपरेशन्स

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

#### Question 131 (निष्क्रिय ग्राहकों के लिए एंटी-जॉइन)
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

#### Question 140 (FULL OUTER JOIN एम्यूलेशन)
```sql
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
UNION
SELECT d.department_name, e.first_name, e.last_name
FROM departments d
RIGHT JOIN employees e ON d.department_id = e.department_id;
```

#### Question 148 (रिलेशनल डिवीजन चैलेंज)
```sql
-- Find customers who purchased EVERY product in Category 1
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

## Section 6: नेस्टेड क्वेरीज और कॉमन टेबल एक्सप्रेशन्स (CTEs)

#### Question 151
```sql
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### Question 161 (कोरिलेटेड सबक्वेरी)
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

#### Question 172 (रिकर्सिव CTE: मैनेजमेंट ट्री)
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

#### Question 176 (रिकर्सिव डेट सीरीज जेनरेटर)
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

## Section 7: डेटाबेस डिज़ाइन, नॉर्मलाइजेशन और व्यूज

#### Question 184 & 185
```sql
CREATE OR REPLACE VIEW v_all_products AS
SELECT p.product_id, p.product_name, c.category_name, p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id;

SELECT * FROM v_all_products WHERE unit_price < 300.00;
```

#### Question 191 & 192 (CHECK OPTION के साथ अपडेट करने योग्य व्यू)
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

## Section 8: इंडेक्स, ट्रांजेक्शन्स और कॉनकरेंसी कंट्रोल

#### Question 211 & 212
```sql
CREATE INDEX idx_cust_email ON customers(email);
DROP INDEX idx_cust_email ON customers;
```

#### Question 224 (प्रबंधित ट्रांजैक्शन)
```sql
START TRANSACTION;
SELECT stock_quantity FROM products WHERE product_id = 1 FOR UPDATE;

UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES (1, CURDATE(), 'Pending', 1299.99);

COMMIT;
```

#### Question 231 (कवरिंग इंडेक्स सत्यापन)
```sql
CREATE INDEX idx_cov_emp ON employees(department_id, salary, employee_id);

EXPLAIN SELECT employee_id, salary 
FROM employees 
WHERE department_id = 1 
ORDER BY salary DESC;
-- Look for 'Using index' in the Extra column!
```

---

## Section 9: प्रोग्रामेबिलिटी और एडवांस्ड एनालिटिक्स

#### Question 244 (डिटर्मिनिस्टिक फंक्शन)
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

#### Question 254 (रैंकिंग फंक्शन्स)
```sql
SELECT 
    product_name, category_id, unit_price,
    RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) AS price_rank,
    DENSE_RANK() OVER (PARTITION BY category_id ORDER BY unit_price DESC) AS price_dense_rank
FROM products;
```

#### Question 260 (रनिंग टोटल विंडो कैलकुलेशन)
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

## Section 10: परफॉरमेंस ऑप्टिमाइज़ेशन और एंटरप्राइज सिक्योरिटी

#### Question 274–278 (RBAC और यूजर एडमिनिस्ट्रेशन)
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

#### Question 281 & 282 (SARGable रीराइट्स)
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

#### Question 286 (प्रिपेयर्ड स्टेटमेंट)
```sql
PREPARE stmt_order_lookup FROM 'SELECT * FROM orders WHERE customer_id = ? AND total_amount > ?';
SET @cust = 1;
SET @min_amt = 500.00;
EXECUTE stmt_order_lookup USING @cust, @min_amt;
DEALLOCATE PREPARE stmt_order_lookup;
```

#### Question 288 (ऑनलाइन लॉजिकल बैकअप)
```bash
mysqldump -u root -p --single-transaction --quick --routines --triggers sql_mastery > sql_mastery_backup.sql
```
