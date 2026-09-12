# Chapter 09 — Built-in SQL Functions: String, Date, Numeric & Flow Control (बिल्ट-इन SQL फंक्शन्स)

---

## 1. What is it? (यह क्या है?)

SQL mein ek **function** ek pre-compiled built-in subroutine (ek ready-made tool) hota hai jo database engine ke sath aata hai. Yeh zero ya usse zyada input arguments leta hai, unpar calculation ya processing karta hai, aur ek single (scalar) result return karta hai.

SQL functions ko mukhya roop se do operational modes mein baanta jata hai:
1. **Scalar Functions**: Yeh har ek individual row ke data par akele kaam karte hain aur har row ke badle ek transformed value dete hain (jaise `UPPER()` text ko capital karta hai, ya `CURDATE()` aaj ki date deta hai).
2. **Aggregate Functions**: Yeh table ya kisi group ki multiple rows ko summarize karte hain aur poore set ka ek single consolidated result nikalte hain (jaise `AVG()` sabhi values ka average nikalta hai, aur `COUNT()` rows count karta hai).

MySQL ke paas built-in functions ki ek behad powerful library hai, jise hum 4 major categories mein divide karte hain:
* **String & Text Functions** (text jodna, kaatna, case change karna, length nikalna)
* **Date & Temporal Functions** (calendar math, intervals, formatting, timezone conversions)
* **Numeric & Mathematical Functions** (rounding, truncation, powers, absolute values)
* **Conditional & Flow Control Functions** (`IF`, `CASE`, `COALESCE`, `IFNULL`, `NULLIF`)

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Server-Side Data Transformation (डेटाबेस के अंदर ही ट्रांसफॉर्मेशन)**: String concatenation (jaise `first_name` aur `last_name` ko jodkar `full_name` banana), text formatting, aur date calculations seedhe database server par execute karne se application code lightweight aur fast banta hai.
2. **Robust Handling of Missing Data (NULL वैल्यूज को संभालना)**: `COALESCE` aur `IFNULL` jaise functions missing (`NULL`) data ki jagah sensible default values (jaise phone number missing hone par `"N/A"`) set karne mein madad karte hain.
3. **Complex Business Logic (क्वेरी के अंदर कंडीशनल लॉजिक)**: `CASE WHEN ... THEN` conditional expressions ki madad se hum queries ke andar hi dynamic categorization kar sakte hain (jaise loyalty points ke hisab se customer ko `"VIP"`, `"Gold"`, ya `"Bronze"` tag dena).
4. **Calendar & Interval Arithmetic (तारीखों का सटीक हिसाब-किताब)**: Do dates ke beech ke din, expiry dates, ya exact age nikalna database ke calendar-aware functions se bina kisi logic bug ke ho jata hai.

---

## 3. Comprehensive Function Taxonomy & Syntax (फंक्शन टैक्सोनॉमी और सिंटैक्स)

### 3.1. String Functions (स्ट्रिंग फंक्शन्स)

| Function | Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| `CONCAT()` | `CONCAT(str1, str2, ...)` | Multiple strings ko aapas mein jodta hai. Agar koi bhi argument `NULL` ho toh result `NULL` ho jata hai. | `CONCAT('Hello', ' ', 'World')` $\rightarrow$ `'Hello World'` |
| `CONCAT_WS()` | `CONCAT_WS(separator, s1, s2, ...)` | Separator ke sath strings ko jodta hai (With Separator). Yeh `NULL` values ko bina error ke skip kar deta hai! | `CONCAT_WS(', ', 'NY', NULL, 'USA')` $\rightarrow$ `'NY, USA'` |
| `UPPER()` / `LOWER()` | `UPPER(str)` / `LOWER(str)` | Text ko uppercase ya lowercase mein convert karta hai. | `UPPER('mysql')` $\rightarrow$ `'MYSQL'` |
| `LENGTH()` | `LENGTH(str)` | String ki length **bytes** mein batata hai (UTF-8 mein special characters 2–4 bytes lete hain). | `LENGTH('SQL')` $\rightarrow$ `3` |
| `CHAR_LENGTH()` | `CHAR_LENGTH(str)` | String ki length **characters** (aksharon) mein batata hai (UTF-8 ke liye accurate). | `CHAR_LENGTH('Café')` $\rightarrow$ `4` |
| `SUBSTRING()` | `SUBSTRING(str, pos, len)` | 1-based index `pos` se shuru karke `len` characters bahar nikalta hai. | `SUBSTRING('Database', 1, 4)` $\rightarrow$ `'Data'` |
| `TRIM()` | `TRIM(str)` | String ke shuruat aur aakhiri ke extra spaces ko saaf karta hai. | `TRIM('  text  ')` $\rightarrow$ `'text'` |
| `REPLACE()` | `REPLACE(str, from, to)` | Kisi substring ke sabhi occurrences ko nayi value se replace kar deta hai. | `REPLACE('v1.0', '1', '2')` $\rightarrow$ `'v2.0'` |
| `INSTR()` | `INSTR(str, substr)` | Kisi substring ke pehle occurrence ka 1-based position number return karta hai. | `INSTR('Code', 'de')` $\rightarrow$ `3` |
| `LPAD()` / `RPAD()` | `LPAD(str, len, pad)` | String ki length `len` karne ke liye left ya right mein padding add karta hai. | `LPAD('42', 5, '0')` $\rightarrow$ `'00042'` |

### 3.2. Date & Time Functions (डेट और टाइम फंक्शन्स)

| Function | Syntax | Description |
| :--- | :--- | :--- |
| `NOW()` / `CURRENT_TIMESTAMP()` | `NOW()` | Query start hone ka exact date aur time (`YYYY-MM-DD HH:MM:SS`) return karta hai. |
| `CURDATE()` | `CURDATE()` | Aaj ki calendar date (`YYYY-MM-DD`) deta hai. |
| `CURTIME()` | `CURTIME()` | Current time (`HH:MM:SS`) deta hai. |
| `YEAR()`, `MONTH()`, `DAY()` | `YEAR(date)` | Date se individual parts (saal, mahina, din) integer ke roop mein nikalta hai. |
| `DATEDIFF()` | `DATEDIFF(end_date, start_date)` | Do dates ke beech ka difference **dino (days)** mein calculate karta hai (`end - start`). |
| `TIMESTAMPDIFF()` | `TIMESTAMPDIFF(unit, start, end)` | Kisi specified `unit` (`YEAR`, `MONTH`, `DAY`, `HOUR`, `SECOND`) mein difference nikalta hai. |
| `DATE_ADD()` / `DATE_SUB()` | `DATE_ADD(date, INTERVAL n UNIT)` | Date mein time units jodta ya ghatata hai (`INTERVAL 7 DAY`, `INTERVAL 1 MONTH`). |
| `DATE_FORMAT()` | `DATE_FORMAT(date, '%M %d, %Y')` | Date ko custom display format string mein convert karta hai. |

### 3.3. Numeric & Mathematical Functions (न्यूमेरिक और मैथ फंक्शन्स)

| Function | Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| `ROUND()` | `ROUND(num, decimals)` | Diye gaye decimal places tak mathematically round-off karta hai. | `ROUND(15.756, 2)` $\rightarrow$ `15.76` |
| `TRUNCATE()` | `TRUNCATE(num, decimals)`| Bina round kiye decimals ko seedhe kaat (chop) deta hai. | `TRUNCATE(15.756, 2)` $\rightarrow$ `15.75` |
| `FLOOR()` | `FLOOR(num)` | Sabse bada integer jo $\le$ number ho (hamesha niche round karta hai). | `FLOOR(15.9)` $\rightarrow$ `15` |
| `CEIL()` / `CEILING()` | `CEIL(num)` | Sabse chota integer jo $\ge$ number ho (hamesha upar round karta hai). | `CEIL(15.1)` $\rightarrow$ `16` |
| `ABS()` | `ABS(num)` | Absolute magnitude deta hai (negative ko positive bana deta hai). | `ABS(-42)` $\rightarrow$ `42` |
| `MOD()` | `MOD(n, m)` | Modulo division ka remainder/sheshfal ($n \pmod m$). | `MOD(11, 4)` $\rightarrow$ `3` |
| `POWER()` / `POW()` | `POWER(x, y)` | $x$ ki power $y$ calculate karta hai ($x^y$). | `POWER(2, 3)` $\rightarrow$ `8` |

### 3.4. Aggregate Functions & NULL Mechanics (एग्रीगेट फंक्शन्स और NULL का व्यवहार)

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
> **Aggregate NULL Trap (एग्रीगेट में NULL का जाल)**: Sabhi aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) **`NULL` values ko chupchaap ignore kar dete hain**. Akela exception `COUNT(*)` hai, jo physical row records ko count karta hai chahe kisi column mein `NULL` ho ya na ho.

### 3.5. Conditional & Flow Control Functions (कंडीशनल और फ्लो कंट्रोल फंक्शन्स)

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

## 4. Basic Example (बुनियादी उदाहरण)

Scalar transformations, date formatting, aur conditional expressions ka basic upyog:

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

## 5. Real-World Example (वास्तविक दुनिया का उदाहरण)

HR aur Executive Operations committee ne `employees` table se ek Workforce Compensation Report generate karne ki demand ki hai:
1. `first_name` aur `last_name` ko combine karke `full_name` banayein.
2. Missing `phone` numbers ko clean karke `'Contact via HR'` show karein.
3. `TIMESTAMPDIFF()` se employee ka total experience/tenure poore saalon mein nikalen.
4. 5% cost-of-living increase ke sath adjusted salary calculate karein aur nearest integer tak round karein.
5. `CASE` expression ka use karke har employee ko compensation tier mein categorize karein.

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

## 6. Step-by-Step Explanation (कदम-दर-कदम व्याख्या)

1. `CONCAT(first_name, ' ', last_name)`:
   * Do string columns ko beech mein ek single space ke sath merge kar deta hai.
2. `COALESCE(phone, 'Contact via HR')`:
   * `phone` column evaluate hota hai. Agar phone mein valid string hai (jaise `'555-0100'`), toh wahi aati hai. Agar value `NULL` hoti hai, toh fallback string `'Contact via HR'` assign ho jaati hai.
3. `TIMESTAMPDIFF(YEAR, hire_date, CURDATE())`:
   * `hire_date` aur aaj ki date ke beech gujare hue poore calendar saalon ki sankhya nikalta hai, jo leap years ko bhi seamlessly handle karta hai.
4. `ROUND(salary * 1.05, 0)`:
   * Salary ko 1.05 (5% hike) se multiply karta hai aur `, 0` specify karke nearest integer tak round kar deta hai.
5. `CASE WHEN ... THEN ... END`:
   * Conditions ko top-to-bottom sequentially check karta hai. Pehli condition jo `TRUE` hoti hai, uska corresponding string label assign karke expression turant `END` par jump kar jata hai.

---

## 7. Expected Result (अपेक्षित परिणाम)

Workforce Compensation Report ka output:

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

## 8. Common Mistakes (आम गलतियाँ)

1. **`CONCAT()` with `NULL` Producing `NULL` (`CONCAT` में NULL से पूरा स्ट्रिंग गायब होना)**:
   * *The Problem*: `SELECT CONCAT(first_name, ' - ', phone) FROM customers;`
   * *Failure*: Agar `phone` `NULL` hai, toh `CONCAT()` **poore string ko `NULL` bana deta hai**!
   * *Remedy*: Hamesha `CONCAT_WS()` use karein (jo NULLs ko skip karta hai) ya phir column ko `COALESCE` mein wrap karein:
     ```sql
     SELECT CONCAT(first_name, ' - ', COALESCE(phone, 'No Phone')) FROM customers;
     ```
2. **Confusing `LENGTH()` with `CHAR_LENGTH()` (बाइट्स बनाम करैक्टर की लंबाई)**:
   * *Mistake*: User ke text ke characters ginne ke liye `LENGTH()` ka use karna.
   * *Problem*: `utf8mb4` encoding mein Hindi akshar, accented letters jaise `'é'`, ya emojis 2 se 4 bytes lete hain. `LENGTH('Café')` result deta hai `5`, jabki `CHAR_LENGTH('Café')` sahi result deta hai `4`. Text character count ke liye hamesha `CHAR_LENGTH()` use karein.
3. **`DATEDIFF()` Argument Ordering (`DATEDIFF` के आर्गुमेंट्स का क्रम)**:
   * MySQL mein `DATEDIFF(date1, date2)` ka calculation hota hai `date1 - date2`. Agar aap `DATEDIFF('2023-01-01', '2023-01-10')` pass karenge toh result negative `-9` aayega.
4. **Misinterpreting `AVG()` with Nullable Columns (`AVG` में NULL वैल्यूज की गणना)**:
   * Agar table mein 4 rows hain jinme values `[100, 200, 300, NULL]` hain, toh `AVG(col)` calculate karega: `(100 + 200 + 300) / 3 = 200`. Yeh 4 se divide nahi karega kyunki NULL ignore ho jata hai! Agar business requirement yeh hai ki NULL ko 0 maana jaye, toh aapko explicitly likhna hoga: `AVG(COALESCE(col, 0))`.

---

## 9. Best Practices (सर्वोत्तम प्रथाएं / Best Practices)

1. **Use `COALESCE` Over Vendor-Specific `IFNULL` (`IFNULL` की जगह `COALESCE` चुनें)**:
   * `IFNULL` sirf MySQL mein chalta hai. Jabki `COALESCE` ek standard ANSI SQL feature hai, multiple fallback arguments support karta hai, aur PostgreSQL, Oracle, aur SQL Server sabhi par portable hai.
2. **Never Call Non-Deterministic Functions in Loops or Joins (क्वेरी में `SYSDATE()` से बचें)**:
   * `SYSDATE()` har ek row inspection par dobara real-time clock check karta hai, jisse performance slow ho jati hai aur query cache disable ho jata hai. Hamesha `NOW()` ya `CURRENT_TIMESTAMP` prefer karein, jo statement start hone par ek baar evaluate hokar poori query ke liye constant rehta hai.
3. **Always Include an `ELSE` in `CASE` Expressions (`CASE` में `ELSE` ज़रूर लिखें)**:
   * Agar koi bhi `WHEN` match nahi hota aur `ELSE` clause nahi diya gaya hai, toh SQL automatically `NULL` return karta hai. Kisi anchaahe `NULL` result se bachne ke liye hamesha safe `ELSE` default specify karein.

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. Ek query likhein jo sabhi customer emails ko complete lowercase mein display kare.
2. Ek query likhein jo teen alag columns mein current date, current time, aur current timestamp show kare.
3. Har product ke `unit_price` ko nearest integer tak round karne ke liye query likhein.

### Medium (मध्यम)
4. `DATE_FORMAT` ka prayog karke sabhi `order_date` values ko `'DD/MM/YYYY'` (jaise `'15/08/2023'`) format mein convert karke display karein.
5. Ek query likhein jo `employees` table ke `email` column se domain name (`'@'` ke baad ka poora text) extract kare.
6. Sabhi active employees ka total payroll (`SUM`), average salary, minimum salary, aur maximum salary nikalne ki query likhein.

### Difficult (कठिन)
7. `products` table ke liye ek query likhein jo `CASE` expression ka use karke ek `reorder_urgency` flag calculate kare:
   * `'CRITICAL'` agar `stock_quantity = 0` ho
   * `'HIGH'` agar `stock_quantity <= reorder_level` ho
   * `'MEDIUM'` agar `stock_quantity <= reorder_level * 1.5` ho
   * `'HEALTHY'` baaki sabhi situations ke liye.
8. `order_items` table par `AVG(discount)` aur `SUM(discount) / COUNT(*)` ke result ko compare karein. Explain karein ki in dono ka numerical answer alag kyun aa sakta hai.

---

## 11. Interview Questions (साक्षात्कार प्रश्न)

### Q1: What is the mechanical difference between `COUNT(*)`, `COUNT(column_name)`, and `COUNT(DISTINCT column_name)`?
**Answer**:
* `COUNT(*)` physically scan kiye gaye total rows ko count karta hai, chahe un rows ke kisi ya sabhi columns mein `NULL` hi kyun na ho.
* `COUNT(column_name)` sirf unhi rows ko count karta hai jahan `column_name` ke andar ek non-NULL value maujood hoti hai. Jin rows mein `column_name IS NULL` hota hai, unhe yeh poori tarah drop kar deta hai.
* `COUNT(DISTINCT column_name)` un sabhi unique aur non-NULL values ki sankhya count karta hai jo us column mein payi jaati hain.

### Q2: What is the difference between `COALESCE()` and `IFNULL()` in MySQL?
**Answer**:
1. **Parameters ki sankhya**: `IFNULL(expr1, expr2)` strictly sirf do arguments leta hai—agar `expr1` `NULL` hai toh `expr2` deta hai. Jabki `COALESCE(expr1, expr2, ..., exprN)` kitne bhi arguments le sakta hai aur left-to-right pehla non-NULL value return karta hai.
2. **Portability**: `COALESCE` standard ANSI SQL ka hissa hai aur sabhi enterprise RDBMS (PostgreSQL, SQL Server, Oracle) par chalte hain. `IFNULL` sirf MySQL ka proprietary syntax hai.

### Q3: How do `NOW()` and `SYSDATE()` differ in MySQL?
**Answer**: `NOW()` query statement ke shuru hone ka exact timestamp return karta hai aur poori query execution ke dauran ek constant value ki tarah rehta hai. Iske viprit, `SYSDATE()` har us moment par real clock time read karta hai jab woh row ya function call execute ho raha hota hai. Agar query 5 second leti hai, toh pehli row aur aakhiri row par `SYSDATE()` ka timestamp alag-alag aayega. Is wajah se optimizer ise optimize nahi kar pata aur non-deterministic behavior create ho jata hai.

---

## 12. Quick Revision (त्वरित सारांश)

* **Scalar functions** single row values transform karte hain; **Aggregate functions** multiple rows ko consolidate karke summary stats dete hain.
* Strings jodte samay **`CONCAT_WS()`** ya **`COALESCE()`** use karein taaki ek single `NULL` poore text ko `NULL` na bana de.
* **`CHAR_LENGTH()`** characters (akshar) ginta hai; **`LENGTH()`** storage bytes napta hai.
* Sabhi aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) **NULLs ko ignore karte hain**; sirf `COUNT(*)` har row count karta hai.
* Multi-branch conditional classification ke liye hamesha standard **`CASE WHEN ... THEN ... ELSE ... END`** syntax ka use karein.
* Saalon, mahino ya dino ka calendar-accurate difference nikalne ke liye **`TIMESTAMPDIFF()`** use karein.
