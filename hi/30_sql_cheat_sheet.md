# अध्याय 30 — मास्टर MySQL प्रोडक्शन चीट शीट (Master MySQL Production Cheat Sheet)

डेवलपर्स, डेटा इंजीनियर्स और डेटाबेस एडमिनिस्ट्रेटर्स के लिए एक कॉम्पैक्ट, कॉम्प्रिहेंसिव सिंटैक्स संदर्भ।

---

### डेटाबेस कमांड्स (DATABASE COMMANDS)
* **`CREATE DATABASE`**: UTF-8 कैरेक्टर एन्कोडिंग के साथ एक नया डेटाबेस कैटलॉग बनाता है।
  ```sql
  CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
  ```
* **`DROP DATABASE`**: किसी डेटाबेस और उसके सभी टेबल्स को स्थायी रूप से नष्ट करता है।
  ```sql
  DROP DATABASE IF EXISTS app_db;
  ```
* **`USE`**: बाद की सभी क्वेरीज के लिए सक्रिय डेटाबेस संदर्भ (context) का चयन करता है।
  ```sql
  USE sql_mastery;
  ```
* **`SHOW DATABASES`**: MySQL इंस्टेंस पर मौजूद सभी डेटाबेस को सूचीबद्ध करता है।
  ```sql
  SHOW DATABASES;
  ```

---

### टेबल कमांड्स (TABLE COMMANDS)
* **`CREATE TABLE`**: कॉलम्स और कंस्ट्रेंट्स के साथ एक नया टेबल स्कीमा बनाता है।
  ```sql
  CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL);
  ```
* **`DROP TABLE`**: किसी टेबल और उसके डेटा पेजेज को स्थायी रूप से हटा देता है।
  ```sql
  DROP TABLE IF EXISTS users;
  ```
* **`TRUNCATE TABLE`**: सभी टेबल डेटा पेजेज को डीएलोकेट करता है और ऑटो-इन्क्रीमेंट काउंटरों को रीसेट करता है।
  ```sql
  TRUNCATE TABLE users;
  ```
* **`DESCRIBE` / `DESC`**: कॉलम प्रकार, नलेबिलिटी, कीज़ और डिफ़ॉल्ट मान प्रदर्शित करता है।
  ```sql
  DESCRIBE employees;
  ```
* **`SHOW CREATE TABLE`**: टेबल बनाने के लिए उपयोग किए गए सटीक SQL DDL स्टेटमेंट को प्रदर्शित करता है।
  ```sql
  SHOW CREATE TABLE employees;
  ```

---

### CRUD ऑपरेशन्स (CRUD OPERATIONS)
* **`INSERT INTO`**: किसी टेबल में एक या अधिक पंक्तियाँ सम्मिलित करता है।
  ```sql
  INSERT INTO departments (department_name, location) VALUES ('DevOps', 'London');
  ```
* **`INSERT ... ON DUPLICATE KEY UPDATE`**: एक पंक्ति को अपसर्ट (upsert) करता है, यदि कोई की टकराव होता है तो मान अपडेट करता है।
  ```sql
  INSERT INTO products (product_id, stock_quantity) VALUES (1, 5) ON DUPLICATE KEY UPDATE stock_quantity = stock_quantity + 5;
  ```
* **`SELECT`**: एक या अधिक टेबल्स से पंक्तियाँ और कॉलम्स प्राप्त करता है।
  ```sql
  SELECT employee_id, first_name, salary FROM employees;
  ```
* **`UPDATE`**: फ़िल्टर स्थिति के आधार पर मौजूदा टेबल पंक्तियों को संशोधित करता है।
  ```sql
  UPDATE employees SET salary = salary * 1.05 WHERE department_id = 1;
  ```
* **`DELETE FROM`**: ट्रिगर्स को फायर करते हुए किसी शर्त से मेल खाने वाली पंक्तियों को हटाता है।
  ```sql
  DELETE FROM orders WHERE status = 'Cancelled' AND order_date < '2023-01-01';
  ```

---

### फिल्टरिंग और लॉजिकल ऑपरेटर्स (FILTERING & LOGICAL OPERATORS)
* **`WHERE`**: ग्रुपिंग या एग्रीगेशन से पहले पंक्तियों को फ़िल्टर करता है।
  ```sql
  SELECT * FROM products WHERE unit_price > 100.00;
  ```
* **`AND`**: केवल तभी सत्य लौटाता है जब दोनों स्थितियाँ सत्य हों।
  ```sql
  SELECT * FROM employees WHERE department_id = 1 AND salary > 100000;
  ```
* **`OR`**: यदि कोई भी स्थिति सत्य है तो सत्य लौटाता है।
  ```sql
  SELECT * FROM customers WHERE country = 'USA' OR country = 'Germany';
  ```
* **`NOT`**: किसी स्थिति के सत्य मान को उलट देता है।
  ```sql
  SELECT * FROM products WHERE NOT (stock_quantity = 0);
  ```
* **`LIKE`**: वाइल्डकार्ड (`%` 0+ कैरेक्टर्स के लिए, `_` 1 कैरेक्टर के लिए) का उपयोग करके पैटर्न मिलान करता है।
  ```sql
  SELECT * FROM customers WHERE email LIKE '%@gmail.com';
  ```
* **`IN`**: जाँचता है कि कोई मान किसी प्रगणित सूची या सबक्वेरी में किसी भी आइटम से मेल खाता है या नहीं।
  ```sql
  SELECT * FROM customers WHERE country IN ('USA', 'Germany', 'Japan');
  ```
* **`BETWEEN`**: एक समावेशी निरंतर सीमा (inclusive range) के भीतर मानों को फ़िल्टर करता है।
  ```sql
  SELECT * FROM orders WHERE order_date BETWEEN '2023-08-01' AND '2023-08-31';
  ```
* **`IS NULL` / `IS NOT NULL`**: परीक्षण करता है कि कोई कॉलम मान गायब (missing) है या नहीं।
  ```sql
  SELECT * FROM customers WHERE phone IS NULL;
  ```
* **`<=>` (NULL-Safe Equality)**: दो मानों की तुलना करता है और यदि दोनों NULL हैं तो true लौटाता है।
  ```sql
  SELECT * FROM employees WHERE manager_id <=> NULL;
  ```

---

### सॉर्टिंग और पेजिनेशन (SORTING & PAGINATION)
* **`ORDER BY`**: परिणामों को आरोही (`ASC`) या अवरोही (`DESC`) क्रम में सॉर्ट करता है।
  ```sql
  SELECT * FROM employees ORDER BY salary DESC, last_name ASC;
  ```
* **`LIMIT`**: लौटाई गई पंक्तियों की अधिकतम संख्या को सीमित करता है।
  ```sql
  SELECT * FROM products ORDER BY unit_price DESC LIMIT 5;
  ```
* **`LIMIT offset, count`**: `offset` पंक्तियों को छोड़ता है और `count` पंक्तियों तक लौटाता है।
  ```sql
  SELECT * FROM products ORDER BY product_id ASC LIMIT 10 OFFSET 20;
  ```
* **`DISTINCT`**: परिणाम सेट से समान पंक्तियों के डुप्लिकेट को समाप्त करता है।
  ```sql
  SELECT DISTINCT country FROM customers;
  ```

---

### ग्रुपिंग और एग्रीगेशन (GROUPING & AGGREGATION)
* **`GROUP BY`**: समान मानों वाली पंक्तियों को सारांश बकेट्स में समूहित करता है।
  ```sql
  SELECT department_id, COUNT(*), AVG(salary) FROM employees GROUP BY department_id;
  ```
* **`HAVING`**: `GROUP BY` चरण के बाद एग्रीगेटेड समूहों को फ़िल्टर करता है।
  ```sql
  SELECT department_id, AVG(salary) FROM employees GROUP BY department_id HAVING AVG(salary) > 90000;
  ```
* **`WITH ROLLUP`**: ग्रुपिंग डायमेंशन्स में हायरार्किकल सबटोटल और ग्रैंड टोटल की गणना करता है।
  ```sql
  SELECT department_id, SUM(salary) FROM employees GROUP BY department_id WITH ROLLUP;
  ```
* **`GROUP_CONCAT()`**: प्रत्येक समूह के गैर-नल मानों को एक एकल स्ट्रिंग में जोड़ता है।
  ```sql
  SELECT department_id, GROUP_CONCAT(first_name SEPARATOR ', ') FROM employees GROUP BY department_id;
  ```

---

### रिलेशनल जॉइन्स (RELATIONAL JOINS)
* **`INNER JOIN`**: दोनों टेबल्स में मिलान मान वाले रिकॉर्ड लौटाता है।
  ```sql
  SELECT e.first_name, d.department_name FROM employees e INNER JOIN departments d ON e.department_id = d.department_id;
  ```
* **`LEFT JOIN`**: बाईं टेबल से सभी पंक्तियों और दाईं टेबल से मिलान की गई पंक्तियों को लौटाता है।
  ```sql
  SELECT c.first_name, o.order_id FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;
  ```
* **`RIGHT JOIN`**: दाईं टेबल से सभी पंक्तियों और बाईं टेबल से मिलान की गई पंक्तियों को लौटाता है।
  ```sql
  SELECT d.department_name, e.first_name FROM employees e RIGHT JOIN departments d ON e.department_id = d.department_id;
  ```
* **`CROSS JOIN`**: दो टेबल्स का कार्टेशियन उत्पाद (Cartesian product) निकालता है।
  ```sql
  SELECT p.product_name, c.city FROM products p CROSS JOIN customers c;
  ```
* **`Self JOIN`**: अलग-अलग एलियास का उपयोग करके किसी टेबल को खुद से जोड़ता है।
  ```sql
  SELECT e.first_name AS worker, m.first_name AS manager FROM employees e LEFT JOIN employees m ON e.manager_id = m.employee_id;
  ```
* **`FULL OUTER JOIN` (Emulation)**: `UNION` के साथ `LEFT JOIN` और `RIGHT JOIN` को जोड़कर एम्यूलेट करता है।
  ```sql
  SELECT * FROM tableA a LEFT JOIN tableB b ON a.id = b.id UNION SELECT * FROM tableA a RIGHT JOIN tableB b ON a.id = b.id;
  ```

---

### सेट ऑपरेशन्स (SET OPERATIONS)
* **`UNION`**: क्वेरी परिणामों को लंबवत रूप से मर्ज करता है और डुप्लिकेट पंक्तियों को समाप्त करता है।
  ```sql
  SELECT city FROM customers UNION SELECT city FROM suppliers;
  ```
* **`UNION ALL`**: डुप्लिकेट को हटाए बिना क्वेरी परिणामों को लंबवत रूप से मर्ज करता है।
  ```sql
  SELECT city FROM customers UNION ALL SELECT city FROM suppliers;
  ```

---

### सबक्वेरीज और कॉमन टेबल एक्सप्रेशन्स (CTEs)
* **Scalar Subquery**: एकल 1x1 मान लौटाने वाली आंतरिक क्वेरी।
  ```sql
  SELECT * FROM employees WHERE salary > (SELECT AVG(salary) FROM employees);
  ```
* **Multi-Row Subquery**: मानों का एक कॉलम लौटाने वाली आंतरिक क्वेरी।
  ```sql
  SELECT * FROM products WHERE category_id IN (SELECT category_id FROM categories WHERE category_name LIKE '%Office%');
  ```
* **`EXISTS`**: सबक्वेरी में पंक्तियों के अस्तित्व का परीक्षण करता है।
  ```sql
  SELECT * FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
  ```
* **CTE (`WITH ...`)**: क्वेरी स्कोप के लिए एक अस्थायी नामित परिणाम सेट को परिभाषित करता है।
  ```sql
  WITH RegionalSales AS (SELECT country, SUM(total_amount) AS revenue FROM orders o JOIN customers c ON o.customer_id = c.customer_id GROUP BY country)
  SELECT * FROM RegionalSales WHERE revenue > 2000;
  ```
* **Recursive CTE**: पदानुक्रम (hierarchies) और अनुक्रमों को पुनरावर्ती रूप से ट्रैवर्स करता है।
  ```sql
  WITH RECURSIVE Seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM Seq WHERE n < 10) SELECT * FROM Seq;
  ```

---

### एग्रीगेट फंक्शन्स (AGGREGATE FUNCTIONS)
* **`COUNT(*)`**: पंक्तियों की कुल संख्या लौटाता है।
  ```sql
  SELECT COUNT(*) FROM orders;
  ```
* **`SUM()`**: गैर-नल मानों के कुल योग की गणना करता है।
  ```sql
  SELECT SUM(total_amount) FROM orders;
  ```
* **`AVG()`**: NULLs को अनदेखा करते हुए गणितीय औसत की गणना करता है।
  ```sql
  SELECT AVG(salary) FROM employees;
  ```
* **`MIN()` / `MAX()`**: सबसे छोटा या सबसे बड़ा गैर-नल मान लौटाता है।
  ```sql
  SELECT MIN(unit_price), MAX(unit_price) FROM products;
  ```

---

### स्ट्रिंग फंक्शन्स (STRING FUNCTIONS)
* **`CONCAT()`**: कई स्ट्रिंग्स को एक में मिलाता है।
  ```sql
  SELECT CONCAT(first_name, ' ', last_name) FROM employees;
  ```
* **`CONCAT_WS()`**: NULLs को छोड़ते हुए एक डेलिमिटर का उपयोग करके स्ट्रिंग्स को मिलाता है।
  ```sql
  SELECT CONCAT_WS(', ', city, state, country) FROM customers;
  ```
* **`LOWER()` / `UPPER()`**: स्ट्रिंग केस को परिवर्तित करता है।
  ```sql
  SELECT LOWER(email), UPPER(country) FROM customers;
  ```
* **`CHAR_LENGTH()`**: किसी स्ट्रिंग में कैरेक्टर्स की गिनती करता है।
  ```sql
  SELECT CHAR_LENGTH(product_name) FROM products;
  ```
* **`SUBSTRING()`**: 1-आधारित इंडेक्स से शुरू होकर सबस्ट्रिंग निकालता है।
  ```sql
  SELECT SUBSTRING(phone, 1, 3) FROM customers;
  ```
* **`TRIM()`**: आगे और पीछे के रिक्त स्थान को हटाता है।
  ```sql
  SELECT TRIM('  clean text  ');
  ```
* **`REPLACE()`**: सबस्ट्रिंग की सभी घटनाओं को बदल देता है।
  ```sql
  SELECT REPLACE('v1.0.0', '1', '2');
  ```
* **`LPAD()` / `RPAD()`**: निर्दिष्ट लंबाई तक पहुंचने के लिए स्ट्रिंग को कैरेक्टर्स से पैड करता है।
  ```sql
  SELECT LPAD('42', 5, '0'); -- '00042'
  ```

---

### डेट और टाइम फंक्शन्स (DATE & TIME FUNCTIONS)
* **`NOW()`**: स्टेटमेंट शुरू होने पर वर्तमान टाइमस्टैम्प लौटाता है।
  ```sql
  SELECT NOW();
  ```
* **`CURDATE()` / `CURTIME()`**: वर्तमान दिनांक या समय लौटाता है।
  ```sql
  SELECT CURDATE(), CURTIME();
  ```
* **`DATEDIFF()`**: दो तिथियों के बीच दिनों का अंतर (`d1 - d2`) लौटाता है।
  ```sql
  SELECT DATEDIFF(CURDATE(), '2023-01-01');
  ```
* **`TIMESTAMPDIFF()`**: निर्दिष्ट टेम्पोरल इकाइयों में तिथियों के बीच अंतर लौटाता है।
  ```sql
  SELECT TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) FROM employees;
  ```
* **`DATE_ADD()` / `DATE_SUB()`**: टेम्पोरल अंतराल जोड़ता या घटाता है।
  ```sql
  SELECT DATE_ADD(CURDATE(), INTERVAL 30 DAY);
  ```
* **`DATE_FORMAT()`**: किसी तिथि को कस्टम स्ट्रिंग पैटर्न में फॉर्मेट करता है।
  ```sql
  SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y');
  ```

---

### न्यूमेरिक फंक्शन्स (NUMERIC FUNCTIONS)
* **`ROUND()`**: किसी संख्या को निर्दिष्ट दशमलव स्थानों तक राउंड करता है।
  ```sql
  SELECT ROUND(123.456, 2); -- 123.46
  ```
* **`TRUNCATE()`**: बिना राउंड किए दशमलव स्थानों को काट देता है।
  ```sql
  SELECT TRUNCATE(123.456, 2); -- 123.45
  ```
* **`FLOOR()` / `CEIL()`**: निकटतम छोटे पूर्णांक तक राउंड डाउन या निकटतम बड़े पूर्णांक तक राउंड अप करता है।
  ```sql
  SELECT FLOOR(15.9), CEIL(15.1); -- 15, 16
  ```
* **`ABS()`**: निरपेक्ष धनात्मक मान (absolute positive value) लौटाता है।
  ```sql
  SELECT ABS(-50); -- 50
  ```
* **`MOD()`**: विभाजन का शेषफल (remainder) लौटाता है।
  ```sql
  SELECT MOD(10, 3); -- 1
  ```
* **`POWER()` / `SQRT()`**: घात (powers) और वर्गमूल (square roots) की गणना करता है।
  ```sql
  SELECT POWER(2, 3), SQRT(144); -- 8, 12
  ```

---

### फ्लो कंट्रोल फंक्शन्स (FLOW CONTROL FUNCTIONS)
* **`IF()`**: सरल इनलाइन कंडीशनल: `IF(test, true_val, false_val)`।
  ```sql
  SELECT IF(salary > 100000, 'Senior', 'Junior') FROM employees;
  ```
* **`IFNULL()`**: अभिव्यक्ति के NULL होने पर फॉलबैक मान लौटाता है।
  ```sql
  SELECT IFNULL(phone, 'N/A') FROM customers;
  ```
* **`COALESCE()`**: सूची में से पहला गैर-नल एक्सप्रेशन लौटाता है।
  ```sql
  SELECT COALESCE(phone, state, country, 'Unknown') FROM customers;
  ```
* **`NULLIF()`**: यदि दोनों तर्क समान हैं तो NULL लौटाता है।
  ```sql
  SELECT 100 / NULLIF(divisor, 0);
  ```
* **`CASE`**: मानक मल्टी-ब्रांच कंडीशनल एक्सप्रेशन।
  ```sql
  SELECT CASE WHEN points > 500 THEN 'Gold' WHEN points > 200 THEN 'Silver' ELSE 'Bronze' END FROM customers;
  ```

---

### कंस्ट्रेंट्स और `ALTER TABLE` (CONSTRAINTS & ALTER TABLE)
* **`PRIMARY KEY`**: विशिष्टता लागू करता है और NULLs को अस्वीकार करता है।
  ```sql
  ALTER TABLE users ADD PRIMARY KEY (user_id);
  ```
* **`FOREIGN KEY`**: पैरेंट टेबल की ओर इशारा करते हुए रेफरेंशियल इंटीग्रिटी लागू करता है।
  ```sql
  ALTER TABLE orders ADD CONSTRAINT fk_ord_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
  ```
* **`UNIQUE`**: गैर-नल पंक्तियों में अलग-अलग मान लागू करता है।
  ```sql
  ALTER TABLE customers ADD CONSTRAINT uq_email UNIQUE (email);
  ```
* **`CHECK`**: बूलियन स्थिति के विरुद्ध पंक्ति मानों को मान्य करता है।
  ```sql
  ALTER TABLE products ADD CONSTRAINT chk_price CHECK (unit_price >= 0);
  ```
* **`NOT NULL`**: लापता मानों को अस्वीकार करता है।
  ```sql
  ALTER TABLE employees MODIFY COLUMN email VARCHAR(100) NOT NULL;
  ```
* **`DROP CONSTRAINT`**: किसी नामित कंस्ट्रेंट को हटा देता है।
  ```sql
  ALTER TABLE orders DROP FOREIGN KEY fk_ord_cust;
  ```

---

### इंडेक्स और परफॉरमेंस (INDEXES & PERFORMANCE)
* **`CREATE INDEX`**: एक या अधिक कॉलम्स पर B+ Tree इंडेक्स बनाता है।
  ```sql
  CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);
  ```
* **`CREATE UNIQUE INDEX`**: एक इंडेक्स बनाता है जो विशिष्टता को भी लागू करता है।
  ```sql
  CREATE UNIQUE INDEX uq_supplier_code ON suppliers(supplier_name);
  ```
* **`DROP INDEX`**: किसी टेबल से इंडेक्स को हटाता है।
  ```sql
  DROP INDEX idx_emp_dept_salary ON employees;
  ```
* **`SHOW INDEX`**: किसी टेबल के सभी इंडेक्स प्रदर्शित करता है।
  ```sql
  SHOW INDEX FROM employees;
  ```
* **`EXPLAIN`**: क्वेरी निष्पादन योजना और इंडेक्स उपयोग प्रदर्शित करता है।
  ```sql
  EXPLAIN SELECT * FROM employees WHERE department_id = 1;
  ```
* **`EXPLAIN ANALYZE`**: वास्तविक निष्पादन समय और इटरेटर पंक्ति गणना को मापता है।
  ```sql
  EXPLAIN ANALYZE SELECT * FROM orders WHERE total_amount > 500;
  ```

---

### व्यूज (VIEWS)
* **`CREATE VIEW`**: क्वेरी के आधार पर एक सहेजा गया वर्चुअल टेबल परिभाषित करता है।
  ```sql
  CREATE OR REPLACE VIEW v_active_products AS SELECT * FROM products WHERE is_active = TRUE;
  ```
* **`DROP VIEW`**: व्यू परिभाषा को हटाता है।
  ```sql
  DROP VIEW IF EXISTS v_active_products;
  ```
* **`WITH CHECK OPTION`**: व्यू के माध्यम से ऐसे इन्सर्ट/अपडेट को रोकता है जो इसके `WHERE` फ़िल्टर का उल्लंघन करते हैं।
  ```sql
  CREATE VIEW v_us_cust AS SELECT * FROM customers WHERE country = 'USA' WITH CHECK OPTION;
  ```

---

### ट्रांजेक्शन्स और कॉनकरेंसी (TRANSACTIONS & CONCURRENCY)
* **`START TRANSACTION`**: एक स्पष्ट एटॉमिक ट्रांजैक्शन ब्लॉक शुरू करता है।
  ```sql
  START TRANSACTION;
  ```
* **`COMMIT`**: ट्रांजैक्शनल संशोधनों को डिस्क पर स्थायी रूप से सहेजता है।
  ```sql
  COMMIT;
  ```
* **`ROLLBACK`**: सक्रिय ट्रांजैक्शन के दौरान किए गए सभी संशोधनों को पूर्ववत करता है।
  ```sql
  ROLLBACK;
  ```
* **`SAVEPOINT`**: एक मध्यवर्ती रोलबैक बिंदु स्थापित करता है।
  ```sql
  SAVEPOINT pt1; ROLLBACK TO SAVEPOINT pt1; RELEASE SAVEPOINT pt1;
  ```
* **`SELECT ... FOR UPDATE`**: मिलान पंक्तियों पर एक एक्सक्लूसिव रो लॉक (X-lock) प्राप्त करता है।
  ```sql
  SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
  ```

---

### स्टोर्ड प्रोसीजर्स और ट्रिगर्स (STORED PROCEDURES & TRIGGERS)
* **`CREATE PROCEDURE`**: एक पूर्व-संकलित प्रक्रियात्मक रूटीन को परिभाषित करता है।
  ```sql
  DELIMITER //
  CREATE PROCEDURE sp_get_emp(IN p_id INT)
  BEGIN
      SELECT * FROM employees WHERE employee_id = p_id;
  END //
  DELIMITER ;
  ```
* **`CALL`**: स्टोर्ड प्रोसीजर को निष्पादित करता है।
  ```sql
  CALL sp_get_emp(1);
  ```
* **`CREATE TRIGGER`**: टेबल DML के लिए एक स्वचालित इवेंट हैंडलर को बांधता है।
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

### उपयोगी `information_schema` क्वेरीज (USEFUL information_schema QUERIES)
* **टेबल स्टोरेज साइज़ (MB) की सूची**:
  ```sql
  SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb FROM information_schema.TABLES WHERE table_schema = 'sql_mastery';
  ```
* **डेटाबेस में सभी फॉरेन कीज की सूची**:
  ```sql
  SELECT table_name, constraint_name, referenced_table_name FROM information_schema.KEY_COLUMN_USAGE WHERE table_schema = 'sql_mastery' AND referenced_table_name IS NOT NULL;
  ```
* **सक्रिय डेटाबेस लॉक्स का निरीक्षण**:
  ```sql
  SELECT * FROM performance_schema.data_locks;
  ```
