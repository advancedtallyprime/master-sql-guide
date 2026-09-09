# Chapter 21 — Custom Logic: User-Defined Functions (UDFs)

---

## 1. What is it?

A **User-Defined Function (UDF)** (or Stored Function) in MySQL is a custom, reusable computational routine stored in the database catalog that accepts zero or more input parameters, performs calculations, and **must return exactly one scalar value** via an explicit `RETURN` statement.

Unlike Stored Procedures (which are executed using the `CALL` statement and can return complex multi-row result sets), Stored Functions are designed to be used **inline within SQL expressions**—in the `SELECT` projection list, `WHERE` clauses, `ORDER BY` clauses, or `HAVING` filters—just like built-in MySQL functions (`ROUND()`, `UPPER()`, or `DATEDIFF()`).

### Function Characteristics: Determinism & Data Access
When creating a stored function, MySQL requires declaring its operational characteristics:
* **`DETERMINISTIC`**: Guarantees that the function will **always** return the exact same output when provided the exact same input arguments (e.g., converting Celsius to Fahrenheit: `(C * 9/5) + 32`). Deterministic functions can be indexed via Generated Virtual Columns and optimized by the query cache.
* **`NOT DETERMINISTIC`**: Indicates that the function's output can vary between invocations even with identical arguments (e.g., functions referencing `NOW()`, `RAND()`, or querying dynamic table data).
* **Data Access Characteristics**:
  * `NO SQL`: Contains no SQL statements (pure mathematical or string manipulation).
  * `READS SQL DATA`: Contains `SELECT` queries that read table records, but does not modify data.
  * `MODIFIES SQL DATA`: Modifies table data (strictly prohibited when the function is called inside standard `SELECT` statements).

---

## 2. Stored Procedures vs Stored Functions: The Definitive Comparison

| Architectural Dimension | Stored Procedure (`CREATE PROCEDURE`) | Stored Function (`CREATE FUNCTION`) |
| :--- | :--- | :--- |
| **Execution Syntax** | Invoked independently via `CALL sp_name(...)`. | Invoked **inline** inside SQL expressions: `SELECT fn_name(...)`. |
| **Return Mechanism** | Can return zero, one, or multiple result sets; returns values via `OUT`/`INOUT` parameters. | **Must return exactly one scalar value** via `RETURN data_type`. |
| **Transaction Control** | Can manage transactions (`START TRANSACTION`, `COMMIT`, `ROLLBACK`). | **Cannot execute transaction control statements** (`COMMIT`/`ROLLBACK` are forbidden). |
| **DML Capabilities** | Can execute arbitrary `INSERT`, `UPDATE`, `DELETE`, and DDL statements. | Cannot execute DML on base tables when called from a `SELECT` statement. |
| **Usage in Clauses** | Cannot be used inside `WHERE`, `JOIN`, or `ORDER BY`. | Can be embedded directly inside `WHERE`, `SELECT`, `HAVING`, and `JOIN`. |

---

## 3. Syntax

```sql
DELIMITER //

CREATE FUNCTION function_name (
    param1 data_type,
    param2 data_type
)
RETURNS return_data_type
[DETERMINISTIC | NOT DETERMINISTIC]
[NO SQL | READS SQL DATA]
BEGIN
    -- Local variables
    DECLARE v_result return_data_type;

    -- Business logic
    SET v_result = ...;

    -- Must terminate with a RETURN statement
    RETURN v_result;
END //

DELIMITER ;

-- Manage Functions
DROP FUNCTION IF EXISTS function_name;
SHOW CREATE FUNCTION function_name;
```

---

## 4. Basic Example

Creating a pure deterministic scalar function that calculates total cost with tax:

```sql
USE sql_mastery;

DELIMITER //

CREATE FUNCTION fn_calculate_sales_tax(
    p_subtotal DECIMAL(10, 2),
    p_tax_rate DECIMAL(4, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_tax_amount DECIMAL(10, 2);
    SET v_tax_amount = ROUND(p_subtotal * p_tax_rate, 2);
    RETURN p_subtotal + v_tax_amount;
END //

DELIMITER ;

-- Test the function inline within a standard SELECT query
SELECT 
    product_name,
    unit_price,
    fn_calculate_sales_tax(unit_price, 0.08) AS price_with_8pct_tax
FROM products
LIMIT 3;

-- Clean up
DROP FUNCTION fn_calculate_sales_tax;
```

---

## 5. Real-World Example

The enterprise finance group requires a standardized customer classification function named `fn_get_customer_tier` that evaluates a customer's total loyalty points and lifetime order value, returning a standardized tier label (`'Platinum'`, `'Gold'`, `'Silver'`, or `'Standard'`).

```sql
USE sql_mastery;

DELIMITER //

CREATE FUNCTION fn_get_customer_tier(p_customer_id INT)
RETURNS VARCHAR(20)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_points INT;
    DECLARE v_total_spend DECIMAL(12, 2);
    DECLARE v_tier VARCHAR(20);

    -- Retrieve customer loyalty points
    SELECT loyalty_points INTO v_points
    FROM customers
    WHERE customer_id = p_customer_id;

    -- Retrieve customer lifetime spending
    SELECT COALESCE(SUM(total_amount), 0.00) INTO v_total_spend
    FROM orders
    WHERE customer_id = p_customer_id AND status != 'Cancelled';

    -- Evaluate customer tier using combined multi-variable logic
    IF v_points >= 600 AND v_total_spend >= 1000.00 THEN
        SET v_tier = 'Platinum';
    ELSEIF v_points >= 300 OR v_total_spend >= 500.00 THEN
        SET v_tier = 'Gold';
    ELSEIF v_points >= 100 THEN
        SET v_tier = 'Silver';
    ELSE
        SET v_tier = 'Standard';
    END IF;

    RETURN v_tier;
END //

DELIMITER ;

-- Query customers using our custom function directly in the SELECT list and WHERE clause!
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    loyalty_points,
    fn_get_customer_tier(customer_id) AS membership_tier
FROM customers
ORDER BY loyalty_points DESC;
```

---

## 6. Step-by-Step Explanation

1. `CREATE FUNCTION fn_get_customer_tier(...) RETURNS VARCHAR(20)`:
   * Compiles the function and registers it in the `mysql.proc` / data dictionary.
2. `NOT DETERMINISTIC READS SQL DATA`:
   * Informs MySQL that this function queries dynamic table data (`customers` and `orders`), meaning its output can change if new orders are inserted.
3. `SELECT loyalty_points INTO v_points ...`:
   * Reads the current point balance for the specified customer into local variable `v_points`.
4. `SELECT COALESCE(SUM(total_amount), 0.00) INTO v_total_spend ...`:
   * Computes the lifetime non-cancelled order spend, converting `NULL` into `0.00` via `COALESCE`.
5. `IF ... ELSEIF ... END IF`:
   * Evaluates business rules and assigns the appropriate tier string.
6. `RETURN v_tier;`:
   * Emits the scalar result back to the outer SQL query engine, which incorporates it directly into the result set stream.

---

## 7. Expected Result

Output of the customer tier query:

```
+-------------+-------------------+----------------+-----------------+
| customer_id | customer_name     | loyalty_points | membership_tier |
+-------------+-------------------+----------------+-----------------+
|          10 | Ethan Hunt        |            940 | Gold            |
|           3 | Sophia Garcia     |            750 | Gold            |
|           5 | Aisha Khan        |            610 | Platinum        |
|           9 | Chloe Dubois      |            480 | Gold            |
|           1 | Emily Watson      |            420 | Platinum        |
|           6 | Lucas Muller      |            310 | Gold            |
|           8 | Mateo Silva       |            290 | Silver          |
|           2 | Michael Brown     |            180 | Silver          |
|           4 | James Wilson      |             90 | Gold            |
|           7 | Hannah Scott      |             50 | Standard        |
+-------------+-------------------+----------------+-----------------+
10 rows in set (0.01 sec)
```
*(Notice that Customer 5 [Aisha] and Customer 1 [Emily] qualify for Platinum because both their points exceed 600/300 AND their total lifetime spend exceeds $1,000).*

---

## 8. Common Mistakes

1. **Missing Determinism Declarations (MySQL Error 1418)**:
   * *The Error*:
     `ERROR 1418 (HY000): This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled`
   * *Why?*: When binary logging is enabled in MySQL (e.g. for replication), MySQL requires every function to be marked as `DETERMINISTIC` or with a data access clause to guarantee that replicated execution on replica servers produces identical data. Always include these keywords!
2. **Calling Functions that Read Tables Inside Huge Queries (The $N+1$ Problem)**:
   * Calling a function like `fn_get_customer_tier(customer_id)` in a query that processes 100,000 rows causes the function to execute 100,000 separate subqueries, destroying query throughput. For large datasets, compute metrics using set-based `LEFT JOIN`s and `CASE` expressions rather than row-by-row function calls.
3. **Attempting to Execute Transactions Inside a Function**:
   * Placing `START TRANSACTION;` or `COMMIT;` inside a function triggers a fatal compilation error:
     `ERROR 1422 (HY000): Explicit or implicit commit is not allowed in stored function`.

---

## 9. Best Practices

1. **Keep Functions Short, Pure, and Fast**:
   * Ideal functions are pure scalar utilities (calculating tax, validating email patterns, formatting phone numbers, converting currencies).
2. **Prefix Custom Functions**:
   * Prefix functions with `fn_` or `udf_` (e.g., `fn_calculate_tax`) to distinguish them from native MySQL built-ins.
3. **Use Deterministic Functions to Back Generated Virtual Columns**:
   * You can define a generated column in a table using a deterministic function and place an index on it:
     ```sql
     ALTER TABLE products ADD COLUMN discounted_price DECIMAL(10,2) 
     AS (fn_calculate_discount(unit_price)) STORED;
     CREATE INDEX idx_discounted_price ON products(discounted_price);
     ```

---

## 10. Practice Questions

### Easy
1. What is the fundamental operational difference between a Stored Procedure and a User-Defined Function?
2. What keyword is mandatory inside the body of a stored function to pass the result back?
3. Which keyword declares that a function will always return the exact same output for identical inputs?

### Medium
4. Write a deterministic function named `fn_celsius_to_fahrenheit` that accepts a `DECIMAL(5,2)` temperature in Celsius and returns the corresponding Fahrenheit value (`(C * 9/5) + 32`).
5. Write a function named `fn_format_phone` that accepts a 7-digit string (e.g., `'5550100'`) and formats it with a dash (e.g., `'555-0100'`).
6. Write a function `fn_get_employee_tenure` that accepts an `employee_id` and returns their tenure in complete years by querying the `employees` table.

### Difficult
7. Explain why MySQL forbids executing transactions (`COMMIT` / `ROLLBACK`) or modifying base tables inside a function that is invoked within a `SELECT` statement.
8. Compare the execution plan and performance of running `SELECT fn_get_customer_tier(customer_id) FROM customers;` versus writing an equivalent set-based `LEFT JOIN ... GROUP BY ... CASE` query. Under what circumstances will the set-based query outperform the function by orders of magnitude?

---

## 11. Interview Questions

### Q1: What is the difference between a Stored Procedure and a Stored Function in MySQL?
**Answer**:
1. **Calling Context**: Procedures are invoked using `CALL procedure_name(...)` as independent statements. Functions are invoked inline within SQL expressions (`SELECT fn(col) FROM table`).
2. **Return Constraints**: A procedure can return multiple result sets, or return multiple values through `OUT`/`INOUT` parameters. A function must return exactly **one scalar value** using the `RETURN` keyword.
3. **Transaction Control**: Procedures can manage transactions (`START TRANSACTION`, `COMMIT`, `ROLLBACK`). Functions cannot execute transaction control statements.
4. **Side Effects**: Functions invoked within a `SELECT` statement are strictly forbidden from modifying table data (no `INSERT`, `UPDATE`, or `DELETE` on base tables), guaranteeing that read queries do not alter system state.

### Q2: Why is the `DETERMINISTIC` keyword significant in MySQL functions?
**Answer**: `DETERMINISTIC` informs the query optimizer that the function will always return the exact same result given the same input parameters. 
Significance:
1. **Optimization**: The query optimizer can cache function results, optimize subqueries, and avoid re-evaluating the function repeatedly for identical values during a table scan.
2. **Generated Columns**: Only deterministic functions can be used to define virtual or stored generated columns in MySQL tables.
3. **Replication Safety**: In environments with binary logging enabled, MySQL requires functions to be declared `DETERMINISTIC` (or declare that they do not modify data) to prevent non-deterministic values from creating inconsistencies between primary and replica servers.

### Q3: What is the "N+1 Problem" when using stored functions that query tables inside a `SELECT` statement?
**Answer**: When a stored function contains a `SELECT` query (e.g., querying order totals for a customer) and is invoked in the projection of an outer query (`SELECT customer_id, fn_get_lifetime_spend(customer_id) FROM customers`), the database executes 1 query to fetch the $N$ customers, and then invokes the function individually for each row, executing $N$ additional subqueries. This results in $N+1$ total queries. For large datasets (e.g., 100,000 customers), this causes severe I/O bottlenecks. It should be rewritten as a single set-based query joining `customers` to a pre-aggregated subquery on `orders`.

---

## 12. Quick Revision

* **User-Defined Functions (UDFs)** return **exactly one scalar value** and run **inline** inside SQL queries.
* Functions **cannot manage transactions** (`COMMIT`/`ROLLBACK` are forbidden).
* Mark functions as **`DETERMINISTIC`** if identical inputs always produce identical results.
* Use **`READS SQL DATA`** or **`NO SQL`** to satisfy binary logging requirements (Error 1418).
* Avoid row-by-row table queries inside functions on large datasets to prevent the **N+1 query bottleneck**.
