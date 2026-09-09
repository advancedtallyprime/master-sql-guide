# Chapter 01 — SQL & Relational Database Fundamentals

---

## 1. What is it?

A **database** is an organized, persistent repository of structured information designed for rapid search, retrieval, and concurrent modification. 

To understand modern databases, consider the contrast between informal data storage and a database management system:
* **The Spreadsheet / File Analogy**: In a spreadsheet (e.g., Excel) or file directory, a single user opens a workbook where rows represent records and columns represent attributes. However, when hundreds of users modify the file simultaneously, files become corrupted, duplicate entries proliferate, and data validation breaks down.
* **A Database Management System (DBMS)**: Software that acts as an intelligent intermediary between end users, client applications, and physical disk storage. It enforces consistency rules, manages multi-user concurrency, guarantees security permissions, and prevents system crashes from losing committed work.
* **A Relational Database Management System (RDBMS)**: A specialized DBMS based on the relational model introduced by E.F. Codd (1970). In an RDBMS, data is organized into mathematically defined two-dimensional **tables** (relations) composed of **rows** (tuples) and **columns** (attributes). Tables are linked together through shared values called **keys**. Popular RDBMS engines include **MySQL**, **PostgreSQL**, **Oracle Database**, and **Microsoft SQL Server**.

**Structured Query Language (SQL)** is the universal, declarative programming language standardized by ANSI and ISO used to interact with RDBMS engines. Unlike imperative programming languages (like Python, Java, or C++) where you specify *how* to execute a process step-by-step, SQL is declarative: you specify *what* data you require, and the RDBMS's internal **Query Optimizer** figures out the most efficient algorithmic path to retrieve or manipulate it.

SQL commands are classified into five fundamental sub-languages:
1. **DDL (Data Definition Language)**: Defines and alters schema structures (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`).
2. **DQL (Data Query Language)**: Reads and queries stored data (`SELECT`).
3. **DML (Data Manipulation Language)**: Modifies table records (`INSERT`, `UPDATE`, `DELETE`).
4. **DCL (Data Control Language)**: Manages permissions and security privileges (`GRANT`, `REVOKE`).
5. **TCL (Transaction Control Language)**: Manages transactional boundaries and state persistence (`COMMIT`, `ROLLBACK`, `SAVEPOINT`).

---

## 2. Why do we use it?

Relational databases and SQL form the backbone of global enterprise technology. We use them because:
1. **ACID Guarantees**: Relational engines guarantee transactional integrity: Atomicity (all-or-nothing), Consistency (rules never violated), Isolation (independent concurrent transactions), and Durability (committed transactions survive hardware failure).
2. **Elimination of Data Redundancy**: Through relational links (foreign keys) and normalization, customer addresses or department names are stored once rather than repeated across millions of order records.
3. **High-Performance Querying**: RDBMS engines employ sophisticated indexing algorithms (such as B+ Trees and Hash indexes) and Cost-Based Optimizers capable of querying millions of records in milliseconds.
4. **Declarative Simplicity & Standardization**: Learning SQL allows developers to query almost any database system across clouds, platforms, and data warehouses with minimal dialectal adjustment.
5. **Robust Concurrency & Security**: Thousands of transactions can write to separate rows simultaneously using row-level locking without blocking system-wide read traffic.

---

## 3. Syntax

### Client Connection & Database Context Syntax
```sql
-- Connect via MySQL CLI:
-- mysql -h <host> -P <port> -u <username> -p

-- Inspect existing databases on the server instance
SHOW DATABASES;

-- Select a database to establish the active session context
USE database_name;

-- Inspect tables residing inside the active database
SHOW TABLES;

-- Inspect structural definition of a specific table
DESCRIBE table_name;
-- Equivalent shorthand:
DESC table_name;
```

### Basic Query Architecture
```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition_is_true;
```

---

## 4. Basic Example

Inspecting the active environment and checking table definitions:

```sql
-- Switch to the practice database
USE sql_mastery;

-- Show all tables present in the database
SHOW TABLES;

-- Describe the structure of the departments table
DESCRIBE departments;
```

---

## 5. Real-World Example

In our `sql_mastery` database, let us verify the system architecture and examine the structural metadata of the `employees` table:

```sql
-- Establish session context
USE sql_mastery;

-- Display column definitions, types, nullability, keys, and defaults for employees
DESC employees;

-- Query basic workforce metadata to confirm connectivity
SELECT employee_id, first_name, last_name, salary, hire_date
FROM employees
WHERE salary > 100000.00;
```

---

## 6. Step-by-Step Explanation

1. `USE sql_mastery;`
   * Tells the MySQL server daemon that all subsequent unqualified table references (such as `employees`) should be resolved against the `sql_mastery` schema.
2. `DESC employees;`
   * The server queries the MySQL internal data dictionary (`information_schema.columns`) and displays the column names, physical storage types (`INT`, `VARCHAR`, `DECIMAL`), whether NULL values are permitted, primary/foreign key designations (`PRI`, `UNI`, `MUL`), default values, and attributes like `AUTO_INCREMENT`.
3. `SELECT employee_id, first_name, last_name, salary, hire_date FROM employees WHERE salary > 100000.00;`
   * **Parsing**: The SQL parser validates syntax and checks that the user has `SELECT` privileges on `employees`.
   * **Optimization**: The query optimizer evaluates whether to perform a full table scan or utilize an index on the `salary` column.
   * **Execution**: The storage engine (`InnoDB`) reads the relevant data pages into the Buffer Pool, filters records satisfying `salary > 100000.00`, projects the five specified columns, and streams the result set back to the client.

---

## 7. Expected Result

Output of `DESC employees;`:

```
+---------------+---------------+------+-----+-------------------+-------------------+
| Field         | Type          | Null | Key | Default           | Extra             |
+---------------+---------------+------+-----+-------------------+-------------------+
| employee_id   | int           | NO   | PRI | NULL              | auto_increment    |
| first_name    | varchar(50)   | NO   |     | NULL              |                   |
| last_name     | varchar(50)   | NO   |     | NULL              |                   |
| email         | varchar(100)  | NO   | UNI | NULL              |                   |
| phone         | varchar(20)   | YES  |     | NULL              |                   |
| hire_date     | date          | NO   |     | NULL              |                   |
| salary        | decimal(10,2) | NO   |     | NULL              |                   |
| department_id | int           | YES  | MUL | NULL              |                   |
| manager_id    | int           | YES  | MUL | NULL              |                   |
| is_active     | tinyint(1)    | YES  |     | 1                 |                   |
| created_at    | timestamp     | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+---------------+---------------+------+-----+-------------------+-------------------+
```

Output of the filtered `SELECT` query:

```
+-------------+------------+-----------+-----------+------------+
| employee_id | first_name | last_name | salary    | hire_date  |
+-------------+------------+-----------+-----------+------------+
|           1 | Alex       | Morgan    | 145000.00 | 2019-03-15 |
|           2 | Sarah      | Chen      | 125000.00 | 2020-06-01 |
|           4 | Priya      | Patel     | 135000.00 | 2020-02-10 |
|           6 | Elena      | Rostova   | 130000.00 | 2018-11-05 |
|           8 | Jessica    | Taylor    | 110000.00 | 2019-08-12 |
+-------------+------------+-----------+-----------+------------+
5 rows in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Forgetting the Semicolon (`;`)**:
   * *Mistake*: Typing `SELECT * FROM employees` in the terminal and pressing Enter. The MySQL prompt responds with `->` and appears frozen.
   * *Explanation*: The CLI expects statements to terminate with a delimiter (by default `;` or `\g`). Simply type `;` and hit Enter.
2. **Omitting the `USE` Command**:
   * *Mistake*: Opening a fresh terminal connection and issuing `SELECT * FROM employees;`.
   * *Error*: `ERROR 1046 (3D000): No database selected`.
   * *Correction*: Explicitly set the database context using `USE sql_mastery;` or qualify the table: `SELECT * FROM sql_mastery.employees;`.
3. **Confusing Database with Table**:
   * *Mistake*: Attempting to insert data directly into a database rather than into a specific table contained within that database.
4. **Treating SQL as Case-Sensitive for Keywords**:
   * While SQL keywords (`SELECT`, `FROM`) are case-insensitive, table names on Linux operating systems may be case-sensitive depending on the underlying filesystem and MySQL configuration setting `lower_case_table_names`.

---

## 9. Best Practices

1. **Adopt a Consistent Uppercase Convention for SQL Keywords**:
   * Write SQL keywords (`SELECT`, `FROM`, `WHERE`, `JOIN`, `ORDER BY`) in uppercase, and schema identifiers (table names, column names) in lowercase with underscores (`snake_case`). This improves readability.
2. **Never Query Unfiltered Datasets in Production (`SELECT *`)**:
   * Avoid `SELECT *` in production code. Always specify explicit column names. This avoids unnecessary memory consumption, network transfer overhead, and breaks caused by schema modifications.
3. **Keep SQL Scripts Idempotent**:
   * When drafting setup scripts, write guarded statements such as `CREATE DATABASE IF NOT EXISTS dbname;` or `DROP TABLE IF EXISTS tablename;`.
4. **Maintain Commented Code**:
   * Use standard SQL double-dash `-- ` (with a space) for single-line comments and `/* ... */` for multi-line comments.

---

## 10. Practice Questions

### Easy
1. Write a command to display all databases currently available on your MySQL server.
2. Write a statement to switch the active database context to `sql_mastery`.
3. Write a query to list all tables inside the active database.

### Medium
4. Write a command to display the exact column structure, data types, and nullability rules of the `customers` table.
5. Write a query to inspect the structure of the `orders` table and identify which column serves as the Primary Key.
6. Write a query to display the first name, last name, and email of all customers from the `customers` table without filtering.

### Difficult
7. Write a single SQL statement that retrieves the table names and table engine types from MySQL's internal `information_schema.tables` for the `sql_mastery` schema.
8. Explain the mechanical difference between what occurs when you run `DESCRIBE employees;` versus when you run `SHOW CREATE TABLE employees;`. Test both commands in your terminal.

---

## 11. Interview Questions

### Q1: What is the difference between a DBMS and an RDBMS?
**Answer**: A DBMS (Database Management System) is any system that stores and retrieves data from files (including hierarchical and key-value stores). An RDBMS (Relational DBMS) is a specialized subset based on relational algebra, where data is organized into structured tables with rows and columns, relationships are enforced via foreign keys, and transactions adhere to ACID properties.

### Q2: What are the five sub-languages of SQL, and which category does `TRUNCATE` belong to?
**Answer**:
1. DDL (Data Definition Language)
2. DML (Data Manipulation Language)
3. DQL (Data Query Language)
4. DCL (Data Control Language)
5. TCL (Transaction Control Language)
`TRUNCATE` belongs to **DDL**, because it deallocates data pages directly at the table schema level without logging individual row deletions, rather than operating as a DML row-by-row removal.

### Q3: Explain the declarative nature of SQL compared to imperative programming.
**Answer**: In imperative languages (e.g., Python, C++), the programmer dictates step-by-step algorithms, memory allocation, and loop control. In declarative SQL, the developer specifies the target outcome (which columns, which conditions, which groupings), and the database engine's Parser, Catalog, and Cost-Based Optimizer determine the optimal execution plan (selecting index seeks, hash joins, or merge sorts).

---

## 12. Quick Revision

* A **database** is a container for tables; a **table** consists of rows (records) and columns (attributes).
* **SQL** is the declarative language used to manage and query relational databases.
* Always establish database context using `USE <database_name>;` before querying unqualified tables.
* Use `SHOW DATABASES;`, `SHOW TABLES;`, and `DESCRIBE <table_name>;` for environment and schema inspection.
* Standard SQL commands are divided into **DDL**, **DML**, **DQL**, **DCL**, and **TCL**.
