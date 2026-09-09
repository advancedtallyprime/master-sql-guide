# Chapter 31 — Structured Learning Roadmaps: 7, 14, 30 & 60-Day Schedules

Four structured learning roadmaps designed for different timelines, career goals, and experience levels:
* **7-Day Crash Course**: Core querying, CRUD, and basic reporting.
* **14-Day Practical Course**: Developer-level SQL for backend engineers and data analysts.
* **30-Day Professional Course**: Comprehensive coverage including subqueries, CTEs, views, and normalization.
* **60-Day Mastery Course**: Database architecture, B-Tree internals, query optimization, concurrency, and enterprise security.

---

# 1. The 7-Day Intensive Crash Course

Designed for professionals needing immediate querying proficiency for interviews or workplace reporting.

| Day | Focus Topic | Study Time | Practice Tasks | Core Queries to Write | Revision & Mini-Challenge |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **Day 1** | RDBMS Fundamentals, Database Setup, `SELECT` & Column Aliasing | 2.5 hrs | Initialize `sql_mastery` schema; inspect table definitions via `DESCRIBE`. | `SELECT first_name, last_name, salary FROM employees;` | **Challenge**: Project each customer's full name and email with column aliases. |
| **Day 2** | Filtering Data (`WHERE`, Operators, `BETWEEN`, `IN`, `LIKE`) | 2.5 hrs | Practice filtering on numbers, dates, wildcards, and strings. | `SELECT * FROM products WHERE unit_price BETWEEN 100 AND 500 AND stock_quantity > 10;` | **Challenge**: Find all customers whose email ends in `.com` and whose state is NULL using `IS NULL`. |
| **Day 3** | Sorting, Pagination & Distinct Values (`ORDER BY`, `LIMIT`, `DISTINCT`) | 2.0 hrs | Practice multi-column sorting and offset-based pagination. | `SELECT DISTINCT country FROM customers ORDER BY country ASC LIMIT 5 OFFSET 2;` | **Challenge**: Retrieve the 3 highest-earning employees in Department 1. |
| **Day 4** | Essential Scalar & Aggregate Functions (`COUNT`, `SUM`, `AVG`, String & Date) | 3.0 hrs | Calculate payroll metrics; format dates and manipulate strings. | `SELECT COUNT(*), ROUND(AVG(salary), 2), SUM(salary) FROM employees;` | **Challenge**: Calculate the number of days elapsed between registration and today for all customers. |
| **Day 5** | Grouping & Filtering Groups (`GROUP BY` & `HAVING`) | 3.0 hrs | Aggregate metrics across categories and departments; filter groups with `HAVING`. | `SELECT department_id, COUNT(*), AVG(salary) FROM employees GROUP BY department_id HAVING COUNT(*) >= 2;` | **Challenge**: Group orders by `customer_id` and find customers with total spending > $500. |
| **Day 6** | Relational Joins (`INNER JOIN`, `LEFT JOIN`, `Self JOIN`) | 3.5 hrs | Join `customers` to `orders`, `orders` to `order_items`, and employees to managers. | `SELECT c.first_name, o.order_id, o.total_amount FROM customers c JOIN orders o ON c.customer_id = o.customer_id;` | **Challenge**: Write an Anti-Join finding all customers who have never placed an order. |
| **Day 7** | Basic Subqueries & Synthesis Capstone Project | 3.5 hrs | Use scalar subqueries in `WHERE`; complete Project 1 (Student Management System). | `SELECT * FROM products WHERE unit_price > (SELECT AVG(unit_price) FROM products);` | **Challenge**: Build the complete 4-table invoice report joining customers, orders, line items, and products. |

---

# 2. The 14-Day Practical Course

Designed for software engineers and data practitioners writing application-layer queries and analytical reports.

* **Day 1 — Architecture & DDL Foundations**: RDBMS concepts, table structures, `CREATE TABLE`, `DROP`, `TRUNCATE`. (2 hrs)
* **Day 2 — Data Types & Storage**: Exploring `INT`, `VARCHAR`, `DECIMAL`, `DATETIME`, `TIMESTAMP`, and `ENUM`. (2 hrs)
* **Day 3 — Integrity Constraints**: Implementing `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, and `CHECK`. (2.5 hrs)
* **Day 4 — CRUD Operations**: Mastering `INSERT` (bulk & explicit), `UPDATE`, and `DELETE` with safe update modes. (2.5 hrs)
* **Day 5 — Advanced Filtering**: Three-valued logic, `IS NULL`, `BETWEEN`, `IN`, `LIKE`, and regular expressions (`REGEXP`). (2.5 hrs)
* **Day 6 — Result Organization**: Multi-column `ORDER BY`, handling nulls in sorting, `LIMIT` & `OFFSET`. (2 hrs)
* **Day 7 — Comprehensive Functions (Part 1)**: String functions (`CONCAT_WS`, `SUBSTRING`, `REPLACE`, `CHAR_LENGTH`). (2.5 hrs)
* **Day 8 — Comprehensive Functions (Part 2)**: Date arithmetic (`DATEDIFF`, `TIMESTAMPDIFF`, `DATE_ADD`, `DATE_FORMAT`). (2.5 hrs)
* **Day 9 — Grouping & Aggregation**: `GROUP BY`, `HAVING`, `GROUP_CONCAT`, avoiding `ONLY_FULL_GROUP_BY` errors. (3 hrs)
* **Day 10 — Relational Joins In-Depth**: `INNER`, `LEFT`, `RIGHT`, `CROSS`, and Anti-Joins. (3.5 hrs)
* **Day 11 — Set Operations**: `UNION` vs `UNION ALL`, schema compatibility rules, compound ordering. (2 hrs)
* **Day 12 — Subqueries & Derived Tables**: Scalar subqueries, multi-row `IN`, and `EXISTS` vs `NOT EXISTS`. (3 hrs)
* **Day 13 — Common Table Expressions (CTEs)**: Transforming nested queries into linear `WITH` pipelines. (3 hrs)
* **Day 14 — Practical Capstone**: Complete Project 2 (Employee & Payroll System) and Project 3 (Multi-Warehouse Inventory). (4 hrs)

---

# 3. The 30-Day Professional Course

Designed for full-stack developers, backend engineers, and business intelligence analysts seeking end-to-end database mastery.

### Week 1: Schema Architecture & Data Ingestion (Days 1–7)
* **Day 1**: Relational Algebra, RDBMS Architecture & MySQL Client Installation.
* **Day 2**: DDL Statements: `CREATE`, `ALTER`, `DROP`, `RENAME`, `TRUNCATE`.
* **Day 3**: Physical Data Types: Fixed vs Floating Point (`DECIMAL` vs `FLOAT`), `VARCHAR` vs `CHAR`.
* **Day 4**: Constraints & Relational Integrity (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `DEFAULT`).
* **Day 5**: DML Operations: Multi-row `INSERT`, `ON DUPLICATE KEY UPDATE` (UPSERT), Safe `UPDATE`/`DELETE`.
* **Day 6**: Core Retrieval: `SELECT`, Column Aliases, Expressions, and `DISTINCT`.
* **Day 7**: Weekly Review & Assessment: Solve Section 1 and Section 2 exercises (Problems 1–60).

### Week 2: Querying, Functions & Grouping (Days 8–14)
* **Day 8**: Advanced Filtering: Three-Valued Logic (`3VL`), `IS NULL`, `BETWEEN`, `IN`, `LIKE`, `REGEXP`.
* **Day 9**: Result Set Shaping: Deterministic `ORDER BY`, Nulls sorting emulation, `LIMIT ... OFFSET`.
* **Day 10**: Text Processing Functions: `CONCAT_WS`, `SUBSTRING`, `INSTR`, `TRIM`, `LPAD`, `CHAR_LENGTH`.
* **Day 11**: Temporal Processing: `NOW()`, `DATEDIFF`, `TIMESTAMPDIFF`, `DATE_ADD`, `DATE_FORMAT`.
* **Day 12**: Mathematical & Conditional Functions: `ROUND`, `TRUNCATE`, `MOD`, `COALESCE`, `NULLIF`, `CASE`.
* **Day 13**: Grouping & Summaries: Multi-column `GROUP BY`, `HAVING`, `WITH ROLLUP`, `GROUPING()`.
* **Day 14**: Mid-Course Milestone: Complete Project 1 (Student Academy) and Project 2 (Corporate HR).

### Week 3: Relational Joins, Sets & Nested Queries (Days 15–21)
* **Day 15**: Relational Joins: `INNER JOIN`, `LEFT JOIN`, and Multi-Table Join pipelines (3+ tables).
* **Day 16**: Advanced Joins: `Self JOIN` (hierarchies), Anti-Joins, and emulating `FULL OUTER JOIN`.
* **Day 17**: Set Operations: `UNION` vs `UNION ALL`, compound limits and ordering rules.
* **Day 18**: Subqueries: Scalar, Multi-Row (`IN`, `ALL`, `ANY`), and Table Derived Subqueries in `FROM`.
* **Day 19**: Correlated Subqueries & Short-Circuit `EXISTS` / `NOT EXISTS`.
* **Day 20**: Common Table Expressions (CTEs): Non-Recursive CTEs and modular query design.
* **Day 21**: Weekly Review & Assessment: Solve Section 5 and Section 6 exercises (Problems 121–180).

### Week 4: Database Design, Views & Programmability (Days 22–30)
* **Day 22**: Database Design: Conceptual to Physical, ER Modeling, Crow's Foot Notation, Cardinalities.
* **Day 23**: Normalization Theory: Anomalies, Functional Dependencies, 1NF, 2NF, 3NF, BCNF.
* **Day 24**: Controlled Denormalization & OLAP Star Schema Dimensional Modeling.
* **Day 25**: Views: Security Data Masking, Updatable Views, `WITH CHECK OPTION`.
* **Day 26**: Stored Procedures: `DELIMITER`, `IN`/`OUT`/`INOUT`, `IF-THEN-ELSE`, error handlers.
* **Day 27**: Stored Functions: Deterministic UDFs, return values, comparison with procedures.
* **Day 28**: Triggers: `BEFORE`/`AFTER`, `NEW`/`OLD` images, audit logging, `SIGNAL SQLSTATE`.
* **Day 29**: Capstone Engineering: Complete Project 4 (Enterprise E-Commerce Platform).
* **Day 30**: Final Evaluation: Complete the 50 Intermediate Interview Questions (Questions 51–100).

---

# 4. The 60-Day Mastery Course

Designed for Senior Database Engineers, Tech Leads, and Data Architects requiring deep internal knowledge of engine mechanics, query optimization, and high-concurrency systems.

* **Days 1–15**: Comprehensive coverage of Days 1–15 from the 30-Day roadmap.
* **Days 16–30**: Comprehensive coverage of Days 16–30 from the 30-Day roadmap.
* **Days 31–34 — InnoDB Storage Engine Internals**:
  * Clustered Index B+ Tree mechanics, page structure (16KB pages), page splits, and fragmentation.
  * Secondary index mechanics and bookmark lookups.
  * Doublewrite buffer, adaptive hash indexes, and Buffer Pool memory management.
* **Days 35–38 — Modern Analytics: Window Functions In-Depth**:
  * `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, and `NTILE()`.
  * Value navigation: `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()`.
  * Window frames: `ROWS` vs `RANGE`, cumulative running totals, rolling moving averages.
* **Days 39–42 — Hierarchical Queries & Semi-Structured Data**:
  * Recursive CTEs: traversing tree hierarchies, organizational charts, and bill-of-materials graphs.
  * Native JSON operations: path extraction (`->`, `->>`), `JSON_OBJECT`, `JSON_ARRAYAGG`.
  * Virtual Generated Columns and indexing JSON documents.
* **Days 43–47 — Transactions, Isolation Levels & Concurrency**:
  * ACID properties and physical enforcement (Undo Log vs Redo Log).
  * Concurrency phenomena: Dirty Reads, Non-Repeatable Reads, Phantom Reads.
  * Transaction isolation levels: `READ UNCOMMITTED` to `SERIALIZABLE`.
  * Multi-Version Concurrency Control (MVCC) in InnoDB.
* **Days 48–52 — Locking Mechanics & Deadlocks**:
  * Shared (S) vs Exclusive (X) locks, `SELECT ... FOR UPDATE`, `SELECT ... FOR SHARE`.
  * Record locks, Gap locks, and Next-Key locking mechanics.
  * Diagnosing, simulating, and mitigating Deadlocks (Error 1213); lock timeout tuning.
* **Days 53–56 — Performance Tuning & Query Optimization**:
  * Decoupling query execution: Cost-Based Optimizer (CBO), stats generation.
  * `EXPLAIN` and `EXPLAIN ANALYZE`: interpreting iterator trees, actual time, loops, and costs.
  * SARGability principles: converting non-SARGable functions to index-seekable filters.
  * Designing Covering Indexes (`Extra: Using index`) and eliminating `Using filesort`.
* **Days 57–58 — Enterprise Security & Disaster Recovery**:
  * Role-Based Access Control (RBAC), host-based identities, `GRANT`/`REVOKE`.
  * SQL Injection anatomy and prepared statements parameterized defense.
  * Online logical backups using `mysqldump --single-transaction`.
* **Days 59–60 — Capstone Mastery**:
  * Build Project 5 (Enterprise Sales Analytics Star Schema Data Mart).
  * Complete the 50 Advanced Interview Questions (Questions 101–150).
