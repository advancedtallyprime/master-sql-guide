# Chapter 02 — Database & Table Management (DDL)

---

## 1. What is it?

**Data Definition Language (DDL)** encompasses the set of SQL commands responsible for defining, altering, and deconstructing the structural architecture of a database and its objects. 

DDL commands manage the "skeletons" or blueprints that contain your records. When you execute a DDL command in MySQL (such as creating a database, adding a column to a table, or dropping an index), MySQL alters the data dictionary and storage engine metadata directly. 

In MySQL (specifically the default **InnoDB** engine), most DDL operations execute with **implicit commit semantics**: they automatically commit any open transaction on your connection, and the structural change cannot be undone with a standard `ROLLBACK` statement.

The core DDL statements are:
* `CREATE`: Instantiates a new database, table, view, or index.
* `ALTER`: Modifies the structure of an existing database object in-place without deleting its data.
* `DROP`: Irrevocably destroys an object and all of its associated data pages from disk.
* `TRUNCATE`: Rapidly purges all records from a table by resetting its high-water mark and deallocating its storage pages, preserving the table structure.
* `RENAME`: Renames a table or database object cleanly.

---

## 2. Why do we use it?

Software applications undergo continuous architectural evolution:
1. **Initial Provisioning**: Building new application features requires spinning up isolated schemas and relational tables configured with appropriate character encodings and storage engines.
2. **Schema Migration & Evolution**: As products scale, database administrators must add columns, expand field sizes (e.g., from `VARCHAR(50)` to `VARCHAR(100)`), rename columns for domain clarity, or deprecate unused fields without losing existing data.
3. **Safe Script Automation**: Using guarded statements like `IF EXISTS` and `IF NOT EXISTS` ensures automated Continuous Integration / Continuous Deployment (CI/CD) deployment scripts run idempotently without crashing.
4. **Storage & Lifecycle Management**: Discarding staging tables or purging test databases via `DROP` and `TRUNCATE` reclaims disk storage immediately.

---

## 3. Syntax

### Database Management
```sql
-- Create a database with UTF-8 character encoding and case-insensitive collation
CREATE DATABASE [IF NOT EXISTS] database_name
  [CHARACTER SET utf8mb4]
  [COLLATE utf8mb4_0900_ai_ci];

-- Delete a database and all its contents
DROP DATABASE [IF EXISTS] database_name;
```

### Table Creation & Duplication
```sql
-- Basic Table Creation
CREATE TABLE [IF NOT EXISTS] table_name (
    column_name_1 data_type [CONSTRAINTS],
    column_name_2 data_type [CONSTRAINTS],
    ...
    [TABLE_CONSTRAINTS]
) ENGINE = InnoDB;

-- Create Table As Select (CTAS) - creates table and copies matching rows
CREATE TABLE new_table_name AS
SELECT column1, column2 FROM existing_table WHERE condition;

-- Create an empty structural clone of an existing table
CREATE TABLE cloned_table LIKE existing_table;
```

### Altering Tables
```sql
-- 1. Add a new column (optionally specifying position: FIRST or AFTER existing_col)
ALTER TABLE table_name
ADD COLUMN new_column_name data_type [CONSTRAINTS] [FIRST | AFTER existing_column];

-- 2. Drop an existing column
ALTER TABLE table_name
DROP COLUMN column_name;

-- 3. Modify a column's datatype or constraints without changing its name
ALTER TABLE table_name
MODIFY COLUMN column_name new_data_type [CONSTRAINTS];

-- 4. Change (rename) a column and optionally alter its datatype
ALTER TABLE table_name
CHANGE COLUMN old_column_name new_column_name new_data_type [CONSTRAINTS];

-- 5. Rename a table
RENAME TABLE old_table_name TO new_table_name;
-- Alternative syntax:
-- ALTER TABLE old_table_name RENAME TO new_table_name;
```

### Purging & Destroying Tables
```sql
-- Purge all records, reset auto-increment, retain structure (Fast DDL)
TRUNCATE TABLE table_name;

-- Permanently destroy table structure and all data
DROP TABLE [IF EXISTS] table_name;
```

---

## 4. Basic Example

Creating and modifying a temporary sandbox table:

```sql
USE sql_mastery;

-- Create a simple staging table
CREATE TABLE IF NOT EXISTS staging_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Add a column after username
ALTER TABLE staging_users
ADD COLUMN is_verified BOOLEAN DEFAULT FALSE AFTER username;

-- Modify the email column length
ALTER TABLE staging_users
MODIFY COLUMN email VARCHAR(150) NOT NULL;

-- Rename the username column to handle
ALTER TABLE staging_users
CHANGE COLUMN username user_handle VARCHAR(50) NOT NULL;

-- Clean up
DROP TABLE staging_users;
```

---

## 5. Real-World Example

A business requires adding an `affiliate_code` to the `customers` table, repositioning a column, indexing the affiliate code, and establishing an archive table for closed customer accounts.

```sql
USE sql_mastery;

-- Step 1: Add affiliate_code to customers table, positioned after loyalty_points
ALTER TABLE customers
ADD COLUMN affiliate_code VARCHAR(20) DEFAULT NULL AFTER loyalty_points;

-- Step 2: Modify affiliate_code to ensure it defaults to 'STANDARD'
ALTER TABLE customers
MODIFY COLUMN affiliate_code VARCHAR(20) NOT NULL DEFAULT 'STANDARD';

-- Step 3: Create an archive clone of the customers table for decommissioned users
CREATE TABLE customers_archive LIKE customers;

-- Step 4: Verify the schema of both the active table and its clone
DESC customers;
DESC customers_archive;

-- Step 5: Remove the temporary affiliate_code from customers to maintain base state
ALTER TABLE customers
DROP COLUMN affiliate_code;

-- Step 6: Drop the archive clone
DROP TABLE customers_archive;
```

---

## 6. Step-by-Step Explanation

1. `ALTER TABLE customers ADD COLUMN affiliate_code VARCHAR(20) DEFAULT NULL AFTER loyalty_points;`:
   * **Metadata Lock**: MySQL obtains an Exclusive Metadata Lock on `customers`.
   * **Online DDL Engine**: Under InnoDB (`ALGORITHM=INPLACE`), MySQL updates the table definition and physically adds the column offset to existing clustered index leaf pages without requiring a full table rebuild.
   * **Positional Pointer**: `AFTER loyalty_points` informs the storage engine to position the logical column ordinal immediately following `loyalty_points`.
2. `CREATE TABLE customers_archive LIKE customers;`:
   * Reads the structural schema definition of `customers`, including all column datatypes, primary keys, and unique indexes, and generates an exact, empty replica table named `customers_archive`. It does not copy data rows.
3. `ALTER TABLE customers DROP COLUMN affiliate_code;`:
   * Scans the data pages to mark the column storage space as reusable and drops the column metadata from the internal catalog.
4. `DROP TABLE customers_archive;`:
   * Drops the `.ibd` tablespace file (or frees pages in the shared tablespace) from disk, returning memory and disk pages back to the operating system.

---

## 7. Expected Result

Execution output from `DESC customers;` after adding the column:

```
+----------------+---------------+------+-----+-----------+-------------------+
| Field          | Type          | Null | Key | Default   | Extra             |
+----------------+---------------+------+-----+-----------+-------------------+
| customer_id    | int           | NO   | PRI | NULL      | auto_increment    |
| first_name     | varchar(50)   | NO   |     | NULL      |                   |
| last_name      | varchar(50)   | NO   |     | NULL      |                   |
| email          | varchar(100)  | NO   | UNI | NULL      |                   |
| phone          | varchar(20)   | YES  |     | NULL      |                   |
| city           | varchar(50)   | NO   |     | NULL      |                   |
| state          | varchar(50)   | YES  |     | NULL      |                   |
| country        | varchar(50)   | NO   |     | NULL      |                   |
| loyalty_points | int           | YES  |     | 0         |                   |
| affiliate_code | varchar(20)   | NO   |     | STANDARD  |                   |
| registered_at  | date          | NO   |     | NULL      |                   |
| is_active      | tinyint(1)    | YES  |     | 1                 |                   |
| created_at     | timestamp     | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+----------------+---------------+------+-----+-----------+-------------------+
```

---

## 8. Common Mistakes

1. **Confusing `MODIFY COLUMN` with `CHANGE COLUMN`**:
   * *Mistake*: `ALTER TABLE customers MODIFY COLUMN old_col new_col VARCHAR(50);`
   * *Error*: Syntax error!
   * *Rule*: Use `MODIFY` when changing the datatype, nullability, or default value *without* changing the column name. Use `CHANGE` when you want to rename the column (it requires specifying both the old name and the new name, along with the complete datatype).
2. **Confusing `TRUNCATE` with `DELETE FROM table;`**:
   * *Mistake*: Running `DELETE FROM orders;` expecting auto-increment IDs to reset.
   * *Distinction*: `DELETE` removes records row-by-row, firing row triggers and preserving the auto-increment counter sequence. `TRUNCATE` drops the physical storage pages, does not fire `DELETE` triggers, and resets the `AUTO_INCREMENT` counter back to 1 (or the initial sequence).
3. **Dropping a Table Referenced by Foreign Keys**:
   * *Mistake*: Running `DROP TABLE customers;` while `orders` has an active foreign key referencing `customers(customer_id)`.
   * *Error*: `ERROR 3730 (HY000): Cannot drop table 'customers' referenced by a foreign key constraint 'fk_orders_customer' on table 'orders'.`
   * *Rule*: Child tables must be dropped before parent tables, or the foreign key constraint must be dropped first.
4. **Failing to Specify Column Position**:
   * In MySQL, omitting `FIRST` or `AFTER col` during `ADD COLUMN` places the new column at the very end of the table by default.

---

## 9. Best Practices

1. **Always Use `utf8mb4` Character Set**:
   * Always create databases with `CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`. The older MySQL `utf8` character set is deprecated because it only supports up to 3 bytes per character, failing on emojis and four-byte Unicode characters.
2. **Always Use Guard Clauses in DDL Scripts**:
   * Use `CREATE DATABASE IF NOT EXISTS`, `CREATE TABLE IF NOT EXISTS`, and `DROP TABLE IF EXISTS` to ensure automation scripts can be re-run safely without aborting mid-deployment.
3. **Check Constraint and Foreign Key Names**:
   * Explicitly name constraints (e.g., `CONSTRAINT fk_orders_customer`, `CONSTRAINT chk_price_positive`) rather than letting MySQL generate anonymous system identifiers (`orders_ibfk_1`). This makes schema alterations and debugging far easier.
4. **Be Aware of DDL Locking on Large Tables**:
   * Modifying large tables (tens of millions of rows) can lock tables or consume massive I/O. Use tools like `pt-online-schema-change` or MySQL 8.0 `ALGORITHM=INPLACE, LOCK=NONE` when modifying active production schemas.

---

## 10. Practice Questions

### Easy
1. Write a SQL statement to create a new database named `corporate_hr` using `utf8mb4` character set.
2. Write a statement to create a table named `job_titles` with `title_id INT AUTO_INCREMENT PRIMARY KEY` and `title_name VARCHAR(50) NOT NULL`.
3. Write a command to delete the table `job_titles` only if it currently exists.

### Medium
4. Given the table `job_titles`, write an `ALTER TABLE` statement to add a column named `min_salary DECIMAL(10,2) NOT NULL DEFAULT 30000.00` immediately after `title_name`.
5. Write an `ALTER TABLE` statement that modifies `title_name` from `VARCHAR(50)` to `VARCHAR(100)` while preserving the `NOT NULL` constraint.
6. Write a single statement to rename the table `job_titles` to `company_roles`.

### Difficult
7. Write an SQL sequence that creates a table `inventory_staging`, adds three columns in specific positions (`sku` as FIRST, `quantity` after `sku`, `warehouse_code` after `quantity`), modifies `quantity` to disallow negative numbers using a CHECK constraint, and finally truncates the table.
8. Explain the difference between `CREATE TABLE t2 AS SELECT * FROM t1;` and `CREATE TABLE t2 LIKE t1;`. Which preserves indexes and auto-increment properties?

---

## 11. Interview Questions

### Q1: What is the mechanical difference between `TRUNCATE TABLE`, `DROP TABLE`, and `DELETE FROM TABLE`?
**Answer**:
* `DELETE` is a DML operation. It removes rows one-by-one, writes each deletion to the transaction undo and redo logs, fires any associated `DELETE` triggers, and allows transaction rollback. It does *not* reset auto-increment counters or reduce the high-water mark of allocated disk space.
* `TRUNCATE` is a DDL operation. It deallocates the underlying data pages directly, bypasses row triggers, immediately resets auto-increment sequences, cannot be rolled back in most transactional contexts, and executes significantly faster on large tables.
* `DROP` is a DDL operation. It permanently removes the table schema, constraints, triggers, indexes, and all physical files from disk.

### Q2: Why cannot DDL statements like `ALTER TABLE` or `CREATE TABLE` be rolled back inside a transaction in MySQL?
**Answer**: In MySQL's architecture, DDL operations cause an **implicit commit**. Before and after any DDL statement executes, the MySQL server automatically calls an internal `COMMIT` on the active transaction. This behavior ensures data dictionary consistency across threads, but means DDL statements cannot be rolled back via `ROLLBACK`.

### Q3: What is the difference between `ALTER TABLE ... MODIFY` and `ALTER TABLE ... CHANGE`?
**Answer**: `MODIFY` can alter the column's data type, nullability, default value, or position, but **cannot** change the column's name. `CHANGE` requires providing the existing column name followed by the new column name, allowing you to rename the column and simultaneously adjust its datatype and attributes.

---

## 12. Quick Revision

* **DDL** statements (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`) modify database structure and trigger implicit transaction commits in MySQL.
* Always declare schemas using `utf8mb4` for full international Unicode and emoji support.
* Use `ALTER TABLE ... ADD COLUMN ... FIRST | AFTER <col>` for deterministic column positioning.
* `MODIFY` alters column types/constraints in place; `CHANGE` renames columns.
* `TRUNCATE` purges rows and resets auto-increment sequences via page deallocation; `DROP` destroys the entire table structure.
