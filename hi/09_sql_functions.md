# Chapter 09 — Built-in SQL Functions: String, Date, Numeric & Flow Control (Built-in SQL Functions)

---

## 1. What is it? (Ye Kya Hai?)

Ek **SQL function** RDBMS engine ka built-in, pre-compiled subroutine hota hai jo zero ya usse zyada input parameters accept karta hai, ek dedicated algorithmic operation perform karta hai, aur ek scalar (single) value return karta hai.

SQL functions ko broadly 2 operational modes mein divide kiya jata hai:
1. **Scalar Functions**: Ye individual row values par independently operate karte hain, aur har input row ke liye ek transformed value return karte hain (jaise `UPPER()` se text ko uppercase banana, ya `CURDATE()` se current date nikalna).
2. **Aggregate Functions**: Ye table ya partition ki multiple rows par operate karte hain, aur poore set of values ko summarize karke ek single consolidated result return karte hain (jaise `AVG()` se average nikalna, ya `COUNT()` se entries count karna).

MySQL mein production-tested functions ki ek badi library hai jise 4 main functional disciplines mein organize kiya gaya hai:
* **String & Text Functions** (manipulation, formatting, slicing, length calculation)
* **Date & Temporal Functions** (calendar math, intervals, formatting, timezone conversions)
* **Numeric & Mathematical Functions** (rounding, truncation, trigonometry, powers)
* **Conditional & Flow Control Functions** (`IF`, `CASE`, `COALESCE`, `IFNULL`, `NULLIF`)

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Server-Side Data Transformation**: String concatenations karna (jaise `first_name` aur `last_name` ko merge karna), text casing change karna, aur date calculations database ke andar directly perform karne se application code simple rehta hai aur client-side processing overhead kam hota hai.
2. **Robust Handling of Missing Data**: `COALESCE` aur `IFNULL` jaise functions missing (`NULL`) values ko sensible business defaults se replace kar dete hain (jaise blank phone number ki jagah `"N/A"` display karna).
3. **Complex Business Logic**: `CASE WHEN ... THEN` jaise conditional expressions queries ke andar directly dynamic categorization allow karte hain (jaise loyalty points ke base par customers ko `"VIP"`, `"Gold"`, ya `"Bronze"` tag karna).
4. **Calendar & Interval Arithmetic**: Elapsed days, expiry dates, ya age in years calculate karne ke liye calendar-aware engine primitives use karna brittle manual calculation se kahin behtar aur safe hota hai.

---

## 3. Syntax

### 3.1. String Functions

| Function | Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| `CONCAT()` | `CONCAT(str1, str2, ...)` | Multiple strings ko aapas mein jodta hai. Agar koi bhi argument `NULL` ho toh `NULL` return karta hai. | `CONCAT('Hello', ' ', 'World')` $\rightarrow$ `'Hello World'` |
| `CONCAT_WS()` | `CONCAT_WS(separator, s1, s2, ...)` | Concatenate With Separator. `NULL` values ko cleanly skip kar deta hai! | `CONCAT_WS(', ', 'NY', NULL, 'USA')` $\rightarrow$ `'NY, USA'` |
| `UPPER()` / `LOWER()` | `UPPER(str)` / `LOWER(str)` | Character string ko uppercase ya lowercase mein convert karta hai. | `UPPER('mysql')` $\rightarrow$ `'MYSQL'` |
| `LENGTH()` | `LENGTH(str)` | String ki length **bytes** mein return karta hai (multi-byte UTF-8 chars 2–4 bytes lete hain). | `LENGTH('SQL')` $\rightarrow$ `3` |
| `CHAR_LENGTH()` | `CHAR_LENGTH(str)` | String ki length **characters** mein return karta hai (UTF-8 ke liye accurate). | `CHAR_LENGTH('Café')` $\rightarrow$ `4` |
| `SUBSTRING()` | `SUBSTRING(str, pos, len)` | 1-based index `pos` se start karke `len` characters extract karta hai. | `SUBSTRING('Database', 1, 4)` $\rightarrow$ `'Data'` |
| `TRIM()` | `TRIM(str)` | Leading aur trailing whitespace ko strip kar deta hai. | `TRIM('  text  ')` $\rightarrow$ `'text'` |
| `REPLACE()` | `REPLACE(str, from, to)` | Substring ke sabhi occurrences ko replace karta hai. | `REPLACE('v1.0', '1', '2')` $\rightarrow$ `'v2.0'` |
| `INSTR()` | `INSTR(str, substr)` | Substring ke pehle occurrence ki 1-based position return karta hai. | `INSTR('Code', 'de')` $\rightarrow$ `3` |
| `LPAD()` / `RPAD()` | `LPAD(str, len, pad)` | String ko specified length `len` tak left ya right pad karta hai. | `LPAD('42', 5, '0')` $\rightarrow$ `'00042'` |

### 3.2. Date & Time Functions

| Function | Syntax | Description |
| :--- | :--- | :--- |
| `NOW()` / `CURRENT_TIMESTAMP()` | `NOW()` | Statement start hone par current date aur time (`YYYY-MM-DD HH:MM:SS`) return karta hai. |
| `CURDATE()` | `CURDATE()` | Current calendar date (`YYYY-MM-DD`) return karta hai. |
| `CURTIME()` | `CURTIME()` | Current time (`HH:MM:SS`) return karta hai. |
| `YEAR()`, `MONTH()`, `DAY()` | `YEAR(date)` | Individual date parts ko integers ke roop mein extract karta hai. |
| `DATEDIFF()` | `DATEDIFF(end_date, start_date)` | Difference **days** mein calculate karta hai (`end - start`). |
| `TIMESTAMPDIFF()` | `TIMESTAMPDIFF(unit, start, end)` | Specified `unit` (`YEAR`, `MONTH`, `DAY`, `HOUR`, `SECOND`) mein difference calculate karta hai. |
| `DATE_ADD()` / `DATE_SUB()` | `DATE_ADD(date, INTERVAL n UNIT)` | Temporal units ko add ya subtract karta hai (`INTERVAL 7 DAY`, `INTERVAL 1 MONTH`). |
| `DATE_FORMAT()` | `DATE_FORMAT(date, '%M %d, %Y')` | Date ko custom display string mein format karta hai. |

### 3.3. Numeric & Mathematical Functions

| Function | Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| `ROUND()` | `ROUND(num, decimals)` | Specified decimal place par nearest value par round karta hai. | `ROUND(15.756, 2)` $\rightarrow$ `15.76` |
| `TRUNCATE()` | `TRUNCATE(num, decimals)`| Decimals ko bina rounding ke seedhe chop off kar deta hai. | `TRUNCATE(15.756, 2)` $\rightarrow$ `15.75` |
| `FLOOR()` | `FLOOR(num)` | Largest integer $\le$ number return karta hai (niche round karta hai). | `FLOOR(15.9)` $\rightarrow$ `15` |
| `CEIL()` / `CEILING()` | `CEIL(num)` | Smallest integer $\ge$ number return karta hai (upar round karta hai). | `CEIL(15.1)` $\rightarrow$ `16` |
| `ABS()` | `ABS(num)` | Absolute (positive) magnitude return karta hai. | `ABS(-42)` $\rightarrow$ `42` |
| `MOD()` | `MOD(n, m)` | Modulo division remainder ($n \pmod m$) return karta hai. | `MOD(11, 4)` $\rightarrow$ `3` |
| `POWER()` / `POW()` | `POWER(x, y)` | $x$ ki power $y$ ($x^y$) calculate karta hai. | `POWER(2, 3)` $\rightarrow$ `8` |

### 3.4. Aggregate Functions & NULL Mechanics

```sql
SELECT 
    COUNT(*) AS total_rows,              -- Counts all rows (including rows with NULLs)
    COUNT(phone) AS rows_with_phone,     -- Counts only rows where phone IS NOT NULL
    COUNT(DISTINCT country) AS countries, -- Counts unique non-null countries
    SUM(salary) AS total_payroll,        -- Sum of non-null salaries
    AVG(salary) AS average_salary,       -- Sum / COUNT(salary) - strictly ignores NULLs!
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees;
```

> [!IMPORTANT]
> **Aggregate NULL Trap**: Sabhi aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) **NULLs ko silently ignore karte hain**. Sirf ek exception hai: `COUNT(*)`, jo individual columns ke contents ki parwah kiye bina total physical rows count karta hai.

### 3.5. Conditional & Flow Control Functions

```sql
-- 1. Simple Two-Branch IF: IF(condition, value_if_true, value_if_false)
SELECT first_name, IF(salary >= 100000, 'Executive', 'Standard') AS pay_band FROM employees;

-- 2. IFNULL: IFNULL(expression, fallback_value)
SELECT first_name, IFNULL(phone, 'No Phone on Record') AS contact_phone FROM customers;

-- 3. COALESCE: Returns the FIRST non-null value in an arbitrary parameter list
SELECT first_name, COALESCE(phone, state, country, 'Unknown') AS fallback_location FROM customers;

-- 4. NULLIF: Returns NULL if both arguments are equal, otherwise returns arg1
SELECT NULLIF(status, 'Pending') FROM orders;

-- 5. Standard CASE Expression (Searched CASE)
SELECT 
    customer_id,
    first_name,
    loyalty_points,
    CASE 
        WHEN loyalty_points >= 700 THEN 'Platinum Tier'
        WHEN loyalty_points >= 400 THEN 'Gold Tier'
        WHEN loyalty_points >= 100 THEN 'Silver Tier'
        ELSE 'Bronze Tier'
    END AS customer_tier
FROM customers;
```

---

## 4. Basic Example

Scalar transformations, date formatting, aur conditional expressions ke examples:

```sql
USE sql_mastery;

-- String manipulation
SELECT 
    CONCAT(UPPER(last_name), ', ', first_name) AS formal_name,
    CONCAT('USR-', LPAD(customer_id, 5, '0')) AS formatted_code,
    CHAR_LENGTH(email) AS email_character_count
FROM customers
LIMIT 3;

-- Date calculations
SELECT 
    order_id,
    order_date,
    DATE_FORMAT(order_date, '%W, %M %d, %Y') AS formatted_date,
    DATEDIFF(CURDATE(), order_date) AS days_since_order,
    DATE_ADD(order_date, INTERVAL 30 DAY) AS payment_due_date
FROM orders
LIMIT 3;
```

---

## 5. Real-World Example

HR aur Executive Operations committee ko `employees` table se ek comprehensive Workforce Compensation Report chahiye:
1. `first_name` aur `last_name` ko combine karke `full_name` banao.
2. Missing `phone` numbers ki jagah `'Contact via HR'` display karo.
3. `TIMESTAMPDIFF()` use karke employee tenure complete elapsed years mein calculate karo.
4. Cost-of-living adjusted salary calculate karo aur nearest integer par round karo.
5. `CASE` expression use karke har employee ko ek compensation band mein classify karo.

```sql
USE sql_mastery;

SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    COALESCE(phone, 'Contact via HR') AS office_contact,
    hire_date,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS tenure_years,
    salary AS base_salary,
    ROUND(salary * 1.05, 0) AS adjusted_salary_5pct,
    CASE 
        WHEN salary >= 130000 THEN 'Tier 1 — Principal/Executive'
        WHEN salary >= 100000 THEN 'Tier 2 — Senior Specialist'
        WHEN salary >= 80000  THEN 'Tier 3 — Mid-Level Specialist'
        ELSE 'Tier 4 — Associate'
    END AS compensation_tier
FROM employees
ORDER BY salary DESC;
```

---

## 6. Step-by-Step Explanation

1. `CONCAT(first_name, ' ', last_name)`:
   * Dono string columns ko beech mein space literal ke sath merge karta hai.
2. `COALESCE(phone, 'Contact via HR')`:
   * `phone` ko evaluate karta hai. Agar phone string value hai (jaise `'555-0100'`), toh wahi return hoti hai. Agar `phone` `NULL` hai, toh `COALESCE` fallback string `'Contact via HR'` return karta hai.
3. `TIMESTAMPDIFF(YEAR, hire_date, CURDATE())`:
   * Leap years ko consider karte hue `hire_date` aur aaj ki calendar date ke beech total full elapsed years calculate karta hai.
4. `ROUND(salary * 1.05, 0)`:
   * Salary ko 1.05 se multiply karta hai (5% adjustment) aur result ko 0 decimal places par round karta hai.
5. `CASE WHEN ... THEN ... END`:
   * Conditions ko top se bottom sequentially evaluate karta hai. Pehli condition jo `TRUE` hoti hai, uska corresponding string assign hota hai, aur execution turant `END` par jump kar jata hai.

---

## 7. Expected Result

Workforce Compensation Report query ka output:

```
+-------------+---------------------+-------------------+------------+--------------+-------------+----------------------+-------------------------------+
| employee_id | full_name           | office_contact    | hire_date  | tenure_years | base_salary | adjusted_salary_5pct | compensation_tier             |
+-------------+---------------------+-------------------+------------+--------------+-------------+----------------------+-------------------------------+
|           1 | Alex Morgan         | 555-0100          | 2019-03-15 |            7 |   145000.00 |               152250 | Tier 1 — Principal/Executive  |
|           4 | Priya Patel         | 555-0103          | 2020-02-10 |            6 |   135000.00 |               141750 | Tier 1 — Principal/Executive  |
|           6 | Elena Rostova       | 555-0105          | 2018-11-05 |            7 |   130000.00 |               136500 | Tier 1 — Principal/Executive  |
|           2 | Sarah Chen          | 555-0101          | 2020-06-01 |            6 |   125000.00 |               131250 | Tier 2 — Senior Specialist    |
|           8 | Jessica Taylor      | 555-0107          | 2019-08-12 |            7 |   110000.00 |               115500 | Tier 2 — Senior Specialist    |
|           3 | Marcus Vance        | 555-0102          | 2021-01-15 |            5 |    98000.00 |               102900 | Tier 3 — Mid-Level Specialist |
|           5 | David Kim           | 555-0104          | 2021-07-20 |            5 |    92000.00 |                96600 | Tier 3 — Mid-Level Specialist |
|          10 | Fatima Al-Mansoor   | 555-0109          | 2022-05-18 |            4 |    85000.00 |                89250 | Tier 3 — Mid-Level Specialist |
|           7 | Liam OConnor        | 555-0106          | 2022-03-01 |            4 |    78000.00 |                81900 | Tier 4 — Associate            |
|           9 | Carlos Mendoza      | 555-0108          | 2021-10-01 |            4 |    72000.00 |                75600 | Tier 4 — Associate            |
+-------------+---------------------+-------------------+------------+--------------+-------------+----------------------+-------------------------------+
10 rows in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **`CONCAT()` with `NULL` Producing `NULL`**:
   * *The Problem*: `SELECT CONCAT(first_name, ' - ', phone) FROM customers;`
   * *Failure*: Agar `phone` `NULL` hai, toh `CONCAT()` **poori string ko hi `NULL` bana deta hai**!
   * *Remedy*: `CONCAT_WS()` use karo (jo NULLs ko skip karta hai) ya phir column ko `COALESCE(phone, '')` mein wrap karo:
     ```sql
     SELECT CONCAT(first_name, ' - ', COALESCE(phone, 'No Phone')) FROM customers;
     ```
2. **Confusing `LENGTH()` with `CHAR_LENGTH()`**:
   * *Mistake*: Characters count karne ke liye `LENGTH()` ka use karna.
   * *Problem*: `utf8mb4` encoding mein `'é'` ya emojis jaise characters 2 se 4 bytes lete hain. `LENGTH('Café')` 5 return karega, jabki `CHAR_LENGTH('Café')` 4 return karega. Character count ke liye hamesha `CHAR_LENGTH()` use karo.
3. **`DATEDIFF()` Argument Ordering**:
   * MySQL mein `DATEDIFF(date1, date2)` internally `date1 - date2` compute karta hai. Agar aap `DATEDIFF('2023-01-01', '2023-01-10')` pass karenge, toh ye `-9` return karega.
4. **Misinterpreting `AVG()` with Nullable Columns**:
   * Agar kisi table mein 4 rows hain jinme values `[100, 200, 300, NULL]` hain, toh `AVG(col)` internally `(100 + 200 + 300) / 3 = 200` compute karta hai. Ye 4 se divide nahi karta! Agar aapke business logic mein NULL ko 0 treat karna required hai, toh explicitly likhna padega: `AVG(COALESCE(col, 0))`.

---

## 9. Best Practices

1. **Use `COALESCE` Over Vendor-Specific `IFNULL`**:
   * `IFNULL` sirf MySQL-specific hai. `COALESCE` ANSI SQL standard ka part hai, multiple fallback parameters accept karta hai, aur PostgreSQL, Oracle, aur SQL Server par fully portable hai.
2. **Never Call Non-Deterministic Functions in Loops or Joins**:
   * `SYSDATE()` call karne se har ek row evaluation par clock time recalculate hota hai, jisse performance degrade hoti hai aur query caching disable ho jati hai. Iski jagah `NOW()` ya `CURRENT_TIMESTAMP` prefer karo, jo statement start hone par ek constant timestamp evaluate karta hai.
3. **Always Include an `ELSE` in `CASE` Expressions**:
   * Agar koi bhi `WHEN` branch match nahi karti aur koi `ELSE` clause nahi hota, toh SQL default mein `NULL` return karta hai. Unintended `NULL` propagation se bachne ke liye hamesha ek `ELSE` fallback zaroor do.

---

## 10. Practice Questions

### Easy
1. Sabhi customer emails ko fully lowercase mein convert karke display karne ke liye query likho.
2. Current date, current time, aur current timestamp ko teen alag-alag columns mein display karne ke liye query likho.
3. Har product ki unit price ko nearest integer par round karne ke liye query likho.

### Medium
4. `DATE_FORMAT` use karke sabhi `order_date` values ko `'DD/MM/YYYY'` format (jaise `'15/08/2023'`) mein display karne ke liye query likho.
5. `employees` table ke `email` column se domain name (`'@'` symbol ke baad ka text) extract karne ke liye query likho.
6. Sabhi active employees ke liye total payroll, average salary, minimum salary, aur maximum salary compute karne ke liye query likho.

### Difficult
7. `products` table ke against aisi query likho jo `CASE` expression use karke `reorder_urgency` flag calculate kare:
   * `'CRITICAL'` agar `stock_quantity = 0`
   * `'HIGH'` agar `stock_quantity <= reorder_level`
   * `'MEDIUM'` agar `stock_quantity <= reorder_level * 1.5`
   * `'HEALTHY'` otherwise.
8. `order_items` table par `AVG(discount)` aur `SUM(discount) / COUNT(*)` ke output ko compare karo. Explain karo ki ye dono alag numerical results kyun de sakte hain.

---

## 11. Interview Questions

### Q1: What is the mechanical difference between `COUNT(*)`, `COUNT(column_name)`, and `COUNT(DISTINCT column_name)`?
**Answer**:
* `COUNT(*)` retrieve ki gayi total physical rows count karta hai, chahe us row ke kisi bhi column mein `NULL` ho ya na ho.
* `COUNT(column_name)` sirf un rows ko count karta hai jahan specified column non-NULL value contain karta hai. Jin rows mein `column_name IS NULL` hota hai, unhe completely ignore kar deta hai.
* `COUNT(DISTINCT column_name)` matching rows ke andar us column ki unique, non-NULL values ka count return karta hai.

### Q2: What is the difference between `COALESCE()` and `IFNULL()` in MySQL?
**Answer**:
1. **Parameter Flexibility**: `IFNULL(expr1, expr2)` strictly do arguments accept karta hai, aur agar `expr1` `NULL` ho toh `expr2` return karta hai. `COALESCE(expr1, expr2, ..., exprN)` arbitrary number of arguments accept karta hai aur left to right pehla non-NULL expression return karta hai.
2. **Portability**: `COALESCE` standard ANSI SQL specification ka part hai aur sabhi enterprise RDBMS engines (PostgreSQL, SQL Server, Oracle) par supported hai. `IFNULL` ek proprietary MySQL function hai.

### Q3: How do `NOW()` and `SYSDATE()` differ in MySQL?
**Answer**: `NOW()` wo exact timestamp return karta hai jab SQL statement ne *execution start kiya tha*, aur ye poori query duration ke dauran ek deterministic constant ki tarah behave karta hai. `SYSDATE()` wo real-time clock timestamp return karta hai jab wo particular *row ya function call physically evaluate hota hai*. Long-running queries ya row-by-row scans mein `SYSDATE()` ke repeated calls alag-alag timestamps return kar sakte hain, jisse query optimizer ki kai optimizations disable ho jati hain aur non-deterministic behavior introduce hota hai.

---

## 12. Quick Revision

* **Scalar functions** single row values transform karte hain; **Aggregate functions** multiple rows ko summary metrics mein consolidate karte hain.
* Strings ke sath **`CONCAT_WS()`** ya **`COALESCE()`** use karo taki single `NULL` poori string concatenation ko nullify na kare.
* **`CHAR_LENGTH()`** UTF-8 characters count karta hai; **`LENGTH()`** raw storage bytes measure karta hai.
* Sabhi aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) **NULLs ko ignore karte hain**; sirf `COUNT(*)` har physical row ko count karta hai.
* Complex conditional classification ke liye standard **`CASE WHEN ... THEN ... ELSE ... END`** use karo.
* Calendar-aware differences (years, months, days) ke liye **`TIMESTAMPDIFF()`** use karo.
