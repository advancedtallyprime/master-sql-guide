# Chapter 07 — Result Organization: Sorting & Limiting

---

## 1. What is it?

In relational database theory (Codd's Relational Model), tables are defined as mathematical sets: **there is no inherent order to rows stored on disk**. Unless an explicit **`ORDER BY`** clause is specified in your query, the order in which rows are returned by the storage engine is completely non-deterministic and can vary based on storage page fragmentation, parallel query execution, or cache state.

* **`ORDER BY`**: Dictates the deterministic ordering of the returned result set based on one or more columns, expressions, or aliases, sorted in either ascending (`ASC`) or descending (`DESC`) order.
* **`LIMIT` & `OFFSET`**: Restricts the maximum number of rows streamed back to the client application, enabling UI pagination (e.g., displaying "20 items per page").
  * `LIMIT count`: Returns at most `count` rows.
  * `LIMIT offset, count` (or ANSI standard `LIMIT count OFFSET offset`): Skips `offset` rows before beginning to return up to `count` rows.

---

## 2. Why do we use it?

1. **Deterministic User Experience**: Applications require predictable ordering—displaying top-rated products first, sorting leaderboard rankings, or displaying transactions chronologically.
2. **Resource Throttling & Pagination**: Transferring 50,000 rows when a mobile screen only displays 25 wastes network bandwidth, exhausts client device memory, and delays render times.
3. **Top-N Business Analytics**: Answering questions such as *"Who are our 5 highest-earning employees?"* or *"What was yesterday's single largest order?"* requires pairing `ORDER BY` with `LIMIT 1` or `LIMIT N`.

---

## 3. Syntax

```sql
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
ORDER BY 
    column1 [ASC | DESC],
    column2 [ASC | DESC],
    ...
LIMIT [offset,] row_count;

-- Alternative Standard ANSI SQL syntax for offset pagination:
-- LIMIT row_count OFFSET offset;
```

### Advanced Null Sorting Emulation in MySQL
In MySQL, `NULL` values are treated as physically lower than any non-NULL value. Consequently:
* In `ASC` ordering, `NULL` values appear **first**.
* In `DESC` ordering, `NULL` values appear **last**.

To override this default and place `NULL` values last in an ascending sort:
```sql
-- Technique 1: Using boolean IS NULL (since TRUE=1, FALSE=0)
ORDER BY column_name IS NULL ASC, column_name ASC;

-- Technique 2: Using CASE expression
ORDER BY CASE WHEN column_name IS NULL THEN 1 ELSE 0 END, column_name ASC;
```

---

## 4. Basic Example

Basic sorting and pagination queries:

```sql
USE sql_mastery;

-- Sort employees by salary descending (Highest paid first)
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY salary DESC;

-- Multi-column sorting: First by department_id ascending, then by salary descending
SELECT department_id, first_name, last_name, salary
FROM employees
ORDER BY department_id ASC, salary DESC;

-- Retrieve the top 3 highest-priced products
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 3;

-- UI Pagination: Page 2 (Skip first 3 products, fetch next 3)
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 3 OFFSET 3;
```

---

## 5. Real-World Example

In our `sql_mastery` database, the finance director requires a prioritized report of all customer accounts:
1. Customers must be sorted by `loyalty_points` descending.
2. In the event of ties in loyalty points, sort alphabetically by `last_name` ascending, then `first_name` ascending.
3. We need to display Page 1 of the executive dashboard, limited to the top 5 records.
4. Any customer with a `NULL` state must be pushed to the bottom of the list without disrupting the loyalty hierarchy.

```sql
USE sql_mastery;

SELECT 
    customer_id,
    first_name,
    last_name,
    city,
    state,
    country,
    loyalty_points
FROM customers
ORDER BY 
    state IS NULL ASC,        -- Guarantees customers with valid states appear before NULL states
    loyalty_points DESC,      -- Primary business sort
    last_name ASC,            -- Secondary tie-breaker
    first_name ASC            -- Tertiary tie-breaker
LIMIT 5 OFFSET 0;
```

---

## 6. Step-by-Step Explanation

1. **`FROM customers`**: The engine accesses the `customers` table.
2. **`ORDER BY` Evaluation**:
   * `state IS NULL ASC`: Evaluates the boolean expression `state IS NULL`. If `state` is NOT null, this returns `0`. If `state` IS null, this returns `1`. Because `0 < 1` in ascending order, all customers with non-null states are grouped first!
   * `loyalty_points DESC`: Within each state-nullability partition, the engine compares `loyalty_points` in descending order, ranking customers with 940, 750, 610, etc., at the top.
   * `last_name ASC, first_name ASC`: If two customers share the exact same loyalty point balance, MySQL breaks the tie by sorting alphabetically.
3. **`LIMIT 5 OFFSET 0`**: The engine's Filesort algorithm maintains a priority queue in memory (using `sort_buffer_size`). Once the top 5 rows have been isolated, execution terminates immediately, avoiding the need to sort the remaining rows.

---

## 7. Expected Result

Output of the executive customer dashboard query:

```
+-------------+------------+-----------+---------------+-------+---------+----------------+
| customer_id | first_name | last_name | city          | state | country | loyalty_points |
+-------------+------------+-----------+---------------+-------+---------+----------------+
|          3 | Sophia     | Garcia    | Miami         | FL    | USA     |            750 |
|          5 | Aisha      | Khan      | Bengaluru     | KA    | India   |            610 |
|          1 | Emily      | Watson    | San Francisco | CA    | USA     |            420 |
|          8 | Mateo      | Silva     | Sao Paulo     | SP    | Brazil  |            290 |
|          2 | Michael    | Brown     | Austin        | TX    | USA     |            180 |
+-------------+------------+-----------+---------------+-------+---------+----------------+
5 rows in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Assuming Natural Table Order Exists**:
   * *Mistake*: Issuing `SELECT * FROM orders LIMIT 1;` expecting to receive the "first" order ever created.
   * *Correction*: Without `ORDER BY order_date ASC` or `ORDER BY order_id ASC`, the engine can return any arbitrary row. Never rely on implicit physical ordering.
2. **Confusing MySQL Comma Syntax (`LIMIT offset, count`)**:
   * *The Syntax Confusion*:
     * MySQL comma syntax: `LIMIT 10, 5` means **Skip 10 rows, return 5 rows**.
     * ANSI standard syntax: `LIMIT 5 OFFSET 10` means **Return 5 rows, skip 10 rows**.
   * Beginners often write `LIMIT 10, 5` thinking it means "Return rows 5 through 10". To prevent bugs, prefer the explicit `LIMIT count OFFSET offset` syntax.
3. **The "Deep Paging" Performance Trap**:
   * *The Problematic Query*:
     ```sql
     SELECT * FROM orders ORDER BY order_date DESC LIMIT 20 OFFSET 1000000;
     ```
   * *Catastrophic Performance*: The engine cannot jump straight to row 1,000,000 on disk. It must scan, sort, and materialize all 1,000,020 rows through the sort buffer, only to discard the first 1,000,000 rows and return the final 20.
   * *The Professional Fix (Keyset / Cursor Pagination)*:
     ```sql
     -- Instead of OFFSET, filter using the last seen primary key / timestamp:
     SELECT * FROM orders 
     WHERE order_id < 894520 
     ORDER BY order_id DESC 
     LIMIT 20;
     ```
     This executes via an instant index seek.

---

## 9. Best Practices

1. **Always Back `ORDER BY ... LIMIT` with an Index**:
   * If you frequently execute `SELECT * FROM orders ORDER BY order_date DESC LIMIT 10`, build an index on `orders(order_date)`. The engine reads the first 10 leaf entries from the B+ Tree in reverse order and finishes instantly, avoiding a full table scan and an in-memory **Filesort**.
2. **Always Include a Deterministic Tie-Breaker**:
   * If sorting by a non-unique column (such as `order_date` or `salary`), multiple rows may share identical values. Different database replicas or query invocations can return ties in differing sequences, causing records to skip or appear twice between paginated screens. Always append a unique tie-breaker:
     ```sql
     ORDER BY order_date DESC, order_id DESC
     ```
3. **Avoid Sorting by Raw Column Position Numbers**:
   * Avoid writing `ORDER BY 1, 3 DESC;`. If someone later alters the `SELECT` column list or adds a column, the query will silently sort by the wrong fields, causing subtle logic bugs. Always write explicit column names.

---

## 10. Practice Questions

### Easy
1. Write a query to list all products ordered from least expensive to most expensive.
2. Write a query to retrieve the 5 most recently hired employees from the `employees` table.
3. Write a query to fetch the single most expensive product in category 1.

### Medium
4. Write a query to return rows for Page 3 of an employee directory, where each page contains 4 employees, sorted alphabetically by `last_name` ascending.
5. Write a query that selects all customers, sorting them so that customers residing in `'USA'` appear at the top, and all other countries appear below them sorted alphabetically.
6. Write a query retrieving `order_id`, `order_date`, and `total_amount`, sorted by `total_amount` descending, skipping the top 2 highest orders and returning the next 3.

### Difficult
7. Write a query against the `employees` table that sorts records by `department_id` ascending, with all employees who have a `NULL` department placed strictly at the end, and ties within each department broken by `salary` descending.
8. Explain what an `Using filesort` note indicates in a MySQL `EXPLAIN` execution plan for an `ORDER BY` query. How can creating an index eliminate this overhead?

---

## 11. Interview Questions

### Q1: What is the "Deep Paging Problem" with `LIMIT offset, count`, and how do you solve it in production?
**Answer**: In relational databases, `LIMIT 1000000, 20` requires the storage engine to physically scan and process 1,000,020 rows, buffering them through memory and discarding the first 1,000,000 rows to deliver the final 20. This wastes substantial I/O, CPU, and memory, and query execution time scales linearly with offset size. 
The production solution is **Keyset Pagination (or Cursor-based Pagination)**. Instead of using numeric offsets, the client application tracks the unique identifier (or timestamp) of the last seen record from the current page and requests the next page via a direct indexed filter:
`WHERE order_id < last_seen_order_id ORDER BY order_id DESC LIMIT 20`. This uses an index seek and executes in constant $O(1)$ time regardless of page depth.

### Q2: How does MySQL handle `NULL` values when executing an `ORDER BY` statement?
**Answer**: MySQL considers `NULL` values to be lower in magnitude than any non-NULL value. Under `ORDER BY column ASC`, all `NULL` values are grouped together at the very beginning of the result set. Under `ORDER BY column DESC`, all `NULL` values appear at the very end. To alter this behavior (for example, to display NULLs last in an ascending sort), you can use an explicit boolean expression such as `ORDER BY column IS NULL ASC, column ASC`.

### Q3: What is the difference between sorting via an index seek versus sorting via a Filesort in MySQL?
**Answer**:
* **Index-based Ordering**: When an index exists on the sorting columns matching the query's `ORDER BY` specifications, the engine navigates the B+ Tree sequentially. The data is already physically ordered, allowing MySQL to stream rows immediately without any in-memory sorting.
* **Filesort**: When no suitable index exists, MySQL must extract candidate rows meeting the `WHERE` criteria into memory (`sort_buffer_size`) and perform an explicit sorting algorithm (typically quicksort or merge sort). If the candidate dataset exceeds the allocated buffer size, temporary sort files are written to disk, introducing severe disk I/O bottlenecks.

---

## 12. Quick Revision

* Relational tables have **no default order**; deterministic results require an explicit **`ORDER BY`** clause.
* **`ASC`** sorts from smallest to largest; **`DESC`** sorts from largest to smallest.
* In MySQL, **`NULL` is sorted as the smallest possible value** (first in `ASC`, last in `DESC`).
* Use **`LIMIT count OFFSET offset`** for UI pagination.
* Avoid large numeric offsets (the **Deep Paging Problem**); prefer **Keyset Pagination** for high-volume datasets.
* Always append a unique tie-breaker column (such as the Primary Key) to guarantee stable, deterministic sorting across pages.
