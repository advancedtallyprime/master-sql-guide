# Chapter 13 — Nested Queries: Subqueries & Common Table Expressions (CTEs) (Subqueries aur CTEs)

---

## 1. What is it? (Ye Kya Hai?)

Ek **subquery** (ya nested query) parentheses ke andar enclosed ek aisi inner `SELECT` query hoti hai jo kisi outer SQL statement (jaise `SELECT`, `INSERT`, `UPDATE`, ya `DELETE`) ke andar embedded hoti hai. Outer query inner query ke produce kiye gaye data ko consume karti hai.

Subqueries ko do dimensions ke according categorize kiya jata hai:

### Dimension 1: Structural Return Shape
1. **Scalar Subquery**: Ye exactly **ek row aur ek column** (single scalar value) return karti hai. Ise wahan har jagah use kiya ja sakta hai jahan koi literal constant ya expression valid hota hai (jaise `WHERE salary > (SELECT AVG(salary) FROM employees)`).
2. **Column Subquery (Multi-Row)**: Ye **multiple rows mein ek column** (vector/list) return karti hai. Iska use membership operators jaise `IN`, `NOT IN`, `ANY`, ya `ALL` ke sath hota hai.
3. **Row Subquery**: Ye **exactly ek row mein multiple columns** (ek tuple) return karti hai (for example, `WHERE (department_id, manager_id) = (SELECT 1, 2)`).
4. **Table Subquery (Derived Table)**: Ye **poori multi-row, multi-column virtual table** return karti hai. Iska main use `FROM` clause mein hota hai, aur MySQL mein isko table alias assign karna **mandatory** hai!

### Dimension 2: Dependency & Execution Mechanics
1. **Non-Correlated Subquery**: Ye ek aisi independent query hoti hai jo outer query ke kisi bhi column ko reference **nahi** karti. Database engine ise sirf **ek baar** execute karta hai, result ko cache karta hai, aur outer query ko feed kar deta hai.
2. **Correlated Subquery**: Ye ek aisi inner query hoti hai jo outer query ke ek ya multiple columns ko reference karti hai (jaise `WHERE e1.salary > (SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e1.department_id)`). Inner query outer row ki values par directly depend karti hai.

### Modern SQL: Common Table Expressions (CTEs)
MySQL 8.0 mein introduce kiye gaye **Common Table Expressions (CTEs)** temporary, named result sets hote hain jo **`WITH`** clause use karke ek single statement ke execution scope mein define kiye jate hain. CTEs deeply nested, complex subqueries ko clean, modular, aur top-down readable pipelines se replace kar dete hain. CTEs **recursive** bhi ho sakte hain, jisse hierarchical data aur organizational graphs ko bina procedural loops ke traverse kiya ja sakta hai.

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Multi-Step Dynamic Filtering**: Aise sawalon ke jawab dena jahan filter criteria ko run-time par calculate karna padta hai (jaise *"Aise sabhi employees find karo jo company ki average salary se zyada kamate hain"*).
2. **Short-Circuit Existence Checks (`EXISTS`)**: Ye verify karna ki matching records exist karte hain ya nahi, bina poori rows ko read ya count kiye.
3. **Derived Metrics & Aggregation of Aggregates**: Counts ka average calculate karna (for example, *"Har customer ke average kitne orders hain?"*).
4. **Graph & Hierarchy Traversal**: Recursive CTEs ka use karke parent-child reporting structures ya bill-of-materials trees ko pure declarative SQL mein trace karna.

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

Scalar subqueries, `IN` subqueries, aur `EXISTS` ke basic examples:

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

Chief Operating Officer (COO) ko organizational reporting chains aur departmental compensation benchmarks ka analysis chahiye:
1. Un sabhi employees ko identify karo jo **apne khud ke department ki average salary se zyada kamate hain** (Correlated Subquery).
2. CEO/Directors se start karke individual contributors tak poori **management hierarchy** ko **Recursive CTE** ke through trace karo, aur corporate tree mein har employee ka depth level report karo.

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
        CONCAT(e.first_name, ' ', last_name) AS employee_name,
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
1. `employees` table ki har candidate row `e` ke liye, engine `e.department_id` read karta hai.
2. Inner query execute hoti hai: `SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e.department_id`.
3. Agar `e.salary` computed departmental average se strictly greater hoti hai, toh outer row result mein admit ho jati hai.
4. Projection correlated calculation ko repeat karta hai taaki `dept_avg_salary` aur `diff_from_avg` display ho sakein.

### Part 2: Recursive CTE Execution
1. **Anchor Step (Iteration 0)**: Engine pehli query run karta hai jo sabhi top-level executives (`manager_id IS NULL`: Alex Morgan, Elena Rostova, Jessica Taylor, Fatima Al-Mansoor) ko dhoondhti hai. Inhe `org_level = 1` ke sath `OrgChart` mein insert kiya jata hai.
2. **Recursive Step (Iteration 1)**: Doosri query `employees e` ko Iteration 0 ki rows ke sath join karti hai (`e.manager_id = oc.employee_id`). Ye Sarah Chen, Priya Patel, Liam OConnor, aur Carlos Mendoza ko find karti hai, unhe `org_level = 2` tag karti hai aur `reporting_path` string build karti hai.
3. **Recursive Step (Iteration 2)**: Recursive step nayi level 2 rows par dubara execute hota hai aur `org_level = 3` par Marcus Vance aur David Kim ko find karta hai.
4. **Termination**: Iteration 3 execute hota hai. Level 3 employees ko report karne wala koi employee nahi milta, isliye recursion cleanly terminate ho jata hai aur poora combined set client ko stream ho jata hai.

---

## 7. Expected Result

Part 1 (Departmental Above-Average Earners) ka output:

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

Part 2 (Recursive Organizational Hierarchy) ka output:

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
   * *Correction*: Hamesha alias append karo: `... FROM (...) AS order_summary;`.
2. **Scalar Subquery Returning Multiple Rows**:
   * *Mistake*:
     ```sql
     SELECT * FROM employees WHERE salary = (SELECT salary FROM employees WHERE department_id = 1);
     ```
   * *Error*: Agar Department 1 mein multiple employees hain, toh subquery 3 rows return kar degi, jisse error aayega:
     `ERROR 1242 (21000): Subquery returns more than 1 row.`
   * *Correction*: `IN`, `ANY` use karo, ya confirm karo ki subquery aggregate function (`MAX`, `MIN`) ya `LIMIT 1` use karti ho.
3. **Correlated Subquery Performance Explosion**:
   * Bina proper indexing ke 1,000,000 rows wali table par correlated subquery chalane se 1,000,000 table scans force ho sakte hain, jisme ghanto lag sakte hain. Jahan possible ho, correlated subqueries ko pre-aggregated derived tables ya window functions ke sath `JOIN`s mein rewrite karo.
4. **Infinite Loops in Recursive CTEs**:
   * Agar recursive relationship mein koi cycle ho (jaise A manages B, aur B manages A), toh recursive CTE endlessly loop karega jab tak MySQL execution halt na kar de:
     `ERROR 3636 (HY000): Recursive query aborted after 1001 iterations. Try increasing @@cte_max_recursion_depth.`

---

## 9. Best Practices

1. **Prefer `EXISTS` Over `IN` for Subquery Checking**:
   * Child tables mein existence check karte waqt `EXISTS` pehla match milte hi short-circuit kar jata hai. Iske alawa, `NOT EXISTS` `NULL` values ko safely handle karta hai aur `NOT IN` ke fatal zero-row bug se bachata hai.
2. **Use CTEs to Improve Readability**:
   * Subqueries ko 4 levels deep nest karne ke bajay logic ko `WITH Stage1 AS (...), Stage2 AS (...)` ke zariye readable CTE stages mein divide karo.
3. **Set Recursion Safeguards**:
   * Recursive queries likhte waqt `SET SESSION cte_max_recursion_depth = 500;` ke zariye infinite cycles se protect karein aur termination conditions thoroughly verify karein.

---

## 10. Practice Questions

### Easy
1. Subquery use karke order `1001` place karne wale customer ka name find karne ke liye query likho.
2. Un sabhi products ko find karne ke liye query likho jinki `unit_price` sabhi products ki average `unit_price` se kam hai.
3. `IN` use karke un sabhi employees ko find karne ke liye query likho jo ya toh `'Engineering'` ya `'Data & Analytics'` department se belong karte hain.

### Medium
4. `NOT EXISTS` use karke un sabhi customers ko find karne ke liye query likho jinhone kabhi koi order place nahi kiya.
5. Har customer dwara spend kiya gaya total amount compute karne ke liye ek CTE likho, aur phir un customers ko select karo jinka total spending $1,000 se exceed karta ho.
6. `order_items` ke sabhi orders ke across per-order average number of items calculate karne ke liye derived table use karke query likho.

### Difficult
7. Har `category_id` ke andar sabse expensive single product find karne ke liye ek correlated subquery likho.
8. Ek Recursive CTE construct karo jo `'2023-08-01'` se `'2023-08-31'` tak continuous date series generate kare, aur `orders` table ke against `LEFT JOIN` perform karke har calendar day par place hue orders count kare (zero orders wale days ke liye 0 dikhaye).

---

## 11. Interview Questions

### Q1: What is the difference between a Correlated Subquery and a Non-Correlated Subquery?
**Answer**:
* **Non-Correlated Subquery** outer query se completely independent hoti hai. Isme outer table columns ka koi reference nahi hota. Query engine ise sirf ek baar execute karta hai, result set ko materialize ya cache karta hai, aur outer query ko evaluate karne ke liye use karta hai.
* **Correlated Subquery** outer query ke ek ya multiple columns ko reference karti hai. Conceptually ise ek baar evaluate nahi kiya ja sakta; engine ko outer query dwara process ki jane wali har candidate row ke liye inner query ko dubara evaluate karna padta hai. Halanki modern query optimizers in queries ko internally decorrelate karke joins mein convert kar dete hain, un-indexed correlated subqueries $O(N^2)$ execution complexity ka shikar ho sakti hain.

### Q2: Why is `NOT EXISTS` generally preferred over `NOT IN` when interacting with subqueries?
**Answer**:
1. **Three-Valued Logic / NULL Safety**: Agar `WHERE col NOT IN (SELECT other_col ...)` ki subquery ek bhi `NULL` value return kar deti hai, toh poori `NOT IN` condition sabhi rows ke liye `UNKNOWN` evaluate hoti hai, jisse outer query zero rows return karti hai. Iske opposite, `NOT EXISTS` existence check karti hai; subquery ke andar rows `NULL` contain karti hain ya nahi isse koi farak nahi padta, aur result hamesha predictable rehta hai.
2. **Early Short-Circuiting**: `EXISTS` aur `NOT EXISTS` storage engine ko pehla matching row milte hi subquery table scan stop karne ka instruction dete hain, jabki `IN` subqueries ko candidate values ko temporary set mein materialize karna pad sakta hai.

### Q3: What is a Common Table Expression (CTE), and what are its advantages over traditional inline subqueries?
**Answer**: Common Table Expression (CTE) ek named, temporary result set hota hai jo query ke shuruat mein `WITH` clause use karke define kiya jata hai.
Fayde (Advantages):
1. **Readability & Modularity**: Deeply nested subqueries ko top-down, linear pipelines mein transform kar deta hai.
2. **Reusability**: Ek single CTE ko usi statement ke andar multiple times reference kiya ja sakta hai (jaise usi CTE ko khud se join karna), jisse duplicate query logic eliminate hota hai.
3. **Recursion**: CTEs `WITH RECURSIVE` support karte hain, jisse declarative tarike se tree structures, graphs, aur hierarchical data ko traverse kiya ja sakta hai jo traditional subqueries bina procedural code ke achieve nahi kar saktein.

---

## 12. Quick Revision

* Ek **subquery** outer statement ke andar nested `SELECT` query hoti hai.
* **Scalar subqueries** 1x1 value return karti hain; **Column subqueries** list return karti hain; **Derived tables** virtual tables return karti hain aur **alias require karti hain**.
* **Correlated subqueries** outer query columns ko reference karti hain aur row-by-row evaluate hoti hain.
* **`EXISTS`** high-performance, short-circuit boolean checking provide karta hai aur `NULL` values ke against safe hota hai.
* **CTEs (`WITH ...`)** subqueries ka cleaner, modular alternative hain aur **`RECURSIVE`** hierarchy traversal support karte hain.
