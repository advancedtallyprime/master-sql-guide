# Chapter 06 — Data Querying & Filtering: SELECT & WHERE

---

## 1. What is it?

**Data Query Language (DQL)** allows users and applications to retrieve stored data from tables. In SQL, querying begins with the **`SELECT`** statement.

At its simplest, a query projects rows and columns from a table. However, in production databases containing millions of records, returning entire tables is impractical. The **`WHERE`** clause provides conditional filtering: it evaluates a boolean predicate for every candidate row, returning only the subset of rows for which the predicate evaluates to `TRUE`.

In SQL, boolean logic is **three-valued (3VL)** rather than binary. A condition can evaluate to:
* `TRUE`: The row satisfies the condition and is included in the output.
* `FALSE`: The row fails the condition and is filtered out.
* `UNKNOWN` (`NULL`): When comparing missing or unknown values, SQL returns `UNKNOWN`. Because `WHERE` only admits rows that evaluate strictly to `TRUE`, rows evaluating to `UNKNOWN` are excluded!

The primary filtering constructs in SQL are:
1. **Relational Comparison Operators**: `=`, `!=` (or `<>`), `<`, `>`, `<=`, `>=`.
2. **Range Filtering (`BETWEEN ... AND ...`)**: Tests whether a value falls within an inclusive continuous range $[A, B]$.
3. **Discrete Set Membership (`IN (...)` and `NOT IN (...)`)**: Tests whether a value exists within an enumerated list or subquery result.
4. **Pattern Matching (`LIKE` and `NOT LIKE`)**: Performs string searches using wildcards (`%` and `_`).
5. **Three-Valued Nullability Checks (`IS NULL` and `IS NOT NULL`)**: Evaluates whether a column contains a missing value.

---

## 2. Why do we use it?

1. **Bandwidth & Latency Minimization**: Transferring 10 relevant rows over a network connection rather than 10,000,000 unneeded rows reduces query latency from minutes to milliseconds.
2. **Targeted Business Analytics**: Business intelligence requires precise subsets: finding orders shipped in the last 7 days, filtering customers residing in Germany, or identifying products needing replenishment.
3. **Database Index Acceleration**: When a `WHERE` clause references an indexed column (e.g., `WHERE customer_id = 4`), the database engine navigates directly to the target record via a B+ Tree index seek, bypassing the need to scan disk pages for unrelated records.

---

## 3. Syntax

```sql
SELECT [DISTINCT] column1, column2, ...
FROM table_name
WHERE boolean_predicate;
```

### Filtering Predicate Forms
```sql
-- 1. Equality & Inequality
WHERE status = 'Delivered';
WHERE status != 'Cancelled';   -- Equivalent to: status <> 'Cancelled'

-- 2. Numeric Comparisons
WHERE salary >= 100000.00;
WHERE stock_quantity < reorder_level;

-- 3. Continuous Range (Inclusive: >= min AND <= max)
WHERE order_date BETWEEN '2023-08-01' AND '2023-08-31';

-- 4. Discrete List Membership
WHERE country IN ('USA', 'Germany', 'Japan');
WHERE category_id NOT IN (1, 4);

-- 5. Pattern Matching Wildcards
WHERE email LIKE '%@gmail.com';     -- Ends with @gmail.com (% matches 0 or more characters)
WHERE phone LIKE '555-01__';        -- Matches 555-01 followed by exactly 2 characters (_ matches 1 char)

-- 6. Three-Valued Logic NULL Checks (NEVER use: WHERE col = NULL)
WHERE phone IS NULL;
WHERE phone IS NOT NULL;
```

---

## 4. Basic Example

Selecting and filtering rows from a single table:

```sql
USE sql_mastery;

-- Retrieve distinct countries where our customers reside
SELECT DISTINCT country 
FROM customers;

-- Find products priced between $200 and $600
SELECT product_name, unit_price, stock_quantity
FROM products
WHERE unit_price BETWEEN 200.00 AND 600.00;

-- Find customers without a recorded phone number
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE phone IS NULL;
```

---

## 5. Real-World Example

In our `sql_mastery` database, the operations director needs to identify all active products in categories 1 (`Electronics`) or 2 (`Home Appliances`) that have a unit price of at least $300 and have stock at or below their reorder safety thresholds.

```sql
USE sql_mastery;

-- Complex multi-predicate real-world inventory check
SELECT 
    product_id,
    product_name,
    category_id,
    unit_price,
    stock_quantity,
    reorder_level,
    (reorder_level - stock_quantity) AS units_to_order
FROM products
WHERE is_active = TRUE
  AND category_id IN (1, 2)
  AND unit_price >= 300.00
  AND stock_quantity <= reorder_level;
```

---

## 6. Step-by-Step Explanation

Let us trace how the database executes this query:

1. **`FROM products`**: The storage engine establishes access to the `products` table.
2. **`WHERE` Clause Evaluation (Row-by-Row Filtering)**:
   * `is_active = TRUE`: Filters out discontinued items.
   * `category_id IN (1, 2)`: Verifies if the product belongs to Electronics (1) or Home Appliances (2).
   * `unit_price >= 300.00`: Filters out inexpensive accessories, isolating high-value assets.
   * `stock_quantity <= reorder_level`: Dynamically compares two column values on the same row. A row is only admitted if its current inventory is depleted down to or below its threshold.
3. **Logical Intersection (`AND`)**: All four predicates must evaluate simultaneously to `TRUE`.
4. **`SELECT` Projection**: For every surviving row, MySQL computes the mathematical expression `(reorder_level - stock_quantity)` as `units_to_order`, projects the requested columns, and transmits the resulting rows to the client.

---

## 7. Expected Result

Output of the inventory filtering query:

```
+------------+-------------------------------+-------------+------------+----------------+---------------+----------------+
| product_id | product_name                  | category_id | unit_price | stock_quantity | reorder_level | units_to_order |
+------------+-------------------------------+-------------+------------+----------------+---------------+----------------+
|          4 | UltraVision 4K 27in Monitor   |           1 |     389.00 |             10 |            10 |              0 |
+------------+-------------------------------+-------------+------------+----------------+---------------+----------------+
1 row in set (0.00 sec)
```
*(Notice how only the monitor matches: price $389.00 is $\ge 300$, category is 1, and stock 10 is $\le$ reorder level 10).*

---

## 8. Common Mistakes

1. **Writing `WHERE column = NULL`**:
   * *Mistake*: `SELECT * FROM customers WHERE phone = NULL;`
   * *Problem*: Returns **empty set (0 rows)** even when rows with `NULL` phone numbers exist!
   * *Why?*: In ANSI SQL, `NULL` represents an unknown. Comparing anything to an unknown yields `UNKNOWN`. Because `WHERE` filters out anything that is not `TRUE`, the condition always fails.
   * *Correction*: Always use `WHERE phone IS NULL` or `WHERE phone IS NOT NULL`.
2. **Misunderstanding `BETWEEN` Boundaries**:
   * *Mistake*: Assuming `BETWEEN 10 AND 20` excludes 10 or 20.
   * *Reality*: In SQL, `BETWEEN` is **strictly inclusive**. It is mathematically equivalent to: `col >= 10 AND col <= 20`.
3. **The `NOT IN` with `NULL` Pitfall**:
   * *The Classic Trap*:
     ```sql
     SELECT * FROM customers WHERE customer_id NOT IN (1, 2, NULL);
     ```
   * *Catastrophic Result*: **Returns 0 rows!**
   * *Why?*: `x NOT IN (1, 2, NULL)` expands to `x != 1 AND x != 2 AND x != NULL`. Since `x != NULL` evaluates to `UNKNOWN`, the entire compound `AND` expression resolves to `UNKNOWN` or `FALSE`. Consequently, every row is discarded.
   * *Rule*: Ensure subqueries or lists inside `NOT IN` never contain `NULL` values (or prefer using `NOT EXISTS`).
4. **Leading Wildcards in `LIKE` (`'%term'`)**:
   * *Problem*: `WHERE email LIKE '%@company.com'` prevents the engine from utilizing a standard B+ Tree index on `email`, forcing a slow full table scan.

---

## 9. Best Practices

1. **Project Only Needed Columns**:
   * Never use `SELECT *` in production services. Explicitly declaring columns prevents fetching large unneeded `TEXT` or `BLOB` fields, avoids memory overhead, and allows queries to be satisfied directly by covering indexes.
2. **Keep Filter Predicates SARGable (Search Argument Able)**:
   * Avoid wrapping indexed columns inside functions:
     * *Non-SARGable (Cannot use index)*:
       ```sql
       WHERE YEAR(order_date) = 2023;
       ```
     * *SARGable (Can use index seek)*:
       ```sql
       WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
       ```
3. **Use `DISTINCT` Judiciously**:
   * Do not slap `DISTINCT` on queries as a quick fix for duplicate rows caused by improper join conditions. `DISTINCT` requires the database engine to sort or hash the entire result set in memory to remove duplicates, adding significant computational cost.

---

## 10. Practice Questions

### Easy
1. Write a query to select the `product_name` and `unit_price` of all products with a `unit_price` greater than $500.00.
2. Write a query to find all employees hired on or after `'2021-01-01'`.
3. Write a query to find all orders with status `'Delivered'`.

### Medium
4. Write a query to find all customers whose `email` address ends with `'@gmail.com'`.
5. Write a query to retrieve all products whose `stock_quantity` is between 20 and 60 inclusive, but whose `category_id` is NOT equal to 1.
6. Write a query to find all orders placed in the month of August 2023 (`2023-08-01` to `2023-08-31`) that have a `shipping_fee` greater than $0.00.

### Difficult
7. Write a query to find all customers who have a recorded `state` (i.e. `state IS NOT NULL`) and whose `first_name` starts with either 'S' or 'E' and is at least 5 characters in length.
8. Explain the exact boolean result when evaluating: `SELECT (5 = NULL), (NULL = NULL), (NULL IS NULL), (5 > NULL);`. Predict each column's value before running the query.

---

## 11. Interview Questions

### Q1: Why does `SELECT * FROM table WHERE column = NULL;` not return rows with NULL values?
**Answer**: SQL implements three-valued logic (3VL) featuring `TRUE`, `FALSE`, and `UNKNOWN`. `NULL` signifies missing or unknown information. When an equality operator compares any value to `NULL` (including `NULL = NULL`), the engine cannot know if two unknown pieces of data are equal, so the expression evaluates to `UNKNOWN`. The `WHERE` clause admits only rows where the conditional expression evaluates strictly to `TRUE`. To match missing values, SQL provides the dedicated unary operator `IS NULL`.

### Q2: What is a SARGable query, and why does writing `WHERE LOWER(email) = 'user@example.com'` degrade performance?
**Answer**: SARGable stands for *Search Argument Able*. A query predicate is SARGable if the database engine's optimizer can leverage a B+ Tree index seek to navigate directly to the matching key values without scanning every leaf page. Wrapping an indexed column in a function (such as `LOWER(email)`) transforms each stored value dynamically at runtime, preventing the engine from utilizing the index ordering. To evaluate the condition, the engine must perform a full table scan, evaluating the function across every single row.

### Q3: What is the risk of using `NOT IN` with a subquery that returns a `NULL`?
**Answer**: `column NOT IN (val1, val2, NULL)` expands logically to:
`column != val1 AND column != val2 AND column != NULL`.
Because any comparison with `NULL` returns `UNKNOWN`, the entire logical `AND` chain evaluates to `UNKNOWN` for every candidate row. Because `WHERE` filters out anything not strictly `TRUE`, the entire query returns an empty result set (zero rows), often creating a silent, critical application bug. The solution is to filter out NULLs in the subquery or use `NOT EXISTS`.

---

## 12. Quick Revision

* **`SELECT`** controls column projection; **`WHERE`** controls row filtering.
* SQL uses **Three-Valued Logic**: `TRUE`, `FALSE`, and `UNKNOWN`.
* Never use `= NULL`; always use **`IS NULL`** or **`IS NOT NULL`**.
* **`BETWEEN`** is always inclusive of its upper and lower boundary values.
* **`LIKE`** supports wildcards: `%` (zero or more characters) and `_` (exactly one character).
* Keep queries **SARGable**: do not wrap indexed columns inside functions in the `WHERE` clause.
