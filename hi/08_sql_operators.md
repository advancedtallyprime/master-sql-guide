# Chapter 08 — SQL Operators & Expression Evaluation (SQL Operators aur Expression Evaluation)

---

## 1. What is it? (Ye Kya Hai?)

SQL mein ek **operator** ek reserved keyword ya symbol hota hai jo database engine ko ek ya multiple data items (operands) par specific mathematical, logical, comparison, ya bitwise computation perform karne ka instruction deta hai.

Operands table column values, literal constants, subquery results, ya functions ke return values ho sakte hain. Jab operators aur operands aapas mein combine hote hain, toh wo **expressions** banate hain jo ek scalar value (jaise number, string, ya boolean truth value) evaluate karte hain.

SQL operators ko 6 alag-alag functional families mein organize kiya gaya hai:
1. **Arithmetic Operators**: Basic numerical computations perform karte hain (`+`, `-`, `*`, `/`, `DIV`, `%` / `MOD`).
2. **Comparison Operators**: Do expressions ko compare karte hain aur boolean truth value return karte hain (`=`, `!=`, `<>`, `<`, `>`, `<=`, `>=`, `<=>`).
3. **Logical Operators**: Multiple boolean conditions ko combine karte hain (`AND`, `OR`, `NOT`, `XOR`).
4. **Set & Membership Operators**: Sets ya ranges ke against presence test karte hain (`IN`, `NOT IN`, `BETWEEN`, `EXISTS`, `ANY`, `ALL`).
5. **Pattern & Regular Expression Operators**: String patterns test karte hain (`LIKE`, `NOT LIKE`, `REGEXP` / `RLIKE`).
6. **Bitwise Operators**: Binary bit-level operations perform karte hain (`&`, `|`, `^`, `~`, `<<`, `>>`).

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Dynamic Business Calculations**: Discounted prices calculate karna (`unit_price * (1 - discount)`), employee bonuses calculate karna, ya database engine mein directly tax withholdings determine karna.
2. **Multi-Condition Filtering**: Multiple business rules ko combine karna (for example, *"Aise orders select karo jo ya toh Shipped hon YA Delivered hon AUR unka total amount $500 se zyada ho"*).
3. **Advanced Pattern Matching**: User text inputs search karna, email formats validate karna, ya regular expressions (`REGEXP`) use karke international dialing prefixes extract karna.
4. **Safe Nullability Comparison**: Aise do columns ko compare karna jin dono mein `NULL` ho sakta hai, bina MySQL ke NULL-Safe Equality operator (`<=>`) ke relational logic break kiye.

---

## 3. Syntax

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
> **Operator Precedence Trap**: `AND` ki precedence `OR` se higher hoti hai. Expression `A OR B AND C` internally `A OR (B AND C)` evaluate hota hai. Apna intended evaluation order guarantee karne ke liye hamesha parentheses `(A OR B) AND C` use karo!

### 3.4. Regular Expression Operators (`REGEXP` / `RLIKE`)

```sql
-- Checks if first_name starts with A, E, I, O, or U (case-insensitive by default)
SELECT first_name FROM customers WHERE first_name REGEXP '^[AEIOU]';

-- Checks if phone contains only numbers and dashes
SELECT phone FROM customers WHERE phone REGEXP '^[0-9-]+$';
```

---

## 4. Basic Example

Basic arithmetic, logical precedence, aur pattern operators ko evaluate karne ke examples:

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

E-commerce sales director ko `order_items` ke line items ka ek comprehensive audit chahiye. Har ordered item ke liye:
1. Gross total calculate karo (`quantity * unit_price`).
2. Monetary discount amount calculate karo (`gross_total * discount`).
3. Discounts apply karne ke baad net billed price calculate karo.
4. Sirf unhi items ko filter karo jahan net item price $200 se zyada ho AUR ya toh discount apply hua ho (`discount > 0`) YA phir item quantity 1 se zyada ho.

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
   * Integer column `quantity` ko exact decimal column `unit_price` se multiply karta hai, jisse raw gross monetary value milti hai.
2. `(1.00 - discount)`:
   * Discount apply hone ke baad remaining percentage calculate karta hai (jaise `1.00 - 0.05 = 0.95`).
3. `ROUND(quantity * unit_price * (1.00 - discount), 2)`:
   * Net price calculate karta hai aur result ko 2 decimal places tak round karta hai taki exact currency cents ensure ho sakein.
4. `WHERE (...) > 200.00 AND (discount > 0.00 OR quantity > 1)`:
   * **Sub-expression 1**: `(quantity * unit_price * (1.00 - discount)) > 200.00` net price ko evaluate karta hai.
   * **Sub-expression 2**: `(discount > 0.00 OR quantity > 1)` check karta hai ki customer ko ya toh promotion mila ho YA unhone bulk mein buy kiya ho.
   * **Logical Operator**: `AND` operator ensure karta hai ki dono parenthesized conditions ek sath satisfy hon.

---

## 7. Expected Result

Order item discount audit query ka output:

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
   * *Consequence*: Status `'Shipped'` wala koi bhi order return ho jayega chahe uska `total_amount` kitna bhi kam ho (bhale hi wo $5.00 ho)!
   * *Correction*: Hamesha explicitly likho: `WHERE (status = 'Shipped' OR status = 'Processing') AND total_amount > 500;`.
2. **Dividing by Zero**:
   * *Query*: `SELECT 100 / 0;`
   * *Behavior*: MySQL ke default mode mein, division by zero `NULL` return karta hai aur ek warning issue karta hai (`Warning 1365: Division by 0`). Strict SQL modes (`ERROR_FOR_DIVISION_BY_ZERO`) mein ye execution halt kar deta hai. Aise calculations ko `NULLIF` ke sath protect karo: `100 / NULLIF(divisor, 0)`.
3. **Using `=` for NULL Checks in Joins or Filtering**:
   * Agar do tables ke columns mein dono values `NULL` ho sakti hain, toh `t1.manager_id = t2.manager_id` par join karne se wo rows kabhi match nahi hongi jahan dono managers `NULL` hain.
   * *Fix*: NULL-safe equality operator use karo: `t1.manager_id <=> t2.manager_id`.
4. **Confusing `%` (Modulo) with `%` (LIKE Wildcard)**:
   * Arithmetic expressions (`10 % 3`) mein `%` division remainder (`1`) calculate karta hai. Pattern strings (`WHERE name LIKE '%son'`) mein `%` arbitrary character sequences match karta hai.

---

## 9. Best Practices

1. **Always Use Parentheses to Disambiguate Compound Logical Predicates**:
   * Bhale hi aapko operator precedence zabani yaad ho, aapke team members ko shayad na ho. Parentheses ambiguity ko eliminate karte hain aur code review ko easy banate hain.
2. **Prefer Standard ANSI SQL Operator Names**:
   * Dialect shortcuts jaise `&&`, `||`, `!`, `!=` ke bajay standard `AND`, `OR`, `NOT`, `<>` use karo. Isse queries MySQL, PostgreSQL, Oracle, aur Snowflake ke beech fully portable rehti hain.
3. **Guard Against Division by Zero Using `NULLIF`**:
   * Production analytical calculations mein runtime crash se bachne ke liye hamesha `dividend / NULLIF(divisor, 0)` likho.
4. **Optimize Pattern Searches**:
   * Simple prefix matches (`name LIKE 'San%'`) B+ Tree indexes use kar sakte hain. Complex regular expressions (`name REGEXP '^San[a-z]+'`) standard indexes use nahi kar sakte aur full table scan trigger karte hain. Large datasets par inka use dhyan se karo.

---

## 10. Practice Questions

### Easy
1. Employees ke liye annual bonus calculate karne ki query likho, jise unki `salary` ka 12% define kiya gaya hai, aur ise `bonus_amount` project karo.
2. Modulo operator (`%`) use karke un sabhi products ko find karne ki query likho jahan `stock_quantity` ek even number hai.
3. `IN` operator use karke un sabhi customers ko find karne ki query likho jinka `country` ya toh `'USA'` hai ya `'Germany'`.

### Medium
4. Ek aisi query likho jo un sabhi employees ko find kare jinka `manager_id` NOT NULL ho aur jinki salary $100,000 se zyada ho.
5. `REGEXP` operator use karke un sabhi customers ko fetch karne ki query likho jinka `email` address ya toh `.com` par ya `.org` par end hota ho.
6. `orders` table ke against aisi query likho jo un sabhi orders ko find kare jahan `status` `'Pending'` ho YA `status` `'Processing'` ho, AUR `total_amount` plus `shipping_fee` milakar $500.00 se exceed karta ho.

### Difficult
7. Ek aisi query likh kar `col1 = col2` aur `col1 <=> col2` ke beech exact operational difference demonstrate karo jo `(5, 5)`, `(5, NULL)`, aur `(NULL, NULL)` contain karne wale columns ko compare karti ho.
8. `products` table ke against aisi query likho jo bitwise operators use karke check kare ki integer status flag ka 3rd bit set hai ya nahi (`flag & 4 != 0`).

---

## 11. Interview Questions

### Q1: What is operator precedence in SQL, and why is the interaction between `AND` and `OR` a frequent source of bugs?
**Answer**: Operator precedence ye determine karta hai ki database engine complex expression mein alag-alag operators ko kis order mein evaluate karega. SQL mein, `AND` ki precedence `OR` se zyada hoti hai. Is wajah se, bina explicit parentheses ke, `A OR B AND C` jaisa expression internally `A OR (B AND C)` parse hota hai. Agar developer ka intention `(A OR B) AND C` tha, toh ek serious logic bug create ho jayega, kyunki condition `A` satisfy karne wali koi bhi row result set mein shamil ho jayegi, chahe condition `C` kuch bhi ho.

### Q2: What is the NULL-Safe Equality Operator (`<=>`) in MySQL, and when is it required?
**Answer**: Standard SQL mein, agar do values ko compare karte waqt ek ya dono values `NULL` hon (jaise `val = NULL` ya `NULL = NULL`), toh result hamesha `UNKNOWN` (treated as `NULL`) aata hai. MySQL ka NULL-Safe Equality Operator (`<=>`) ek aisi equality check perform karta hai jo `NULL` ko normal comparable value ki tarah treat karti hai:
* Agar dono operands `NULL` hain, toh `NULL <=> NULL` return karega `1` (`TRUE`).
* Agar ek operand `NULL` hai aur doosra nahi hai, toh `val <=> NULL` return karega `0` (`FALSE`).
* Agar dono mein se koi bhi `NULL` nahi hai, toh ye standard `=` operator ki tarah behave karta hai.
Ye operator tab zaroori hota hai jab hum nullable columns ko compare ya join kar rahe hote hain aur chahte hain ki do `NULL` entries ek-doosre se successfully match hon.

### Q3: How do you safely prevent division-by-zero errors in analytical SQL queries?
**Answer**: SQL mein, division-by-zero prevent karne ke liye denominator ko `NULLIF(expression, 0)` function ke andar wrap kiya jata hai. `NULLIF` apne arguments ko evaluate karta hai: agar denominator `0` ke barabar hota hai, toh ye `NULL` return karta hai; warna denominator ki original value return karta hai. SQL mein kisi bhi number ko `NULL` se divide karne par fatal runtime division-by-zero error aane ke bajay clean `NULL` produce hota hai:
```sql
SELECT total_revenue / NULLIF(total_units_sold, 0) AS avg_unit_price FROM sales;
```

---

## 12. Quick Revision

* **Arithmetic**: `+`, `-`, `*`, `/` (standard division), `DIV` (integer division), `%` / `MOD` (remainder).
* **Precedence**: `NOT` $\rightarrow$ `AND` $\rightarrow$ `OR`. Jab `AND` aur `OR` ko mix karein, toh **hamesha parentheses** use karein.
* **NULL-Safe Equality (`<=>`)**: Nullable columns ko safely compare karta hai, aur `NULL <=> NULL` ke liye `1` (`TRUE`) return karta hai.
* **Pattern Matching**: `LIKE` simple wildcards (`%`, `_`) handle karta hai; `REGEXP` / `RLIKE` powerful regular expression matching handle karta hai.
* Fatal division-by-zero errors se bachne ke liye **`NULLIF(divisor, 0)`** use karein.
