# Chapter 29 — Technical Interview Mastery: 150 Curated Questions & Answers

This chapter provides **150 production-grade SQL and MySQL interview questions** structured across three professional competency tiers:
* **Tier 1: Beginner Questions (1–50)** — Relational Fundamentals, CRUD, Basic Filtering, and Core Functions.
* **Tier 2: Intermediate Questions (51–100)** — Joins, Subqueries, GROUP BY/HAVING, Indexes, and Normalization.
* **Tier 3: Advanced Questions (101–150)** — Window Functions, CTEs, Transactions, Locking, MVCC, and Query Optimization.

---

## Tier 1: Beginner SQL Interview Questions (1–50)

### 1. What is a Relational Database Management System (RDBMS)?
**Answer**: An RDBMS is a database system based on Edgar F. Codd's relational model. It organizes data into mathematically defined tables (relations) composed of rows (tuples) and columns (attributes). Data relationships are enforced through shared keys, and operations adhere to ACID properties. Examples include MySQL, PostgreSQL, and Oracle.

### 2. What are the primary differences between SQL and NoSQL databases?
**Answer**: SQL databases are relational, table-based, enforce strict predefined schemas, scale vertically, and prioritize ACID consistency. NoSQL databases are non-relational, document/key-value/graph-based, dynamic or schema-less, scale horizontally across clusters, and prioritize eventual consistency (BASE model).

### 3. What are the five sub-languages of SQL?
**Answer**:
1. **DDL (Data Definition Language)**: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`.
2. **DQL (Data Query Language)**: `SELECT`.
3. **DML (Data Manipulation Language)**: `INSERT`, `UPDATE`, `DELETE`.
4. **DCL (Data Control Language)**: `GRANT`, `REVOKE`.
5. **TCL (Transaction Control Language)**: `COMMIT`, `ROLLBACK`, `SAVEPOINT`.

### 4. What is the difference between `CHAR` and `VARCHAR`?
**Answer**: `CHAR(M)` is fixed-length, right-padding values with spaces to length $M$. `VARCHAR(M)` is variable-length, storing only the actual characters plus a 1- or 2-byte length prefix.

### 5. What does `NULL` represent in SQL, and how is it evaluated in comparisons?
**Answer**: `NULL` represents missing, unknown, or inapplicable data. In three-valued logic (3VL), comparing anything to `NULL` (e.g., `col = NULL` or `NULL = NULL`) yields `UNKNOWN`. Nullability must be tested using `IS NULL` or `IS NOT NULL`.

### 6. What is a Primary Key?
**Answer**: A column (or set of columns) that uniquely identifies each row in a table. A primary key implicitly enforces both `UNIQUE` and `NOT NULL` constraints, and in MySQL InnoDB, physically organizes the table's clustered index.

### 7. Can a table have multiple Primary Keys?
**Answer**: No. A table can have only **one** Primary Key. However, that primary key can be a **Composite Primary Key** composed of multiple columns.

### 8. What is the difference between a Primary Key and a Unique Key?
**Answer**: A table can have only one Primary Key, which strictly forbids `NULL` values. A table can have multiple Unique Keys, and in MySQL, Unique Keys permit multiple `NULL` values (unless also marked `NOT NULL`).

### 9. What is a Foreign Key?
**Answer**: A column in a child table that references the primary key of a parent table, establishing a relational link and enforcing referential integrity.

### 10. What is the difference between `TRUNCATE` and `DELETE`?
**Answer**: `DELETE` is a DML command that deletes rows one-by-one, logs each deletion to the transaction log, fires row-level triggers, and can be rolled back. `TRUNCATE` is a DDL command that deallocates data pages directly, resets auto-increment counters, bypasses triggers, and executes significantly faster.

### 11. What is the difference between `DROP TABLE` and `TRUNCATE TABLE`?
**Answer**: `TRUNCATE TABLE` purges all data rows from the table while preserving the table schema, columns, and constraints. `DROP TABLE` destroys the table schema, constraints, indexes, and physical files permanently.

### 12. How does the `AUTO_INCREMENT` attribute work in MySQL?
**Answer**: It automatically generates a unique, sequential integer identifier for newly inserted rows when the column value is omitted or passed as `NULL`.

### 13. What is the purpose of the `DEFAULT` constraint?
**Answer**: It supplies an automatic fallback value for a column if an `INSERT` statement does not explicitly provide a value.

### 14. What does the `CHECK` constraint do in MySQL 8.0?
**Answer**: It evaluates a boolean expression on inserted or updated row values, rejecting the transaction if the expression evaluates to `FALSE` (e.g., `CHECK (salary > 0)`).

### 15. What is the difference between `COUNT(*)` and `COUNT(column)`?
**Answer**: `COUNT(*)` counts all physical rows in the result set regardless of nullability. `COUNT(column)` counts only rows where the specified column contains a non-NULL value.

### 16. How do `AND` and `OR` operators differ in logical precedence?
**Answer**: `AND` has higher precedence than `OR`. In an unparenthesized expression `A OR B AND C`, the engine evaluates `(B AND C)` first.

### 17. What is the purpose of the `DISTINCT` keyword?
**Answer**: It removes duplicate rows from the projected result set, returning only unique combinations of values.

### 18. How does the `BETWEEN` operator behave with boundary values?
**Answer**: In SQL, `BETWEEN val1 AND val2` is strictly **inclusive** of both boundary values (equivalent to `col >= val1 AND col <= val2`).

### 19. What wildcards are supported by the `LIKE` operator?
**Answer**: The percent sign (`%`) matches zero or more arbitrary characters; the underscore (`_`) matches exactly one character.

### 20. What is the difference between `NOW()` and `CURDATE()`?
**Answer**: `NOW()` returns both the current date and time (`YYYY-MM-DD HH:MM:SS`). `CURDATE()` returns only the current date (`YYYY-MM-DD`).

### 21. What does the `COALESCE()` function do?
**Answer**: It evaluates a list of arguments from left to right and returns the very first non-NULL value.

### 22. What is the difference between `COALESCE()` and `IFNULL()`?
**Answer**: `IFNULL(a, b)` is proprietary to MySQL and accepts only two arguments. `COALESCE(...)` is standard ANSI SQL and accepts an arbitrary number of arguments.

### 23. How does `CONCAT_WS()` differ from `CONCAT()`?
**Answer**: `CONCAT()` returns `NULL` if any argument is `NULL`. `CONCAT_WS()` (Concatenate With Separator) uses the first argument as a delimiter and skips `NULL` values cleanly.

### 24. What is the difference between `LENGTH()` and `CHAR_LENGTH()` in MySQL?
**Answer**: `LENGTH()` measures string size in **bytes**, while `CHAR_LENGTH()` measures the number of **characters** (which matters for multi-byte UTF-8 encodings).

### 25. What does the `LIMIT` clause do in MySQL?
**Answer**: It restricts the maximum number of rows returned by a query, commonly used for pagination (e.g., `LIMIT 10 OFFSET 20`).

### 26. How do you sort results in descending order?
**Answer**: By appending the `DESC` keyword to the column in the `ORDER BY` clause (e.g., `ORDER BY salary DESC`).

### 27. What is an alias, and what keyword defines it?
**Answer**: An alias is a temporary label assigned to a table or column to improve readability, defined using the `AS` keyword (e.g., `SELECT salary AS base_pay`).

### 28. What is the purpose of the `USE` statement?
**Answer**: It establishes the active database schema context for the current client connection.

### 29. How do you add a column to an existing table?
**Answer**: Using `ALTER TABLE table_name ADD COLUMN column_name data_type;`.

### 30. How do you modify a column's data type without renaming it?
**Answer**: Using `ALTER TABLE table_name MODIFY COLUMN column_name new_data_type;`.

### 31. What is the difference between `ALTER TABLE ... MODIFY` and `ALTER TABLE ... CHANGE`?
**Answer**: `MODIFY` changes attributes or data types in place. `CHANGE` requires providing the old name and new name, allowing simultaneous column renaming.

### 32. What is the consequence of executing `UPDATE` without a `WHERE` clause?
**Answer**: Every single row in the table is updated with the specified values.

### 33. What is MySQL's `sql_safe_updates` mode?
**Answer**: A safety setting that prevents executing `UPDATE` or `DELETE` statements that lack a `WHERE` clause referencing a key column or an explicit `LIMIT`.

### 34. What is the purpose of `INSERT INTO ... SELECT`?
**Answer**: It copies data from one table directly into another existing table in a single statement.

### 35. How does `INSERT IGNORE` behave when encountering duplicate keys?
**Answer**: It silently skips rows that violate primary key or unique constraints without raising an error or aborting the batch.

### 36. What is an UPSERT, and how is it implemented in MySQL?
**Answer**: An operation that inserts a row if it is new, or updates it if a duplicate key already exists, implemented via `INSERT ... ON DUPLICATE KEY UPDATE`.

### 37. What is the difference between `UNION` and `UNION ALL`?
**Answer**: `UNION` eliminates duplicate rows between query results (involving sorting overhead); `UNION ALL` preserves all rows including duplicates.

### 38. What rules govern columns combined via `UNION`?
**Answer**: All participating queries must project the exact same number of columns, with compatible data types in corresponding positions.

### 39. What is a Scalar Function?
**Answer**: A function that operates on individual row inputs and returns a single scalar value per row (e.g., `ROUND()`, `UPPER()`).

### 40. What is an Aggregate Function?
**Answer**: A function that operates across multiple rows and returns a single consolidated value (e.g., `SUM()`, `AVG()`).

### 41. How do aggregate functions treat `NULL` values?
**Answer**: All aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) ignore `NULL` values. The only exception is `COUNT(*)`, which counts rows.

### 42. What is the purpose of the `GROUP BY` clause?
**Answer**: It collapses rows with matching values into summary buckets for calculating aggregate metrics.

### 43. What is the difference between `WHERE` and `HAVING`?
**Answer**: `WHERE` filters raw rows *before* aggregation; `HAVING` filters summary groups *after* aggregation.

### 44. Can you use column aliases defined in `SELECT` inside a `WHERE` clause?
**Answer**: No, because `WHERE` is processed by the engine before `SELECT`.

### 45. What is the purpose of `ORDER BY`?
**Answer**: It sorts the final result set deterministically in ascending (`ASC`) or descending (`DESC`) sequence.

### 46. What is the difference between `DATE`, `DATETIME`, and `TIMESTAMP`?
**Answer**: `DATE` stores only calendar dates (3 bytes). `DATETIME` stores date and time statically without timezone conversion (5 bytes). `TIMESTAMP` stores date and time converted to/from UTC (4 bytes, expires in 2038).

### 47. What does `DATEDIFF(date1, date2)` return?
**Answer**: The difference in days calculated as `date1 - date2`.

### 48. What is the purpose of the `EXISTS` operator?
**Answer**: It tests for the existence of rows in a subquery, returning `TRUE` as soon as the first matching row is found.

### 49. How do you comment code in SQL?
**Answer**: Single-line comments use `-- ` (with a trailing space) or `#`; multi-line comments use `/* ... */`.

### 50. How do you view existing databases on a MySQL server?
**Answer**: Using the command `SHOW DATABASES;`.

---

## Tier 2: Intermediate SQL Interview Questions (51–100)

### 51. Explain the operational difference between an `INNER JOIN` and a `LEFT JOIN`.
**Answer**: `INNER JOIN` returns only rows that have matching values in both tables. `LEFT JOIN` returns all rows from the left table, plus matched rows from the right table, populating `NULL` for right-table columns when no match exists.

### 52. What is a `RIGHT JOIN`, and why is it rarely used in practice?
**Answer**: `RIGHT JOIN` returns all rows from the right table and matching rows from the left. It is rarely used because any `RIGHT JOIN` can be rewritten more intuitively as a `LEFT JOIN` by switching table order.

### 53. What is an Anti-Join, and how do you write one?
**Answer**: An Anti-Join finds rows in one table that have no corresponding match in another table, written using `LEFT JOIN ... WHERE right_table.key IS NULL` or `WHERE NOT EXISTS (...)`.

### 54. What is a `CROSS JOIN`?
**Answer**: A join that produces the Cartesian Product of two tables, pairing every row in Table A with every row in Table B ($N \times M$ rows).

### 55. What is a Self JOIN, and when is it required?
**Answer**: A join where a table is joined to itself using two distinct aliases, required for hierarchical or recursive relationships (e.g., matching employees to their managers).

### 56. How do you emulate a `FULL OUTER JOIN` in MySQL?
**Answer**: By taking a `LEFT JOIN` and combining it with a `RIGHT JOIN` using the `UNION` set operator.

### 57. What is the difference between a Correlated and a Non-Correlated subquery?
**Answer**: A non-correlated subquery is independent and executes once. A correlated subquery references columns from the outer query and conceptually evaluates for every row processed by the outer query.

### 58. Why is `NOT EXISTS` safer than `NOT IN` with subqueries?
**Answer**: If a subquery returns even a single `NULL`, `NOT IN` evaluates to `UNKNOWN` for all rows and returns an empty result set. `NOT EXISTS` checks row existence and is not affected by `NULL` values.

### 59. What is a Common Table Expression (CTE)?
**Answer**: A temporary, named result set defined at the beginning of a query using the `WITH` clause that improves readability and can be referenced multiple times.

### 60. How does a Recursive CTE work?
**Answer**: It consists of an **Anchor Member** (base query), a `UNION ALL`, and a **Recursive Member** that references the CTE itself until a termination condition is met.

### 61. What is the `ONLY_FULL_GROUP_BY` SQL mode?
**Answer**: A standard SQL enforcement mode in MySQL that rejects queries where columns in `SELECT` are neither present in the `GROUP BY` clause nor wrapped in aggregate functions.

### 62. What does `WITH ROLLUP` do in a `GROUP BY` query?
**Answer**: It generates hierarchical subtotals and grand totals across grouping dimensions from right to left.

### 63. How do you distinguish between a genuine NULL and a ROLLUP summary NULL?
**Answer**: Using the `GROUPING(column)` function, which returns `1` for rollup summary NULLs and `0` for genuine data values.

### 64. What is Database Normalization?
**Answer**: The systematic process of structuring relational tables to minimize data redundancy and eliminate insertion, update, and deletion anomalies.

### 65. Define First Normal Form (1NF).
**Answer**: A table where all column values are atomic (no arrays or comma-separated lists), there are no repeating groups, and a primary key uniquely identifies each row.

### 66. Define Second Normal Form (2NF).
**Answer**: A table in 1NF that contains no **partial dependencies**—every non-key attribute depends on the entire composite primary key.

### 67. Define Third Normal Form (3NF).
**Answer**: A table in 2NF that contains no **transitive dependencies**—non-key attributes depend only on the primary key, not on other non-key attributes.

### 68. What is Boyce-Codd Normal Form (BCNF)?
**Answer**: A stricter version of 3NF where for every functional dependency $X \rightarrow Y$, the determinant $X$ must be a Super Key.

### 69. What is Denormalization, and when is it appropriate?
**Answer**: The intentional introduction of redundancy into a normalized schema to improve read performance and reduce join overhead in read-heavy analytics or data warehouses.

### 70. What is a View, and does it store data on disk?
**Answer**: A virtual table defined by a saved SQL query. In MySQL, standard views do not store physical data on disk; they execute dynamically against underlying base tables.

### 71. What makes a View updatable in MySQL?
**Answer**: A view is updatable if there is a direct 1:1 relationship between view rows and base table rows, and the view does not contain `GROUP BY`, `DISTINCT`, aggregates, or `UNION`.

### 72. What is the purpose of `WITH CHECK OPTION` on a View?
**Answer**: It prevents inserts or updates through the view that would produce rows that violate the view's own `WHERE` clause.

### 73. What is an Index, and how does it speed up queries?
**Answer**: A B+ Tree data structure that orders column values to enable fast $O(\log N)$ searches, avoiding full table scans.

### 74. What is a Clustered Index in InnoDB?
**Answer**: The primary B+ Tree index that stores the actual row data in its leaf nodes, defined by the table's Primary Key.

### 75. What is a Secondary Index in InnoDB?
**Answer**: A non-clustered index whose leaf nodes store the indexed key value and the corresponding row's Primary Key value.

### 76. What is a Bookmark Lookup?
**Answer**: When a query uses a secondary index to find a row, it retrieves the Primary Key and must perform a second lookup into the Clustered Index to retrieve the rest of the row's columns.

### 77. What is a Covering Index?
**Answer**: An index that contains all columns requested by a query, allowing MySQL to satisfy the query entirely from the index tree without a bookmark lookup (`Extra: Using index`).

### 78. What is the Leftmost Prefix Rule for composite indexes?
**Answer**: A composite index on `(A, B, C)` can only be used by queries that filter on `A`, `(A, B)`, or `(A, B, C)`. It cannot be used for queries filtering on `B` or `C` alone.

### 79. What is Index Cardinality?
**Answer**: The number of unique values in an index. High-cardinality columns (e.g., email) benefit greatly from indexing; low-cardinality columns (e.g., boolean flags) generally do not.

### 80. What are the performance costs of indexing?
**Answer**: Indexes consume disk space, take up memory in the Buffer Pool, and slow down `INSERT`, `UPDATE`, and `DELETE` operations because every index tree must be updated.

### 81. What is a Transaction?
**Answer**: A logical unit of work consisting of one or more SQL statements executed as an atomic, all-or-nothing operation.

### 82. What does Atomicity mean in ACID?
**Answer**: All statements in a transaction succeed and commit together, or all changes are rolled back on failure via the Undo Log.

### 83. What does Consistency mean in ACID?
**Answer**: A transaction can only transition the database between valid states that satisfy all schema rules and constraints.

### 84. What does Isolation mean in ACID?
**Answer**: Concurrent transactions execute independently without observing each other's intermediate, uncommitted states.

### 85. What does Durability mean in ACID?
**Answer**: Committed transactions are permanently written to disk via the Redo Log and survive system crashes or power failures.

### 86. What is a Dirty Read?
**Answer**: When Transaction A reads uncommitted modifications made by Transaction B that are later rolled back.

### 87. What is a Non-Repeatable Read?
**Answer**: When Transaction A reads a row, Transaction B updates that row and commits, and Transaction A re-reads the row to find different values.

### 88. What is a Phantom Read?
**Answer**: When Transaction A runs a range query, Transaction B inserts a new row matching that range and commits, and Transaction A re-runs the query to find a new row.

### 89. What is the default isolation level in MySQL?
**Answer**: `REPEATABLE READ`.

### 90. How does MySQL InnoDB prevent Phantom Reads in `REPEATABLE READ`?
**Answer**: Using consistent non-locking snapshot reads (MVCC) for regular queries, and Next-Key Locking (record locks combined with gap locks) for locking reads.

### 91. What is a Savepoint?
**Answer**: A designated marker within a transaction allowing partial rollbacks (`ROLLBACK TO SAVEPOINT`) without aborting the entire transaction.

### 92. Why cannot DDL statements be rolled back in MySQL?
**Answer**: DDL statements cause an **implicit commit** before and after execution, permanently saving prior DML changes.

### 93. What is a Stored Procedure?
**Answer**: A pre-compiled set of SQL statements and control-flow logic stored in the database and executed via `CALL`.

### 94. What is the difference between a Stored Procedure and a Stored Function?
**Answer**: A procedure is called via `CALL`, can return multiple result sets, and can manage transactions. A function is called inline within SQL expressions, must return exactly one scalar value, and cannot manage transactions.

### 95. What does the `DETERMINISTIC` keyword signify in a function?
**Answer**: It guarantees that the function will always return the exact same output for the same input arguments.

### 96. What is a Trigger?
**Answer**: A database program that executes automatically in response to an `INSERT`, `UPDATE`, or `DELETE` event on a specific table.

### 97. What is the difference between `NEW` and `OLD` in triggers?
**Answer**: `NEW` represents the incoming row values (available in `INSERT` and `UPDATE`). `OLD` represents the pre-modification values (available in `UPDATE` and `DELETE`).

### 98. Why can a trigger not modify its own triggering table?
**Answer**: To prevent infinite recursive execution loops (MySQL Error 1442).

### 99. How do you raise a custom error inside a trigger?
**Answer**: Using `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error description';`.

### 100. What is a Surrogate Key?
**Answer**: An artificial, system-generated identifier (e.g., `INT AUTO_INCREMENT`) with no business meaning, preferred over natural keys for primary key stability.

---

## Tier 3: Advanced SQL Interview Questions (101–150)

### 101. What is a Window Function, and how does it differ from `GROUP BY`?
**Answer**: A window function performs calculations across a set of rows related to the current row without collapsing the rows. Each row preserves its identity while displaying calculated window values.

### 102. What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`?
**Answer**: `ROW_NUMBER()` assigns sequential numbers without ties ($1, 2, 3$). `RANK()` assigns identical ranks to ties and skips subsequent numbers ($1, 2, 2, 4$). `DENSE_RANK()` assigns identical ranks to ties without skipping numbers ($1, 2, 2, 3$).

### 103. What are `LAG()` and `LEAD()` functions used for?
**Answer**: `LAG()` reads a value from a preceding row at a specified offset without a self-join; `LEAD()` reads a value from a subsequent row.

### 104. What is a Window Frame in SQL?
**Answer**: A subset of rows within a partition that defines the boundary of evaluation, specified using `ROWS` (physical row count) or `RANGE` (logical value range) `BETWEEN ... AND ...`.

### 105. Why can window functions not be used in a `WHERE` clause?
**Answer**: Because `WHERE` is evaluated during Step 2 of query processing, while window functions are calculated during the `SELECT` projection phase at Step 5.

### 106. What is the difference between `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` and `RANGE BETWEEN ...`?
**Answer**: `ROWS` treats tied rows individually by physical row position. `RANGE` treats all rows with identical sort values as a single collective set.

### 107. What does the `NTILE(n)` window function do?
**Answer**: It divides a partitioned result set into $n$ roughly equal buckets, assigning bucket numbers from 1 to $n$.

### 108. How do you query a JSON document in MySQL 8.0?
**Answer**: Using path extraction operators: `column->'$.path'` (returns quoted JSON) or `column->>'$.path'` (returns unquoted text).

### 109. How can you index a JSON attribute in MySQL?
**Answer**: By creating a **Virtual Generated Column** that extracts the JSON path and adding a standard B+ Tree index to that generated column.

### 110. What is SARGability, and why is it essential for query performance?
**Answer**: SARGable (*Search Argument Able*) describes query predicates that allow the optimizer to use an index seek rather than a full table scan.

### 111. Why does `WHERE YEAR(date_col) = 2023` destroy performance?
**Answer**: Wrapping the indexed column in a function prevents the engine from navigating the B+ Tree, forcing a full table scan to evaluate the function for every row.

### 112. How does implicit type conversion cause a full table scan?
**Answer**: If a `VARCHAR` column is compared to an integer (`WHERE string_col = 123`), MySQL converts the column to a number for every row, disabling index usage.

### 113. What is the difference between `EXPLAIN` and `EXPLAIN ANALYZE`?
**Answer**: `EXPLAIN` shows the static optimizer plan and cost estimates. `EXPLAIN ANALYZE` executes the query, measures actual execution time and row counts, and displays the iterator tree.

### 114. What does access type `ALL` indicate in an `EXPLAIN` report?
**Answer**: A full table scan; the engine reads every page of the table from disk or buffer pool.

### 115. What does access type `ref` indicate in an `EXPLAIN` report?
**Answer**: A non-unique index seek that matches multiple rows for an indexed value.

### 116. What does `Using filesort` mean in an `EXPLAIN` report?
**Answer**: MySQL could not satisfy the `ORDER BY` clause using an index and performed an explicit sorting pass in memory (`sort_buffer_size`) or on disk.

### 117. What is a Hash Join, and when does MySQL 8.0 use it?
**Answer**: An algorithm that builds an in-memory hash table of the smaller table and streams rows from the larger table against it, used for joins that lack indexes.

### 118. What is Multi-Version Concurrency Control (MVCC) in InnoDB?
**Answer**: A concurrency mechanism where readers do not lock rows. When a row is modified, InnoDB writes the old version to the Undo Log. Concurrent readers view a consistent historical snapshot based on transaction IDs.

### 119. What is a Next-Key Lock in InnoDB?
**Answer**: A combination of an index record lock on a specific row and a **Gap Lock** on the open space preceding that record, used in `REPEATABLE READ` to prevent phantom insertions.

### 120. What is a Deadlock in MySQL?
**Answer**: A circular dependency where Transaction 1 holds Lock A and waits for Lock B, while Transaction 2 holds Lock B and waits for Lock A.

### 121. How does MySQL detect and resolve deadlocks?
**Answer**: InnoDB's Deadlock Detector detects circular dependencies, selects the transaction with the smallest rollback cost, aborts it with Error 1213, and rolls it back, allowing the other transaction to proceed.

### 122. What is the difference between `SELECT ... FOR UPDATE` and `SELECT ... FOR SHARE`?
**Answer**: `FOR UPDATE` acquires an Exclusive Lock (X-lock), blocking other transactions from reading (`FOR UPDATE`) or modifying the rows. `FOR SHARE` acquires a Shared Lock (S-lock), allowing others to read but blocking modifications.

### 123. What is the Deep Paging problem with `LIMIT offset, count`?
**Answer**: For queries like `LIMIT 1000000, 20`, the engine must read and process 1,000,020 rows, discarding the first 1,000,000 to deliver 20 rows, wasting I/O and CPU.

### 124. How does Keyset Pagination (Cursor Pagination) solve Deep Paging?
**Answer**: Instead of using `OFFSET`, it filters using an indexed unique column from the last seen row (`WHERE id < last_id ORDER BY id DESC LIMIT 20`), executing via an instant index seek.

### 125. What is the InnoDB Buffer Pool, and how should it be sized?
**Answer**: The main in-memory cache where InnoDB caches data and index pages. On a dedicated database server, it should be allocated **70%–80% of total physical RAM**.

### 126. What is the Write-Ahead Log (WAL) protocol?
**Answer**: A reliability rule stating that modifications must be written to a persistent append-only log (Redo Log) on disk before data pages in memory are written to disk tablespace files.

### 127. What is the difference between the Redo Log and the Undo Log in InnoDB?
**Answer**: The **Redo Log** guarantees Durability (replays committed changes during crash recovery). The **Undo Log** guarantees Atomicity (reverts uncommitted changes during rollback) and supports MVCC snapshots.

### 128. What is SQL Injection (SQLi)?
**Answer**: A vulnerability where untrusted user input is concatenated into an SQL string, allowing an attacker to manipulate the query syntax tree and execute unauthorized commands.

### 129. Why are Prepared Statements the only true defense against SQL Injection?
**Answer**: Prepared statements compile the query template into a fixed syntax tree before receiving user input. The input parameters are bound as literal data values and cannot alter the query structure.

### 130. What is Role-Based Access Control (RBAC) in MySQL 8.0?
**Answer**: A security model where privileges are granted to named Roles, which are then assigned to user accounts, simplifying permission management.

### 131. How does `mysqldump --single-transaction` achieve non-blocking backups?
**Answer**: It sets the transaction isolation level to `REPEATABLE READ` and begins an explicit transaction, reading a consistent MVCC snapshot of InnoDB tables without locking them.

### 132. What is an Execution Plan?
**Answer**: The set of physical operations (index seeks, scans, joins, filters, sorts) chosen by the Cost-Based Optimizer to execute an SQL statement.

### 133. What is the difference between `ALGORITHM=MERGE` and `ALGORITHM=TEMPTABLE` in views?
**Answer**: `MERGE` merges the view's query with the outer user query into a single execution plan. `TEMPTABLE` materializes the view results into an internal temporary table before running the outer query.

### 134. What is a Clustered Index Page Split?
**Answer**: When a new row is inserted into a full index leaf page, InnoDB must allocate a new page and move half the rows to the new page. Random primary keys (like UUID v4) trigger frequent page splits and disk fragmentation.

### 135. Why are auto-increment integers preferred over random UUIDs for InnoDB Primary Keys?
**Answer**: Monotonically increasing integers append rows sequentially to the end of the clustered index B+ Tree, avoiding page splits, minimizing fragmentation, and consuming significantly less memory in secondary index leaf nodes.

### 136. What is Relational Division?
**Answer**: A relational operation that finds rows in Table A associated with **all** rows in Table B (e.g., finding customers who have purchased *every* product in a category).

### 137. How do you implement Relational Division in SQL?
**Answer**: Using `GROUP BY` and `HAVING COUNT(DISTINCT item) = (SELECT COUNT(*) FROM target_items)`.

### 138. What is a Star Schema in Data Warehousing?
**Answer**: A denormalized multidimensional schema consisting of a central **Fact Table** (containing numeric metrics) surrounded by denormalized **Dimension Tables** (containing descriptive attributes).

### 139. What is a Snowflake Schema?
**Answer**: A variation of a Star Schema where dimension tables are normalized into multiple related tables.

### 140. What is the purpose of `information_schema` in MySQL?
**Answer**: A read-only meta-database that provides access to database metadata, tables, columns, indexes, constraints, and privileges.

### 141. How can you detect unused indexes in MySQL?
**Answer**: By querying the `sys.schema_unused_indexes` view.

### 142. What is the difference between Optimistic and Pessimistic concurrency control?
**Answer**: **Pessimistic locking** locks rows explicitly (`FOR UPDATE`) assuming conflicts will happen. **Optimistic locking** does not lock rows on read; instead, it checks a version column on update, failing if another transaction modified the row in the interim.

### 143. What is a Composite Index, and how should columns be ordered?
**Answer**: An index on two or more columns. Columns should generally be ordered from highest selectivity (most distinct values) to lowest selectivity, matching `WHERE` equality filters first.

### 144. How does `GROUP_CONCAT` handle large strings in MySQL?
**Answer**: Output is truncated if it exceeds `@@group_concat_max_len` (default: 1024 bytes). To handle larger outputs, increase the session variable: `SET SESSION group_concat_max_len = 1000000;`.

### 145. What is the difference between `EXISTS` and `IN` for subqueries?
**Answer**: `EXISTS` short-circuits as soon as a match is found and handles `NULL` values safely. `IN` may materialize the subquery results into a temporary set and returns empty results if a `NULL` is present in `NOT IN`.

### 146. What does `SELECT ... FOR UPDATE SKIP LOCKED` do in MySQL 8.0?
**Answer**: It locks matching rows that are currently unlocked and skips any rows already locked by other transactions, ideal for implementing high-throughput job queues.

### 147. What is an Index Skip Scan in MySQL 8.0?
**Answer**: An optimization that allows MySQL to use a composite index `(A, B)` even if the query does not filter on the leading column `A`, by scanning each distinct value of `A` and performing an index seek on `B`.

### 148. What is the difference between a Table Lock and a Row Lock?
**Answer**: A Table Lock locks the entire table, blocking all other write access. A Row Lock (used by InnoDB) locks only the specific affected row, allowing concurrent transactions to read and write other rows in the same table.

### 149. What is a Lateral Derived Table (LATERAL Join) in MySQL 8.0?
**Answer**: A derived table in the `FROM` clause that can reference columns from preceding tables in the same `FROM` clause, similar to a correlated subquery in the `FROM` clause.

### 150. How do you design a database schema for zero-downtime migrations?
**Answer**: By adopting an **Expand-Contract (Parallel Run)** pattern:
1. *Expand*: Add the new column or table alongside the old one.
2. *Dual-Write*: Update application code to write to both old and new structures.
3. *Backfill*: Migrate historical data in background batches.
4. *Switch*: Update application reads to use the new structure.
5. *Contract*: Deprecate and drop the old structure.
