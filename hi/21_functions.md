# Chapter 21 — Custom Logic: User-Defined Functions (UDFs)

---

## 1. What is it?

MySQL mein ek **User-Defined Function (UDF)** (ya Stored Function) database catalog ke andar store kiya gaya ek custom, reusable computational routine hota hai jo zero ya usse zyada input parameters accept karta hai, un par calculations perform karta hai, aur ek explicit `RETURN` statement ke zariye **hamesha exactly ek scalar value** return karta hai.

Stored Procedures ke opposite (jinhe hum `CALL` statement ke zariye independently execute karte hain aur jo complex multi-row result sets return kar sakte hain), Stored Functions ko SQL expressions ke **andar inline** use karne ke liye design kiya gaya hai—jaise `SELECT` projection list mein, `WHERE` clauses mein, `ORDER BY` clauses mein, ya `HAVING` filters mein—bilkul waise hi jaise aap MySQL ke built-in functions (`ROUND()`, `UPPER()`, ya `DATEDIFF()`) ko use karte hain.

### Function Characteristics: Determinism & Data Access
Jab aap MySQL mein ek stored function create karte hain, toh MySQL aapse uska operational behavior declare karne ko bolta hai:
* **`DETERMINISTIC`**: Ye guarantee deta hai ki agar function ko bilkul identical input arguments diye jayein, toh wo **hamesha** exact same output return karega (for example, Celsius se Fahrenheit convert karna: `(C * 9/5) + 32`). Deterministic functions ko MySQL Generated Virtual Columns ke zariye index kar sakta hai aur query cache ke dwara behtar tareeqe se optimize kiya ja sakta hai.
* **`NOT DETERMINISTIC`**: Ye batata hai ki identical arguments milne par bhi function ka output alag-alag invocations mein change ho sakta hai (for example, aise functions jo `NOW()`, `RAND()`, ya dynamic table data ko query karte hain).
* **Data Access Characteristics**:
  * `NO SQL`: Function ke andar koi SQL statements nahi hain (pure mathematical ya string manipulation).
  * `READS SQL DATA`: Function ke andar `SELECT` queries hain jo table records ko sirf read karti hain, lekin data modify nahi karti.
  * `MODIFIES SQL DATA`: Table data ko modify karta hai (jab function ko kisi standard `SELECT` statement ke andar call kiya jata hai, toh ye strictly prohibited hota hai).

---

## 2. Stored Procedures vs Stored Functions: The Definitive Comparison

| Architectural Dimension | Stored Procedure (`CREATE PROCEDURE`) | Stored Function (`CREATE FUNCTION`) |
| :--- | :--- | :--- |
| **Execution Syntax** | `CALL sp_name(...)` ke zariye independently invoke kiya jata hai. | SQL expressions ke **andar inline** invoke kiya jata hai: `SELECT fn_name(...)`. |
| **Return Mechanism** | Zero, ek, ya multiple result sets return kar sakta hai; values ko `OUT`/`INOUT` parameters ke zariye return karta hai. | `RETURN data_type` ke zariye **hamesha exactly ek scalar value** return karna mandatory hai. |
| **Transaction Control** | Transactions ko manage kar sakta hai (`START TRANSACTION`, `COMMIT`, `ROLLBACK`). | **Transaction control statements execute nahi kar sakta** (`COMMIT`/`ROLLBACK` strictly forbidden hain). |
| **DML Capabilities** | Arbitrary `INSERT`, `UPDATE`, `DELETE`, aur DDL statements execute kar sakta hai. | Jab kisi `SELECT` statement se call kiya jaye, toh base tables par DML execute nahi kar sakta. |
| **Usage in Clauses** | `WHERE`, `JOIN`, ya `ORDER BY` ke andar use nahi kiya ja sakta. | Direct `WHERE`, `SELECT`, `HAVING`, aur `JOIN` ke andar embed kiya ja sakta hai. |

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

Ek pure deterministic scalar function create karte hain jo tax ke sath total cost calculate karta hai:

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

Enterprise finance group ko ek standardized customer classification function chahiye jiska naam `fn_get_customer_tier` hai. Ye function customer ke total loyalty points aur lifetime order value ko evaluate karta hai, aur ek standardized tier label (`'Platinum'`, `'Gold'`, `'Silver'`, ya `'Standard'`) return karta hai.

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
   * Function ko compile karta hai aur ise `mysql.proc` / data dictionary mein register karta hai.
2. `NOT DETERMINISTIC READS SQL DATA`:
   * MySQL ko inform karta hai ki ye function dynamic table data (`customers` aur `orders`) ko query karta hai, jiska matlab hai ki naye orders insert hone par iska output change ho sakta hai.
3. `SELECT loyalty_points INTO v_points ...`:
   * Specified customer ke current point balance ko local variable `v_points` mein read karta hai.
4. `SELECT COALESCE(SUM(total_amount), 0.00) INTO v_total_spend ...`:
   * Customer ke lifetime non-cancelled orders ka total spend compute karta hai, aur `COALESCE` ke zariye `NULL` ko `0.00` mein convert karta hai.
5. `IF ... ELSEIF ... END IF`:
   * Business rules ko evaluate karta hai aur appropriate tier string assign karta hai.
6. `RETURN v_tier;`:
   * Scalar result ko wapas outer SQL query engine ko bhejta hai, jo ise directly result set stream mein incorporate kar leta hai.

---

## 7. Expected Result

Customer tier query ka output:

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
*(Notice karein ki Customer 5 [Aisha] aur Customer 1 [Emily] dono Platinum ke liye qualify karte hain kyunki unke points 600/300 se zyada hain AUR unka total lifetime spend $1,000 se exceed karta hai).*

---

## 8. Common Mistakes

1. **Missing Determinism Declarations (MySQL Error 1418)**:
   * *The Error*:
     `ERROR 1418 (HY000): This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled`
   * *Why?*: Jab MySQL mein binary logging enabled hoti hai (jaise replication ke liye), toh MySQL require karta hai ki har function ko `DETERMINISTIC` ya kisi valid data access clause ke sath explicitly mark kiya jaye, taaki primary aur replica servers ke beech identical data generate hone ki guarantee mil sake. Hamesha in keywords ko declare karein!
2. **Calling Functions that Read Tables Inside Huge Queries (The $N+1$ Problem)**:
   * Ek aisi query mein `fn_get_customer_tier(customer_id)` jaise function ko call karna jo 100,000 rows process kar rahi ho, function ko 100,000 separate subqueries execute karne par majboor kar deta hai, jisse query performance destroy ho jati hai. Large datasets ke liye, row-by-row function calls ke bajaye set-based `LEFT JOIN`s aur `CASE` expressions ka use karke metrics compute karein.
3. **Attempting to Execute Transactions Inside a Function**:
   * Function body ke andar `START TRANSACTION;` ya `COMMIT;` likhne se fatal compilation error trigger hota hai:
     `ERROR 1422 (HY000): Explicit or implicit commit is not allowed in stored function`.

---

## 9. Best Practices

1. **Keep Functions Short, Pure, and Fast**:
   * Ideal functions pure scalar utilities hote hain (jaise tax calculate karna, email patterns validate karna, phone numbers format karna, ya currencies convert karna).
2. **Prefix Custom Functions**:
   * Custom functions ko `fn_` ya `udf_` prefix dekar banayein (for example, `fn_calculate_tax`), taaki unhe native MySQL built-in functions se aasani se distinguish kiya ja sake.
3. **Use Deterministic Functions to Back Generated Virtual Columns**:
   * Aap kisi table mein deterministic function ka use karke generated column define kar sakte hain aur us par index laga sakte hain:
     ```sql
     ALTER TABLE products ADD COLUMN discounted_price DECIMAL(10,2) 
     AS (fn_calculate_discount(unit_price)) STORED;
     CREATE INDEX idx_discounted_price ON products(discounted_price);
     ```

---

## 10. Practice Questions

### Easy
1. Stored Procedure aur User-Defined Function ke beech fundamental operational difference kya hota hai?
2. Stored function ke body ke andar result wapas caller ko pass karne ke liye kaun sa keyword mandatory hai?
3. Kaun sa keyword ye declare karta hai ki function identical inputs ke liye hamesha exact same output return karega?

### Medium
4. Ek deterministic function `fn_celsius_to_fahrenheit` likhiye jo `DECIMAL(5,2)` Celsius temperature accept kare aur corresponding Fahrenheit value (`(C * 9/5) + 32`) return kare.
5. Ek function `fn_format_phone` banayein jo ek 7-digit string (jaise `'5550100'`) accept kare aur use dash ke sath format kare (jaise `'555-0100'`).
6. Ek function `fn_get_employee_tenure` create karein jo `employee_id` accept kare aur `employees` table ko query karke unka tenure complete years mein return kare.

### Difficult
7. Explain karein ki MySQL kisi aise function ke andar transactions (`COMMIT` / `ROLLBACK`) execute karna ya base tables ko modify karna kyu forbid karta hai jise `SELECT` statement ke andar invoke kiya gaya ho.
8. `SELECT fn_get_customer_tier(customer_id) FROM customers;` run karne ke execution plan aur performance ko ek equivalent set-based `LEFT JOIN ... GROUP BY ... CASE` query ke sath compare karein. Kin conditions mein set-based query is function ko orders of magnitude se outperform karegi?

---

## 11. Interview Questions

### Q1: What is the difference between a Stored Procedure and a Stored Function in MySQL?
**Answer**:
1. **Calling Context**: Procedures ko `CALL procedure_name(...)` ke zariye independent statements ke roop mein invoke kiya jata hai. Functions ko SQL expressions ke andar inline invoke kiya jata hai (`SELECT fn(col) FROM table`).
2. **Return Constraints**: Ek procedure multiple result sets return kar sakta hai, ya fir `OUT`/`INOUT` parameters ke zariye multiple values return kar sakta hai. Ek function ko `RETURN` keyword ka use karke **exactly ek scalar value** return karni hoti hai.
3. **Transaction Control**: Procedures transactions ko manage kar sakte hain (`START TRANSACTION`, `COMMIT`, `ROLLBACK`). Functions transaction control statements execute nahi kar sakte.
4. **Side Effects**: `SELECT` statement ke andar invoke kiye gaye functions ko table data modify karne ki bilkul permission nahi hoti (base tables par koi `INSERT`, `UPDATE`, ya `DELETE` nahi chal sakta), jo ye guarantee karta hai ki read queries system state ko alter na karein.

### Q2: Why is the `DETERMINISTIC` keyword significant in MySQL functions?
**Answer**: `DETERMINISTIC` query optimizer ko batata hai ki same input parameters milne par function hamesha exact same result return karega.
Significance:
1. **Optimization**: Query optimizer function ke results ko cache kar sakta hai, subqueries ko optimize kar sakta hai, aur table scan ke dauran identical values ke liye function ko baar-baar re-evaluate karne se bachta hai.
2. **Generated Columns**: Sirf deterministic functions ka use karke hi MySQL tables mein virtual ya stored generated columns define kiye ja sakte hain.
3. **Replication Safety**: Binary logging enabled environments mein, MySQL functions ko `DETERMINISTIC` declare karna (ya ye declare karna ki wo data modify nahi karte) require karta hai, taaki non-deterministic values primary aur replica servers ke beech data inconsistency create na karein.

### Q3: What is the "N+1 Problem" when using stored functions that query tables inside a `SELECT` statement?
**Answer**: Jab kisi stored function ke andar `SELECT` query hoti hai (for example, customer ke order totals query karna) aur use outer query ke projection mein invoke kiya jata hai (`SELECT customer_id, fn_get_lifetime_spend(customer_id) FROM customers`), toh database pehle $N$ customers fetch karne ke liye 1 query execute karta hai, aur fir har ek row ke liye individually function invoke karta hai, jisse $N$ additional subqueries execute hoti hain. Isse total $N+1$ queries run hoti hain. Large datasets (jaise 100,000 customers) ke case mein, ye severe I/O bottleneck create karta hai. Iska standard solution ye hai ki ise ek single set-based query mein rewrite kiya jaye jo `customers` ko `orders` ke pre-aggregated subquery ke sath join karti ho.

---

## 12. Quick Revision

* **User-Defined Functions (UDFs)** hamesha **exactly ek scalar value** return karte hain aur SQL queries ke **andar inline** run hote hain.
* Functions **transactions ko manage nahi kar sakte** (`COMMIT`/`ROLLBACK` strictly forbidden hain).
* Function ko **`DETERMINISTIC`** mark karein agar identical inputs hamesha identical results produce karte hain.
* Binary logging requirements (Error 1418) ko satisfy karne ke liye **`READS SQL DATA`** ya **`NO SQL`** use karein.
* Large datasets par **N+1 query bottleneck** se bachne ke liye functions ke andar row-by-row table queries avoid karein.
