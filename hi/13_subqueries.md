# Chapter 13 — Nested Queries: Subqueries & Common Table Expressions (CTEs) (नेस्टेड क्वेरीज: सबक्वेरीज और CTEs)

---

## 1. What is it? (यह क्या है?)

Ek **subquery** (ya nested query) ek aisi inner `SELECT` query hoti hai jo parentheses `(...)` ke andar band hokar kisi outer SQL statement (jaise `SELECT`, `INSERT`, `UPDATE`, ya `DELETE`) ke andar baithi hoti hai. Outer query inner query ke nikale hue data ko apne calculations ya filtering ke liye use karti hai.

Subqueries ko hum do dimensions par categorize karte hain:

### Dimension 1: Structural Return Shape (डेटा का आकार)
1. **Scalar Subquery**: Theek **ek row aur ek column** (ek akeli single scalar value) return karti hai. Ise aap query mein kisi bhi constant value ya expression ki jagah use kar sakte hain (jaise: `WHERE salary > (SELECT AVG(salary) FROM employees)`).
2. **Column Subquery (Multi-Row)**: Ek column ki **multiple rows** (ek list ya vector) return karti hai. Ise membership operators jaise `IN`, `NOT IN`, `ANY`, ya `ALL` ke sath use kiya jata hai.
3. **Row Subquery**: Ek single row ke **multiple columns** (ek tuple) return karti hai (jaise: `WHERE (department_id, manager_id) = (SELECT 1, 2)`).
4. **Table Subquery (Derived Table)**: Poori **multi-row, multi-column virtual table** return karti hai. Yeh mukhya roop se `FROM` clause mein use hoti hai, aur MySQL mein iska **table alias dena 100% mandatory hota hai!**

### Dimension 2: Dependency & Execution Mechanics (निर्भरता और एग्जीक्यूशन)
1. **Non-Correlated Subquery**: Ek independent query jo outer query ke kisi bhi column par depend **nahi** karti. Database engine ise shuruat mein sirf **ek baar** run karta hai, result cache kar leta hai, aur outer query ko provide kar deta hai.
2. **Correlated Subquery**: Ek aisi inner query jo outer query ke columns ko reference karti hai (jaise: `WHERE e1.salary > (SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e1.department_id)`). Yeh inner query outer row ki har ek value par depend karti hai.

### Modern SQL: Common Table Expressions (CTEs)
MySQL 8.0 mein introduce hua **Common Table Expression (CTE)** ek temporary, named result set hota hai jo **`WITH`** clause ka use karke define kiya jata hai. CTEs complex, nested subqueries ko todkar clean, modular aur easy-to-read pipeline bana dete hain. CTEs **recursive** bhi ho sakte hain, jisse bina kisi loop ya procedural code ke pure SQL mein organizational charts ya hierarchical trees traverse kiye ja sakte hain.

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Multi-Step Dynamic Filtering (डायनामिक फिल्टरिंग)**: Jab filter condition runtime par calculate karni ho (jaise: *"Un sabhi employees ko dhoondho jinki salary company ki average salary se zyada ho"*).
2. **Short-Circuit Existence Checks (`EXISTS`) (रिकॉर्ड्स की मौजूदगी चेक करना)**: Yeh check karna ki related table mein match maujood hai ya nahi, bina saari rows ko count ya scan kiye (`EXISTS` pehla match milte hi turant stop ho jata hai).
3. **Derived Metrics & Aggregation of Aggregates (एग्रीगेट्स का एग्रीगेट निकालना)**: Summary metrics par calculation karna (jaise: *"Per customer average orders kitne hain?"*).
4. **Graph & Hierarchy Traversal (पेरेंट-चाइल्ड रिलेशनशिप्स)**: Recursive CTEs ki madad se reporting structure (CEO $\rightarrow$ Manager $\rightarrow$ Employee) ko aasaani se trace karna.

---

## 3. Syntax (सिंटैक्स)

### Subquery Syntaxes (सबक्वेरी सिंटैक्स)
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

### Common Table Expression (CTE) Syntax (CTE सिंटैक्स)
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

## 4. Basic Example (बुनियादी उदाहरण)

Scalar subqueries, `IN` subqueries, aur `EXISTS` ka prayog:

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

## 5. Real-World Example (वास्तविक दुनिया का उदाहरण)

Chief Operating Officer (COO) ko company ke reporting chains aur compensation benchmarks ka complete analysis chahiye:
1. Un sabhi employees ko identify karein jo **apne khud ke department ki average salary se zyada kamate hain** (Correlated Subquery).
2. **Complete management hierarchy** trace karein (CEO/Directors se lekar ground-level staff tak) ek **Recursive CTE** ka use karke, aur har employee ka corporate tree mein depth level report karein.

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

## 6. Step-by-Step Explanation (कदम-दर-कदम व्याख्या)

### Part 1: Correlated Subquery Execution (कोरिलेटेड सबक्वेरी का प्रवाह)
1. `employees` table ki har ek candidate row `e` ke liye database engine `e.department_id` read karta hai.
2. Inner query execute hoti hai: `SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e.department_id`.
3. Agar `e.salary` uske department ke average salary se zyada hoti hai, tabhi outer row qualify hoti hai.
4. Projection clause wahi calculation repeat karke `dept_avg_salary` aur `diff_from_avg` show karta hai.

### Part 2: Recursive CTE Execution (रिकर्सिव CTE का प्रवाह)
1. **Anchor Step (Iteration 0)**: Pehli query run hoti hai aur un sabhi top executives ko dhoondhti hai jinka `manager_id IS NULL` hai (Alex Morgan, Elena Rostova, Jessica Taylor, Fatima Al-Mansoor). Inhe `org_level = 1` ke sath `OrgChart` mein insert kiya jata hai.
2. **Recursive Step (Iteration 1)**: Dusri query `employees e` ko Iteration 0 ki rows se join karti hai (`e.manager_id = oc.employee_id`). Isse Sarah Chen, Priya Patel, Liam OConnor, aur Carlos Mendoza milte hain, jinhe `org_level = 2` assign kiya jata hai aur string `reporting_path` update hoti hai.
3. **Recursive Step (Iteration 2)**: Level 2 ki rows par dobara recursion chalti hai, jisse Marcus Vance aur David Kim `org_level = 3` par aate hain.
4. **Termination**: Iteration 3 chalti hai. Kyunki level 3 ke staff ko koi report nahi karta, matching rows 0 milti hain aur recursion cleanly band ho jati hai. Poora result set client ko stream ho jata hai.

---

## 7. Expected Result (अपेक्षित परिणाम)

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

## 8. Common Mistakes (आम गलतियाँ)

1. **Forgetting to Alias Derived Tables in `FROM` (`FROM` में डिराइव्ड टेबल का एलियास भूलना)**:
   * *Mistake*:
     ```sql
     SELECT * FROM (SELECT customer_id, COUNT(*) FROM orders GROUP BY customer_id);
     ```
   * *Error*:
     `ERROR 1248 (42000): Every derived table must have its own alias.`
   * *Correction*: Hamesha alias lagayein: `... FROM (...) AS order_summary;`.
2. **Scalar Subquery Returning Multiple Rows (स्केलर सबक्वेरी में 1 से अधिक रो आना)**:
   * *Mistake*:
     ```sql
     SELECT * FROM employees WHERE salary = (SELECT salary FROM employees WHERE department_id = 1);
     ```
   * *Error*: Agar Dept 1 mein 3 employees hain toh subquery 3 rows return karegi, jisse query crash hogi:
     `ERROR 1242 (21000): Subquery returns more than 1 row.`
   * *Correction*: Multiple values ke liye `=` ki jagah `IN` use karein, ya subquery mein `MAX()`, `MIN()` ya `LIMIT 1` lagayein.
3. **Correlated Subquery Performance Explosion (परफॉरमेंस की समस्या)**:
   * 1,000,000 rows wali table par correlated subquery bina indexing ke chalane par database ko 1,000,000 full table scans karne pad sakte hain! Isse query ghanton atak sakti hai. Correlated subqueries ko hamesha pre-aggregated derived table ke sath `JOIN` ya window functions mein rewrite karein.
4. **Infinite Loops in Recursive CTEs (रिकर्सिव CTE में अनंत लूप)**:
   * Agar data ke andar koi cycle ho (jaise A ka manager B hai, aur B ka manager A hai), toh recursive CTE hamesha loop mein ghoomti rahegi jab tak MySQL error na de de:
     `ERROR 3636 (HY000): Recursive query aborted after 1001 iterations. Try increasing @@cte_max_recursion_depth.`

---

## 9. Best Practices (सर्वोत्तम प्रथाएं / Best Practices)

1. **Prefer `EXISTS` Over `IN` for Subquery Checking (`IN` की जगह `EXISTS` चुनें)**:
   * Jab kisi table mein presence check karni ho, toh `EXISTS` pehla match milte hi turant short-circuit ho jata hai. Iske alawa, `NOT EXISTS` `NULL` values ko safely handle karta hai, jabki `NOT IN` ke subquery mein ek single `NULL` aane par poori query 0 rows return karne lagti hai.
2. **Use CTEs to Improve Readability (कोड को साफ़ रखने के लिए CTEs का उपयोग करें)**:
   * 4-level deep nested subqueries likhne ke bajaye, logic ko top-to-bottom clean CTE stages mein baantein: `WITH Stage1 AS (...), Stage2 AS (...)`.
3. **Set Recursion Safeguards (रिकर्शन पर लिमिट लगाएं)**:
   * Recursive queries likhte waqt infinite loops se bachne ke liye `SET SESSION cte_max_recursion_depth = 500;` jaise safeguards set karein aur termination condition verify karein.

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. Ek subquery ka prayog karke order `1001` place karne wale customer ka naam nikalne ki query likhein.
2. Sabhi products ka overall average price nikalen aur subquery se un sabhi products ko find karein jinka `unit_price` average se kam hai.
3. `IN` operator ka use karke aise sabhi employees ko fetch karein jo ya toh `'Engineering'` ya `'Data & Analytics'` department se belong karte hain.

### Medium (मध्यम)
4. `NOT EXISTS` ka prayog karke aise sabhi customers ko dhoondhein jinhone aaj tak ek bhi order place nahi kiya hai.
5. Ek CTE banayein jo har customer ka total expenditure calculate kare, aur phir us CTE se un customers ko select karein jinka total spending $1,000 se zyada ho.
6. `order_items` table par derived table ka use karke har order mein average kitne items order hue the, yeh calculate karein.

### Difficult (कठिन)
7. Har `category_id` ke andar sabse mehanga product nikalne ke liye ek correlated subquery likhein.
8. Ek Recursive CTE construct karein jo `'2023-08-01'` se `'2023-08-31'` tak ki dates ki continuous series generate kare, aur `orders` table ke sath `LEFT JOIN` karke bataye ki har calendar din kitne orders place hue the (jin dino koi order nahi tha wahan 0 show karein).

---

## 11. Interview Questions (साक्षात्कार प्रश्न)

### Q1: What is the difference between a Correlated Subquery and a Non-Correlated Subquery?
**Answer**:
* **Non-Correlated Subquery**: Yeh outer query se completely swatantra (independent) hoti hai. Isme outer table ke kisi bhi column ka reference nahi hota. Database engine ise shuruat mein sirf ek baar execute karta hai, iska result memory mein cache kar leta hai, aur phir outer query ko evaluate karne ke liye use karta hai.
* **Correlated Subquery**: Yeh inner query outer query ke ek ya zyada columns par depend karti hai. Iska matlab ise sirf ek baar run nahi kiya ja sakta; engine ko outer query dwara process kiye jaane wale har ek row ke liye inner query ko dobara evaluate karna padta hai. Modern query optimizers aksar inhe de-correlate karke joins mein badal dete hain, lekin un-indexed tables par yeh $O(N^2)$ complexity tak ja sakti hai.

### Q2: Why is `NOT EXISTS` generally preferred over `NOT IN` when interacting with subqueries?
**Answer**:
1. **Three-Valued Logic / NULL Safety**: Agar `WHERE col NOT IN (SELECT other_col ...)` subquery ke result mein galti se ek bhi `NULL` value aati hai, toh standard SQL ke 3-Valued Logic ke mutabik poora `NOT IN` condition har ek row ke liye `UNKNOWN` evaluate ho jata hai. Result: Outer query 0 rows return karti hai! Iske viprit, `NOT EXISTS` sirf row ki existence check karta hai; subquery mein `NULL` ho ya na ho, yeh hamesha sahi aur predictable result deta hai.
2. **Early Short-Circuiting**: `EXISTS` aur `NOT EXISTS` storage engine ko instruction dete hain ki jaise hi pehla matching record mil jaye, aage scan karna turant band kar dein, jabki `IN` subqueries ko candidate values ka set banana padta hai.

### Q3: What is a Common Table Expression (CTE), and what are its advantages over traditional inline subqueries?
**Answer**: Common Table Expression (CTE) ek named, temporary result set hota hai jo query ke shuru mein `WITH` clause ka prayog karke banaya jata hai.
Fayde:
1. **Readability & Modularity**: Nested subqueries ke jhaal (spaghetti code) ko linear aur easy-to-understand pipeline mein badal deta hai.
2. **Reusability**: Ek hi statement ke andar ek single CTE ko multiple baar refer ya join kiya ja sakta hai, jisse duplicate queries nahi likhni padti.
3. **Recursion**: CTEs `WITH RECURSIVE` support karte hain, jisse tree structures, organizational graphs, aur hierarchical data ko pure SQL mein declarative tarike se traverse kiya ja sakta hai.

---

## 12. Quick Revision (त्वरित सारांश)

* **Subquery** ek outer SQL statement ke andar baithi hui nested `SELECT` query hoti hai.
* **Scalar subquery** 1x1 value return karti hai; **Column subquery** ek list deti hai; **Derived table** virtual table hoti hai aur **uska alias mandatory hota hai**.
* **Correlated subquery** outer table ke columns ko refer karti hai aur row-by-row evaluate hoti hai.
* **`EXISTS`** fast short-circuit check provide karta hai aur `NULL` values ke trap se 100% safe rehta hai.
* **CTEs (`WITH ...`)** modular aur clean SQL code likhne mein madad karte hain aur **`RECURSIVE`** hierarchies ko seamlessly traverse kar sakte hain.
