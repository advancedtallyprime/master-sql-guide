# Chapter 32 — High-Yield Rapid Revision Guide & Knowledge Checkpoints

A rapid-review study guide organized into modular checkpoints across the core SQL and MySQL domains. Use this chapter for last-minute interview preparation, pre-exam review, or quick refresher checks.

---

## Checkpoint 1: Database & Table Management (DDL)

### What You Should Know
* DDL commands (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`) manage schema structures and trigger **implicit transaction commits** in MySQL.
* `TRUNCATE` deallocates table pages and resets auto-increment sequences; `DELETE` removes rows one-by-one; `DROP` destroys the entire table schema and files.
* Always declare databases using `utf8mb4` encoding to support full multi-byte Unicode and emojis.

### What You Should Be Able to Write
```sql
CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(100) NOT NULL UNIQUE);
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;
ALTER TABLE users MODIFY COLUMN phone VARCHAR(30) NOT NULL;
ALTER TABLE users CHANGE COLUMN phone contact_phone VARCHAR(30) NOT NULL;
DROP TABLE IF EXISTS users;
```

### Common Failure Traps
* **Trap**: Attempting to rollback a `DROP TABLE` or `TRUNCATE` inside a transaction block (`ROLLBACK` has no effect on DDL).
* **Trap**: Confusing `MODIFY` (preserves name) with `CHANGE` (requires both old and new column names).

### 5-Question Checkpoint Quiz
1. *What happens to the AUTO_INCREMENT counter when a table is TRUNCATED vs when all rows are DELETED?* $\rightarrow$ Truncate resets it to 1; Delete preserves the current counter.
2. *Can a table have multiple primary keys?* $\rightarrow$ No, only one primary key (though it can be composite).
3. *Why is `utf8mb4` preferred over `utf8` in MySQL?* $\rightarrow$ The legacy `utf8` in MySQL only supports 3-byte characters, failing on emojis and 4-byte Unicode characters.
4. *How do you add a column at the very beginning of a table?* $\rightarrow$ Using the `FIRST` keyword: `ALTER TABLE t ADD COLUMN col INT FIRST;`.
5. *What error occurs if you try to drop a parent table referenced by an active foreign key?* $\rightarrow$ Error 3730: Cannot drop table referenced by a foreign key constraint.

### Practical Challenge
Write an idempotent DDL script that safely creates an `order_archive` table, adds an indexed `archived_at` timestamp, and drops a deprecated `notes` column if it exists.

---

## Checkpoint 2: Data Types & Integrity Constraints

### What You Should Know
* Use `DECIMAL(M, D)` for money/currency; never use `FLOAT` or `DOUBLE` due to IEEE 754 rounding drift.
* In InnoDB, the `PRIMARY KEY` defines the physical **clustered index**; compact integer keys (`INT UNSIGNED`) are preferred over wide, random UUID strings.
* `UNIQUE` constraints permit multiple `NULL` values in MySQL unless explicitly declared `NOT NULL`.
* `CHECK` constraints are fully enforced in MySQL 8.0.16+.

### What You Should Be Able to Write
```sql
CREATE TABLE accounts (
    account_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_number CHAR(10) NOT NULL UNIQUE,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_positive_balance CHECK (balance >= 0.00)
);
```

### Common Failure Traps
* **Trap**: Using `VARCHAR` for fixed-length strings like country codes (`CHAR(2)` is more efficient).
* **Trap**: Relying on 32-bit `TIMESTAMP` for dates beyond January 19, 2038 (use `DATETIME` instead).

### 5-Question Checkpoint Quiz
1. *What data type should you use to store precise monetary amounts?* $\rightarrow$ `DECIMAL(M, D)` or `NUMERIC(M, D)`.
2. *Does a column marked UNIQUE allow NULL values?* $\rightarrow$ Yes, multiple NULLs are permitted unless `NOT NULL` is also specified.
3. *What is the difference between `ON DELETE CASCADE` and `ON DELETE RESTRICT`?* $\rightarrow$ Cascade automatically deletes child rows; Restrict blocks parent row deletion if child rows exist.
4. *What MySQL type corresponds to a boolean?* $\rightarrow$ `TINYINT(1)`.
5. *Why should Primary Keys be marked `UNSIGNED`?* $\rightarrow$ Primary key counters never contain negative numbers, and `UNSIGNED` doubles the positive addressable range without consuming extra storage bytes.

### Practical Challenge
Construct a `transactions` table with foreign keys referencing `accounts`, enforcing that `amount > 0` via a named `CHECK` constraint and preventing duplicate transactions using a composite unique constraint on `(account_id, transaction_ref)`.

---

## Checkpoint 3: Filtering, Sorting & Functions

### What You Should Know
* SQL uses **Three-Valued Logic (3VL)**: `TRUE`, `FALSE`, `UNKNOWN`. Comparing anything to `NULL` yields `UNKNOWN`, which `WHERE` filters out. Always use `IS NULL`.
* `AND` has higher precedence than `OR`; always use parentheses to group logical expressions.
* `BETWEEN val1 AND val2` is inclusive of both boundary values.
* In MySQL, `NULL` sorts as the lowest possible value (first in `ASC`, last in `DESC`).
* All aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) ignore `NULL`s; only `COUNT(*)` counts physical rows.

### What You Should Be Able to Write
```sql
SELECT 
    CONCAT_WS(', ', last_name, first_name) AS full_name,
    COALESCE(phone, 'No Phone') AS contact_phone,
    ROUND(salary * 1.10, 2) AS projected_salary,
    DATE_FORMAT(hire_date, '%Y-%m-%d') AS formatted_hire_date
FROM employees
WHERE (department_id = 1 OR department_id = 2)
  AND salary >= 90000.00
  AND hire_date BETWEEN '2020-01-01' AND '2023-12-31'
ORDER BY salary DESC, last_name ASC
LIMIT 10 OFFSET 0;
```

### Common Failure Traps
* **Trap**: Writing `WHERE email = NULL` (returns empty set; must write `WHERE email IS NULL`).
* **Trap**: Writing `WHERE col NOT IN (1, 2, NULL)` (returns empty set because comparison against NULL produces UNKNOWN).
* **Trap**: Wrapping indexed columns in functions in the `WHERE` clause (e.g., `WHERE YEAR(date_col) = 2023` breaks SARGability and forces a full table scan).

### 5-Question Checkpoint Quiz
1. *What does `SELECT (NULL = NULL)` evaluate to?* $\rightarrow$ `NULL` (UNKNOWN).
2. *How do you write a NULL-Safe equality check in MySQL?* $\rightarrow$ Using `<=>` (e.g., `NULL <=> NULL` returns 1/TRUE).
3. *What is the difference between `LENGTH()` and `CHAR_LENGTH()`?* $\rightarrow$ `LENGTH()` counts bytes; `CHAR_LENGTH()` counts UTF-8 characters.
4. *How does `CONCAT()` behave if one of its arguments is `NULL`?* $\rightarrow$ It returns `NULL` for the entire string.
5. *How do you sort NULL values to appear last in an ascending sort in MySQL?* $\rightarrow$ `ORDER BY col IS NULL ASC, col ASC`.

### Practical Challenge
Write a query against `customers` that selects all customers whose last name begins with a vowel, formats their registration date into `'Month Day, Year'`, and computes their customer tier using a `CASE` statement.

---

## Checkpoint 4: Grouping, Aggregation & Relational Joins

### What You Should Know
* Logical execution order: `FROM` $\rightarrow$ `WHERE` $\rightarrow$ `GROUP BY` $\rightarrow$ `HAVING` $\rightarrow$ `SELECT` $\rightarrow$ `DISTINCT` $\rightarrow$ `ORDER BY` $\rightarrow$ `LIMIT`.
* `WHERE` filters rows *before* grouping; `HAVING` filters aggregated buckets *after* grouping.
* Under `ONLY_FULL_GROUP_BY`, every projected column must either appear in the `GROUP BY` clause or be wrapped inside an aggregate function.
* `INNER JOIN` returns matching rows; `LEFT JOIN` preserves all left-table rows; Anti-Join (`LEFT JOIN ... WHERE right.key IS NULL`) finds missing links.
* A `Self JOIN` joins a table to itself using two distinct aliases to model hierarchies.

### What You Should Be Able to Write
```sql
-- Aggregation with HAVING
SELECT department_id, COUNT(*) AS headcount, ROUND(AVG(salary), 2) AS avg_sal
FROM employees
WHERE is_active = TRUE
GROUP BY department_id
HAVING COUNT(*) >= 2 AND AVG(salary) > 80000;

-- Multi-table Join with Anti-Join
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

### Common Failure Traps
* **Trap**: Placing aggregate functions inside a `WHERE` clause (`WHERE AVG(salary) > 50000` is invalid syntax).
* **Trap**: Placing a filter on a right table in the `WHERE` clause of a `LEFT JOIN` (silently converts the `LEFT JOIN` into an `INNER JOIN`).
* **Trap**: Omitting join conditions, causing a Cartesian product (`CROSS JOIN`).

### 5-Question Checkpoint Quiz
1. *Why can you not use aggregate functions inside a WHERE clause?* $\rightarrow$ Because `WHERE` executes before groups and aggregates are formed.
2. *What is the difference between `UNION` and `UNION ALL`?* $\rightarrow$ `UNION` deduplicates rows (involves sorting); `UNION ALL` preserves all rows directly.
3. *What does `GROUP_CONCAT()` do?* $\rightarrow$ Concatenates non-null values from each group into a single string.
4. *How does a Self JOIN work?* $\rightarrow$ By joining a table to itself using two distinct table aliases.
5. *What SQL clause emulates a FULL OUTER JOIN in MySQL?* $\rightarrow$ Combining a `LEFT JOIN` and a `RIGHT JOIN` with `UNION`.

### Practical Challenge
Write a query calculating total revenue generated by each product category, displaying category name, total quantity sold, gross revenue, and average discount applied. Filter to include only categories that have generated over $1,000 in gross revenue.

---

## Checkpoint 5: Subqueries, Window Functions & CTEs

### What You Should Know
* Subqueries return scalar values (1x1), columns of values, or derived tables (which require an alias).
* Correlated subqueries reference outer query columns and evaluate per outer row.
* `EXISTS` is safer and faster than `IN` because it short-circuits on the first match and handles NULLs safely.
* Window functions compute calculations across related rows **without collapsing them**.
* The `OVER()` clause defines partitions (`PARTITION BY`), ordering (`ORDER BY`), and frames (`ROWS BETWEEN ...`).
* CTEs (`WITH ...`) make complex queries modular and support recursion (`WITH RECURSIVE`).

### What You Should Be Able to Write
```sql
-- CTE with Window Functions
WITH RankedOrders AS (
    SELECT 
        customer_id,
        order_id,
        order_date,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS recency_rank,
        SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_spend
    FROM orders
)
SELECT * FROM RankedOrders WHERE recency_rank = 1;
```

### Common Failure Traps
* **Trap**: Forgetting to alias a derived table in the `FROM` clause (`ERROR 1248: Every derived table must have its own alias`).
* **Trap**: Attempting to use a window function directly inside a `WHERE` clause (must wrap it in a CTE or subquery first).
* **Trap**: Confusing `RANK()` (skips numbers on ties) with `DENSE_RANK()` (no gaps on ties).

### 5-Question Checkpoint Quiz
1. *What is the difference between `ROW_NUMBER()` and `DENSE_RANK()`?* $\rightarrow$ `ROW_NUMBER()` never produces ties ($1, 2, 3$); `DENSE_RANK()` assigns the same rank to ties without skipping numbers ($1, 2, 2, 3$).
2. *What does `LAG(col, 1)` do?* $\rightarrow$ Accesses the value of `col` from the immediately preceding row.
3. *What are the two parts required in a Recursive CTE?* $\rightarrow$ The Anchor Member and the Recursive Member, combined with `UNION ALL`.
4. *Can a subquery returning multiple rows be used with the `=` operator?* $\rightarrow$ No, it triggers `ERROR 1242: Subquery returns more than 1 row`. Use `IN` or `ANY`.
5. *What operator extracts an unquoted string from a MySQL JSON column?* $\rightarrow$ The `->>` operator.

### Practical Challenge
Write a Recursive CTE that generates the first 10 numbers of the Fibonacci sequence in pure SQL.

---

## Checkpoint 6: Transactions, Concurrency & Locking

### What You Should Know
* ACID guarantees: **Atomicity** (Undo log), **Consistency** (schema invariants), **Isolation** (MVCC & locks), **Durability** (Redo log / WAL).
* MySQL's default isolation level is **`REPEATABLE READ`**, which prevents Dirty, Non-Repeatable, and Phantom reads.
* `SELECT ... FOR UPDATE` acquires an Exclusive Lock (X-lock), blocking other transactions from modifying or locking those rows.
* InnoDB automatically detects Deadlocks, aborts the transaction with the lowest rollback cost (Error 1213), and rolls it back.

### What You Should Be Able to Write
```sql
START TRANSACTION;

SELECT stock_quantity FROM products WHERE product_id = 1 FOR UPDATE;

UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
INSERT INTO orders (customer_id, order_date, total_amount) VALUES (1, CURDATE(), 1299.99);

COMMIT;
```

### Common Failure Traps
* **Trap**: Holding database transactions open while waiting for external third-party HTTP API responses (causes severe lock wait timeouts).
* **Trap**: Running a DDL statement (`ALTER TABLE`) inside a transaction, triggering an implicit commit and breaking atomicity.

### 5-Question Checkpoint Quiz
1. *What is a Dirty Read, and which isolation level allows it?* $\rightarrow$ Reading uncommitted data from another transaction that is later rolled back; permitted only in `READ UNCOMMITTED`.
2. *Which InnoDB log guarantees Durability during system crashes?* $\rightarrow$ The Redo Log.
3. *Which InnoDB log guarantees Atomicity during a rollback?* $\rightarrow$ The Undo Log.
4. *How do you release an exclusive row lock acquired via `SELECT ... FOR UPDATE`?* $\rightarrow$ By issuing `COMMIT` or `ROLLBACK`.
5. *How does MySQL handle deadlocks?* $\rightarrow$ The deadlock detector aborts the transaction with the smallest rollback cost with Error 1213 and rolls it back.

### Practical Challenge
Simulate a concurrent balance transfer between two bank accounts wrapped in a stored transaction, including savepoints and error rollback handlers.

---

## Checkpoint 7: Query Optimization & Security

### What You Should Know
* Use `EXPLAIN` and `EXPLAIN ANALYZE` to inspect execution plans. Eliminate access type `ALL` (full table scans) on large tables.
* A **Covering Index** contains all columns requested by a query, satisfying the query directly from the secondary index leaf nodes (`Extra: Using index`).
* The **Leftmost Prefix Rule**: an index on `(A, B, C)` can only be used if the query filters on `A` first.
* Always use **Prepared Statements (Parameterized Queries)** to defend against SQL Injection.
* Adhere to the **Principle of Least Privilege (PoLP)**; use MySQL 8.0 Roles for permission management.
* Size `innodb_buffer_pool_size` to **70%–80% of physical RAM** on dedicated database instances.

### What You Should Be Able to Write
```sql
-- SARGable Index Query
EXPLAIN ANALYZE
SELECT customer_id, order_date, total_amount
FROM orders
WHERE order_date >= '2023-08-01' AND order_date < '2023-09-01';

-- Role-Based Access Control
CREATE ROLE 'role_app_writer';
GRANT SELECT, INSERT, UPDATE ON sql_mastery.orders TO 'role_app_writer';
CREATE USER 'app_svc'@'10.0.1.%' IDENTIFIED BY 'Vault_Secret_2026!';
GRANT 'role_app_writer' TO 'app_svc'@'10.0.1.%';
SET DEFAULT ROLE ALL TO 'app_svc'@'10.0.1.%';
```

### Common Failure Traps
* **Trap**: Adding indexes to low-cardinality boolean columns (the optimizer ignores them and does a table scan anyway).
* **Trap**: Over-indexing tables (imposes severe write penalties on `INSERT`, `UPDATE`, and `DELETE`).
* **Trap**: Concatenating user inputs directly into SQL strings instead of using parameterized queries.

### 5-Question Checkpoint Quiz
1. *What does `Using filesort` mean in an EXPLAIN output?* $\rightarrow$ MySQL had to perform an explicit sorting pass in memory or on disk because an index could not provide the required order.
2. *What is a SARGable query predicate?* $\rightarrow$ A predicate that can utilize an index seek directly.
3. *Why are prepared statements immune to SQL injection?* $\rightarrow$ Because the query template is compiled into a fixed syntax tree before user parameters are bound, preventing parameters from altering the query structure.
4. *What command performs an online, non-blocking logical backup of InnoDB tables?* $\rightarrow$ `mysqldump --single-transaction`.
5. *Why should `SELECT *` be avoided in production application queries?* $\rightarrow$ It wastes network bandwidth, prevents covering index optimizations, and increases memory usage.

### Practical Challenge
Run `EXPLAIN ANALYZE` on a slow multi-table join query, identify the stage taking the longest execution time, and design a composite covering index that reduces execution time by over 75%.
