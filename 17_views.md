# Chapter 17 — Schema Abstraction & Security: MySQL Views

---

## 1. What is it?

A **View** in MySQL is a named, saved `SELECT` query stored in the database data dictionary that functions as a **virtual table**.

Unlike a standard relational base table, a view does **not** store physical data rows or occupy independent disk space (aside from a small `.frm` / data dictionary definition file). Instead, whenever an application or user queries a view, the MySQL query engine dynamically merges the view's underlying query definition with the user's outer query, generating a combined execution plan that retrieves live data directly from the underlying base tables.

Because views execute their underlying query dynamically at the instant they are accessed, **a view is always 100% up-to-date**: any changes, additions, or deletions committed to the base tables immediately appear in subsequent view queries.

---

## 2. Why do we use it?

1. **Security & Data Masking (Least Privilege Access)**: You can grant an external analytics team access to a view that hides sensitive columns (such as `salary`, `phone`, or credit card details) and exposes only non-sensitive columns.
2. **Simplification of Complex Multi-Table Queries**: Instead of forcing developers and reporting tools to repeatedly write complex 6-table joins with aggregations, wrap that query inside a view (e.g., `sales_summary_view`) so clients can run simple queries like `SELECT * FROM sales_summary_view WHERE region = 'EMEA'`.
3. **Architectural Abstraction & Backward Compatibility**: If you refactor a legacy database table by splitting it into two normalized tables, you can create a view with the old table's name that joins the two new tables. Legacy application queries will continue running without knowing the underlying schema changed.
4. **Consistency in Business Metrics**: Defining standardized metrics (such as "active high-value orders") inside a shared view guarantees that Marketing, Finance, and Operations all calculate revenue using the exact same business logic.

---

## 3. Syntax

### Creating and Managing Views
```sql
-- 1. Create or Replace View
CREATE OR REPLACE VIEW view_name AS
SELECT column1, column2, ...
FROM base_table
WHERE condition;

-- 2. Querying a View (Treated identically to a table)
SELECT * FROM view_name WHERE column1 > 100;

-- 3. Altering an Existing View
ALTER VIEW view_name AS
SELECT column1, column2, column3
FROM base_table;

-- 4. Dropping a View
DROP VIEW IF EXISTS view_name;
```

### Updatable Views & `WITH CHECK OPTION`
MySQL allows certain simple views to accept `INSERT`, `UPDATE`, and `DELETE` statements, passing those mutations down to the underlying base table. 

To prevent users from inserting or updating rows through the view that would violate the view's own filtering criteria, append **`WITH CHECK OPTION`**:

```sql
CREATE OR REPLACE VIEW local_customers_view AS
SELECT customer_id, first_name, last_name, country
FROM customers
WHERE country = 'USA'
WITH CHECK OPTION;
```

---

## 4. Basic Example

Creating a security view that masks employee salaries:

```sql
USE sql_mastery;

-- Create a public staff directory view that omits salary and personal phone numbers
CREATE OR REPLACE VIEW v_public_staff_directory AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email AS corporate_email,
    d.department_name,
    e.hire_date
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE;

-- Query the view
SELECT * FROM v_public_staff_directory WHERE department_name = 'Engineering';

-- Clean up
DROP VIEW v_public_staff_directory;
```

---

## 5. Real-World Example

In our `sql_mastery` database, the finance and operations executives require:
1. An executive view named `v_order_financial_summary` that joins `orders`, `customers`, and `payments`, computing the total line item value, actual payments collected, and payment balance status.
2. An updatable regional inventory view named `v_urgent_reorder_products` restricted to products needing replenishment, guarded with `WITH CHECK OPTION`.

```sql
USE sql_mastery;

-- 1. Complex Analytical Reporting View
CREATE OR REPLACE VIEW v_order_financial_summary AS
SELECT 
    o.order_id,
    o.order_date,
    o.status AS order_status,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country AS customer_country,
    o.total_amount AS billed_total,
    COALESCE(p.amount, 0.00) AS amount_paid,
    COALESCE(p.payment_method, 'Unpaid') AS payment_method,
    COALESCE(p.payment_status, 'No Payment') AS payment_status,
    ROUND(o.total_amount - COALESCE(p.amount, 0.00), 2) AS outstanding_balance
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id;

-- Query the financial view for orders with outstanding balances
SELECT order_id, customer_name, billed_total, amount_paid, outstanding_balance
FROM v_order_financial_summary
WHERE outstanding_balance > 0;

-- 2. Updatable View with WITH CHECK OPTION
CREATE OR REPLACE VIEW v_active_electronics AS
SELECT 
    product_id,
    product_name,
    category_id,
    unit_price,
    stock_quantity,
    is_active
FROM products
WHERE category_id = 1 AND is_active = TRUE
WITH CHECK OPTION;

-- Test updating through the view: Increase stock of Laptop (Product 1)
UPDATE v_active_electronics
SET stock_quantity = stock_quantity + 5
WHERE product_id = 1;

-- Test WITH CHECK OPTION rejection:
-- Attempting to set category_id = 2 through this view will FAIL!
-- ERROR 1369 (HY000): CHECK OPTION failed 'sql_mastery.v_active_electronics'
UPDATE v_active_electronics
SET category_id = 2
WHERE product_id = 1;
```

---

## 6. Step-by-Step Explanation

1. `CREATE OR REPLACE VIEW v_order_financial_summary AS ...`:
   * MySQL parses the query, validates that all referenced tables and columns exist in `sql_mastery`, and confirms the current database user has the `CREATE VIEW` privilege.
   * The SQL definition is stored in the data dictionary metadata without materializing any data pages to disk.
2. `SELECT ... FROM v_order_financial_summary WHERE outstanding_balance > 0;`:
   * The query optimizer reads the view definition and merges the outer filter `outstanding_balance > 0` directly into the underlying query pipeline.
   * Joins execute dynamically against `orders`, `customers`, and `payments`, streaming up-to-the-second live data.
3. `WITH CHECK OPTION` Enforcement:
   * When an `UPDATE` or `INSERT` targets `v_active_electronics`, MySQL evaluates the new row against the view's `WHERE` clause (`category_id = 1 AND is_active = TRUE`).
   * If a user tries to change `category_id` to `2`, the row would no longer satisfy the view's condition, so MySQL aborts the operation and issues:
     `ERROR 1369 (HY000): CHECK OPTION failed 'sql_mastery.v_active_electronics'`.

---

## 7. Expected Result

Output of querying the financial view:

```
+----------+---------------+--------------+-------------+---------------------+
| order_id | customer_name | billed_total | amount_paid | outstanding_balance |
+----------+---------------+--------------+-------------+---------------------+
|     1010 | Mateo Silva   |       344.00 |        0.00 |              344.00 |
+----------+---------------+--------------+-------------+---------------------+
1 row in set (0.00 sec)
```
*(Order 1010 has no matching payment record, accurately showing an outstanding balance of $344.00).*

---

## 8. Common Mistakes

1. **Assuming Views Store Physical Data (Performance Misunderstanding)**:
   * *Mistake*: Creating a view over a slow, unindexed 10-table join and expecting queries on the view to run faster.
   * *Reality*: In standard MySQL, views are strictly virtual. Querying a view executes its underlying query every single time. If the underlying query is slow, querying the view will be equally slow.
2. **Trying to Update Non-Updatable Views**:
   * Attempting to run an `UPDATE` or `DELETE` on a view that contains:
     * Aggregate functions (`SUM`, `AVG`, `COUNT`)
     * `DISTINCT`
     * `GROUP BY` or `HAVING`
     * `UNION` or `UNION ALL`
     * Joins (unless updating columns belonging strictly to a single base table with a 1:1 row mapping)
   * MySQL will reject the mutation with:
     `ERROR 1288 (HY000): The target table v_summary of the UPDATE is not updatable`.
3. **Dropping a Base Table While a View Still References It**:
   * If you run `DROP TABLE customers;`, the view `v_order_financial_summary` remains in the catalog. However, any subsequent attempt to query the view fails with:
     `ERROR 1356 (HY000): View 'sql_mastery.v_order_financial_summary' references invalid table(s) or column(s)`. Always drop dependent views before dropping base tables.

---

## 9. Best Practices

1. **Use Explicit Column Lists in View Definitions**:
   * Never use `SELECT *` inside a view definition. If a column is added or dropped from the base table later, a view defined with `SELECT *` can become corrupted or misaligned. Always explicitly list all projected columns.
2. **Enforce `WITH CHECK OPTION` on All Updatable Views**:
   * If an updatable view filters rows (e.g., `WHERE department_id = 1`), always append `WITH CHECK OPTION` to prevent users from inserting rows belonging to other departments.
3. **Use Views for Row-Level and Column-Level Access Control**:
   * Grant external applications access only to dedicated views, revoking direct access to underlying base tables (`REVOKE ALL ON employees FROM reporting_user; GRANT SELECT ON v_public_staff_directory TO reporting_user;`).
4. **Prefix View Names Consistently**:
   * Prefix view names with `v_` or `vw_` (e.g., `v_customers_active`) to clearly distinguish virtual views from physical base tables in application code and data dictionaries.

---

## 10. Practice Questions

### Easy
1. Write a statement to create a view named `v_us_customers` that projects the `customer_id`, `first_name`, `last_name`, and `city` of all customers residing in `'USA'`.
2. Write a query to retrieve all rows from `v_us_customers` where the city is `'San Francisco'`.
3. Write a command to delete the view `v_us_customers`.

### Medium
4. Write a view named `v_product_stock_status` that displays the product ID, product name, category name, unit price, stock quantity, and an automated label `'Needs Reorder'` if `stock_quantity <= reorder_level` or `'Sufficient'` otherwise.
5. Demonstrate that a view is dynamic: query `v_product_stock_status`, update the stock quantity of a product in the underlying `products` table, and query the view again to observe the updated data.
6. Create an updatable view `v_marketing_emails` on `customers` filtering for customers with `loyalty_points > 200`, appending `WITH CHECK OPTION`. Test inserting an invalid customer with `loyalty_points = 50` and verify the failure.

### Difficult
7. In MySQL, explain the difference between `ALGORITHM = MERGE` and `ALGORITHM = TEMPTABLE` in view creation. Which algorithm permits the view to be updatable, and why?
8. Because MySQL does not support native Materialized Views, design an architecture that emulates a Materialized View for a complex daily sales summary table using a physical table, a stored procedure, and MySQL Event Scheduler.

---

## 11. Interview Questions

### Q1: What is a View in SQL, and does it consume disk storage?
**Answer**: A View is a virtual table defined by a stored SQL query. It does not store physical data rows or consume disk storage for data pages. When a view is queried, the database engine executes the underlying query dynamically (or merges the view definition with the outer query using `ALGORITHM=MERGE`) and fetches live data from the underlying base tables. The only disk storage consumed by a view is its small schema definition entry in the database catalog.

### Q2: What criteria make a View updatable in MySQL?
**Answer**: A view is updatable only if the database engine can map every row and column of the view unambiguously to a single, specific row in the underlying base table (a 1-to-1 relationship). A view is **NOT updatable** if its definition contains any of the following:
1. Aggregate functions (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`)
2. `DISTINCT` keyword
3. `GROUP BY` or `HAVING` clauses
4. `UNION` or `UNION ALL` set operations
5. Non-updatable subqueries or derived tables
6. Multiple base tables in a join (except for updating columns belonging strictly to one table in a join without violating referential constraints)
7. `LIMIT` clause (in certain contexts)

### Q3: What is the purpose of `WITH CHECK OPTION` on a View?
**Answer**: `WITH CHECK OPTION` prevents data modifications (`INSERT` or `UPDATE`) performed through an updatable view from creating or modifying rows that do not satisfy the view's own `WHERE` clause. 
Without `WITH CHECK OPTION`, a user could use a view defined as `WHERE country = 'USA'` to update a customer's country to `'Germany'`. The update would succeed in the underlying table, but the row would vanish from the view. With `WITH CHECK OPTION`, MySQL evaluates the modified row and aborts the statement with an error if it violates the view's filter criteria.

---

## 12. Quick Revision

* A **View** is a stored virtual table that runs dynamically against underlying base tables.
* Views consume **no data storage** on disk and always reflect live, up-to-date data.
* Use views for **security (data masking)**, **query simplification**, and **consistent business logic**.
* Views containing `GROUP BY`, `DISTINCT`, `UNION`, or aggregate functions are **non-updatable**.
* Always append **`WITH CHECK OPTION`** to updatable views to prevent modifications that would cause rows to fall outside the view's filter criteria.
