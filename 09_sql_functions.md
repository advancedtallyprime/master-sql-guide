# Chapter 09 — Built-in SQL Functions: String, Date, Numeric & Flow Control

---

## 1. What is it?

A **SQL function** is a built-in, pre-compiled subroutine provided by the RDBMS engine that accepts zero or more input parameters, performs a dedicated algorithmic operation, and returns a scalar (single) value.

Functions are categorized broadly into two operational modes:
1. **Scalar Functions**: Operate on individual row values independently, returning one transformed value for every input row (e.g., transforming text to uppercase with `UPPER()`, or calculating the current date with `CURDATE()`).
2. **Aggregate Functions**: Operate across multiple rows within a table or partition, summarizing an entire set of values into a single consolidated result (e.g., computing an average with `AVG()`, or counting entries with `COUNT()`).

MySQL features an extensive library of production-tested functions organized into four primary functional disciplines:
* **String & Text Functions** (manipulation, formatting, slicing, length calculation)
* **Date & Temporal Functions** (calendar math, intervals, formatting, timezone conversions)
* **Numeric & Mathematical Functions** (rounding, truncation, trigonometry, powers)
* **Conditional & Flow Control Functions** (`IF`, `CASE`, `COALESCE`, `IFNULL`, `NULLIF`)

---

## 2. Why do we use it?

1. **Server-Side Data Transformation**: Performing string concatenations (e.g., merging `first_name` and `last_name`), text casing, and date calculations directly inside the database reduces application code complexity and client-side processing overhead.
2. **Robust Handling of Missing Data**: Functions like `COALESCE` and `IFNULL` replace missing (`NULL`) values with sensible business defaults (e.g., showing `"N/A"` instead of a blank phone number).
3. **Complex Business Logic**: Conditional expressions like `CASE WHEN ... THEN` allow dynamic categorization directly inside queries (e.g., tagging customers as `"VIP"`, `"Gold"`, or `"Bronze"` based on loyalty points).
4. **Calendar & Interval Arithmetic**: Safely calculating elapsed days, expiry dates, or age in years using calendar-aware engine primitives rather than brittle custom calculations.

---

## 3. Comprehensive Function Taxonomy & Syntax

### 3.1. String Functions

| Function | Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| `CONCAT()` | `CONCAT(str1, str2, ...)` | Concatenates multiple strings together. Returns `NULL` if any argument is `NULL`. | `CONCAT('Hello', ' ', 'World')` $\rightarrow$ `'Hello World'` |
| `CONCAT_WS()` | `CONCAT_WS(separator, s1, s2, ...)` | Concatenate With Separator. Skips `NULL` values cleanly! | `CONCAT_WS(', ', 'NY', NULL, 'USA')` $\rightarrow$ `'NY, USA'` |
| `UPPER()` / `LOWER()` | `UPPER(str)` / `LOWER(str)` | Converts character string to uppercase or lowercase. | `UPPER('mysql')` $\rightarrow$ `'MYSQL'` |
| `LENGTH()` | `LENGTH(str)` | Returns length of string in **bytes** (multi-byte UTF-8 chars count as 2–4 bytes). | `LENGTH('SQL')` $\rightarrow$ `3` |
| `CHAR_LENGTH()` | `CHAR_LENGTH(str)` | Returns length of string in **characters** (accurate for UTF-8). | `CHAR_LENGTH('Café')` $\rightarrow$ `4` |
| `SUBSTRING()` | `SUBSTRING(str, pos, len)` | Extracts `len` characters starting at 1-based index `pos`. | `SUBSTRING('Database', 1, 4)` $\rightarrow$ `'Data'` |
| `TRIM()` | `TRIM(str)` | Strips leading and trailing whitespace. | `TRIM('  text  ')` $\rightarrow$ `'text'` |
| `REPLACE()` | `REPLACE(str, from, to)` | Replaces all occurrences of a substring. | `REPLACE('v1.0', '1', '2')` $\rightarrow$ `'v2.0'` |
| `INSTR()` | `INSTR(str, substr)` | Returns the 1-based position of first substring occurrence. | `INSTR('Code', 'de')` $\rightarrow$ `3` |
| `LPAD()` / `RPAD()` | `LPAD(str, len, pad)` | Left/right pads a string to length `len`. | `LPAD('42', 5, '0')` $\rightarrow$ `'00042'` |

### 3.2. Date & Time Functions

| Function | Syntax | Description |
| :--- | :--- | :--- |
| `NOW()` / `CURRENT_TIMESTAMP()` | `NOW()` | Returns current date and time (`YYYY-MM-DD HH:MM:SS`) when statement starts. |
| `CURDATE()` | `CURDATE()` | Returns current calendar date (`YYYY-MM-DD`). |
| `CURTIME()` | `CURTIME()` | Returns current time (`HH:MM:SS`). |
| `YEAR()`, `MONTH()`, `DAY()` | `YEAR(date)` | Extracts individual date parts as integers. |
| `DATEDIFF()` | `DATEDIFF(end_date, start_date)` | Computes difference in **days** (`end - start`). |
| `TIMESTAMPDIFF()` | `TIMESTAMPDIFF(unit, start, end)` | Computes difference in specified `unit` (`YEAR`, `MONTH`, `DAY`, `HOUR`, `SECOND`). |
| `DATE_ADD()` / `DATE_SUB()` | `DATE_ADD(date, INTERVAL n UNIT)` | Adds or subtracts temporal units (`INTERVAL 7 DAY`, `INTERVAL 1 MONTH`). |
| `DATE_FORMAT()` | `DATE_FORMAT(date, '%M %d, %Y')` | Formats date into custom display string. |

### 3.3. Numeric & Mathematical Functions

| Function | Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| `ROUND()` | `ROUND(num, decimals)` | Rounds to nearest value at specified decimal place. | `ROUND(15.756, 2)` $\rightarrow$ `15.76` |
| `TRUNCATE()` | `TRUNCATE(num, decimals)`| Chops off decimals without rounding. | `TRUNCATE(15.756, 2)` $\rightarrow$ `15.75` |
| `FLOOR()` | `FLOOR(num)` | Returns largest integer $\le$ number (rounds down). | `FLOOR(15.9)` $\rightarrow$ `15` |
| `CEIL()` / `CEILING()` | `CEIL(num)` | Returns smallest integer $\ge$ number (rounds up). | `CEIL(15.1)` $\rightarrow$ `16` |
| `ABS()` | `ABS(num)` | Returns absolute (positive) magnitude. | `ABS(-42)` $\rightarrow$ `42` |
| `MOD()` | `MOD(n, m)` | Modulo division remainder ($n \pmod m$). | `MOD(11, 4)` $\rightarrow$ `3` |
| `POWER()` / `POW()` | `POWER(x, y)` | Raises $x$ to the power of $y$ ($x^y$). | `POWER(2, 3)` $\rightarrow$ `8` |

### 3.4. Aggregate Functions & NULL Mechanics

```sql
SELECT 
    COUNT(*) AS total_rows,              -- Counts all rows (including rows with NULLs)
    COUNT(phone) AS rows_with_phone,     -- Counts only rows where phone IS NOT NULL
    COUNT(DISTINCT country) AS countries, -- Counts unique non-null countries
    SUM(salary) AS total_payroll,        -- Sum of non-null salaries
    AVG(salary) AS average_salary,       -- Sum / COUNT(salary) - strictly ignores NULLs!
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees;
```

> [!IMPORTANT]
> **Aggregate NULL Trap**: All aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) **silently ignore NULLs**. The only exception is `COUNT(*)`, which counts physical row records regardless of individual column contents.

### 3.5. Conditional & Flow Control Functions

```sql
-- 1. Simple Two-Branch IF: IF(condition, value_if_true, value_if_false)
SELECT first_name, IF(salary >= 100000, 'Executive', 'Standard') AS pay_band FROM employees;

-- 2. IFNULL: IFNULL(expression, fallback_value)
SELECT first_name, IFNULL(phone, 'No Phone on Record') AS contact_phone FROM customers;

-- 3. COALESCE: Returns the FIRST non-null value in an arbitrary parameter list
SELECT first_name, COALESCE(phone, state, country, 'Unknown') AS fallback_location FROM customers;

-- 4. NULLIF: Returns NULL if both arguments are equal, otherwise returns arg1
SELECT NULLIF(status, 'Pending') FROM orders;

-- 5. Standard CASE Expression (Searched CASE)
SELECT 
    customer_id,
    first_name,
    loyalty_points,
    CASE 
        WHEN loyalty_points >= 700 THEN 'Platinum Tier'
        WHEN loyalty_points >= 400 THEN 'Gold Tier'
        WHEN loyalty_points >= 100 THEN 'Silver Tier'
        ELSE 'Bronze Tier'
    END AS customer_tier
FROM customers;
```

---

## 4. Basic Example

Demonstrating scalar transformations, date formatting, and conditional expressions:

```sql
USE sql_mastery;

-- String manipulation
SELECT 
    CONCAT(UPPER(last_name), ', ', first_name) AS formal_name,
    CONCAT('USR-', LPAD(customer_id, 5, '0')) AS formatted_code,
    CHAR_LENGTH(email) AS email_character_count
FROM customers
LIMIT 3;

-- Date calculations
SELECT 
    order_id,
    order_date,
    DATE_FORMAT(order_date, '%W, %M %d, %Y') AS formatted_date,
    DATEDIFF(CURDATE(), order_date) AS days_since_order,
    DATE_ADD(order_date, INTERVAL 30 DAY) AS payment_due_date
FROM orders
LIMIT 3;
```

---

## 5. Real-World Example

The HR and Executive Operations committee requests a comprehensive Workforce Compensation Report from the `employees` table:
1. Combine `first_name` and `last_name` into `full_name`.
2. Clean up missing `phone` numbers by displaying `'Contact via HR'`.
3. Compute employee tenure in complete elapsed years using `TIMESTAMPDIFF()`.
4. Calculate a cost-of-living adjusted salary rounded to the nearest integer.
5. Classify every employee into a compensation band using a `CASE` expression.

```sql
USE sql_mastery;

SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    COALESCE(phone, 'Contact via HR') AS office_contact,
    hire_date,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS tenure_years,
    salary AS base_salary,
    ROUND(salary * 1.05, 0) AS adjusted_salary_5pct,
    CASE 
        WHEN salary >= 130000 THEN 'Tier 1 — Principal/Executive'
        WHEN salary >= 100000 THEN 'Tier 2 — Senior Specialist'
        WHEN salary >= 80000  THEN 'Tier 3 — Mid-Level Specialist'
        ELSE 'Tier 4 — Associate'
    END AS compensation_tier
FROM employees
ORDER BY salary DESC;
```

---

## 6. Step-by-Step Explanation

1. `CONCAT(first_name, ' ', last_name)`:
   * Merges the two string columns with an intervening space literal.
2. `COALESCE(phone, 'Contact via HR')`:
   * Evaluates `phone`. If `phone` is a string (e.g. `'555-0100'`), it is returned. If `phone` is `NULL`, `COALESCE` falls back to `'Contact via HR'`.
3. `TIMESTAMPDIFF(YEAR, hire_date, CURDATE())`:
   * Calculates the exact number of full years elapsed between the `hire_date` and today's calendar date, taking leap years into account.
4. `ROUND(salary * 1.05, 0)`:
   * Multiplies salary by 1.05 (a 5% adjustment) and rounds to 0 decimal places.
5. `CASE WHEN ... THEN ... END`:
   * Evaluates conditions sequentially from top to bottom. The first condition that evaluates to `TRUE` assigns the corresponding string, and execution jumps immediately to `END`.

---

## 7. Expected Result

Output of the Workforce Compensation Report:

```
+-------------+---------------------+-------------------+------------+--------------+-------------+----------------------+-------------------------------+
| employee_id | full_name           | office_contact    | hire_date  | tenure_years | base_salary | adjusted_salary_5pct | compensation_tier             |
+-------------+---------------------+-------------------+------------+--------------+-------------+----------------------+-------------------------------+
|           1 | Alex Morgan         | 555-0100          | 2019-03-15 |            7 |   145000.00 |               152250 | Tier 1 — Principal/Executive  |
|           4 | Priya Patel         | 555-0103          | 2020-02-10 |            6 |   135000.00 |               141750 | Tier 1 — Principal/Executive  |
|           6 | Elena Rostova       | 555-0105          | 2018-11-05 |            7 |   130000.00 |               136500 | Tier 1 — Principal/Executive  |
|           2 | Sarah Chen          | 555-0101          | 2020-06-01 |            6 |   125000.00 |               131250 | Tier 2 — Senior Specialist    |
|           8 | Jessica Taylor      | 555-0107          | 2019-08-12 |            7 |   110000.00 |               115500 | Tier 2 — Senior Specialist    |
|           3 | Marcus Vance        | 555-0102          | 2021-01-15 |            5 |    98000.00 |               102900 | Tier 3 — Mid-Level Specialist |
|           5 | David Kim           | 555-0104          | 2021-07-20 |            5 |    92000.00 |                96600 | Tier 3 — Mid-Level Specialist |
|          10 | Fatima Al-Mansoor   | 555-0109          | 2022-05-18 |            4 |    85000.00 |                89250 | Tier 3 — Mid-Level Specialist |
|           7 | Liam OConnor        | 555-0106          | 2022-03-01 |            4 |    78000.00 |                81900 | Tier 4 — Associate            |
|           9 | Carlos Mendoza      | 555-0108          | 2021-10-01 |            4 |    72000.00 |                75600 | Tier 4 — Associate            |
+-------------+---------------------+-------------------+------------+--------------+-------------+----------------------+-------------------------------+
10 rows in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **`CONCAT()` with `NULL` Producing `NULL`**:
   * *The Problem*: `SELECT CONCAT(first_name, ' - ', phone) FROM customers;`
   * *Failure*: If `phone` is `NULL`, `CONCAT()` turns the **entire string into `NULL`**!
   * *Remedy*: Use `CONCAT_WS()` (which skips NULLs) or wrap the column in `COALESCE(phone, '')`:
     ```sql
     SELECT CONCAT(first_name, ' - ', COALESCE(phone, 'No Phone')) FROM customers;
     ```
2. **Confusing `LENGTH()` with `CHAR_LENGTH()`**:
   * *Mistake*: Using `LENGTH()` to count user characters.
   * *Problem*: In `utf8mb4`, characters like `'é'` or emojis consume 2 to 4 bytes. `LENGTH('Café')` returns `5`, while `CHAR_LENGTH('Café')` returns `4`. Use `CHAR_LENGTH()` for character counts.
3. **`DATEDIFF()` Argument Ordering**:
   * In MySQL, `DATEDIFF(date1, date2)` computes `date1 - date2`. If you pass `DATEDIFF('2023-01-01', '2023-01-10')`, it returns `-9`.
4. **Misinterpreting `AVG()` with Nullable Columns**:
   * If a table has 4 rows with values `[100, 200, 300, NULL]`, `AVG(col)` computes `(100 + 200 + 300) / 3 = 200`. It does NOT divide by 4. If business logic requires treating NULL as 0, you must explicitly write: `AVG(COALESCE(col, 0))`.

---

## 9. Best Practices

1. **Use `COALESCE` Over Vendor-Specific `IFNULL`**:
   * `IFNULL` is MySQL-specific. `COALESCE` is ANSI SQL-standard, accepts multiple fallback parameters, and is fully portable across PostgreSQL, Oracle, and SQL Server.
2. **Never Call Non-Deterministic Functions in Loops or Joins**:
   * Calling `SYSDATE()` recalculates the clock time on every single row inspection, which degrades performance and prevents query caching. Prefer `NOW()` or `CURRENT_TIMESTAMP`, which evaluates to a constant timestamp once at statement start.
3. **Always Include an `ELSE` in `CASE` Expressions**:
   * If no `WHEN` branch matches and there is no `ELSE` clause, SQL defaults to returning `NULL`. Always specify an `ELSE` fallback to prevent unintended `NULL` propagation.

---

## 10. Practice Questions

### Easy
1. Write a query to display all customer emails converted entirely to lowercase.
2. Write a query to display the current date, current time, and current timestamp in three separate columns.
3. Write a query to round the unit price of every product to the nearest integer.

### Medium
4. Write a query using `DATE_FORMAT` to display all `order_date` values in the format `'DD/MM/YYYY'` (e.g. `'15/08/2023'`).
5. Write a query that extracts the domain name (everything following the `'@'` symbol) from the `email` column of the `employees` table.
6. Write a query that computes the total payroll, average salary, minimum salary, and maximum salary for all active employees.

### Difficult
7. Write a query against `products` that uses a `CASE` expression to calculate a `reorder_urgency` flag:
   * `'CRITICAL'` if `stock_quantity = 0`
   * `'HIGH'` if `stock_quantity <= reorder_level`
   * `'MEDIUM'` if `stock_quantity <= reorder_level * 1.5`
   * `'HEALTHY'` otherwise.
8. Compare the output of `AVG(discount)` versus `SUM(discount) / COUNT(*)` against `order_items`. Explain why they might produce different numerical results.

---

## 11. Interview Questions

### Q1: What is the mechanical difference between `COUNT(*)`, `COUNT(column_name)`, and `COUNT(DISTINCT column_name)`?
**Answer**:
* `COUNT(*)` counts the total number of physical rows retrieved, regardless of whether any or all column values in that row contain `NULL`.
* `COUNT(column_name)` counts only rows where `column_name` contains a non-NULL value, completely ignoring rows where `column_name IS NULL`.
* `COUNT(DISTINCT column_name)` counts the number of unique, non-NULL values present in that column across all matching rows.

### Q2: What is the difference between `COALESCE()` and `IFNULL()` in MySQL?
**Answer**:
1. **Parameter Flexibility**: `IFNULL(expr1, expr2)` accepts strictly two arguments, returning `expr2` if `expr1` is `NULL`. `COALESCE(expr1, expr2, ..., exprN)` accepts an arbitrary number of arguments and returns the very first non-NULL expression from left to right.
2. **Portability**: `COALESCE` is part of the standard ANSI SQL specification and supported across all enterprise RDBMS engines (PostgreSQL, SQL Server, Oracle). `IFNULL` is a proprietary MySQL function.

### Q3: How do `NOW()` and `SYSDATE()` differ in MySQL?
**Answer**: `NOW()` returns the exact timestamp at which the SQL statement *began execution*, behaving as a deterministic constant throughout the query duration. `SYSDATE()` returns the real-time clock timestamp at the exact instant that specific *row or function call is evaluated*. In long-running queries or row-by-row scans, repeated invocations of `SYSDATE()` can produce differing timestamps, which disables certain query optimizer optimizations and introduces non-deterministic behavior.

---

## 12. Quick Revision

* **Scalar functions** transform single row values; **Aggregate functions** consolidate multiple rows into summary metrics.
* Use **`CONCAT_WS()`** or **`COALESCE()`** with strings to prevent a single `NULL` from nullifying an entire string concatenation.
* **`CHAR_LENGTH()`** counts UTF-8 characters; **`LENGTH()`** measures raw storage bytes.
* All aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) **ignore NULLs**; only `COUNT(*)` counts every row.
* Use standard **`CASE WHEN ... THEN ... ELSE ... END`** for complex conditional classification.
* Use **`TIMESTAMPDIFF()`** for calendar-aware differences in years, months, or days.
