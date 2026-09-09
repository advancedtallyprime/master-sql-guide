# Chapter 04 — Integrity Constraints & Validation Rules

---

## 1. What is it?

**Integrity constraints** are declarative rules enforced by the RDBMS engine at the schema level to guarantee the accuracy, validity, consistency, and reliability of stored records.

Whenever an application issues an `INSERT`, `UPDATE`, or `DELETE` statement, the storage engine validates the incoming data against these constraints before committing any bytes to disk. If a single constraint is violated, the engine halts execution, rejects the entire operation, generates an informative error code, and leaves the database state completely unchanged.

By enforcing business and relational rules directly within the database schema rather than relying solely on application-layer code (e.g., Python, Node.js, Go), you ensure that bad data can **never** enter your database, regardless of how many different microservices, scripts, or reporting tools connect to it.

The primary SQL constraints are:
1. **`PRIMARY KEY`**: Uniquely identifies each row in a table. It implicitly enforces both `UNIQUE` and `NOT NULL`. In MySQL's InnoDB engine, the primary key defines the physical **clustered index** that dictates row storage on disk.
2. **`FOREIGN KEY`**: Enforces **referential integrity** between two tables, ensuring that a value in a child table must correspond to an existing primary key in a parent table.
3. **`NOT NULL`**: Disallows the `NULL` marker, guaranteeing that a column must always contain a concrete value.
4. **`UNIQUE`**: Guarantees that all non-NULL values across a column (or composite set of columns) are distinct.
5. **`CHECK`**: Evaluates a boolean expression on the row's values, rejecting modifications where the expression evaluates to `FALSE` (fully enforced in MySQL 8.0+).
6. **`DEFAULT`**: Supplies an automatic fallback value if an `INSERT` statement omits that specific column.
7. **`AUTO_INCREMENT`**: An engine-managed counter that automatically generates sequential integer identifiers for newly inserted records.

---

## 2. Why do we use it?

1. **Defensive Schema Architecture**: Software bugs in frontend forms or API layers are inevitable. Constraints act as an unbreakable safety net, preventing corrupted, orphaned, or impossible records from entering storage.
2. **Referential Stability**: Foreign keys eliminate **orphaned rows** (e.g., an order item referencing a product that was deleted, or an employee assigned to a department that no longer exists).
3. **High-Performance Query Paths**: The engine automatically constructs indexes to back `PRIMARY KEY`, `UNIQUE`, and `FOREIGN KEY` constraints, providing instant $O(\log N)$ logarithmic B+ Tree search paths.
4. **Self-Documenting Schemas**: Anyone reading a table's DDL immediately understands the core business invariants (e.g., "salary must exceed 0", "discount must be between 0.00 and 1.00").

---

## 3. Syntax

### Defining Constraints During Table Creation
```sql
CREATE TABLE table_name (
    -- Column-level constraints
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    amount DECIMAL(10, 2) NOT NULL,
    parent_id INT,

    -- Explicitly named table-level constraints
    CONSTRAINT chk_positive_amount CHECK (amount >= 0.00),
    CONSTRAINT fk_table_parent FOREIGN KEY (parent_id)
        REFERENCES parent_table(parent_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Composite Primary Key (Multiple Columns Combined)
CREATE TABLE composite_demo (
    tenant_id INT NOT NULL,
    user_id INT NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (tenant_id, user_id)
);
```

### Adding, Modifying, and Dropping Constraints via `ALTER TABLE`
```sql
-- Add NOT NULL constraint
ALTER TABLE table_name
MODIFY COLUMN column_name data_type NOT NULL;

-- Remove NOT NULL (Allow NULLs)
ALTER TABLE table_name
MODIFY COLUMN column_name data_type NULL;

-- Add a UNIQUE constraint
ALTER TABLE table_name
ADD CONSTRAINT uq_column_name UNIQUE (column_name);

-- Add a CHECK constraint
ALTER TABLE table_name
ADD CONSTRAINT chk_rule_name CHECK (boolean_expression);

-- Add a FOREIGN KEY constraint
ALTER TABLE child_table
ADD CONSTRAINT fk_child_parent FOREIGN KEY (parent_id)
    REFERENCES parent_table(parent_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Drop constraints:
ALTER TABLE table_name DROP PRIMARY KEY;
ALTER TABLE table_name DROP INDEX uq_column_name;         -- Drops UNIQUE in MySQL
ALTER TABLE table_name DROP CHECK chk_rule_name;           -- Drops CHECK in MySQL 8.0+
ALTER TABLE child_table DROP FOREIGN KEY fk_child_parent;  -- Drops FOREIGN KEY
```

---

## 4. Basic Example

Demonstrating constraints with a simple subscription management table:

```sql
USE sql_mastery;

CREATE TABLE subscriptions_demo (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    monthly_rate DECIMAL(6, 2) NOT NULL DEFAULT 9.99,
    discount_rate DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_rate CHECK (monthly_rate > 0.00),
    CONSTRAINT chk_discount CHECK (discount_rate >= 0.00 AND discount_rate <= 1.00)
);

-- Valid Insert
INSERT INTO subscriptions_demo (user_email, monthly_rate, discount_rate)
VALUES ('subscriber@example.com', 19.99, 0.15);

-- Clean up
DROP TABLE subscriptions_demo;
```

---

## 5. Real-World Example

In our `sql_mastery` database, let us examine the comprehensive constraint architecture built into the `order_items` table:

```sql
USE sql_mastery;

-- Inspect the table creation definition and constraints
SHOW CREATE TABLE order_items\G

-- Let us test the enforcement of each constraint:

-- TEST 1: Violation of CHECK constraint (quantity must be > 0)
-- This will trigger ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES (1001, 2, 0, 999.00, 0.00);

-- TEST 2: Violation of UNIQUE composite constraint (uq_order_product)
-- Order 1001 already contains product_id 1. Inserting it again should fail:
-- This will trigger ERROR 1062 (23000): Duplicate entry '1001-1' for key 'order_items.uq_order_product'
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES (1001, 1, 2, 1299.99, 0.00);

-- TEST 3: Violation of FOREIGN KEY constraint (Referencing non-existent product)
-- Product 9999 does not exist in the products table.
-- This triggers ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES (1001, 9999, 1, 49.99, 0.00);
```

---

## 6. Step-by-Step Explanation

1. `CONSTRAINT chk_item_quantity CHECK (quantity > 0)`:
   * When an `INSERT` or `UPDATE` targets `order_items`, MySQL's runtime constraint evaluator executes before the row is physically committed to the clustered index.
   * If `quantity <= 0`, the engine aborts the transaction statement and emits:
     `ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.`
2. `CONSTRAINT uq_order_product UNIQUE (order_id, product_id)`:
   * MySQL builds a composite unique B+ Tree index covering both columns.
   * When inserting a row with `(1001, 1)`, MySQL searches the index. Finding the combination already present, it rejects the insert to prevent duplicate line items for the same product in a single order.
3. `CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)`:
   * The child table points to the parent table `products`.
   * When attempting to insert product `9999`, the InnoDB storage engine checks the clustered index of `products` for key `9999`. Finding nothing, it halts execution and rolls back the statement.

---

## 7. Expected Result

Terminal output confirming constraint enforcement:

```
mysql> INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -> VALUES (1001, 2, 0, 999.00, 0.00);
ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.

mysql> INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -> VALUES (1001, 1, 2, 1299.99, 0.00);
ERROR 1062 (23000): Duplicate entry '1001-1' for key 'order_items.uq_order_product'

mysql> INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -> VALUES (1001, 9999, 1, 49.99, 0.00);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`sql_mastery`.`order_items`, CONSTRAINT `fk_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE)
```

---

## 8. Common Mistakes

1. **Assuming `UNIQUE` Forbids `NULL` Values**:
   * *Mistake*: Assuming a column marked `UNIQUE` cannot have empty values.
   * *Reality*: In ANSI SQL and MySQL, `NULL` represents an "unknown" value. Because an unknown value cannot be determined to equal another unknown value (`NULL = NULL` yields `NULL`, not `TRUE`), MySQL permits **multiple `NULL` values** in a column with a `UNIQUE` constraint (unless the column is also explicitly declared `NOT NULL`).
2. **Confusing Primary Keys with Unique Constraints**:
   * A table can have **only one** `PRIMARY KEY` (which cannot contain `NULL`), but can have **multiple** `UNIQUE` constraints.
3. **Assuming `CHECK` Constraints Worked in MySQL 5.7**:
   * In MySQL 5.7 and earlier, the parser accepted `CHECK` syntax without errors, but silently ignored it during runtime data insertion. Full `CHECK` enforcement was added in **MySQL 8.0.16**.
4. **Trying to Drop a Column That Is Part of a Foreign Key**:
   * Attempting to run `ALTER TABLE order_items DROP COLUMN product_id;` directly causes an error. You must first drop the foreign key constraint (`ALTER TABLE order_items DROP FOREIGN KEY fk_items_product;`), and only then drop the column.
5. **Omitting Constraint Names**:
   * Writing `CHECK (salary > 0)` without prefixing it with `CONSTRAINT chk_salary` causes MySQL to assign a system-generated name like `employees_chk_1`, making future schema migrations and error message interpretation difficult.

---

## 9. Best Practices

1. **Always Use Descriptive Constraint Naming Conventions**:
   * Prefix constraints with their functional type:
     * Primary Keys: `pk_tablename`
     * Foreign Keys: `fk_childtable_parenttable`
     * Unique Constraints: `uq_tablename_column`
     * Check Constraints: `chk_tablename_rule`
2. **Carefully Select Foreign Key Deletion Actions**:
   * Use `ON DELETE RESTRICT` (default) when parent records must not be deleted if child records exist (e.g., do not delete a customer if they have historic orders).
   * Use `ON DELETE CASCADE` when the child row is an owned dependent that has no business meaning without the parent (e.g., deleting an `order` should cascade-delete all its `order_items`).
   * Use `ON DELETE SET NULL` when the relationship is optional (e.g., if an employee's `manager_id` references a departing employee, set their manager to `NULL`).
3. **Avoid Composite Primary Keys for High-Volume Foreign Key Relationships**:
   * While natural composite keys (e.g., `(order_id, product_id)`) are valid, prefer single-column surrogate keys (`item_id INT AUTO_INCREMENT PRIMARY KEY`) combined with a composite `UNIQUE (order_id, product_id)` constraint if other child tables will need to reference `order_items`. This prevents multi-column foreign key bloat.

---

## 10. Practice Questions

### Easy
1. Which two constraints are automatically enforced when a column is defined as `PRIMARY KEY`?
2. How many `PRIMARY KEY` constraints can exist on a single table?
3. How many `UNIQUE` constraints can exist on a single table?

### Medium
4. Write a `CREATE TABLE` statement for `bank_accounts` containing `account_id INT AUTO_INCREMENT PRIMARY KEY`, `account_number VARCHAR(20) NOT NULL UNIQUE`, and `balance DECIMAL(12,2) NOT NULL DEFAULT 0.00` with a CHECK constraint ensuring `balance >= 0.00`.
5. Given a table `students` and a table `enrollments`, write the SQL statement to add a named foreign key constraint `fk_enrollment_student` on `enrollments(student_id)` referencing `students(student_id)` with cascading deletes.
6. Write the exact command to drop the check constraint `chk_employee_salary` from the `employees` table in MySQL 8.0.

### Difficult
7. Explain what occurs internally when you try to insert two rows containing `NULL` into a column configured with a `UNIQUE` constraint versus two rows containing `NULL` into a column configured as `PRIMARY KEY`.
8. Write an `ALTER TABLE` statement that adds a multi-column check constraint ensuring that in an `events` table, `end_time` is strictly greater than `start_time`.

---

## 11. Interview Questions

### Q1: What is the difference between a `PRIMARY KEY` and a `UNIQUE` constraint?
**Answer**:
1. **Quantity**: A table can have only one `PRIMARY KEY`, but may contain multiple `UNIQUE` constraints.
2. **Nullability**: A `PRIMARY KEY` strictly forbids `NULL` values. A `UNIQUE` constraint permits `NULL` values (and in MySQL, allows multiple `NULL` values unless `NOT NULL` is also specified).
3. **Clustering**: In MySQL InnoDB, the `PRIMARY KEY` physically organizes the table data on disk as a **clustered index** (the leaf nodes store the actual row data). Secondary `UNIQUE` constraints are stored as non-clustered secondary indexes whose leaf nodes point back to the primary key.

### Q2: What are the differences between `ON DELETE CASCADE`, `ON DELETE SET NULL`, and `ON DELETE RESTRICT`?
**Answer**:
* `ON DELETE RESTRICT` (or `NO ACTION`): Prevents deletion of a parent row if any child rows reference it, raising a foreign key violation error.
* `ON DELETE CASCADE`: Automatically deletes all child rows whenever their referenced parent row is deleted.
* `ON DELETE SET NULL`: Retains child rows but sets their foreign key column values to `NULL` when the parent row is deleted (requires the child foreign key column to be nullable).

### Q3: How are `CHECK` constraints handled across MySQL versions?
**Answer**: In MySQL versions prior to 8.0.16, `CHECK` constraints were syntactically parsed but completely ignored by the storage engine during runtime DML operations. Starting with MySQL 8.0.16, the engine fully enforces `CHECK` constraints on `INSERT` and `UPDATE` statements, aborting execution with `ERROR 3819 (HY000)` if the evaluated boolean expression evaluates to `FALSE`.

---

## 12. Quick Revision

* **Integrity constraints** protect database reliability by rejecting invalid data modifications at the storage engine boundary.
* A table has exactly one **`PRIMARY KEY`**, which cannot be `NULL` and forms the physical clustered index in InnoDB.
* **`UNIQUE`** prevents duplicates but permits multiple `NULL` values in MySQL unless explicitly declared `NOT NULL`.
* **`FOREIGN KEY`** preserves parent-child relational integrity, with configurable cascade behaviors (`RESTRICT`, `CASCADE`, `SET NULL`).
* **`CHECK`** constraints enforce custom validation rules (fully active in MySQL 8.0.16+).
* Always provide descriptive constraint names (`fk_...`, `chk_...`, `uq_...`) for maintainability.
