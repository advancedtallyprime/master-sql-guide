# Chapter 20 — Database Programmability: Stored Procedures & Control Flow

---

## 1. What is it?

A **Stored Procedure** is a pre-compiled subroutine consisting of one or more SQL statements and procedural control-flow logic (`IF`, `CASE`, `WHILE`, `LOOP`) stored directly inside the database data dictionary.

Applications execute a stored procedure by issuing a single **`CALL procedure_name(...)`** command. Because the routine lives on the database server, the query statements are parsed, validated, and optimized in advance.

### The `DELIMITER` Command: Why Is It Mandatory?
By default, the MySQL client interprets a semicolon (`;`) as the termination delimiter of an SQL statement. However, a stored procedure contains multiple internal semicolons to separate its statements. If you do not change the client delimiter, the MySQL parser attempts to execute the first internal line of the procedure before the definition is complete, triggering syntax errors!

To define a procedure in the MySQL CLI, you temporarily reassign the statement delimiter to an alternative string (commonly `//` or `$$`), complete the procedure definition, and then reset the delimiter back to `;`:

```sql
DELIMITER //
CREATE PROCEDURE my_procedure()
BEGIN
    -- Internal statements end with standard semicolon ;
    SELECT * FROM employees;
END //
DELIMITER ;
```

---

## 2. Why do we use it?

1. **Reduced Network Traffic**: Complex business transactions requiring 15 separate queries can be bundled inside a single stored procedure. Instead of sending 15 round-trip network requests between the application server and the database, the application issues a single `CALL` statement, drastically reducing network latency.
2. **Encapsulation & Security**: You can grant users `EXECUTE` privileges on a stored procedure while revoking direct `SELECT`, `UPDATE`, and `DELETE` permissions on the underlying base tables. The stored procedure acts as a secure API gateway controlling access to sensitive data.
3. **Centralized Business Logic**: When multiple disparate applications (e.g., a Python backend, a legacy Java service, and a mobile reporting tool) interact with the same database, embedding shared business rules (such as checkout validation or payroll calculation) inside a stored procedure ensures identical logic across all platforms.
4. **Pre-Compiled Execution Efficiency**: Stored procedures reduce query parsing overhead on repeated executions.

---

## 3. Parameter Modes: `IN`, `OUT`, and `INOUT`

Stored procedures communicate with calling applications through three distinct parameter modes:

| Parameter Mode | Direction | Behavior Description |
| :--- | :--- | :--- |
| **`IN`** (Default) | Caller $\rightarrow$ Procedure | Passes a value into the procedure. The procedure can read and modify the variable internally, but changes are **not** visible to the caller. |
| **`OUT`** | Procedure $\rightarrow$ Caller | Passes an uninitialized variable into the procedure. The procedure computes a result and assigns it to the variable, returning it to the caller. |
| **`INOUT`** | Caller $\leftrightarrow$ Procedure | Passes an initial value into the procedure; the procedure can read it, modify it, and return the modified value back to the caller. |

---

## 4. Syntax

### Procedural Control-Flow Constructs
```sql
DELIMITER //

CREATE PROCEDURE sp_demo_flow(
    IN p_employee_id INT,
    OUT p_bonus_amount DECIMAL(10,2)
)
BEGIN
    -- 1. Local Variable Declarations (Must appear first in BEGIN block)
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_tenure_years INT;

    -- 2. Populate variables from table queries using INTO
    SELECT salary, TIMESTAMPDIFF(YEAR, hire_date, CURDATE())
    INTO v_salary, v_tenure_years
    FROM employees
    WHERE employee_id = p_employee_id;

    -- 3. Conditional Flow: IF - ELSEIF - ELSE
    IF v_tenure_years >= 5 THEN
        SET p_bonus_amount = v_salary * 0.20;
    ELSEIF v_tenure_years >= 2 THEN
        SET p_bonus_amount = v_salary * 0.10;
    ELSE
        SET p_bonus_amount = v_salary * 0.05;
    END IF;

END //

DELIMITER ;
```

### Managing Stored Procedures
```sql
-- Execute a Stored Procedure
CALL procedure_name(arg1, @out_var);

-- View Procedure Definition
SHOW CREATE PROCEDURE procedure_name;

-- Drop Procedure
DROP PROCEDURE IF EXISTS procedure_name;
```

---

## 5. Basic Example

Creating and calling a simple stored procedure:

```sql
USE sql_mastery;

DELIMITER //

CREATE PROCEDURE sp_get_department_employees(IN p_dept_id INT)
BEGIN
    SELECT employee_id, first_name, last_name, salary
    FROM employees
    WHERE department_id = p_dept_id
    ORDER BY salary DESC;
END //

DELIMITER ;

-- Call the procedure for Department 1 (Engineering)
CALL sp_get_department_employees(1);

-- Clean up
DROP PROCEDURE sp_get_department_employees;
```

---

## 6. Real-World Example: An Enterprise Checkout Order Processor

Let us design an enterprise stored procedure `sp_process_order_checkout` that coordinates:
1. Validating that the product exists and has sufficient stock.
2. Generating a new order record inside a managed transaction.
3. Inserting the line item and calculating totals.
4. Decrementing stock inventory.
5. Returning the newly created `order_id` as an `OUT` parameter, along with an informative status message.

```sql
USE sql_mastery;

DELIMITER //

CREATE PROCEDURE sp_process_order_checkout(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_new_order_id INT,
    OUT p_status_message VARCHAR(100)
)
BEGIN
    -- Local variables
    DECLARE v_current_stock INT;
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE v_total_cost DECIMAL(12, 2);

    -- Declare an exception handler for SQLEXCEPTION: rollback on any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_new_order_id = NULL;
        SET p_status_message = 'ERROR: Transaction rolled back due to internal database failure.';
    END;

    -- Step 1: Check product stock and price
    SELECT stock_quantity, unit_price
    INTO v_current_stock, v_unit_price
    FROM products
    WHERE product_id = p_product_id;

    -- Validate product existence
    IF v_unit_price IS NULL THEN
        SET p_new_order_id = NULL;
        SET p_status_message = 'REJECTED: Product does not exist.';
    -- Validate stock quantity
    ELSEIF v_current_stock < p_quantity THEN
        SET p_new_order_id = NULL;
        SET p_status_message = CONCAT('REJECTED: Insufficient stock. Only ', v_current_stock, ' available.');
    ELSE
        -- Step 2: Begin Transaction
        START TRANSACTION;

        SET v_total_cost = v_unit_price * p_quantity;

        -- Insert Order
        INSERT INTO orders (customer_id, order_date, status, shipping_fee, total_amount)
        VALUES (p_customer_id, CURDATE(), 'Pending', 15.00, v_total_cost + 15.00);

        -- Capture auto-generated order_id
        SET p_new_order_id = LAST_INSERT_ID();

        -- Insert Line Item
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
        VALUES (p_new_order_id, p_product_id, p_quantity, v_unit_price, 0.00);

        -- Decrement stock
        UPDATE products
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;

        -- Commit changes
        COMMIT;

        SET p_status_message = 'SUCCESS: Order placed and inventory updated successfully.';
    END IF;

END //

DELIMITER ;
```

---

## 7. Step-by-Step Explanation & Execution

Let us test the stored procedure:

```sql
USE sql_mastery;

-- Test 1: Successful Order (Customer 1 orders 2 units of Product 3 TrueSound Headphones)
CALL sp_process_order_checkout(1, 3, 2, @order_id, @status_msg);

-- Inspect output parameters
SELECT @order_id AS generated_order_id, @status_msg AS execution_result;

-- Test 2: Insufficient Stock Rejection (Customer 1 tries to order 9999 units of Product 3)
CALL sp_process_order_checkout(1, 3, 9999, @failed_order_id, @failed_msg);

-- Inspect rejection output
SELECT @failed_order_id AS failed_order_id, @failed_msg AS rejection_reason;

-- Clean up demo order
DELETE FROM order_items WHERE order_id = @order_id;
DELETE FROM orders WHERE order_id = @order_id;
UPDATE products SET stock_quantity = stock_quantity + 2 WHERE product_id = 3;
DROP PROCEDURE sp_process_order_checkout;
```

---

## 8. Expected Result

Terminal output from calling the stored procedure:

```
mysql> SELECT @order_id AS generated_order_id, @status_msg AS execution_result;
+--------------------+---------------------------------------------------------------+
| generated_order_id | execution_result                                              |
+--------------------+---------------------------------------------------------------+
|               1011 | SUCCESS: Order placed and inventory updated successfully.     |
+--------------------+---------------------------------------------------------------+
1 row in set (0.01 sec)

mysql> SELECT @failed_order_id AS failed_order_id, @failed_msg AS rejection_reason;
+-----------------+----------------------------------------------------+
| failed_order_id | rejection_reason                                   |
+-----------------+----------------------------------------------------+
|            NULL | REJECTED: Insufficient stock. Only 118 available.  |
+-----------------+----------------------------------------------------+
1 row in set (0.00 sec)
```

---

## 9. Common Mistakes

1. **Forgetting to Reset the `DELIMITER`**:
   * *Mistake*: Changing `DELIMITER //`, compiling the procedure, and forgetting to run `DELIMITER ;`.
   * *Consequence*: Subsequent standard SQL queries like `SELECT * FROM employees;` will appear to hang, waiting for `//` to terminate the statement.
2. **Variable Shadowing (Name Collisions)**:
   * *The Nightmare Trap*:
     ```sql
     CREATE PROCEDURE get_emp(IN employee_id INT)
     BEGIN
         SELECT * FROM employees WHERE employee_id = employee_id; -- AMBIGUOUS!
     END;
     ```
   * *Consequence*: The parser evaluates `employee_id = employee_id` as a tautology (`WHERE 1 = 1`), returning **every employee in the entire company** instead of the requested one!
   * *Rule*: Always prefix parameters with `p_` (e.g., `p_employee_id`) and local variables with `v_` (e.g., `v_salary`).
3. **Placing `DECLARE` Statements Out of Order**:
   * In MySQL stored procedures, all `DECLARE` statements for local variables, conditions, cursors, and handlers must be placed at the **very beginning** of the `BEGIN ... END` block, before any executable statements. Placing a `DECLARE` after an assignment triggers a syntax error.

---

## 10. Best Practices

1. **Adopt Strict Naming Conventions**:
   * Prefix procedures with `sp_` or `usp_` (User Stored Procedure).
   * Prefix parameters with `p_` and local variables with `v_`.
2. **Always Implement Exception Handlers with Transactions**:
   * Include `DECLARE EXIT HANDLER FOR SQLEXCEPTION` when writing multi-statement transactions to ensure that errors automatically trigger a `ROLLBACK`, preventing orphaned uncommitted locks.
3. **Avoid Procedural Loops When Set-Based SQL Can Do the Job**:
   * Beginners often write procedural `WHILE` loops and `CURSORS` to process rows one by one. In relational databases, set-based operations (`UPDATE table SET col = ... WHERE ...`) are typically 100x faster than cursor loops. Use loops only when procedural logic cannot be expressed declaratively.

---

## 11. Practice Questions

### Easy
1. Why must you change the client `DELIMITER` when creating a stored procedure in MySQL?
2. What is the difference between an `IN` parameter and an `OUT` parameter?
3. Which SQL command executes a stored procedure?

### Medium
4. Write a stored procedure named `sp_update_product_price` that accepts a `p_product_id INT` and a `p_percentage_increase DECIMAL(4,2)` as `IN` parameters and increases the product's `unit_price` by that percentage.
5. Write a procedure `sp_get_customer_metrics` that takes a `customer_id` as an `IN` parameter and returns their total order count as an `OUT` parameter and total spend as an `OUT` parameter.
6. Write a stored procedure using a `WHILE` loop to insert 5 test records into a table.

### Difficult
7. Write a stored procedure `sp_transfer_department` that moves an employee from their current department to a new department, updates their salary based on the new department's average, and logs the transfer in an audit table. Wrap all operations in a transaction with an `EXIT HANDLER FOR SQLEXCEPTION`.
8. Explain the performance implications of placing heavy business logic inside MySQL stored procedures versus executing that logic within an application service layer (e.g., Go, Java, or Python microservices). What are the scaling tradeoffs?

---

## 12. Interview Questions

### Q1: What are the primary advantages and disadvantages of using Stored Procedures?
**Answer**:
* **Advantages**:
  1. **Reduced Network Overhead**: Consolidates multi-query interactions into a single network round-trip.
  2. **Security & Data Abstraction**: Applications can be granted `EXECUTE` rights on procedures without direct table access.
  3. **Centralized Business Rules**: Shared logic is maintained in one place across multiple client applications.
* **Disadvantages**:
  1. **Database Server CPU Contention**: Intensive procedural computations consume database CPU, which is typically harder and more expensive to scale horizontally than stateless application servers.
  2. **Version Control & CI/CD Complexity**: Managing database migration scripts, branching, and automated testing for stored routines is more difficult than standard application code.
  3. **Vendor Lock-in**: Procedural dialects (MySQL PL/SQL, Oracle PL/SQL, SQL Server T-SQL) are proprietary and non-portable.

### Q2: What is the difference between an `IN`, `OUT`, and `INOUT` parameter?
**Answer**:
* **`IN`**: Passes data into the procedure. The procedure can read it, but cannot overwrite the caller's original variable outside the procedure.
* **`OUT`**: Passes an empty variable into the procedure. The procedure computes a value and assigns it to the variable, making the result available to the caller after the procedure finishes.
* **`INOUT`**: Passes an initialized variable into the procedure; the procedure reads the initial value, modifies it, and returns the updated value back to the caller.

### Q3: What is variable shadowing in MySQL stored procedures, and how do you prevent it?
**Answer**: Variable shadowing occurs when a parameter or local variable shares the exact same identifier name as a column in a referenced table (e.g., `WHERE customer_id = customer_id`). The MySQL parser cannot distinguish between the column reference and the variable reference, typically resolving the clause to `true` for every row. This results in unintended updates or mass data exposure. 
It is prevented by strictly adopting prefix naming conventions: prefixing all procedure parameters with `p_` (e.g., `p_customer_id`) and all local variables with `v_` (e.g., `v_customer_id`).

---

## 13. Quick Revision

* Use **`DELIMITER //`** when creating procedures to prevent early statement termination.
* **`IN`** passes data in; **`OUT`** returns data to the caller; **`INOUT`** does both.
* Place all **`DECLARE`** statements at the very beginning of the `BEGIN ... END` block.
* Avoid name collisions by prefixing parameters with **`p_`** and local variables with **`v_`**.
* Use **`DECLARE EXIT HANDLER FOR SQLEXCEPTION`** to automatically roll back transactions upon error.
