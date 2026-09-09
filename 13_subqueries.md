# Chapter 13 — Nested Queries: Subqueries & Common Table Expressions (CTEs)

---

## 1. What is it?

A **subquery** (or nested query) is an inner `SELECT` statement enclosed within parentheses that is embedded inside an outer SQL statement (such as `SELECT`, `INSERT`, `UPDATE`, or `DELETE`). The outer query consumes the data produced by the inner query.

Subqueries are categorized along two dimensions:

### Dimension 1: Structural Return Shape
1. **Scalar Subquery**: Returns exactly **one row and one column** (a single scalar value). It can be used anywhere a literal constant or expression is permitted (e.g., `WHERE salary > (SELECT AVG(salary) FROM employees)`).
2. **Column Subquery (Multi-Row)**: Returns **one column across multiple rows** (a vector/list). Used with membership operators like `IN`, `NOT IN`, `ANY`, or `ALL`.
3. **Row Subquery**: Returns **multiple columns across exactly one row** (a tuple, e.g. `WHERE (department_id, manager_id) = (SELECT 1, 2)`).
4. **Table Subquery (Derived Table)**: Returns a **full multi-row, multi-column virtual table**. Used primarily in the `FROM` clause, and **must** be assigned a table alias in MySQL!

### Dimension 2: Dependency & Execution Mechanics
1. **Non-Correlated Subquery**: An independent query that does **not** reference any columns from the outer query. The database engine executes it **once**, caches the result, and feeds it into the outer query.
2. **Correlated Subquery**: An inner query that references one or more columns from the outer query (e.g., `WHERE e1.salary > (SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e1.department_id)`). The inner query depends on the outer row's values.

### Modern SQL: Common Table Expressions (CTEs)
Introduced in MySQL 8.0, a **Common Table Expression (CTE)** is a temporary, named result set defined within the execution scope of a single statement using the **`WITH`** clause. CTEs replace deeply nested, unreadable subqueries with clean, modular, top-down pipelines. CTEs can also be **recursive**, enabling queries to traverse organizational hierarchies and graphs without procedural loops.

---

## 2. Why do we use it?

1. **Multi-Step Dynamic Filtering**: Answering questions where the filter criteria must be calculated on-the-fly (e.g., *"Find all employees who earn more than the company average salary"*).
2. **Short-Circuit Existence Checks (`EXISTS`)**: Verifying whether matching related records exist without reading or counting all rows.
3. **Derived Metrics & Aggregation of Aggregates**: Calculating the average of counts (e.g., *"What is the average number of orders per customer?"*).
4. **Graph & Hierarchy Traversal**: Using Recursive CTEs to trace parent-child reporting structures or bill-of-materials trees in pure declarative SQL.

---

## 3. Syntax

### Subquery Syntaxes
```sql
-- 1. Scalar Subquery in WHERE
SELECT first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 2. Multi-Row Subquery with IN
SELECT product_name
FROM products
WHERE category_id IN (SELECT category_id FROM categories WHERE category_name LIKE '%Tech%');

-- 3. Derived Table in FROM (Alias is mandatory!)
SELECT dept_id, avg_sal
FROM (
    SELECT department_id AS dept_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department_id
) AS dept_averages
WHERE avg_sal > 90000;

-- 4. Correlated Subquery with EXISTS
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.customer_id = c.customer_id AND o.total_amount > 1000.00
);
```

### Common Table Expression (CTE) Syntax
```sql
-- Standard Non-Recursive CTE
WITH HighValueOrders AS (
    SELECT customer_id, order_id, total_amount
    FROM orders
    WHERE total_amount > 500.00
),
CustomerSummary AS (
    SELECT customer_id, COUNT(*) AS count_high_value
    FROM HighValueOrders
    GROUP BY customer_id
)
SELECT c.first_name, c.email, cs.count_high_value
FROM customers c
JOIN CustomerSummary cs ON c.customer_id = cs.customer_id;

-- Recursive CTE Architecture (e.g. Org Chart)
WITH RECURSIVE HierarchyCTE AS (
    -- 1. Anchor Member (Root nodes)
    SELECT employee_id, first_name, manager_id, 1 AS depth_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- 2. Recursive Member (Traverses down the tree)
    SELECT e.employee_id, e.first_name, e.manager_id, h.depth_level + 1
    FROM employees e
    JOIN HierarchyCTE h ON e.manager_id = h.employee_id
)
SELECT * FROM HierarchyCTE;
```

---

## 4. Basic Example

Demonstrating scalar subqueries, `IN` subqueries, and `EXISTS`:

```sql
USE sql_mastery;

-- Scalar: Products priced higher than the global product average
SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);

-- Column Subquery: Customers who have placed an order in August 2023
SELECT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM orders WHERE order_date BETWEEN '2023-08-01' AND '2023-08-31'
);

-- Correlated Subquery with EXISTS: Suppliers that supply at least one active product
SELECT supplier_id, supplier_name
FROM suppliers s
WHERE EXISTS (
    SELECT 1 FROM products p
    WHERE p.supplier_id = s.supplier_id AND p.is_active = TRUE
);
```

---

## 5. Real-World Example

The Chief Operating Officer needs an analysis of organizational reporting chains and departmental compensation benchmarks:
1. Identify all employees who earn **more than the average salary of their own department** (Correlated Subquery).
2. Trace the **complete management hierarchy** starting from CEO/Directors down to individual contributors using a **Recursive CTE**, reporting each employee's depth in the corporate tree.

```sql
USE sql_mastery;

-- Part 1: Correlated Subquery — Departmental Above-Average Earners
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.department_id,
    e.salary,
    ROUND((SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e.department_id), 2) AS dept_avg_salary,
    ROUND(e.salary - (SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e.department_id), 2) AS diff_from_avg
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
)
ORDER BY e.department_id ASC, e.salary DESC;

-- Part 2: Recursive CTE — Full Organizational Hierarchy Mapping
WITH RECURSIVE OrgChart AS (
    -- Anchor Member: Find top-level executives (manager_id IS NULL)
    SELECT 
        employee_id,
        CONCAT(first_name, ' ', last_name) AS employee_name,
        manager_id,
        CAST(first_name AS CHAR(200)) AS reporting_path,
        1 AS org_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive Member: Join employees to their managers
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        e.manager_id,
        CONCAT(oc.reporting_path, ' -> ', e.first_name) AS reporting_path,
        oc.org_level + 1 AS org_level
    FROM employees e
    INNER JOIN OrgChart oc ON e.manager_id = oc.employee_id
)
SELECT 
    employee_id,
    employee_name,
    org_level,
    reporting_path
FROM OrgChart
ORDER BY org_level ASC, employee_id ASC;
```

---

## 6. Step-by-Step Explanation

### Part 1: Correlated Subquery Execution
1. For each candidate row `e` in `employees`, the engine reads `e.department_id`.
2. The inner query executes: `SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e.department_id`.
3. If `e.salary` is strictly greater than the computed departmental average, the outer row is admitted.
4. The projection repeats the correlated calculation to display `dept_avg_salary` and `diff_from_avg`.

### Part 2: Recursive CTE Execution
1. **Anchor Step (Iteration 0)**: The engine executes the first query finding all top-level executives (`manager_id IS NULL`: Alex Morgan, Elena Rostova, Jessica Taylor, Fatima Al-Mansoor). These are inserted into `OrgChart` with `org_level = 1`.
2. **Recursive Step (Iteration 1)**: The second query joins `employees e` against the rows added in Iteration 0 (`e.manager_id = oc.employee_id`). This finds Sarah Chen, Priya Patel, Liam OConnor, and Carlos Mendoza, tagging them with `org_level = 2` and building the string `reporting_path`.
3. **Recursive Step (Iteration 2)**: The recursive step executes again on the newly found level 2 rows, finding Marcus Vance and David Kim at `org_level = 3`.
4. **Termination**: Iteration 3 executes. Finding zero employees reporting to level 3 staff, the recursion terminates cleanly and streams the combined set to the client.

---

## 7. Expected Result

Output of Part 1 (Departmental Above-Average Earners):

```
+-------------+---------------+---------------+-----------+-----------------+---------------+
| employee_id | employee_name | department_id | salary    | dept_avg_salary | diff_from_avg |
+-------------+---------------+---------------+-----------+-----------------+---------------+
|           1 | Alex Morgan   |             1 | 145000.00 |       122666.67 |      22333.33 |
|           2 | Sarah Chen    |             1 | 125000.00 |       122666.67 |        2333.33 |
|           4 | Priya Patel   |             2 | 135000.00 |       113500.00 |      21500.00 |
|           6 | Elena Rostova |             3 | 130000.00 |       104000.00 |      26000.00 |
|           8 | Jessica Taylor|             4 | 110000.00 |        91000.00 |      19000.00 |
+-------------+---------------+---------------+-----------+-----------------+---------------+
5 rows in set (0.00 sec)
```

Output of Part 2 (Recursive Organizational Hierarchy):

```
+-------------+-------------------+-----------+-----------------------------------+
| employee_id | employee_name     | org_level | reporting_path                    |
+-------------+-------------------+-----------+-----------------------------------+
|           1 | Alex Morgan       |         1 | Alex                              |
|           6 | Elena Rostova     |         1 | Elena                             |
|           8 | Jessica Taylor    |         1 | Jessica                           |
|          10 | Fatima Al-Mansoor |         1 | Fatima                            |
|           2 | Sarah Chen        |         2 | Alex -> Sarah                     |
|           4 | Priya Patel       |         2 | Alex -> Priya                     |
|           7 | Liam OConnor      |         2 | Elena -> Liam                     |
|           9 | Carlos Mendoza    |         2 | Jessica -> Carlos                 |
|           3 | Marcus Vance      |         3 | Alex -> Sarah -> Marcus           |
|           5 | David Kim         |         3 | Alex -> Priya -> David            |
+-------------+-------------------+-----------+-----------------------------------+
10 rows in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Forgetting to Alias Derived Tables in `FROM`**:
   * *Mistake*:
     ```sql
     SELECT * FROM (SELECT customer_id, COUNT(*) FROM orders GROUP BY customer_id);
     ```
   * *Error*:
     `ERROR 1248 (42000): Every derived table must have its own alias.`
   * *Correction*: Always append an alias: `... FROM (...) AS order_summary;`.
2. **Scalar Subquery Returning Multiple Rows**:
   * *Mistake*:
     ```sql
     SELECT * FROM employees WHERE salary = (SELECT salary FROM employees WHERE department_id = 1);
     ```
   * *Error*: If Department 1 has multiple employees, the subquery returns 3 rows, causing:
     `ERROR 1242 (21000): Subquery returns more than 1 row.`
   * *Correction*: Use `IN`, `ANY`, or ensure the subquery uses an aggregate function (`MAX`, `MIN`) or `LIMIT 1`.
3. **Correlated Subquery Performance Explosion**:
   * Executing a correlated subquery on a table with 1,000,000 rows without proper indexing can force 1,000,000 table scans, taking hours to finish. Always rewrite correlated subqueries as `JOIN`s against pre-aggregated derived tables or window functions where possible.
4. **Infinite Loops in Recursive CTEs**:
   * If a recursive relationship contains a cycle (e.g., A manages B, and B manages A), a recursive CTE will loop infinitely until MySQL halts execution with:
     `ERROR 3636 (HY000): Recursive query aborted after 1001 iterations. Try increasing @@cte_max_recursion_depth.`

---

## 9. Best Practices

1. **Prefer `EXISTS` Over `IN` for Subquery Checking**:
   * When checking existence in child tables, `EXISTS` short-circuits as soon as a single match is found. Additionally, `NOT EXISTS` handles `NULL` values safely, avoiding the catastrophic zero-row bug inherent in `NOT IN` with NULLs.
2. **Use CTEs to Improve Readability**:
   * Rather than nesting subqueries 4 levels deep, break the logic into linear, readable CTE stages using `WITH Stage1 AS (...), Stage2 AS (...)`.
3. **Set Recursion Safeguards**:
   * When writing recursive queries, protect against cycles using `SET SESSION cte_max_recursion_depth = 500;` and verify terminating conditions.

---

## 10. Practice Questions

### Easy
1. Write a query to find the name of the customer who placed order `1001` using a subquery.
2. Write a query to find all products whose `unit_price` is less than the average `unit_price` across all products.
3. Write a query using `IN` to find all employees who belong to either the `'Engineering'` or `'Data & Analytics'` department.

### Medium
4. Write a query using `NOT EXISTS` to find all customers who have never placed an order.
5. Write a query that computes the total amount spent by each customer as a CTE, and then selects the customers whose total spending exceeds $1,000.
6. Write a query using a derived table to calculate the average number of items per order across all orders in `order_items`.

### Difficult
7. Write a correlated subquery that finds the single most expensive product within each `category_id`.
8. Construct a Recursive CTE that generates a continuous date series from `'2023-08-01'` to `'2023-08-31'`, and performs a `LEFT JOIN` against `orders` to count how many orders were placed on every single calendar day (showing 0 for days with no orders).

---

## 11. Interview Questions

### Q1: What is the difference between a Correlated Subquery and a Non-Correlated Subquery?
**Answer**:
* A **Non-Correlated Subquery** is completely independent of the outer query. It contains no references to outer table columns. The query engine executes it once, caches or materializes the result set, and uses it to evaluate the outer query.
* A **Correlated Subquery** references one or more columns from the outer query. Conceptually, it cannot be evaluated once; the engine must re-evaluate the inner query for every candidate row processed by the outer query. While modern query optimizers frequently un-nest or decorrelate these queries into joins, un-indexed correlated subqueries can suffer from $O(N^2)$ execution complexity.

### Q2: Why is `NOT EXISTS` generally preferred over `NOT IN` when interacting with subqueries?
**Answer**:
1. **Three-Valued Logic / NULL Safety**: If the subquery in `WHERE col NOT IN (SELECT other_col ...)` returns even a single `NULL` value, the entire `NOT IN` condition evaluates to `UNKNOWN` for all rows, causing the outer query to return zero rows. In contrast, `NOT EXISTS` tests for existence; whether rows inside the subquery contain `NULL` is irrelevant, guaranteeing predictable behavior.
2. **Early Short-Circuiting**: `EXISTS` and `NOT EXISTS` instruct the storage engine to stop scanning the subquery table as soon as the first matching row is found, whereas `IN` subqueries may need to materialize candidate values into a temporary set.

### Q3: What is a Common Table Expression (CTE), and what are its advantages over traditional inline subqueries?
**Answer**: A Common Table Expression (CTE) is a named, temporary result set defined at the beginning of a query using the `WITH` clause. 
Advantages:
1. **Readability & Modularity**: Transforms deeply nested subqueries into top-down, linear pipelines.
2. **Reusability**: A single CTE can be referenced multiple times within the same statement (e.g., joined to itself), avoiding duplicate query logic.
3. **Recursion**: CTEs support `WITH RECURSIVE`, allowing declarative traversal of tree structures, graphs, and hierarchical data that traditional subqueries cannot achieve without procedural code.

---

## 12. Quick Revision

* A **subquery** is a `SELECT` query nested inside an outer statement.
* **Scalar subqueries** return a 1x1 value; **Column subqueries** return a list; **Derived tables** return virtual tables and **require an alias**.
* **Correlated subqueries** reference outer query columns and evaluate per row.
* **`EXISTS`** provides high-performance, short-circuit boolean checking and is safe against `NULL` values.
* **CTEs (`WITH ...`)** offer cleaner, modular alternatives to subqueries and support **`RECURSIVE`** hierarchy traversal.
