# Chapter 08 — SQL Operators & Expression Evaluation

---

## 1. What is it?

An **operator** in SQL is a reserved keyword or symbol that instructs the database engine to perform a specific mathematical, logical, comparison, or bitwise computation on one or more data items (operands).

Operands can be table column values, literal constants, subquery results, or the return values of functions. When combined, operators and operands form **expressions** that evaluate to a scalar value (e.g., a number, string, or boolean truth value).

SQL operators are organized into six distinct functional families:
1. **Arithmetic Operators**: Perform basic numerical computations (`+`, `-`, `*`, `/`, `DIV`, `%` / `MOD`).
2. **Comparison Operators**: Compare two expressions and return a boolean truth value (`=`, `!=`, `<>`, `<`, `>`, `<=`, `>=`, `<=>`).
3. **Logical Operators**: Combine multiple boolean conditions (`AND`, `OR`, `NOT`, `XOR`).
4. **Set & Membership Operators**: Test presence against sets or ranges (`IN`, `NOT IN`, `BETWEEN`, `EXISTS`, `ANY`, `ALL`).
5. **Pattern & Regular Expression Operators**: Test string patterns (`LIKE`, `NOT LIKE`, `REGEXP` / `RLIKE`).
6. **Bitwise Operators**: Perform binary bit-level operations (`&`, `|`, `^`, `~`, `<<`, `>>`).

---

## 2. Why do we use it?

1. **Dynamic Business Calculations**: Computing discounted prices (`unit_price * (1 - discount)`), calculating employee bonuses, or determining tax withholdings directly in the database engine.
2. **Multi-Condition Filtering**: Combining business rules (e.g., *"Select orders that are either Shipped OR Delivered AND have a total amount over $500"*).
3. **Advanced Pattern Matching**: Searching user text inputs, validating email formats, or extracting international dialing prefixes using regular expressions (`REGEXP`).
4. **Safe Nullability Comparison**: Comparing two columns that might both contain `NULL` without breaking relational logic via the MySQL NULL-Safe Equality operator (`<=>`).

---

## 3. Comprehensive Operator Taxonomy & Syntax

### 3.1. Arithmetic Operators

```sql
SELECT 
    10 + 5  AS addition,         -- 15
    10 - 3  AS subtraction,      -- 7
    10 * 4  AS multiplication,   -- 40
    10 / 4  AS standard_div,     -- 2.5000 (Exact or float division)
    10 DIV 4 AS integer_div,     -- 2 (Truncates fractional portion)
    10 % 3  AS modulo_op,        -- 1 (Remainder)
    MOD(10, 3) AS mod_function;  -- 1
```

### 3.2. Comparison & NULL-Safe Equality Operators

```sql
-- Standard equality and inequality
SELECT * FROM products WHERE unit_price = 49.99;
SELECT * FROM products WHERE unit_price <> 49.99; -- Standard inequality

-- NULL-Safe Equality Operator: <=>
-- Standard '=' fails when comparing two NULLs: (NULL = NULL) yields NULL (UNKNOWN).
-- The '<=>' operator safely evaluates (NULL <=> NULL) as TRUE (1), and (10 <=> NULL) as FALSE (0).
SELECT 
    (NULL = NULL)   AS standard_eq,    -- NULL
    (NULL <=> NULL) AS null_safe_eq;   -- 1 (TRUE)
```

### 3.3. Logical Operators & Precedence Rules

| Operator | Syntax Alias | Description | Precedence Rank |
| :--- | :--- | :--- | :--- |
| `NOT` | `!` | Reverses boolean truth value (`NOT TRUE` $\rightarrow$ `FALSE`) | High |
| `AND` | `&&` | Evaluates to `TRUE` only if **both** operands are `TRUE` | Medium |
| `OR` | `\|\|` | Evaluates to `TRUE` if **either** operand is `TRUE` | Low |
| `XOR` | | Evaluates to `TRUE` if exactly **one** operand is `TRUE` | Low |

> [!CAUTION]
> **Operator Precedence Trap**: `AND` has higher precedence than `OR`. The expression `A OR B AND C` is evaluated as `A OR (B AND C)`. Always use parentheses `(A OR B) AND C` to guarantee your intended evaluation order!

### 3.4. Regular Expression Operators (`REGEXP` / `RLIKE`)

```sql
-- Checks if first_name starts with A, E, I, O, or U (case-insensitive by default)
SELECT first_name FROM customers WHERE first_name REGEXP '^[AEIOU]';

-- Checks if phone contains only numbers and dashes
SELECT phone FROM customers WHERE phone REGEXP '^[0-9-]+$';
```

---

## 4. Basic Example

Evaluating basic arithmetic, logical precedence, and pattern operators:

```sql
USE sql_mastery;

-- Arithmetic calculation in projection
SELECT 
    product_name,
    unit_price,
    stock_quantity,
    (unit_price * stock_quantity) AS total_inventory_value
FROM products;

-- Precedence demo: Without parentheses vs With parentheses
-- Q: Find employees in Department 1 or 2 who make over $100,000.

-- WRONG: Evaluates as: department_id = 1 OR (department_id = 2 AND salary > 100000)
SELECT employee_id, first_name, department_id, salary
FROM employees
WHERE department_id = 1 OR department_id = 2 AND salary > 100000;

-- CORRECT: Enforces the OR condition first
SELECT employee_id, first_name, department_id, salary
FROM employees
WHERE (department_id = 1 OR department_id = 2) AND salary > 100000;
```

---

## 5. Real-World Example

The e-commerce sales director needs a comprehensive audit of line items in `order_items`. For every item ordered:
1. Calculate the gross total (`quantity * unit_price`).
2. Calculate the monetary discount amount (`gross_total * discount`).
3. Calculate the net billed price after applying discounts.
4. Filter only items where the net item price exceeds $200 AND either the discount was applied (`discount > 0`) OR the item quantity exceeded 1.

```sql
USE sql_mastery;

SELECT 
    item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount,
    (quantity * unit_price) AS gross_total,
    ROUND(quantity * unit_price * discount, 2) AS discount_amount,
    ROUND(quantity * unit_price * (1.00 - discount), 2) AS net_billed_amount
FROM order_items
WHERE (quantity * unit_price * (1.00 - discount)) > 200.00
  AND (discount > 0.00 OR quantity > 1);
```

---

## 6. Step-by-Step Explanation

1. `(quantity * unit_price)`:
   * Multiplies the integer column `quantity` by the exact decimal column `unit_price`, yielding the raw gross monetary value.
2. `(1.00 - discount)`:
   * Calculates the percentage remainder after discount (e.g., `1.00 - 0.05 = 0.95`).
3. `ROUND(quantity * unit_price * (1.00 - discount), 2)`:
   * Computes the net price and rounds the result to 2 decimal places to ensure exact currency cents.
4. `WHERE (...) > 200.00 AND (discount > 0.00 OR quantity > 1)`:
   * **Sub-expression 1**: `(quantity * unit_price * (1.00 - discount)) > 200.00` evaluates the net price.
   * **Sub-expression 2**: `(discount > 0.00 OR quantity > 1)` checks that the customer either received a promotion OR bought in bulk.
   * **Logical Operator**: The `AND` operator requires both parenthesized conditions to be simultaneously satisfied.

---

## 7. Expected Result

Output of the order item discount audit:

```
+---------+----------+------------+----------+------------+----------+-------------+-----------------+-------------------+
| item_id | order_id | product_id | quantity | unit_price | discount | gross_total | discount_amount | net_billed_amount |
+---------+----------+------------+----------+------------+----------+-------------+-----------------+-------------------+
|       5 |     1004 |          1 |        1 |    1299.99 |     0.05 |     1299.99 |           65.00 |           1234.99 |
|      11 |     1008 |          3 |        1 |     249.50 |     0.05 |      249.50 |           12.48 |            237.03 |
+---------+----------+------------+----------+------------+----------+-------------+-----------------+-------------------+
2 rows in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Forgetting Parentheses with `AND` and `OR`**:
   * *Mistake*:
     ```sql
     WHERE status = 'Shipped' OR status = 'Processing' AND total_amount > 500;
     ```
   * *What actually runs*:
     ```sql
     WHERE status = 'Shipped' OR (status = 'Processing' AND total_amount > 500);
     ```
   * *Consequence*: Any order with status `'Shipped'` will be returned regardless of its `total_amount` (even if it's $5.00)!
   * *Correction*: Explicitly write: `WHERE (status = 'Shipped' OR status = 'Processing') AND total_amount > 500;`.
2. **Dividing by Zero**:
   * *Query*: `SELECT 100 / 0;`
   * *Behavior*: In MySQL's default mode, division by zero returns `NULL` and issues a warning (`Warning 1365: Division by 0`). In strict SQL modes (`ERROR_FOR_DIVISION_BY_ZERO`), it halts execution. Protect computations with `NULLIF`: `100 / NULLIF(divisor, 0)`.
3. **Using `=` for NULL Checks in Joins or Filtering**:
   * If two tables have columns where both values can be `NULL`, joining on `t1.manager_id = t2.manager_id` will never match rows where both managers are `NULL`.
   * *Fix*: Use the NULL-safe equality operator: `t1.manager_id <=> t2.manager_id`.
4. **Confusing `%` (Modulo) with `%` (LIKE Wildcard)**:
   * In arithmetic expressions (`10 % 3`), `%` calculates the division remainder (`1`). In pattern strings (`WHERE name LIKE '%son'`), `%` matches arbitrary character sequences.

---

## 9. Best Practices

1. **Always Use Parentheses to Disambiguate Compound Logical Predicates**:
   * Even if you know operator precedence by heart, your teammates might not. Parentheses eliminate ambiguity and make code reviews straightforward.
2. **Prefer Standard ANSI SQL Operator Names**:
   * Use `AND`, `OR`, `NOT`, `<>` instead of dialect shortcuts like `&&`, `||`, `!`, `!=`. This ensures queries remain portable across MySQL, PostgreSQL, Oracle, and Snowflake.
3. **Guard Against Division by Zero Using `NULLIF`**:
   * Always write `dividend / NULLIF(divisor, 0)` in production analytical calculations to prevent runtime crashes.
4. **Optimize Pattern Searches**:
   * Simple prefix matches (`name LIKE 'San%'`) can use B+ Tree indexes. Complex regular expressions (`name REGEXP '^San[a-z]+'`) cannot use standard indexes and force full table scans. Use them judiciously on large datasets.

---

## 10. Practice Questions

### Easy
1. Write a query to calculate the annual bonus for employees, defined as 12% of their `salary`, projected as `bonus_amount`.
2. Write a query to find all products where `stock_quantity` is an even number using the modulo operator (`%`).
3. Write a query to find all customers whose `country` is either `'USA'` or `'Germany'` using the `IN` operator.

### Medium
4. Write a query to find all employees whose `manager_id` is NOT NULL and who earn more than $100,000.
5. Write a query using the `REGEXP` operator to retrieve all customers whose `email` address ends with either `.com` or `.org`.
6. Write a query against `orders` to find all orders where `status` is `'Pending'` OR `status` is `'Processing'`, AND the `total_amount` plus `shipping_fee` exceeds $500.00.

### Difficult
7. Demonstrate the exact operational difference between `col1 = col2` and `col1 <=> col2` by writing a query comparing columns containing `(5, 5)`, `(5, NULL)`, and `(NULL, NULL)`.
8. Write a query against `products` that uses bitwise operators to verify if an integer status flag has its 3rd bit set (`flag & 4 != 0`).

---

## 11. Interview Questions

### Q1: What is operator precedence in SQL, and why is the interaction between `AND` and `OR` a frequent source of bugs?
**Answer**: Operator precedence determines the order in which the database engine evaluates different operators in a complex expression. In SQL, `AND` has a higher precedence than `OR`. Consequently, without explicit parentheses, an expression like `A OR B AND C` is parsed as `A OR (B AND C)`. A developer who intended `(A OR B) AND C` will introduce a serious bug, as any row satisfying `A` will be included in the result set regardless of condition `C`.

### Q2: What is the NULL-Safe Equality Operator (`<=>`) in MySQL, and when is it required?
**Answer**: In standard SQL, testing equality between two values where one or both are `NULL` (such as `val = NULL` or `NULL = NULL`) always yields `UNKNOWN` (treated as `NULL`). The MySQL NULL-Safe Equality Operator (`<=>`) performs an equality check that treats `NULL` as a normal comparable value:
* If both operands are `NULL`, `NULL <=> NULL` returns `1` (`TRUE`).
* If one operand is `NULL` and the other is not, `val <=> NULL` returns `0` (`FALSE`).
* If neither operand is `NULL`, it behaves identically to the standard `=` operator.
It is required when comparing or joining columns that can legitimately contain `NULL` values and you want two `NULL` entries to match.

### Q3: How do you safely prevent division-by-zero errors in analytical SQL queries?
**Answer**: In SQL, you prevent division-by-zero by wrapping the denominator in the `NULLIF(expression, 0)` function. `NULLIF` evaluates its arguments: if the denominator equals `0`, it returns `NULL`; otherwise, it returns the denominator. When dividing any number by `NULL`, SQL produces `NULL` rather than raising a fatal runtime division-by-zero error or warning:
```sql
SELECT total_revenue / NULLIF(total_units_sold, 0) AS avg_unit_price FROM sales;
```

---

## 12. Quick Revision

* **Arithmetic**: `+`, `-`, `*`, `/` (standard division), `DIV` (integer division), `%` / `MOD` (remainder).
* **Precedence**: `NOT` $\rightarrow$ `AND` $\rightarrow$ `OR`. **Always use parentheses** when mixing `AND` with `OR`.
* **NULL-Safe Equality (`<=>`)**: Safely compares nullable columns, returning `1` (`TRUE`) for `NULL <=> NULL`.
* **Pattern Matching**: `LIKE` handles simple wildcards (`%`, `_`); `REGEXP` / `RLIKE` handles powerful regular expression matching.
* Use **`NULLIF(divisor, 0)`** to prevent fatal division-by-zero errors.
