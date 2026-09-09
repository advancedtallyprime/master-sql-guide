# Chapter 05 — Data Manipulation: CRUD Operations

---

## 1. What is it?

**CRUD** is an industry acronym denoting the four foundational primitives of persistent software applications:
* **C**reate $\rightarrow$ `INSERT` (and advanced variants: `INSERT IGNORE`, `ON DUPLICATE KEY UPDATE`, `REPLACE`)
* **R**ead $\rightarrow$ `SELECT`
* **U**pdate $\rightarrow$ `UPDATE`
* **D**elete $\rightarrow$ `DELETE`

In relational database management, CRUD operations represent **Data Manipulation Language (DML)**. Unlike DDL commands that modify schema blueprints, DML statements operate on the actual records stored inside tables. 

DML operations in the InnoDB storage engine execute inside transactional boundaries: changes are written to the active transaction's Undo Log (for potential rollback) and Redo Log (for crash recovery) before being permanently committed to disk data pages.

---

## 2. Why do we use it?

1. **Transactional Record Ingestion**: High-volume applications require efficient methods to ingest single events, batch loads, or mass imports without corrupting system indexes.
2. **Idempotent Data Synchronization (UPSERT)**: When syncing data from external APIs or queues, you often need to insert a record if it is new, or update its existing attributes if it already exists, in an atomic statement.
3. **Targeted State Mutation**: Business workflows continuously update order statuses, adjust account balances, or correct typographical errors.
4. **Data Lifecycle Hygiene**: Deleting cancelled reservations or purging expired cart sessions reclaims database capacity.

---

## 3. Syntax

### INSERT Operations
```sql
-- 1. Explicit Column Insert (Production Best Practice)
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);

-- 2. Bulk Multi-Row Insert (Efficient batch loading)
INSERT INTO table_name (column1, column2, column3)
VALUES 
    (valA1, valA2, valA3),
    (valB1, valB2, valB3),
    (valC1, valC2, valC3);

-- 3. Insert from Existing Query (INSERT INTO ... SELECT)
INSERT INTO target_table (col1, col2)
SELECT colA, colB FROM source_table WHERE condition;

-- 4. Insert Ignore (Silently skip rows violating PRIMARY KEY or UNIQUE constraints)
INSERT IGNORE INTO table_name (id, email, name)
VALUES (1, 'user@example.com', 'Alex');

-- 5. UPSERT (Insert or Update on Duplicate Key)
INSERT INTO table_name (id, counter_value, updated_at)
VALUES (1, 10, NOW())
ON DUPLICATE KEY UPDATE 
    counter_value = counter_value + VALUES(counter_value),
    updated_at = NOW();

-- Note on MySQL 8.0.20+ UPSERT alias syntax:
-- INSERT INTO table_name (id, counter_value) VALUES (1, 10) AS new_data
-- ON DUPLICATE KEY UPDATE counter_value = counter_value + new_data.counter_value;
```

### Basic SELECT Retrieval
```sql
SELECT column1, column2 AS custom_alias, (column1 * 1.10) AS calculated_tax
FROM table_name;
```

### UPDATE Operations
```sql
-- Standard Update with Filter
UPDATE table_name
SET column1 = new_value1,
    column2 = new_value2
WHERE primary_key_col = target_id;

-- Multi-table Update (Updating based on a relational join)
UPDATE customers c
JOIN orders o ON c.customer_id = o.customer_id
SET c.loyalty_points = c.loyalty_points + 50
WHERE o.total_amount > 1000.00;
```

### DELETE Operations
```sql
-- Targeted Row Deletion
DELETE FROM table_name
WHERE filter_column = value;

-- Delete with Order and Limit (e.g., delete oldest 100 failed logs)
DELETE FROM table_name
WHERE status = 'Failed'
ORDER BY created_at ASC
LIMIT 100;
```

---

## 4. Basic Example

Performing complete CRUD lifecycle operations on a sandbox table:

```sql
USE sql_mastery;

CREATE TABLE audit_notes (
    note_id INT AUTO_INCREMENT PRIMARY KEY,
    author VARCHAR(50) NOT NULL,
    note_text VARCHAR(255) NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE
);

-- CREATE (Insert single and bulk)
INSERT INTO audit_notes (author, note_text)
VALUES ('Security Bot', 'Routine port scan passed');

INSERT INTO audit_notes (author, note_text, is_resolved)
VALUES 
    ('DevOps', 'Disk alert 85%', FALSE),
    ('DBA', 'Index maintenance scheduled', TRUE);

-- READ
SELECT note_id, author, note_text, is_resolved 
FROM audit_notes;

-- UPDATE
UPDATE audit_notes
SET is_resolved = TRUE
WHERE note_id = 2;

-- DELETE
DELETE FROM audit_notes
WHERE note_id = 1;

-- Clean up
DROP TABLE audit_notes;
```

---

## 5. Real-World Example

In our `sql_mastery` database, let us walk through a complete business transaction:
1. Registering a new customer.
2. Ingesting product stock updates using `ON DUPLICATE KEY UPDATE`.
3. Updating customer loyalty points based on completed orders.
4. Safely removing a test order item.

```sql
USE sql_mastery;

-- 1. CREATE: Register a new customer with explicit columns
INSERT INTO customers (first_name, last_name, email, phone, city, state, country, loyalty_points, registered_at)
VALUES ('Vikram', 'Sharma', 'vikram.sharma@example.in', '555-0399', 'Mumbai', 'MH', 'India', 100, CURDATE());

-- Verify insertion and check the auto-generated customer_id
SELECT customer_id, first_name, last_name, email, loyalty_points, registered_at
FROM customers
WHERE email = 'vikram.sharma@example.in';

-- 2. ADVANCED CREATE / UPSERT: Sync product catalog inventory
-- If Product ID 1 exists, add 10 to stock_quantity; if not, insert new product
INSERT INTO products (product_id, product_name, category_id, supplier_id, unit_price, stock_quantity, reorder_level, is_active)
VALUES (1, 'Quantum Pro 15 Laptop', 1, 1, 1299.99, 10, 10, TRUE)
ON DUPLICATE KEY UPDATE 
    stock_quantity = stock_quantity + 10;

-- 3. UPDATE: Award 50 bonus loyalty points to customers who have placed an order over $1,000
UPDATE customers c
JOIN orders o ON c.customer_id = o.customer_id
SET c.loyalty_points = c.loyalty_points + 50
WHERE o.total_amount > 1000.00 AND o.status = 'Delivered';

-- 4. DELETE: Remove the newly added demo customer
DELETE FROM customers
WHERE email = 'vikram.sharma@example.in';

-- Restore Product 1 stock back to initial 45 units
UPDATE products
SET stock_quantity = 45
WHERE product_id = 1;
```

---

## 6. Step-by-Step Explanation

1. `INSERT INTO customers (...) VALUES (...)`:
   * The parser verifies that all non-nullable columns without default values (`first_name`, `last_name`, `email`, `city`, `country`, `registered_at`) are provided.
   * The storage engine validates that `vikram.sharma@example.in` does not violate the `UNIQUE (email)` constraint.
   * An auto-increment sequence lock (`innodb_autoinc_lock_mode`) assigns the next sequential integer `customer_id` (e.g., `11`), appends the record into an index leaf page, and logs the change to the Redo Log.
2. `INSERT ... ON DUPLICATE KEY UPDATE`:
   * MySQL attempts an index lookup on `product_id = 1`.
   * Finding the row already present in the clustered index, MySQL does not fail with duplicate key error `1062`; instead, it takes an exclusive row lock on product 1 and executes the assignment: `stock_quantity = stock_quantity + 10`.
3. `UPDATE customers c JOIN orders o ...`:
   * The query optimizer performs a join between `customers` and `orders`.
   * Only matching customer rows whose order meets `total_amount > 1000.00 AND status = 'Delivered'` are locked and updated. The `SET` statement increments `loyalty_points` in place.
4. `DELETE FROM customers WHERE email = 'vikram.sharma@example.in'`:
   * Finds the single row via the unique index on `email`. Because customer 11 has no child records in `orders`, the row is deleted cleanly without triggering a foreign key restriction.

---

## 7. Expected Result

Checking customer table retrieval after insertion:

```
+-------------+------------+-----------+--------------------------+----------------+---------------+
| customer_id | first_name | last_name | email                    | loyalty_points | registered_at |
+-------------+------------+-----------+--------------------------+----------------+---------------+
|          11 | Vikram     | Sharma    | vikram.sharma@example.in |            100 | 2026-09-09    |
+-------------+------------+-----------+--------------------------+----------------+---------------+
1 row in set (0.00 sec)
```

Product stock verification after `ON DUPLICATE KEY UPDATE`:

```
+------------+-----------------------+----------------+
| product_id | product_name          | stock_quantity |
+------------+-----------------------+----------------+
|          1 | Quantum Pro 15 Laptop |             55 |
+------------+-----------------------+----------------+
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Executing `UPDATE` or `DELETE` Without a `WHERE` Clause**:
   * *The Nightmare Scenario*:
     ```sql
     UPDATE employees SET salary = 50000;
     ```
   * *Consequence*: Omitting `WHERE` updates **every single row** in the table! All employee salaries across the entire company become 50,000.
   * *Defense*: Enable MySQL Safe Updates mode (`SET sql_safe_updates = 1;`), which refuses to execute `UPDATE` or `DELETE` statements that lack a `WHERE` clause referencing a key or a `LIMIT` clause.
2. **Omitting Column Lists During `INSERT`**:
   * *Fragile Syntax*:
     ```sql
     INSERT INTO categories VALUES (6, 'Apparel', 'Clothing');
     ```
   * *Problem*: If an administrator later runs `ALTER TABLE categories ADD COLUMN icon_url VARCHAR(255);`, all application code written with implicit column lists will crash immediately due to column count mismatch:
     `ERROR 1136 (21S01): Column count doesn't match value count at row 1.`
   * *Rule*: Always write explicit column names: `INSERT INTO categories (category_id, category_name, description) VALUES (...)`.
3. **Single-Row INSERT Loops Instead of Bulk Inserts**:
   * *Inefficient Pattern*: Issuing 1,000 separate `INSERT INTO ... VALUES (...)` statements inside an application loop.
   * *Performance Cost*: Each query triggers its own network round-trip, statement parsing, and redo log disk flush.
   * *Remedy*: Batch inserts into a single multi-row statement (`INSERT INTO table VALUES (...), (...), (...)`), which can run 50–100x faster.
4. **Confusing `REPLACE INTO` with `ON DUPLICATE KEY UPDATE`**:
   * `REPLACE INTO` executes a `DELETE` followed by an `INSERT`. This causes unintended side effects: auto-increment IDs advance, existing unmentioned columns reset to default, and foreign keys configured with `ON DELETE CASCADE` can delete related child records! Always prefer `ON DUPLICATE KEY UPDATE`.

---

## 9. Best Practices

1. **Always Enable `sql_safe_updates` in Development**:
   ```sql
   SET sql_safe_updates = 1;
   ```
2. **Test `UPDATE` and `DELETE` with a `SELECT` First**:
   * Before running:
     ```sql
     DELETE FROM orders WHERE status = 'Cancelled' AND order_date < '2022-01-01';
     ```
   * First run:
     ```sql
     SELECT COUNT(*) FROM orders WHERE status = 'Cancelled' AND order_date < '2022-01-01';
     ```
   * Inspect the count to confirm you are targeting only the expected records.
3. **Use Transactions for Multi-Step Mutations**:
   * Whenever updating one table depends on updating another (such as creating an `order` and decrementing product `stock_quantity`), wrap both statements in `START TRANSACTION; ... COMMIT;`.
4. **Batch Massive Deletions with `LIMIT`**:
   * Deleting millions of rows in a single query locks large portions of the table, expands the Undo Log, and degrades replication. Purge in batches:
     ```sql
     DELETE FROM application_logs WHERE log_date < '2022-01-01' LIMIT 5000;
     ```
     Run this in a loop until 0 rows are affected.

---

## 10. Practice Questions

### Easy
1. Write a SQL query to insert a new department named `'Legal'` situated in `'London'` into the `departments` table.
2. Write a statement to retrieve only the `first_name`, `last_name`, and `salary` from the `employees` table.
3. Write a query to update the phone number of customer with `customer_id = 1` to `'555-9999'`.

### Medium
4. Write a single bulk `INSERT` statement adding three distinct office supply products into the `products` table in one command.
5. Write an `UPDATE` statement that increases the `salary` of every employee in department 1 (`Engineering`) by 8%.
6. Write a query to delete all payments that have a `payment_status` of `'Failed'`.

### Difficult
7. Write an idempotent `INSERT ... ON DUPLICATE KEY UPDATE` statement for the `suppliers` table. If the `supplier_name` or `contact_email` matches an existing supplier, update the `contact_name` and `contact_phone` to new values; otherwise, insert the new supplier.
8. Write a multi-table `DELETE` statement that removes all orders (and relies on `ON DELETE CASCADE` to remove order items) for customers who registered before `2021-01-01` and have `loyalty_points = 0`.

---

## 11. Interview Questions

### Q1: What is the performance difference between inserting 1,000 individual rows versus inserting a single statement with 1,000 tuples?
**Answer**: Individual `INSERT` statements incur 1,000 network round-trips, 1,000 query parsing/optimization cycles, and—if `autocommit` is enabled—1,000 separate disk flushes to the InnoDB transaction redo log. A single multi-row `INSERT INTO table VALUES (...), (...), ...` statement bundles all rows into one network packet, parses once, and commits the batch in a single log write, frequently yielding a 20x to 100x performance improvement.

### Q2: What is the difference between `REPLACE INTO` and `INSERT ... ON DUPLICATE KEY UPDATE`?
**Answer**:
* `REPLACE INTO` operates mechanically as a `DELETE` followed by an `INSERT`. If a duplicate key is detected, the old row is physically deleted and a new row is inserted. Consequently, the auto-increment ID changes, columns not explicitly specified in the `REPLACE` statement revert to their schema defaults, and any dependent child tables with `ON DELETE CASCADE` will have their child records deleted.
* `INSERT ... ON DUPLICATE KEY UPDATE` performs an in-place `UPDATE` on the existing row. The row identity, auto-increment counter, and unmentioned columns are preserved, and foreign key cascades are avoided.

### Q3: What is MySQL's `sql_safe_updates` mode?
**Answer**: `sql_safe_updates` is a session or global configuration variable (`SET sql_safe_updates = 1;`). When enabled, MySQL refuses to execute `UPDATE` or `DELETE` statements unless the statement specifies a `WHERE` clause that utilizes a key (primary or index column) or includes an explicit `LIMIT` clause. It prevents catastrophic accidents where a developer accidentally forgets the `WHERE` clause and modifies or wipes out an entire table.

---

## 12. Quick Revision

* **CRUD** corresponds directly to the SQL verbs `INSERT`, `SELECT`, `UPDATE`, and `DELETE`.
* Always write **explicit column lists** in `INSERT` statements to keep your code resilient against schema changes.
* Use **bulk inserts** to ingest large datasets efficiently.
* Never execute an `UPDATE` or `DELETE` without verifying your `WHERE` filter first, and keep `sql_safe_updates` enabled in development.
* Use `INSERT ... ON DUPLICATE KEY UPDATE` (UPSERT) for idempotent data synchronization; avoid `REPLACE INTO` due to destructive delete-and-reinsert side effects.
