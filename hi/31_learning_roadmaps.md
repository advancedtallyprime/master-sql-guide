# Chapter 31 — Structured Learning Roadmaps: 7, 14, 30 & 60-Day Schedules

Alag-alag timelines, career goals, aur experience levels ke liye design kiye gaye chaar structured learning roadmaps:

* **7-Day Crash Course**: Core querying, CRUD, aur basic reporting.
* **14-Day Practical Course**: Backend engineers aur data analysts ke liye developer-level SQL.
* **30-Day Professional Course**: Subqueries, CTEs, views, aur normalization samet comprehensive coverage.
* **60-Day Mastery Course**: Database architecture, B-Tree internals, query optimization, concurrency, aur enterprise security.

---

# 1. The 7-Day Intensive Crash Course

Un professionals ke liye designed jinhe interviews ya workplace reporting ke liye immediate querying proficiency chahiye.

| Day | Focus Topic | Study Time | Practice Tasks | Core Queries to Write | Revision & Mini-Challenge |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **Day 1** | RDBMS Fundamentals, Database Setup, `SELECT` & Column Aliasing | 2.5 hrs | `sql_mastery` schema initialize karein; `DESCRIBE` ke through table definitions inspect karein. | `SELECT first_name, last_name, salary FROM employees;` | **Challenge**: Column aliases ke saath har customer ka full name aur email project karein. |
| **Day 2** | Filtering Data (`WHERE`, Operators, `BETWEEN`, `IN`, `LIKE`) | 2.5 hrs | Numbers, dates, wildcards, aur strings par filtering practice karein. | `SELECT * FROM products WHERE unit_price BETWEEN 100 AND 500 AND stock_quantity > 10;` | **Challenge**: `IS NULL` ka use karke un sabhi customers ko find karein jinka email `.com` par end hota hai aur state NULL hai. |
| **Day 3** | Sorting, Pagination & Distinct Values (`ORDER BY`, `LIMIT`, `DISTINCT`) | 2.0 hrs | Multi-column sorting aur offset-based pagination practice karein. | `SELECT DISTINCT country FROM customers ORDER BY country ASC LIMIT 5 OFFSET 2;` | **Challenge**: Department 1 mein top 3 highest-earning employees retrieve karein. |
| **Day 4** | Essential Scalar & Aggregate Functions (`COUNT`, `SUM`, `AVG`, String & Date) | 3.0 hrs | Payroll metrics calculate karein; dates format karein aur strings manipulate karein. | `SELECT COUNT(*), ROUND(AVG(salary), 2), SUM(salary) FROM employees;` | **Challenge**: Sabhi customers ke liye registration date aur aaj ke beech elapsed days calculate karein. |
| **Day 5** | Grouping & Filtering Groups (`GROUP BY` & `HAVING`) | 3.0 hrs | Categories aur departments ke across metrics aggregate karein; `HAVING` se groups filter karein. | `SELECT department_id, COUNT(*), AVG(salary) FROM employees GROUP BY department_id HAVING COUNT(*) >= 2;` | **Challenge**: Orders ko `customer_id` ke according group karein aur total spend > $500 wale customers find karein. |
| **Day 6** | Relational Joins (`INNER JOIN`, `LEFT JOIN`, `Self JOIN`) | 3.5 hrs | `customers` ko `orders` se, `orders` ko `order_items` se, aur employees ko managers se join karein. | `SELECT c.first_name, o.order_id, o.total_amount FROM customers c JOIN orders o ON c.customer_id = o.customer_id;` | **Challenge**: Ek Anti-Join likhein jo un sabhi customers ko find kare jinhone kabhi order place nahi kiya. |
| **Day 7** | Basic Subqueries & Synthesis Capstone Project | 3.5 hrs | `WHERE` mein scalar subqueries use karein; Project 1 (Student Management System) complete karein. | `SELECT * FROM products WHERE unit_price > (SELECT AVG(unit_price) FROM products);` | **Challenge**: Customers, orders, line items, aur products ko join karne wali complete 4-table invoice report build karein. |

---

# 2. The 14-Day Practical Course

Application-layer queries aur analytical reports likhne wale software engineers aur data practitioners ke liye designed.

* **Day 1 — Architecture & DDL Foundations**: RDBMS concepts, table structures, `CREATE TABLE`, `DROP`, `TRUNCATE`. (2 hrs)
* **Day 2 — Data Types & Storage**: `INT`, `VARCHAR`, `DECIMAL`, `DATETIME`, `TIMESTAMP`, aur `ENUM` ki detailed understanding. (2 hrs)
* **Day 3 — Integrity Constraints**: `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, aur `CHECK` implement karna. (2.5 hrs)
* **Day 4 — CRUD Operations**: Safe update modes ke saath `INSERT` (bulk & explicit), `UPDATE`, aur `DELETE` master karna. (2.5 hrs)
* **Day 5 — Advanced Filtering**: Three-valued logic (`3VL`), `IS NULL`, `BETWEEN`, `IN`, `LIKE`, aur regular expressions (`REGEXP`). (2.5 hrs)
* **Day 6 — Result Organization**: Multi-column `ORDER BY`, sorting mein nulls handle karna, `LIMIT` & `OFFSET`. (2 hrs)
* **Day 7 — Comprehensive Functions (Part 1)**: String functions (`CONCAT_WS`, `SUBSTRING`, `REPLACE`, `CHAR_LENGTH`). (2.5 hrs)
* **Day 8 — Comprehensive Functions (Part 2)**: Date arithmetic (`DATEDIFF`, `TIMESTAMPDIFF`, `DATE_ADD`, `DATE_FORMAT`). (2.5 hrs)
* **Day 9 — Grouping & Aggregation**: `GROUP BY`, `HAVING`, `GROUP_CONCAT`, `ONLY_FULL_GROUP_BY` errors avoid karna. (3 hrs)
* **Day 10 — Relational Joins In-Depth**: `INNER`, `LEFT`, `RIGHT`, `CROSS`, aur Anti-Joins. (3.5 hrs)
* **Day 11 — Set Operations**: `UNION` vs `UNION ALL`, schema compatibility rules, compound ordering. (2 hrs)
* **Day 12 — Subqueries & Derived Tables**: Scalar subqueries, multi-row `IN`, aur `EXISTS` vs `NOT EXISTS`. (3 hrs)
* **Day 13 — Common Table Expressions (CTEs)**: Nested queries ko linear `WITH` pipelines mein transform karna. (3 hrs)
* **Day 14 — Practical Capstone**: Project 2 (Employee & Payroll System) aur Project 3 (Multi-Warehouse Inventory) complete karein. (4 hrs)

---

# 3. The 30-Day Professional Course

End-to-end database mastery seekhne wale full-stack developers, backend engineers, aur business intelligence analysts ke liye designed.

### Week 1: Schema Architecture & Data Ingestion (Days 1–7)
* **Day 1**: Relational Algebra, RDBMS Architecture & MySQL Client Installation.
* **Day 2**: DDL Statements: `CREATE`, `ALTER`, `DROP`, `RENAME`, `TRUNCATE`.
* **Day 3**: Physical Data Types: Fixed vs Floating Point (`DECIMAL` vs `FLOAT`), `VARCHAR` vs `CHAR`.
* **Day 4**: Constraints & Relational Integrity (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `DEFAULT`).
* **Day 5**: DML Operations: Multi-row `INSERT`, `ON DUPLICATE KEY UPDATE` (UPSERT), Safe `UPDATE`/`DELETE`.
* **Day 6**: Core Retrieval: `SELECT`, Column Aliases, Expressions, aur `DISTINCT`.
* **Day 7**: Weekly Review & Assessment: Section 1 aur Section 2 exercises solve karein (Problems 1–60).

### Week 2: Querying, Functions & Grouping (Days 8–14)
* **Day 8**: Advanced Filtering: Three-Valued Logic (`3VL`), `IS NULL`, `BETWEEN`, `IN`, `LIKE`, `REGEXP`.
* **Day 9**: Result Set Shaping: Deterministic `ORDER BY`, Nulls sorting emulation, `LIMIT ... OFFSET`.
* **Day 10**: Text Processing Functions: `CONCAT_WS`, `SUBSTRING`, `INSTR`, `TRIM`, `LPAD`, `CHAR_LENGTH`.
* **Day 11**: Temporal Processing: `NOW()`, `DATEDIFF`, `TIMESTAMPDIFF`, `DATE_ADD`, `DATE_FORMAT`.
* **Day 12**: Mathematical & Conditional Functions: `ROUND`, `TRUNCATE`, `MOD`, `COALESCE`, `NULLIF`, `CASE`.
* **Day 13**: Grouping & Summaries: Multi-column `GROUP BY`, `HAVING`, `WITH ROLLUP`, `GROUPING()`.
* **Day 14**: Mid-Course Milestone: Project 1 (Student Academy) aur Project 2 (Corporate HR) complete karein.

### Week 3: Relational Joins, Sets & Nested Queries (Days 15–21)
* **Day 15**: Relational Joins: `INNER JOIN`, `LEFT JOIN`, aur Multi-Table Join pipelines (3+ tables).
* **Day 16**: Advanced Joins: `Self JOIN` (hierarchies), Anti-Joins, aur `FULL OUTER JOIN` emulation.
* **Day 17**: Set Operations: `UNION` vs `UNION ALL`, compound limits aur ordering rules.
* **Day 18**: Subqueries: Scalar, Multi-Row (`IN`, `ALL`, `ANY`), aur `FROM` clause mein Table Derived Subqueries.
* **Day 19**: Correlated Subqueries & Short-Circuit `EXISTS` / `NOT EXISTS`.
* **Day 20**: Common Table Expressions (CTEs): Non-Recursive CTEs aur modular query design.
* **Day 21**: Weekly Review & Assessment: Section 5 aur Section 6 exercises solve karein (Problems 121–180).

### Week 4: Database Design, Views & Programmability (Days 22–30)
* **Day 22**: Database Design: Conceptual to Physical, ER Modeling, Crow's Foot Notation, Cardinalities.
* **Day 23**: Normalization Theory: Anomalies, Functional Dependencies, 1NF, 2NF, 3NF, BCNF.
* **Day 24**: Controlled Denormalization & OLAP Star Schema Dimensional Modeling.
* **Day 25**: Views: Security Data Masking, Updatable Views, `WITH CHECK OPTION`.
* **Day 26**: Stored Procedures: `DELIMITER`, `IN`/`OUT`/`INOUT`, `IF-THEN-ELSE`, error handlers.
* **Day 27**: Stored Functions: Deterministic UDFs, return values, comparison with procedures.
* **Day 28**: Triggers: `BEFORE`/`AFTER`, `NEW`/`OLD` images, audit logging, `SIGNAL SQLSTATE`.
* **Day 29**: Capstone Engineering: Project 4 (Enterprise E-Commerce Platform) complete karein.
* **Day 30**: Final Evaluation: 50 Intermediate Interview Questions complete karein (Questions 51–100).

---

# 4. The 60-Day Mastery Course

Engine mechanics, query optimization, aur high-concurrency systems ki deep internal knowledge require karne wale Senior Database Engineers, Tech Leads, aur Data Architects ke liye designed.

* **Days 1–15**: 30-Day roadmap ke Days 1–15 ki comprehensive coverage.
* **Days 16–30**: 30-Day roadmap ke Days 16–30 ki comprehensive coverage.
* **Days 31–34 — InnoDB Storage Engine Internals**:
  * Clustered Index B+ Tree mechanics, page structure (16KB pages), page splits, aur fragmentation.
  * Secondary index mechanics aur bookmark lookups.
  * Doublewrite buffer, adaptive hash indexes, aur Buffer Pool memory management.
* **Days 35–38 — Modern Analytics: Window Functions In-Depth**:
  * `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, aur `NTILE()`.
  * Value navigation: `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()`.
  * Window frames: `ROWS` vs `RANGE`, cumulative running totals, rolling moving averages.
* **Days 39–42 — Hierarchical Queries & Semi-Structured Data**:
  * Recursive CTEs: tree hierarchies, organizational charts, aur bill-of-materials graphs traverse karna.
  * Native JSON operations: path extraction (`->`, `->>`), `JSON_OBJECT`, `JSON_ARRAYAGG`.
  * Virtual Generated Columns aur JSON documents indexing.
* **Days 43–47 — Transactions, Isolation Levels & Concurrency**:
  * ACID properties aur physical enforcement (Undo Log vs Redo Log).
  * Concurrency phenomena: Dirty Reads, Non-Repeatable Reads, Phantom Reads.
  * Transaction isolation levels: `READ UNCOMMITTED` se `SERIALIZABLE` tak.
  * InnoDB mein Multi-Version Concurrency Control (MVCC).
* **Days 48–52 — Locking Mechanics & Deadlocks**:
  * Shared (S) vs Exclusive (X) locks, `SELECT ... FOR UPDATE`, `SELECT ... FOR SHARE`.
  * Record locks, Gap locks, aur Next-Key locking mechanics.
  * Deadlocks diagnose, simulate, aur mitigate karna (Error 1213); lock timeout tuning.
* **Days 53–56 — Performance Tuning & Query Optimization**:
  * Decoupling query execution: Cost-Based Optimizer (CBO), stats generation.
  * `EXPLAIN` aur `EXPLAIN ANALYZE`: iterator trees, actual time, loops, aur costs interpret karna.
  * SARGability principles: non-SARGable functions ko index-seekable filters mein convert karna.
  * Covering Indexes design karna (`Extra: Using index`) aur `Using filesort` eliminate karna.
* **Days 57–58 — Enterprise Security & Disaster Recovery**:
  * Role-Based Access Control (RBAC), host-based identities, `GRANT`/`REVOKE`.
  * SQL Injection anatomy aur prepared statements parameterized defense.
  * `mysqldump --single-transaction` ka use karke online logical backups.
* **Days 59–60 — Capstone Mastery**:
  * Project 5 build karein (Enterprise Sales Analytics Star Schema Data Mart).
  * 50 Advanced Interview Questions complete karein (Questions 101–150).
