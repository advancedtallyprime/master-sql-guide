# Chapter 33 — The Master A–Z SQL & MySQL Reference Lexicon

An exhaustive alphabetical dictionary of SQL keywords, MySQL commands, built-in functions, operators, and relational database concepts.

---

### A
* **`ABS(X)`**: Built-in mathematical function that returns the absolute (positive) magnitude of $X$.
  ```sql
  SELECT ABS(-25.5); -- 25.5
  ```
* **`ACID`**: The four fundamental guarantees of a relational transaction: **A**tomicity, **C**onsistency, **I**solation, **D**urability.
* **`ACTION`**: Keyword used in referential integrity specifications (`ON DELETE NO ACTION`, `ON UPDATE CASCADE`).
* **`ADD COLUMN`**: Clause of `ALTER TABLE` used to add a new column to a table.
  ```sql
  ALTER TABLE employees ADD COLUMN middle_name VARCHAR(50);
  ```
* **`AFTER`**:
  1. Positional modifier in `ALTER TABLE ... ADD COLUMN col INT AFTER existing_col;`.
  2. Timing specifier for database triggers (`CREATE TRIGGER trg AFTER INSERT ...`).
* **`ALL`**:
  1. Set operator modifier in `UNION ALL` that preserves duplicate rows.
  2. Subquery comparison quantifier (`WHERE salary > ALL (SELECT salary FROM ...)`).
* **`ALTER DATABASE`**: Modifies characteristics of an existing database (such as default character set and collation).
* **`ALTER TABLE`**: DDL statement used to add, modify, rename, or drop table columns, indexes, and constraints.
* **`ALTER VIEW`**: Modifies the query definition of an existing view without dropping it.
* **`AND`**: Logical operator returning `TRUE` if both boolean conditions evaluate to `TRUE`. Has higher precedence than `OR`.
* **`ANY`**: Subquery comparison operator returning `TRUE` if the comparison is satisfied for at least one row returned by the subquery.
* **`AS`**: Keyword used to define column aliases (`SELECT salary AS base_pay`) or table aliases (`FROM customers AS c`).
* **`ASC`**: Sort order specifier in `ORDER BY` indicating ascending sequence (smallest to largest). This is the default.
* **`AUTO_INCREMENT`**: Column attribute in MySQL that automatically generates sequential integer identifiers for new rows.
* **`AVG(X)`**: Aggregate function returning the arithmetic mean of non-null values of $X$.

---

### B
* **`BCNF` (Boyce-Codd Normal Form)**: Advanced normal form where for every functional dependency $X \rightarrow Y$, $X$ must be a Super Key.
* **`BEFORE`**: Timing specifier for triggers (`CREATE TRIGGER trg BEFORE INSERT ...`), useful for data validation and modifying incoming `NEW` row values.
* **`BEGIN`**: Shorthand for starting a transaction block (`BEGIN;` or `START TRANSACTION;`), or enclosing procedural code (`BEGIN ... END`).
* **`BETWEEN`**: Range operator testing whether a value falls within an inclusive continuous range $[A, B]$.
  ```sql
  WHERE unit_price BETWEEN 10.00 AND 50.00
  ```
* **`BIGINT`**: 8-byte integer type covering values from $-9.22 \times 10^{18}$ to $+9.22 \times 10^{18}$ (or up to $1.84 \times 10^{19}$ if `UNSIGNED`).
* **`BINARY`**: Data type storing fixed-length raw byte strings without character set interpretation.
* **`BIT`**: Data type storing bit-field values (e.g., `BIT(8)`).
* **`BLOB`**: Binary Large Object data type used to store variable-length binary payloads (up to 64 KB for standard `BLOB`, up to 4 GB for `LONGBLOB`).
* **`BOOLEAN` / `BOOL`**: Synonyms for `TINYINT(1)` in MySQL. Zero (`0`) represents `FALSE`; non-zero (typically `1`) represents `TRUE`.
* **`B+ Tree`**: Balanced tree data structure used by MySQL InnoDB to store clustered and secondary indexes.

---

### C
* **`CALL`**: Statement used to execute a Stored Procedure.
  ```sql
  CALL sp_get_employee_payroll(101);
  ```
* **`CASCADE`**: Referential action in foreign keys (`ON DELETE CASCADE`, `ON UPDATE CASCADE`) that propagates deletions or updates to child rows.
* **`CASE`**: Multi-branch conditional expression returning values based on boolean evaluations.
  ```sql
  CASE WHEN points > 500 THEN 'Gold' ELSE 'Silver' END
  ```
* **`CAST()`**: Function that explicitly converts an expression from one data type to another (`CAST('2023-01-01' AS DATE)`).
* **`CEIL()` / `CEILING()`**: Returns the smallest integer greater than or equal to a number (rounds up).
* **`CHANGE COLUMN`**: Clause of `ALTER TABLE` used to rename a column and optionally alter its data type and attributes.
* **`CHAR()`**: Fixed-length character string type storing up to 255 characters, right-padded with spaces.
* **`CHAR_LENGTH()`**: Returns the number of characters in a string (UTF-8 character-aware).
* **`CHECK`**: Integrity constraint validating that row values satisfy a boolean expression (enforced in MySQL 8.0.16+).
* **`CLUSTERED INDEX`**: The primary physical B+ Tree index in InnoDB where leaf pages store the actual table row data.
* **`COALESCE()`**: Function returning the first non-NULL expression from an arbitrary argument list.
* **`COLLATE`**: Specifies the collation rules (case sensitivity, accent sensitivity) for character string comparison and sorting.
* **`COMMIT`**: TCL statement that permanently persists all modifications made during the active transaction to disk.
* **`CONCAT()`**: Function that joins multiple strings together into one. Returns `NULL` if any argument is `NULL`.
* **`CONCAT_WS()`**: Concatenate With Separator. Joins strings using a delimiter and skips `NULL` arguments.
* **`CONSTRAINT`**: Schema rule enforcing relational or domain validity (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`).
* **`COUNT()`**: Aggregate function returning the number of rows matching criteria (`COUNT(*)` vs `COUNT(col)`).
* **`CREATE`**: DDL statement used to instantiate databases, tables, views, indexes, procedures, functions, or triggers.
* **`CROSS JOIN`**: Join producing the Cartesian Product ($N \times M$) of two tables.
* **`CTE (Common Table Expression)`**: Temporary, named result set defined using the `WITH` clause.
* **`CURDATE()`**: Function returning the current date in `'YYYY-MM-DD'` format.
* **`CURRENT_TIMESTAMP()`**: Function returning the current date and time (synonym for `NOW()`).
* **`CURTIME()`**: Function returning the current time in `'HH:MM:SS'` format.

---

### D
* **`DATABASE()`**: Built-in function returning the name of the active default database.
* **`DATE`**: 3-byte temporal data type storing calendar dates from `'1000-01-01'` to `'9999-12-31'`.
* **`DATETIME`**: 5-byte temporal data type storing dates and times statically without timezone conversion.
* **`DATE_ADD()`**: Function adding a temporal interval to a date (`DATE_ADD(CURDATE(), INTERVAL 7 DAY)`).
* **`DATE_FORMAT()`**: Function formatting a date value according to a format string (`DATE_FORMAT(NOW(), '%Y-%m-%d')`).
* **`DATE_SUB()`**: Function subtracting a temporal interval from a date.
* **`DATEDIFF()`**: Function returning the difference in days between two dates (`d1 - d2`).
* **`DAY()` / `DAYOFMONTH()`**: Extracts the day of the month (1–31) from a date.
* **`DAYNAME()`**: Returns the name of the day of the week (e.g., `'Monday'`).
* **`DECIMAL(M, D)`**: Fixed-point numeric data type storing exact numerical values with $M$ total digits and $D$ decimal places. Mandatory for currency.
* **`DECLARE`**: Procedural keyword used in stored routines to define local variables, conditions, cursors, and error handlers.
* **`DEFAULT`**: Constraint specifying a fallback value for a column when an `INSERT` statement omits it.
* **`DELETE`**: DML statement used to remove existing rows from a table based on a filter condition.
* **`DELIMITER`**: Client utility command used to change the statement termination character when creating stored routines.
* **`DENSE_RANK()`**: Window function that assigns rank numbers to rows within a partition without skipping numbers on ties.
* **`DESC` / `DESCRIBE`**:
  1. Statement used to inspect table structural metadata (`DESC employees;`).
  2. Keyword in `ORDER BY` indicating descending sort order.
* **`DETERMINISTIC`**: Keyword declaring that a stored function will always return the exact same result for identical inputs.
* **`DISTINCT`**: Keyword used in `SELECT` to eliminate duplicate rows from query results.
* **`DROP`**: DDL statement permanently destroying databases, tables, views, indexes, or stored routines.

---

### E
* **`ENUM`**: String object with a value chosen from a static list of permitted values defined during table creation.
* **`eq_ref`**: High-performance join access type in `EXPLAIN` where exactly one row is read from a table for each row combination from the preceding table.
* **`EXISTS`**: Boolean operator testing for the existence of rows returned by a subquery.
* **`EXPLAIN`**: Statement that displays the execution plan chosen by the MySQL Cost-Based Optimizer.
* **`EXPLAIN ANALYZE`**: Profiling statement (MySQL 8.0.18+) that executes the query and reports actual runtime performance and iterator row counts.

---

### F
* **`FIRST`**: Positional keyword in `ALTER TABLE ... ADD COLUMN` placing the new column at the very beginning of the table.
* **`FIRST_VALUE()`**: Window function returning the first value within a window frame.
* **`FLOOR()`**: Mathematical function returning the largest integer less than or equal to a number (rounds down).
* **`FOREIGN KEY`**: Referential constraint binding a child table column to a parent table's primary key.
* **`FROM`**: SQL clause specifying the table(s) from which records are retrieved.
* **`FULLTEXT`**: Specialized index type used to perform natural language keyword searches on text columns.
* **`FUNCTION`**: A stored routine that accepts parameters and returns a single scalar value.

---

### G
* **`GRANT`**: DCL statement used to assign privileges or roles to database user accounts.
* **`GROUP BY`**: Clause that groups rows sharing identical values into summary buckets for aggregation.
* **`GROUP_CONCAT()`**: Aggregate function that concatenates non-null strings from each group into a single delimited string.
* **`GROUPING()`**: Function used with `WITH ROLLUP` that returns `1` for generated rollup summary NULLs and `0` for genuine data values.

---

### H
* **`HASH JOIN`**: Modern join algorithm in MySQL 8.0.18+ that joins tables lacking indexes using an in-memory hash table.
* **`HAVING`**: Clause used to filter aggregated summary groups after `GROUP BY` has executed.
* **`HOUR()`**: Function extracting the hour component (0–23) from a time or datetime value.

---

### I
* **`IF()`**: Inline conditional function: `IF(test_condition, true_value, false_value)`.
* **`IFNULL()`**: Function returning a fallback value if the target expression is `NULL`.
* **`IN`**: Operator testing whether a value matches any item within an enumerated list or subquery.
* **`INDEX`**: B+ Tree data structure designed to accelerate data retrieval speeds.
* **`INNER JOIN`**: Relational join returning only rows that have matching values in both tables.
* **`INSERT`**: DML statement used to insert new records into a table.
* **`INSTR()`**: Function returning the 1-based position of the first occurrence of a substring in a string.
* **`INT` / `INTEGER`**: 4-byte integer type storing numbers from $-2.14 \times 10^9$ to $+2.14 \times 10^9$ (up to $4.29 \times 10^9$ if `UNSIGNED`).
* **`IS NULL` / `IS NOT NULL`**: Unary operators testing for the presence or absence of `NULL` markers.
* **`ISOLATION LEVEL`**: Defines the degree to which a transaction's operations are visible to other concurrent transactions (`READ COMMITTED`, `REPEATABLE READ`, etc.).

---

### J
* **`JOIN`**: Operation that combines columns from two or more tables based on a related column.
* **`JSON`**: Native data type storing semi-structured JSON documents with binary parsing and validation.
* **`JSON_EXTRACT()`**: Function extracting values from a JSON document using JSONPath (operator: `->`).
* **`JSON_UNQUOTE()`**: Function stripping quotes from a JSON string (operator: `->>`).

---

### K
* **`KEY`**: Synonym for `INDEX` in MySQL table creation syntax.
* **`Keyset Pagination`**: Pagination technique that filters on a unique indexed column (`WHERE id < last_id`) rather than using `OFFSET`.

---

### L
* **`LAG()`**: Window function that accesses data from a preceding row at a specified offset without a self-join.
* **`LAST_INSERT_ID()`**: Function returning the first automatically generated `AUTO_INCREMENT` value set by the most recent `INSERT` statement on the connection.
* **`LEAD()`**: Window function that accesses data from a subsequent row at a specified offset.
* **`LEFT()`**: Function returning the leftmost $N$ characters from a string.
* **`LEFT JOIN`**: Outer join returning all rows from the left table and matching rows from the right table.
* **`LENGTH()`**: Function returning string length in raw bytes.
* **`LIKE`**: Pattern-matching operator supporting wildcards (`%` and `_`).
* **`LIMIT`**: Clause constraining the maximum number of rows returned by a query.
* **`LOWER()` / `LCASE()`**: Function converting character strings to lowercase.
* **`LPAD()`**: Function left-padding a string with a specified character sequence to reach a target length.

---

### M
* **`MAX()`**: Aggregate function returning the highest non-null value in a column.
* **`MEDIUMINT`**: 3-byte integer type storing values from $-8,388,608$ to $+8,388,607$.
* **`MIN()`**: Aggregate function returning the lowest non-null value in a column.
* **`MINUTE()`**: Function extracting the minute component (0–59) from a time value.
* **`MOD()`**: Modulo operator/function returning the division remainder ($N \pmod M$).
* **`MODIFY COLUMN`**: Clause of `ALTER TABLE` altering column definitions in place without renaming.
* **`MONTH()`**: Function extracting the month component (1–12) from a date.
* **`MONTHNAME()`**: Function returning the full name of the month (e.g., `'August'`).
* **`MVCC` (Multi-Version Concurrency Control)**: Engine architecture allowing concurrent readers to access historical data snapshots via Undo logs without acquiring read locks.

---

### N
* **`NATURAL JOIN`**: Join that automatically matches all columns with identical names in both tables (discouraged in production).
* **`NOT`**: Logical operator reversing a boolean truth value.
* **`NOT NULL`**: Integrity constraint disallowing `NULL` values in a column.
* **`NOW()`**: Function returning the current timestamp at the moment query execution begins.
* **`NTILE()`**: Window function dividing a partition into $N$ equal-sized buckets.
* **`NULL`**: Marker indicating missing, unknown, or inapplicable data.
* **`NULLIF(A, B)`**: Function returning `NULL` if $A = B$; otherwise returns $A$.

---

### O
* **`ON`**: Clause specifying the relational condition used to link tables in a `JOIN`.
* **`ON DELETE`**: Specifies referential actions (`CASCADE`, `RESTRICT`, `SET NULL`) when a referenced parent row is deleted.
* **`ON UPDATE`**: Specifies referential actions when a referenced parent key is modified.
* **`OR`**: Logical operator returning `TRUE` if either condition evaluates to `TRUE`.
* **`ORDER BY`**: Clause sorting output rows in ascending or descending sequence.
* **`OUT`**: Parameter mode in stored procedures returning computed values back to the calling client.
* **`OVER()`**: Clause defining the analytical window (partitioning, ordering, frames) for Window Functions.

---

### P
* **`PARTITION BY`**: Clause dividing rows into distinct processing buckets within a Window Function.
* **`POW()` / `POWER()`**: Mathematical function raising a base number to a specified exponent ($X^Y$).
* **`PRIMARY KEY`**: Column(s) uniquely identifying each row in a table; defines the clustered index in InnoDB.
* **`PROCEDURE`**: Pre-compiled database routine executed via `CALL`.

---

### R
* **`RANK()`**: Window function assigning rank numbers to rows, producing identical ranks for ties with subsequent gaps.
* **`READ COMMITTED`**: Transaction isolation level preventing Dirty Reads, but permitting Non-Repeatable and Phantom Reads.
* **`REDO LOG`**: Write-Ahead Log (WAL) file guaranteeing transaction Durability during system recovery.
* **`REFERENCES`**: Keyword defining the parent table and column in a `FOREIGN KEY` constraint.
* **`REGEXP` / `RLIKE`**: Pattern-matching operator supporting regular expressions.
* **`RENAME TABLE`**: DDL statement that renames one or more database tables.
* **`REPEATABLE READ`**: Default MySQL transaction isolation level; prevents Dirty, Non-Repeatable, and Phantom reads.
* **`REPLACE()`**: Function replacing all occurrences of a substring within a string.
* **`RESTRICT`**: Referential action preventing parent deletion or modification if dependent child records exist.
* **`REVOKE`**: DCL statement removing privileges or roles from database accounts.
* **`RIGHT()`**: Function returning the rightmost $N$ characters of a string.
* **`RIGHT JOIN`**: Outer join returning all rows from the right table and matching rows from the left table.
* **`ROLLBACK`**: TCL statement undoing all uncommitted modifications made during the active transaction.
* **`ROUND()`**: Function rounding a numeric value to a specified number of decimal places.
* **`ROW_NUMBER()`**: Window function assigning strict sequential integers ($1, 2, 3, \dots$) to rows within a partition.

---

### S
* **`SARGable`**: Search Argument Able. Query predicates capable of utilizing B+ Tree index seeks.
* **`SAVEPOINT`**: Marker within a transaction enabling partial rollback.
* **`SELECT`**: Core DQL statement retrieving records from tables.
* **`SET`**:
  1. Clause in `UPDATE` assigning new values to columns.
  2. DDL data type storing multiple string choices from a static list.
* **`SIGNAL`**: Statement raising custom runtime exceptions and error messages inside stored routines.
* **`SMALLINT`**: 2-byte integer type storing values from $-32,768$ to $+32,767$.
* **`SQRT()`**: Mathematical function returning the square root of a number.
* **`START TRANSACTION`**: Statement explicitly beginning an atomic transaction block.
* **`SUBSTRING()` / `SUBSTR()`**: Extracts a portion of a string starting at a designated 1-based offset.
* **`SUM()`**: Aggregate function returning the cumulative sum of non-null values.

---

### T
* **`TEXT`**: Data type storing large character strings (up to 64 KB for standard `TEXT`, up to 4 GB for `LONGTEXT`).
* **`TIME`**: 3-byte temporal data type storing time-of-day or elapsed durations (`'-838:59:59'` to `'838:59:59'`).
* **`TIMESTAMP`**: 4-byte temporal data type converted to/from UTC; subject to the Year 2038 boundary.
* **`TIMESTAMPDIFF()`**: Function calculating the elapsed difference between two dates in specified units (years, months, days, etc.).
* **`TINYINT`**: 1-byte integer type storing values from $-128$ to $+127$ (or 0 to 255 if `UNSIGNED`).
* **`TRIGGER`**: Program that executes automatically upon an `INSERT`, `UPDATE`, or `DELETE` event.
* **`TRIM()`**: Function removing leading and trailing whitespace from strings.
* **`TRUNCATE TABLE`**: DDL statement deallocating all table data pages and resetting auto-increment counters.

---

### U
* **`UCASE()` / `UPPER()`**: Converts strings to uppercase.
* **`UNDO LOG`**: InnoDB storage area maintaining pre-modification row versions to support transaction rollback and MVCC.
* **`UNION`**: Set operator combining results of multiple queries with deduplication.
* **`UNION ALL`**: Set operator combining results of multiple queries without deduplication.
* **`UNIQUE`**: Constraint enforcing distinct values across all non-null rows in a column or column group.
* **`UNSIGNED`**: Numeric attribute disallowing negative numbers and doubling the positive storage range.
* **`UPDATE`**: DML statement modifying existing column values in a table.
* **`USE`**: Statement setting the active database schema context.

---

### V
* **`VALUES`**: Clause in `INSERT` specifying the row data to be inserted.
* **`VARCHAR()`**: Variable-length character string storing up to 65,535 bytes with a 1- or 2-byte length prefix.
* **`VIEW`**: Virtual table defined by a stored SQL query.

---

### W
* **`WHERE`**: Clause filtering rows before grouping or aggregation.
* **`WINDOW`**: Clause defining named window specifications for reuse across multiple window functions.
* **`WITH`**: Clause defining Common Table Expressions (CTEs).
* **`WITH CHECK OPTION`**: Constraint on views preventing inserts or updates that violate the view's `WHERE` filter.
* **`WITH ROLLUP`**: Modifier for `GROUP BY` generating multi-level subtotals and grand totals.

---

### X
* **`XOR`**: Logical operator returning `TRUE` if exactly one of two conditions is `TRUE`.

---

### Y
* **`YEAR`**: 1-byte temporal data type storing 4-digit calendar years (`1901` to `2155`).
* **`YEAR()`**: Function extracting the 4-digit year integer from a date.
