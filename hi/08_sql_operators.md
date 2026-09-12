# Chapter 08 — SQL Operators & Expression Evaluation (SQL ऑपरेटर्स और एक्सप्रेशन इवैल्यूएशन)

---

## 1. What is it? (यह क्या है?)

SQL mein ek **operator** ek reserved keyword ya symbol hota hai jo database engine ko ek ya zyada data items (jinhe hum **operands** kehte hain) par mathematical, logical, comparison ya bitwise calculation karne ka instruction deta hai.

Operands table ke column values ho sakte hain, koi literal constant (jaise `10` ya `'Active'`), kisi subquery ka result, ya phir kisi function ki return value. Jab hum operators aur operands ko aapas mein jodte hain, toh ek **expression** banta hai jo calculate hokar ek scalar value deta hai (jaise koi number, string ya boolean truth value).

SQL operators ko 6 mukhya functional categories mein baanta gaya hai:
1. **Arithmetic Operators**: Basic numerical calculations ke liye (`+`, `-`, `*`, `/`, `DIV`, `%` / `MOD`).
2. **Comparison Operators**: Do expressions ko compare karke boolean result dete hain (`=`, `!=`, `<>`, `<`, `>`, `<=`, `>=`, `<=>`).
3. **Logical Operators**: Multiple boolean conditions ko aapas mein jodne ke liye (`AND`, `OR`, `NOT`, `XOR`).
4. **Set & Membership Operators**: Kisi set ya range ke andar existence check karne ke liye (`IN`, `NOT IN`, `BETWEEN`, `EXISTS`, `ANY`, `ALL`).
5. **Pattern & Regular Expression Operators**: Text ke patterns match karne ke liye (`LIKE`, `NOT LIKE`, `REGEXP` / `RLIKE`).
6. **Bitwise Operators**: Binary bits ke level par operations perform karne ke liye (`&`, `|`, `^`, `~`, `<<`, `>>`).

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Dynamic Business Calculations (बिजनेस कैलकुलेशन डेटाबेस में)**: Discounted prices calculate karna (`unit_price * (1 - discount)`), employees ka bonus nikalna, ya tax withholding calculate karna seedhe database level par efficiently ho jata hai.
2. **Multi-Condition Filtering (जटिल बिजनेस रूल्स)**: Multiple business conditions ko aapas mein combine karna (jaise: *"Aise orders dhundho jo ya toh Shipped hon YA Delivered hon, AUR jinka total amount $500 se zyada ho"*).
3. **Advanced Pattern Matching (सर्च और वैलिडेशन)**: User ke search keywords match karna, email formats validate karna, ya phone numbers se country code nikalne ke liye Regular Expressions (`REGEXP`) ka use karna.
4. **Safe Nullability Comparison (NULL वैल्यूज की सुरक्षित तुलना)**: Do columns ko compare karna jahan dono taraf `NULL` ho sakta hai, bina 3-Valued Logic ke trap mein fase, MySQL ke NULL-Safe Equality operator (`<=>`) se aasaani se sambhav hota hai.

---

## 3. Comprehensive Operator Taxonomy & Syntax (ऑपरेटर टैक्सोनॉमी और सिंटैक्स)

### 3.1. Arithmetic Operators (अंकगणितीय ऑपरेटर्स)

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

### 3.2. Comparison & NULL-Safe Equality Operators (तुलना और NULL-सुरक्षित ऑपरेटर्स)

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

### 3.3. Logical Operators & Precedence Rules (लॉजिकल ऑपरेटर्स और प्राथमिकता नियम)

| Operator | Syntax Alias | Description | Precedence Rank |
| :--- | :--- | :--- | :--- |
| `NOT` | `!` | Boolean truth value ko ulta karta hai (`NOT TRUE` $\rightarrow$ `FALSE`) | High (उच्च) |
| `AND` | `&&` | Tabhi `TRUE` evaluate hota hai jab **dono** operands `TRUE` hon | Medium (मध्यम) |
| `OR` | `\|\|` | Tab `TRUE` evaluate hota hai jab **koi bhi ek** operand `TRUE` ho | Low (कम) |
| `XOR` | | Tab `TRUE` evaluate hota hai jab theek **ek hi** operand `TRUE` ho | Low (कम) |

> [!CAUTION]
> **Operator Precedence Trap (ऑपरेटर प्राथमिकता का जाल)**: `AND` ki priority `OR` se hamesha zyada hoti hai. Iska matlab `A OR B AND C` ko SQL hamesha `A OR (B AND C)` ki tarah evaluate karega. Apne logic ko 100% safe aur bug-free rakhne ke liye hamesha brackets `(A OR B) AND C` ka use karein!

### 3.4. Regular Expression Operators (`REGEXP` / `RLIKE`)

```sql
-- Checks if first_name starts with A, E, I, O, or U (case-insensitive by default)
SELECT first_name FROM customers WHERE first_name REGEXP '^[AEIOU]';

-- Checks if phone contains only numbers and dashes
SELECT phone FROM customers WHERE phone REGEXP '^[0-9-]+$';
```

---

## 4. Basic Example (बुनियादी उदाहरण)

Basic arithmetic, logical precedence, aur pattern operators ka evaluation:

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

## 5. Real-World Example (वास्तविक दुनिया का उदाहरण)

E-commerce sales director ko `order_items` table ka ek complete financial audit report chahiye. Har ordered item ke liye:
1. Gross total calculate karein (`quantity * unit_price`).
2. Monetary discount amount nikalen (`gross_total * discount`).
3. Discount ke baad net billed amount calculate karein.
4. Sirf unhi items ko filter karein jinka net billed price $200 se zyada ho AUR ya toh unpar discount diya gaya ho (`discount > 0`) YA phir unki quantity 1 se zyada ho.

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

## 6. Step-by-Step Explanation (कदम-दर-कदम व्याख्या)

1. `(quantity * unit_price)`:
   * Integer column `quantity` ko exact decimal `unit_price` se multiply karta hai, jisse bina discount ka raw gross total milta hai.
2. `(1.00 - discount)`:
   * Discount ke baad bacha hua percentage calculate karta hai (jaise agar discount 5% yaani `0.05` hai, toh bachega `1.00 - 0.05 = 0.95`).
3. `ROUND(quantity * unit_price * (1.00 - discount), 2)`:
   * Net final price calculate karta hai aur `ROUND(..., 2)` currency cents ke hisab se exact 2 decimal places tak round kar deta hai.
4. `WHERE (...) > 200.00 AND (discount > 0.00 OR quantity > 1)`:
   * **Sub-expression 1**: `(quantity * unit_price * (1.00 - discount)) > 200.00` check karta hai ki net price $200 se upar hai ya nahi.
   * **Sub-expression 2**: `(discount > 0.00 OR quantity > 1)` check karta hai ki customer ko promotional discount mila tha YA unhone bulk mein saman kharida tha.
   * **Logical Operator**: `AND` operator ensure karta hai ki yeh dono conditions ek sath satisfy hon.

---

## 7. Expected Result (अपेक्षित परिणाम)

Order items audit query ka result:

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

## 8. Common Mistakes (आम गलतियाँ)

1. **Forgetting Parentheses with `AND` and `OR` (`AND` और `OR` में ब्रैकेट भूल जाना)**:
   * *Mistake*:
     ```sql
     WHERE status = 'Shipped' OR status = 'Processing' AND total_amount > 500;
     ```
   * *What actually runs (इंजन असल में क्या चलाता है)*:
     ```sql
     WHERE status = 'Shipped' OR (status = 'Processing' AND total_amount > 500);
     ```
   * *Consequence*: Har ek order jiska status `'Shipped'` hai woh result mein aa jayega, chahe uska `total_amount` sirf $5.00 hi kyun na ho!
   * *Correction*: Hamesha brackets lagayein: `WHERE (status = 'Shipped' OR status = 'Processing') AND total_amount > 500;`.
2. **Dividing by Zero (शून्य से भाग देना)**:
   * *Query*: `SELECT 100 / 0;`
   * *Behavior*: MySQL default mode mein division by zero par `NULL` return karta hai aur warning deta hai (`Warning 1365: Division by 0`). Lekin strict mode (`ERROR_FOR_DIVISION_BY_ZERO`) mein yeh query ko seedhe fail kar deta hai. Isse bachne ke liye `NULLIF` ka use karein: `100 / NULLIF(divisor, 0)`.
3. **Using `=` for NULL Checks in Joins or Filtering (NULL चेक्स में `=` लगाना)**:
   * Agar do tables ke columns mein `NULL` values hain, toh `t1.manager_id = t2.manager_id` likhne par dono ke `NULL` aapas mein match nahi honge kyunki SQL mein `NULL = NULL` ka result `UNKNOWN` hota hai.
   * *Fix*: Hamesha NULL-Safe Equality operator use karein: `t1.manager_id <=> t2.manager_id`.
4. **Confusing `%` (Modulo) with `%` (LIKE Wildcard) (`%` के दो अलग मतलब)**:
   * Arithmetic expressions (`10 % 3`) mein `%` remainder (sheshfal) nikalta hai (`1`). Jabki string search pattern (`WHERE name LIKE '%son'`) mein `%` zero ya zyada characters match karne wala wildcard hota hai.

---

## 9. Best Practices (सर्वोत्तम प्रथाएं / Best Practices)

1. **Always Use Parentheses to Disambiguate Compound Logical Predicates (लॉजिकल कंडीशन्स में ब्रैकेट का उपयोग करें)**:
   * Chahe aapko operator precedence kitni bhi achhi tarah yaad ho, team ke dusre developers confuse ho sakte hain. Brackets lagane se code clear rehta hai aur PR reviews aasaan ho jaate hain.
2. **Prefer Standard ANSI SQL Operator Names (मानक ANSI कीवर्ड्स चुनें)**:
   * Non-standard shortcuts jaise `&&`, `||`, `!`, `!=` ke bajaye standard `AND`, `OR`, `NOT`, `<>` ka use karein. Isse aapka SQL code MySQL, PostgreSQL, Oracle, aur Snowflake sabhi par bina badlav ke chalta hai.
3. **Guard Against Division by Zero Using `NULLIF` (`NULLIF` से क्रैश होने से बचाएं)**:
   * Production analytical queries mein hamesha `dividend / NULLIF(divisor, 0)` pattern use karein taaki zero aane par runtime crash na ho.
4. **Optimize Pattern Searches (पैटर्न सर्च ऑप्टिमाइज़ करें)**:
   * Simple prefix match (`name LIKE 'San%'`) B+ Tree index ka use karke fast execute hota hai. Lekin complex regular expressions (`name REGEXP '^San[a-z]+'`) standard index use nahi kar pate aur full table scan karte hain. Large tables par inka use soch-samajhkar karein.

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. `employees` table se har employee ka annual bonus nikalne ki query likhein, jo unki `salary` ka 12% ho, aur use `bonus_amount` ke naam se alias karein.
2. Modulo operator (`%`) ka use karke `products` table se un sabhi products ko find karein jinka `stock_quantity` ek even (sam) number hai.
3. `IN` operator ka use karke un sabhi customers ko find karein jinki `country` ya toh `'USA'` hai ya `'Germany'`.

### Medium (मध्यम)
4. Aise sabhi employees ko find karne ke liye query likhein jinka `manager_id` `NOT NULL` hai aur jinki salary $100,000 se zyada hai.
5. `REGEXP` operator ka use karke un sabhi customers ko nikalen jinka `email` address `.com` ya `.org` par end hota hai.
6. `orders` table se un sabhi orders ko find karein jinka `status` `'Pending'` YA `'Processing'` ho, AUR jinka `total_amount` + `shipping_fee` milakar $500.00 se zyada ho.

### Difficult (कठिन)
7. Ek aisi query likhein jo `(5, 5)`, `(5, NULL)`, aur `(NULL, NULL)` values par `col1 = col2` aur `col1 <=> col2` ka exact difference live compare karke dikhaye.
8. `products` table par ek query likhein jo bitwise operator ka use karke verify kare ki kisi integer status flag ka 3rd bit set hai ya nahi (`flag & 4 != 0`).

---

## 11. Interview Questions (साक्षात्कार प्रश्न)

### Q1: What is operator precedence in SQL, and why is the interaction between `AND` and `OR` a frequent source of bugs?
**Answer**: Operator precedence yeh tay karti hai ki complex expressions mein database engine kis operator ko pehle evaluate karega. SQL mein `AND` ki priority `OR` se zyada hoti hai. Isliye, agar brackets nahi lagaye jayein, toh `A OR B AND C` ko database hamesha `A OR (B AND C)` manta hai. Agar developer ka matlab tha `(A OR B) AND C`, toh ek gambhir bug paida ho jata hai—kyunki condition `A` satisfy karne wali koi bhi row result mein chali aayegi chahe condition `C` fail hi kyun na ho rahi ho.

### Q2: What is the NULL-Safe Equality Operator (`<=>`) in MySQL, and when is it required?
**Answer**: Standard SQL mein jab aap do values ko compare karte hain aur unme se koi ek ya dono `NULL` hoti hain (jaise `val = NULL` ya `NULL = NULL`), toh result hamesha `UNKNOWN` (`NULL`) aata hai. 
MySQL ka NULL-Safe Equality Operator (`<=>`) ek special equality check hai jo `NULL` ko ek normal comparable value ki tarah treat karta hai:
* Agar dono operands `NULL` hain, toh `NULL <=> NULL` return karta hai `1` (`TRUE`).
* Agar ek operand `NULL` hai aur dusra nahi, toh `val <=> NULL` return karta hai `0` (`FALSE`).
* Agar dono operands non-null hain, toh yeh normal `=` operator ki tarah hi kaam karta hai.
Yeh operator tab behad zaroori ho jata hai jab aap nullable columns ko compare kar rahe hon ya join kar rahe hon aur do `NULL` entries ko match karwana chahte hon.

### Q3: How do you safely prevent division-by-zero errors in analytical SQL queries?
**Answer**: SQL queries mein division-by-zero se bachne ke liye hum denominator ko `NULLIF(expression, 0)` function ke andar wrap karte hain. `NULLIF` apne arguments ko check karta hai: agar denominator ki value `0` hoti hai, toh yeh `NULL` return karta hai, warna normal value deta hai. Aur SQL mein kisi bhi number ko `NULL` se divide karne par result `NULL` aata hai, bina kisi fatal runtime error ya warning ke:
```sql
SELECT total_revenue / NULLIF(total_units_sold, 0) AS avg_unit_price FROM sales;
```

---

## 12. Quick Revision (त्वरित सारांश)

* **Arithmetic**: `+`, `-`, `*`, `/` (standard division), `DIV` (integer division), `%` / `MOD` (remainder/sheshfal).
* **Precedence Order**: `NOT` $\rightarrow$ `AND` $\rightarrow$ `OR`. Jab bhi `AND` aur `OR` ko mix karein, **hamesha brackets use karein**.
* **NULL-Safe Equality (`<=>`)**: Nullable columns ko safely compare karta hai; `NULL <=> NULL` ka result `1` (`TRUE`) hota hai.
* **Pattern Matching**: `LIKE` simple wildcards (`%`, `_`) handle karta hai; `REGEXP` / `RLIKE` powerful regular expressions handle karta hai.
* Production calculations mein fatal division-by-zero errors se bachne ke liye hamesha **`NULLIF(divisor, 0)`** ka prayog karein.
