# Chapter 22 — Event-Driven Architecture: MySQL Triggers

---

## 1. What is it?

A **Trigger** is a specialized stored program in MySQL that automatically executes ("fires") in response to a specific **Data Manipulation Language (DML)** event (`INSERT`, `UPDATE`, or `DELETE`) occurring on a specific base table.

Unlike Stored Procedures (which must be called explicitly by an application), triggers cannot be called directly. They operate as **implicit event handlers** managed entirely by the storage engine. 

A trigger is defined by two fundamental axes:
1. **Activation Timing**:
   * **`BEFORE`**: Fires *prior* to the row modification being written to the storage engine's data pages. Commonly used for data validation, data sanitization (e.g., trimming whitespace or hashing passwords), and modifying incoming values before they hit disk.
   * **`AFTER`**: Fires *subsequent* to the row modification being written. Commonly used for immutable audit logging, cross-table synchronizations, and event notifications.
2. **Activation Event**: `INSERT`, `UPDATE`, or `DELETE`.

Because MySQL employs row-level triggers (`FOR EACH ROW`), if an `UPDATE` statement modifies 50 rows, the trigger code executes exactly 50 times (once for every affected row).

---

## 2. Row Pseudo-Records: `NEW` vs `OLD`

Within the trigger body, MySQL provides two virtual pseudo-records representing the data row:
* **`NEW`**: Represents the new record being inserted or updated.
  * Available in: **`INSERT`** and **`UPDATE`**.
  * In `BEFORE` triggers, you can overwrite incoming values: `SET NEW.email = LOWER(NEW.email);`.
* **`OLD`**: Represents the existing record prior to modification or deletion.
  * Available in: **`UPDATE`** and **`DELETE`**.
  * It is strictly read-only.

| Trigger Event | `OLD.column` Available? | `NEW.column` Available? | Can Modify `NEW.column`? |
| :--- | :--- | :--- | :--- |
| `INSERT` | No | **Yes** (values to be inserted) | **Yes** (in `BEFORE INSERT` only) |
| `UPDATE` | **Yes** (pre-update values) | **Yes** (post-update values) | **Yes** (in `BEFORE UPDATE` only) |
| `DELETE` | **Yes** (values being removed) | No | No |

---

## 3. Syntax

```sql
DELIMITER //

CREATE TRIGGER trigger_name
[BEFORE | AFTER] [INSERT | UPDATE | DELETE]
ON table_name
FOR EACH ROW
BEGIN
    -- Trigger logic
    -- Access NEW.col or OLD.col
END //

DELIMITER ;

-- Managing Triggers
SHOW TRIGGERS FROM database_name;
DROP TRIGGER IF EXISTS trigger_name;
```

### Aborting Operations with `SIGNAL SQLSTATE`
To reject an operation and roll back the enclosing transaction from inside a trigger, raise a custom database exception using `SIGNAL SQLSTATE '45000'`:

```sql
IF NEW.salary <= 0 THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integrity Error: Employee salary must be greater than zero.';
END IF;
```

---

## 4. Basic Example

Creating a `BEFORE INSERT` trigger to automatically normalize user data:

```sql
USE sql_mastery;

DELIMITER //

CREATE TRIGGER trg_customers_before_insert
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    -- Force email addresses to lowercase and trim any whitespace
    SET NEW.email = LOWER(TRIM(NEW.email));
    
    -- Assign default loyalty points if null
    IF NEW.loyalty_points IS NULL THEN
        SET NEW.loyalty_points = 0;
    END IF;
END //

DELIMITER ;

-- Clean up
DROP TRIGGER trg_customers_before_insert;
```

---

## 5. Real-World Example: Enterprise Audit Logging & Price Validation

In our `sql_mastery` database, the executive compliance committee requires two automated protections:
1. **Validation (`BEFORE UPDATE` on `products`)**: Prevent any price reduction greater than 50% in a single update to protect against accidental catastrophic price drops, aborting the transaction if violated.
2. **Audit Trail (`AFTER UPDATE` on `products`)**: Whenever a product's `unit_price` or `stock_quantity` is modified, log the change to an immutable audit table capturing the product ID, previous values, new values, the user who executed the update, and a timestamp.

```sql
USE sql_mastery;

-- Step 1: Create the immutable audit trail table
CREATE TABLE product_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    old_stock INT,
    new_stock INT,
    action_type VARCHAR(20) NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

-- Step 2: BEFORE UPDATE Trigger for Business Rule Enforcement
CREATE TRIGGER trg_products_before_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    -- Safeguard: Disallow dropping price by more than 50% in a single update
    IF NEW.unit_price < (OLD.unit_price * 0.50) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'TRANSACTION REJECTED: Price drops exceeding 50% require managerial authorization.';
    END IF;
END //

-- Step 3: AFTER UPDATE Trigger for Immutable Audit Logging
CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Only log if price or stock actually changed
    IF (OLD.unit_price != NEW.unit_price) OR (OLD.stock_quantity != NEW.stock_quantity) THEN
        INSERT INTO product_audit_log (
            product_id,
            old_price,
            new_price,
            old_stock,
            new_stock,
            action_type,
            changed_by
        ) VALUES (
            OLD.product_id,
            OLD.unit_price,
            NEW.unit_price,
            OLD.stock_quantity,
            NEW.stock_quantity,
            'PRICE_STOCK_UPDATE',
            CURRENT_USER()
        );
    END IF;
END //

DELIMITER ;
```

---

## 6. Step-by-Step Explanation & Execution

Let us test both triggers:

```sql
USE sql_mastery;

-- TEST 1: Trigger the Price Drop Guard
-- Quantum Pro 15 Laptop is $1,299.99. Dropping price to $500.00 is a 61% drop!
-- This MUST be rejected by trg_products_before_update!
UPDATE products
SET unit_price = 500.00
WHERE product_id = 1;

-- TEST 2: Authorized Legitimate Price Update
-- Update Laptop price to $1,199.99 (8% drop) and decrement stock by 2
UPDATE products
SET unit_price = 1199.99,
    stock_quantity = stock_quantity - 2
WHERE product_id = 1;

-- Inspect the automatically populated Audit Log!
SELECT * FROM product_audit_log;

-- Restore base state and clean up
UPDATE products SET unit_price = 1299.99, stock_quantity = stock_quantity + 2 WHERE product_id = 1;
DROP TRIGGER trg_products_before_update;
DROP TRIGGER trg_products_after_update;
DROP TABLE product_audit_log;
```

---

## 7. Expected Result

Terminal output confirming trigger execution:

```
mysql> UPDATE products SET unit_price = 500.00 WHERE product_id = 1;
ERROR 1644 (45000): TRANSACTION REJECTED: Price drops exceeding 50% require managerial authorization.

mysql> UPDATE products SET unit_price = 1199.99, stock_quantity = stock_quantity - 2 WHERE product_id = 1;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM product_audit_log\G
*************************** 1. row ***************************
   audit_id: 1
 product_id: 1
  old_price: 1299.99
  new_price: 1199.99
  old_stock: 45
  new_stock: 43
action_type: PRICE_STOCK_UPDATE
 changed_by: root@localhost
 changed_at: 2026-09-09 10:13:30
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Mutating the Triggering Table Inside the Trigger (Error 1442)**:
   * *The Critical Mistake*:
     ```sql
     CREATE TRIGGER trg_bad AFTER INSERT ON orders
     FOR EACH ROW
     BEGIN
         UPDATE orders SET total_amount = 100 WHERE order_id = NEW.order_id; -- FATAL!
     END;
     ```
   * *Error*:
     `ERROR 1442 (HY000): Can't update table 'orders' in stored function/trigger because it is already being used by statement which invoked this stored function/trigger.`
   * *Rule*: A trigger cannot execute DML (`INSERT`, `UPDATE`, `DELETE`) on the table it is attached to! If you want to modify incoming values on the same table, use a `BEFORE INSERT/UPDATE` trigger and assign values directly: `SET NEW.total_amount = 100;`.
2. **Hidden Business Logic & Debugging Nightmares**:
   * Placing complex business logic inside triggers hides application behavior. When an API developer runs an `UPDATE` that unexpectedly fails or triggers 20 secondary changes, tracking down the issue can be difficult if triggers are undocumented.
3. **Severe Bulk DML Performance Penalties**:
   * Row-level triggers execute for **every single row**. If an application loads 1,000,000 rows in a bulk `INSERT`, an `AFTER INSERT` trigger will execute 1,000,000 times, turning a 2-second bulk insert into a 15-minute bottleneck.

---

## 9. Best Practices

1. **Keep Triggers Small, Fast, and Non-Intrusive**:
   * Triggers execute within the caller's active transaction. Heavy trigger computations prolong lock hold times, increasing the likelihood of lock wait timeouts and deadlocks.
2. **Restrict Triggers to Auditing, Data Normalization, and Strict Invariants**:
   * Excellent use cases: maintaining audit logs, calculating hash checksums, and enforcing cross-field schema rules.
   * Poor use cases: calling external webhooks, sending emails, or executing multi-table business workflows.
3. **Use Meaningful Trigger Naming Conventions**:
   * Format: `trg_<tablename>_<timing>_<event>`
   * Examples: `trg_products_before_update`, `trg_orders_after_insert`.
4. **Always Guard Audit Inserts with Change Detection**:
   * Check `IF (OLD.col != NEW.col)` so you only write audit log records when values have actually changed, avoiding unnecessary audit table bloat.

---

## 10. Practice Questions

### Easy
1. What is the difference in activation timing between a `BEFORE` trigger and an `AFTER` trigger?
2. Which pseudo-record (`NEW` or `OLD`) is available inside a `DELETE` trigger?
3. Which pseudo-record is available inside an `INSERT` trigger?

### Medium
4. Write a `BEFORE INSERT` trigger on `employees` that ensures any newly inserted employee has their `hire_date` set to `CURDATE()` if `hire_date` was supplied as `NULL`.
5. Write a `BEFORE UPDATE` trigger on `employees` that forbids reducing an employee's `salary`. If an update attempts to set `NEW.salary < OLD.salary`, raise error state `'45000'` with the message `'Salaries cannot be reduced.'`.
6. Write a query to list all triggers currently defined in the `sql_mastery` database.

### Difficult
7. Design an automatic stock synchronization trigger: When a new line item is added to `order_items`, an `AFTER INSERT` trigger automatically decrements the corresponding product's `stock_quantity` in `products`. What concurrency or deadlock risks does this introduce?
8. Explain why MySQL raises `ERROR 1442` if a trigger on table `T` executes an `UPDATE` on table `T`. How can you achieve same-table mutation safely?

---

## 11. Interview Questions

### Q1: What is the difference between the `NEW` and `OLD` pseudo-records in MySQL triggers?
**Answer**:
* **`NEW`** represents the row state being introduced. It is available in `INSERT` and `UPDATE` triggers. In `BEFORE INSERT` and `BEFORE UPDATE` triggers, columns of `NEW` can be modified (`SET NEW.col = value`) to sanitize or transform data before it is physically written to disk.
* **`OLD`** represents the row state prior to modification. It is available in `UPDATE` and `DELETE` triggers, and is strictly read-only.
In an `UPDATE` trigger, both `OLD` (pre-update state) and `NEW` (post-update state) are accessible simultaneously, enabling field-level delta comparisons.

### Q2: Why does MySQL prohibit a trigger from modifying the table upon which it is defined?
**Answer**: Modifying the triggering table from within its own trigger creates the risk of **infinite recursion**. For example, if an `AFTER UPDATE` trigger on `orders` executed an `UPDATE` statement on `orders`, that update would fire the trigger again, which would issue another update, creating an endless loop that would exhaust server memory and stack space. To prevent this, MySQL strictly enforces Error 1442, forbidding any DML operations on the triggering table within the trigger body.

### Q3: How do you raise a custom runtime exception inside a MySQL trigger to abort an illegal transaction?
**Answer**: You raise a custom exception using the **`SIGNAL`** statement with SQLState `'45000'` (the ANSI standard code for unhandled user-defined exceptions):
```sql
SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Validation Failed: Custom Error Description';
```
When `SIGNAL` executes, MySQL immediately halts execution, aborts the active statement, rolls back uncommitted changes within the transaction, and returns the custom error message and error code 1644 to the calling client.

---

## 12. Quick Revision

* **Triggers** are automated event handlers that execute on `INSERT`, `UPDATE`, or `DELETE`.
* **`BEFORE`** triggers run before writes (ideal for validation and modifying `NEW`); **`AFTER`** triggers run after writes (ideal for audit logging).
* **`NEW`** contains incoming row values; **`OLD`** contains pre-modification values.
* Use **`SIGNAL SQLSTATE '45000'`** to reject invalid transactions.
* Triggers **cannot modify the table they are defined on** (Error 1442).
* Keep triggers lightweight to prevent transaction lock contention on high-throughput tables.
