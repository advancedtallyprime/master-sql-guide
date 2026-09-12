# Chapter 20 — Database Programmability: Stored Procedures & Control Flow (Stored Procedures Aur Control Flow)

---

## 1. What is it? (Ye Kya Hai?)

MySQL me **Stored Procedure** ek pre-compiled subroutine (ya functions ka block) hota hai jisme ek ya ek se zyada SQL statements aur procedural control-flow logic (`IF`, `CASE`, `WHILE`, `LOOP`) shamil hote hain, jo seedhe database dictionary ke andar permanently store rehte hain.

Application servers database ko sirf ek single command bhejkar procedure call karte hain: **`CALL procedure_name(...)`**. Kyunki ye routine database server par pehle se maujood rehti hai, isliye SQL queries pehle se parsed, validated aur optimized hoti hain, jisse execution speed kaafi tez ho jaati hai.

### The `DELIMITER` Command: Iski Zaroorat Kyun Padti Hai?
By default, MySQL client terminal ek semicolon (`;`) ko SQL statement ka termination delimiter maanta hai. Lekin ek Stored Procedure ke andar multiple internal SQL statements hote hain jo har line ke aage semicolon (`;`) lagate hain. Agar aap client delimiter nahi badlenge, toh MySQL parser pehli internal line ke semicolon par hi procedure ko execute karne ki koshish karega aur poora procedure banne se pehle hi syntax error throw kar dega!

Isliye MySQL CLI me procedure likhte waqt hum temporary roop se statement delimiter ko kisi doosre symbol (aamtaur par `//` ya `$$`) par switch karte hain, poora procedure compile karte hain, aur fir delimiter ko wapas standard semicolon (`;`) par reset kar dete hain:

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

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Reduced Network Traffic**: Agar kisi complex business process ke liye 15 alag-alag queries run karni hain, toh application aur database server ke beech 15 baar network round-trip lene ke bajaye, app sirf ek `CALL` command bhejti hai. Poora 15-step execution database ke andar hi fast local memory me execute ho jata hai, jisse network latency drastically reduce ho jaati hai.
2. **Encapsulation & Strong Security**: Aap users aur applications ko stored procedure par `EXECUTE` privilege de sakte hain aur base tables par direct `SELECT`, `UPDATE`, ya `DELETE` permissions poori tarah revoke kar sakte hain. Stored procedure ek secure API gateway ban jata hai jo sensitive raw tables ko directly expose nahi hone deta.
3. **Centralized Business Logic**: Agar aapki company me alag-alag technology stacks hain (jaise Python backend, Java enterprise microservice, aur mobile reporting tool), toh business logic (jaise checkout validation ya salary calculation) har jagah duplicate likhne ke bajaye stored procedure me daal dijiye. Sabhi clients ke liye bilkul identical rules chalenge!
4. **Pre-Compiled Efficiency**: Repeated executions ke liye query parsing aur optimization overhead reduce ho jata hai.

---

## 3. Syntax (Syntax)

Stored procedures calling application ke sath teen tarah ke parameter modes ke zariye communicate karte hain:

| Parameter Mode | Direction | Behavior Description |
| :--- | :--- | :--- |
| **`IN`** (Default) | Caller $\rightarrow$ Procedure | Procedure ke andar data pass karta hai. Procedure is variable ko andar read aur modify kar sakta hai, lekin caller ke original variable par koi asar nahi padta. |
| **`OUT`** | Procedure $\rightarrow$ Caller | Procedure ke andar ek uninitialized variable bheja jata hai. Procedure calculation karta hai aur result isme assign karke caller ko wapas return karta hai. |
| **`INOUT`** | Caller $\leftrightarrow$ Procedure | Ek initial value procedure ke andar aati hai; procedure use read karta hai, modify karta hai, aur badli hui value caller ko wapas return karta hai. |

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

## 4. Basic Example (Basic Example)

Ek simple stored procedure banate hain aur call karke dekhte hain:

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

## 5. Real-World Example (Real-World Example)

Chaliye ek production-ready enterprise stored procedure `sp_process_order_checkout` banate hain jo complete business transaction coordinate karta hai:
1. Product ki existence aur sufficient stock availability verify karta hai.
2. Error aane par poore transaction ko automatic `ROLLBACK` karne ke liye `SQLEXCEPTION` handler declare karta hai.
3. Managed transaction ke andar naya order record generate karta hai.
4. Line item create karta hai aur inventory ko automatically decrement karta hai.
5. Naya generated `order_id` aur status message `OUT` parameters ke roop me caller ko safely return karta hai.

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

## 6. Step-by-Step Explanation (Step-by-Step Explanation)

Chaliye procedure ko test karke execution steps verify karte hain:

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

## 7. Expected Result (Expected Result)

Stored procedure call karne par terminal output:

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

## 8. Common Mistakes (Common Mistakes)

1. **`DELIMITER` Ko Wapas Reset Karna Bhool Jana**:
   * *Mistake*: `DELIMITER //` karke procedure compile kar liya aur aakhiri line me `DELIMITER ;` run karna bhool gaye.
   * *Natija*: Iske baad aapki koi bhi aam query (jaise `SELECT * FROM employees;`) run nahi hogi aur terminal freeze hokar `//` symbol aane ka wait karta rahega!
2. **Variable Shadowing (Name Collisions Ka Khatarnak Jaal)**:
   * *The Nightmare Trap*:
     ```sql
     CREATE PROCEDURE get_emp(IN employee_id INT)
     BEGIN
         SELECT * FROM employees WHERE employee_id = employee_id; -- AMBIGUOUS!
     END;
     ```
   * *Result*: MySQL parser `employee_id = employee_id` ko ek tautology (`WHERE 1 = 1`) samajh leta hai aur specific employee ke bajaye **company ke sabhi employees ka data ek sath return kar deta hai**! Massive security aur privacy leak!
   * *Rule*: Hamesha parameters ke aage `p_` lagayein (`p_employee_id`) aur local variables ke aage `v_` lagayein (`v_salary`).
3. **`DECLARE` Statements Ko Galat Jagah Likhna**:
   * MySQL stored procedures me sabhi `DECLARE` statements (variables, handlers, cursors) ko `BEGIN ... END` block ke **bilkul shuruat** me likhna mandatory hota hai. Kisi bhi executable statement (jaise `SET` ya `SELECT`) ke baad `DECLARE` likhne par syntax error aata hai.

---

## 9. Best Practices (Best Practices)

1. **Strict Naming Conventions Apnayein**:
   * Procedures ke aage `sp_` ya `usp_` (User Stored Procedure) lagayein.
   * Parameters ke aage hamesha `p_` aur local variables ke aage `v_` lagayein taaki column name collisions ka koi chance na rahe.
2. **Transactions Ke Sath Hamesha Exception Handlers Lagayein**:
   * Multi-statement transactional procedures me hamesha `DECLARE EXIT HANDLER FOR SQLEXCEPTION` use karein taaki runtime error aane par uncommitted locks na phasein aur database automatically `ROLLBACK` ho jaye.
3. **Procedural Loops Ke Bajaye Set-Based SQL Use Karein**:
   * Beginners aksar row-by-row data process karne ke liye `WHILE` loops aur `CURSORS` likhne lagte hain. Relational database engines set-based operations (`UPDATE table SET col = ... WHERE ...`) par 100 guna zyada tez chalte hain. Loops ka use sirf tabhi karein jab koi task pure SQL me solve karna impossible ho.

---

## 10. Practice Questions (Practice Questions)

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

## 11. Interview Questions (Interview Questions)

### Q1: What are the primary advantages and disadvantages of using Stored Procedures?
**Answer**:
* **Advantages (Fayde)**:
  1. **Reduced Network Overhead**: Consolidates multi-query interactions into a single network round-trip.
  2. **Security & Data Abstraction**: Applications can be granted `EXECUTE` rights on procedures without direct table access.
  3. **Centralized Business Rules**: Shared logic is maintained in one place across multiple client applications.
* **Disadvantages (Nuksan)**:
  1. **Database Server CPU Contention**: Intensive procedural computations consume database CPU, which is typically harder and more expensive to scale horizontally than stateless application servers.
  2. **Version Control & CI/CD Complexity**: Managing database migration scripts, branching, and automated testing for stored routines is more difficult than standard application code.
  3. **Vendor Lock-in**: Procedural dialects (MySQL PL/SQL, Oracle PL/SQL, SQL Server T-SQL) are proprietary and non-portable.

### Q2: What is the difference between an `IN`, `OUT`, and `INOUT` parameter?
**Answer**:
* **`IN`**: Passes data into the procedure. The procedure can read it, but cannot overwrite the caller's original variable outside the procedure.
* **`OUT`**: Passes an uninitialized variable into the procedure. The procedure computes a value and assigns it to the variable, making the result available to the caller after the procedure finishes.
* **`INOUT`**: Passes an initialized variable into the procedure; the procedure reads the initial value, modifies it, and returns the updated value back to the caller.

### Q3: What is variable shadowing in MySQL stored procedures, and how do you prevent it?
**Answer**: Variable shadowing occurs when a parameter or local variable shares the exact same identifier name as a column in a referenced table (e.g., `WHERE customer_id = customer_id`). The MySQL parser cannot distinguish between the column reference and the variable reference, typically resolving the clause to `true` for every row. This results in unintended updates or mass data exposure. 
It is prevented by strictly adopting prefix naming conventions: prefixing all procedure parameters with `p_` (e.g., `p_customer_id`) and all local variables with `v_` (e.g., `v_customer_id`).

---

## 12. Quick Revision (Quick Revision)

* Use **`DELIMITER //`** when creating procedures to prevent early statement termination.
* **`IN`** passes data in; **`OUT`** returns data to the caller; **`INOUT`** does both.
* Place all **`DECLARE`** statements at the very beginning of the `BEGIN ... END` block.
* Avoid name collisions by prefixing parameters with **`p_`** and local variables with **`v_`**.
* Use **`DECLARE EXIT HANDLER FOR SQLEXCEPTION`** to automatically roll back transactions upon error.
