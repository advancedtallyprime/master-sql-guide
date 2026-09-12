# Chapter 06 — Data Querying & Filtering: SELECT & WHERE (Data Querying aur Filtering: SELECT aur WHERE)

---

## 1. What is it? (Ye Kya Hai?)

**Data Query Language (DQL)** users aur applications ko database tables me store kiye gaye records ko retrieve (read) karne ki capability deta hai. SQL me kisi bhi data querying ki shuruat hamesha **`SELECT`** statement ke sath hoti hai.

Simple words me kahein, to ek basic query table se rows aur columns ko project (fetch) karti hai. Lekin real-world production databases me jahan millions of records hote hain, poori table ko bina kisi filter ke return karna practically impossible aur inefficient hota hai. Yahan kaam aata hai **`WHERE`** clause: ye har candidate row ke upar ek conditional boolean predicate evaluate karta hai, aur client ko sirf wahi specific rows return karta hai jinke liye condition strictly **`TRUE`** evaluate hoti hai.

SQL me boolean logic standard binary (`TRUE`/`FALSE`) nahi hota, balki **Three-Valued Logic (3VL)** par kaam karta hai. SQL me kisi bhi condition ke teen possible outcomes ho sakte hain:
* `TRUE`: Row condition ko satisfy karti hai aur output result set me include hogi.
* `FALSE`: Row condition fail kar deti hai aur filter out ho jaati hai.
* `UNKNOWN` (`NULL`): Jab missing ya unknown data ke sath comparison hota hai, to SQL `UNKNOWN` return karta hai. Kyunki `WHERE` clause sirf aur sirf strictly `TRUE` rows ko admit karta hai, isliye `UNKNOWN` result aane par row ko instantly exclude kar diya jata hai!

SQL me primary filtering constructs ye hain:
1. **Relational Comparison Operators**: `=`, `!=` (ya `<>`), `<`, `>`, `<=`, `>=`.
2. **Range Filtering (`BETWEEN ... AND ...`)**: Check karta hai ki kya koi value ek inclusive continuous range $[A, B]$ ke beech exist karti hai.
3. **Discrete Set Membership (`IN (...)` aur `NOT IN (...)`)**: Verify karta hai ki value kisi comma-separated list ya subquery result set ka part hai ya nahi.
4. **Pattern Matching (`LIKE` aur `NOT LIKE`)**: Wildcards (`%` aur `_`) ka use karke text patterns search karta hai.
5. **Three-Valued Nullability Checks (`IS NULL` aur `IS NOT NULL`)**: Check karta hai ki kisi column me actual value missing (NULL) hai ya present hai.

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Bandwidth & Latency Minimization (Superfast Response Time)**: Network connection par 10,000,000 unneeded rows transfer karne ke bajaye sirf 10 relevant rows transfer karne se query response latency minutes se ghat kar milliseconds par aa jaati hai.
2. **Targeted Business Analytics (Pinpoint Insights)**: Business operations ko precise data chahiye hota hai: jaise pichhle 7 dino me ship hue orders dhoondhna, Mumbai ke active customers ko filter karna, ya un products ko nikalna jinka stock safety level se kam ho gaya hai.
3. **Database Index Acceleration (B+ Tree Seeks)**: Jab aapka `WHERE` clause kisi indexed column ko target karta hai (jaise `WHERE customer_id = 4`), to database engine poori table scan karne ke bajaye directly B+ Tree index seek ke through target record par jump kar jata hai.

---

## 3. Syntax

```sql
SELECT [DISTINCT] column1, column2, ...
FROM table_name
WHERE boolean_predicate;
```

### Filtering Predicate Forms
```sql
-- 1. Equality & Inequality
WHERE status = 'Delivered';
WHERE status != 'Cancelled';   -- Equivalent to: status <> 'Cancelled'

-- 2. Numeric Comparisons
WHERE salary >= 100000.00;
WHERE stock_quantity < reorder_level;

-- 3. Continuous Range (Inclusive: >= min AND <= max)
WHERE order_date BETWEEN '2023-08-01' AND '2023-08-31';

-- 4. Discrete List Membership
WHERE country IN ('USA', 'Germany', 'Japan');
WHERE category_id NOT IN (1, 4);

-- 5. Pattern Matching Wildcards
WHERE email LIKE '%@gmail.com';     -- Ends with @gmail.com (% matches 0 or more characters)
WHERE phone LIKE '555-01__';        -- Matches 555-01 followed by exactly 2 characters (_ matches 1 char)

-- 6. Three-Valued Logic NULL Checks (NEVER use: WHERE col = NULL)
WHERE phone IS NULL;
WHERE phone IS NOT NULL;
```

---

## 4. Basic Example

Aaiye ek single table se distinct values retrieve karne aur alag-alag filters apply karne ka basic example dekhte hain:

```sql
USE sql_mastery;

-- Retrieve distinct countries where our customers reside
SELECT DISTINCT country 
FROM customers;

-- Find products priced between $200 and $600
SELECT product_name, unit_price, stock_quantity
FROM products
WHERE unit_price BETWEEN 200.00 AND 600.00;

-- Find customers without a recorded phone number
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE phone IS NULL;
```

---

## 5. Real-World Example

Hamare production `sql_mastery` database me, operations team ko ek critical inventory analysis chahiye: Category 1 (`Electronics`) ya 2 (`Home Appliances`) ke aise sabhi active products identify karo jinka unit price kam se kam $300 ho aur jinki current stock quantity safety reorder level tak ya usse niche gir chuki ho.

```sql
USE sql_mastery;

-- Complex multi-predicate real-world inventory check
SELECT 
    product_id,
    product_name,
    category_id,
    unit_price,
    stock_quantity,
    reorder_level,
    (reorder_level - stock_quantity) AS units_to_order
FROM products
WHERE is_active = TRUE
  AND category_id IN (1, 2)
  AND unit_price >= 300.00
  AND stock_quantity <= reorder_level;
```

---

## 6. Step-by-Step Explanation

Aaiye dekhein ki database engine is complex filtering query ko internally kaise execute karta hai:

1. **`FROM products`**: Sabse pehle storage engine `products` table ko open karke access establish karta hai.
2. **`WHERE` Clause Evaluation (Row-by-Row Filtering)**:
   * `is_active = TRUE`: Jo products discontinue ho chuke hain unhe filter out kar deta hai.
   * `category_id IN (1, 2)`: Check karta hai ki kya item Electronics (1) ya Home Appliances (2) category me aata hai.
   * `unit_price >= 300.00`: Chhote-mote accessories ko discard karke sirf high-value items ko isolate karta hai.
   * `stock_quantity <= reorder_level`: Ek hi row ke do alag-alag columns ko dynamically compare karta hai. Row tabhi select hogi jab available inventory reorder point tak ya usse kam ho chuki ho.
3. **Logical Intersection (`AND`)**: Ye chaaro predicates simultaneously `TRUE` evaluate hone compulsory hain. Agar ek bhi condition `FALSE` ya `UNKNOWN` hui, to row drop ho jayegi.
4. **`SELECT` Projection**: Survive karne wali rows ke liye MySQL on-the-fly calculated column `(reorder_level - stock_quantity)` compute karta hai aur use `units_to_order` ka alias dekar requested columns ke sath client ko return kar deta hai.

---

## 7. Expected Result

Inventory filtering query ka output:

```
+------------+-------------------------------+-------------+------------+----------------+---------------+----------------+
| product_id | product_name                  | category_id | unit_price | stock_quantity | reorder_level | units_to_order |
+------------+-------------------------------+-------------+------------+----------------+---------------+----------------+
|          4 | UltraVision 4K 27in Monitor   |           1 |     389.00 |             10 |            10 |              0 |
+------------+-------------------------------+-------------+------------+----------------+---------------+----------------+
1 row in set (0.00 sec)
```
*(Notice kijiye ki sirf Monitor match hua: iska price $389.00 jo ki $\ge 300$ hai, category 1 hai, aur stock 10 reorder level 10 ke $\le$ hai).*

---

## 8. Common Mistakes

1. **`WHERE column = NULL` Likhna**:
   * *Mistake*: `SELECT * FROM customers WHERE phone = NULL;`
   * *Problem*: Hamesha **Empty set (0 rows)** return karega, chahe table me hazaron customers ke phone numbers NULL kyun na hon!
   * *Why?*: ANSI SQL me `NULL` ka matlab hota hai unknown. Kisi bhi value ko unknown se compare karne par result hamesha `UNKNOWN` aata hai. Aur kyunki `WHERE` clause sirf `TRUE` results ko accept karta hai, isliye condition hamesha fail ho jaati hai.
   * *Correction*: Hamesha `WHERE phone IS NULL` ya `WHERE phone IS NOT NULL` use karein.
2. **`BETWEEN` Ke Boundaries Ko Galat Samajhna**:
   * *Mistake*: Ye maan lena ki `BETWEEN 10 AND 20` sirf 11 se 19 tak include karega.
   * *Reality*: SQL me `BETWEEN` hamesha **strictly inclusive** hota hai. Ye mathematically `col >= 10 AND col <= 20` ke barabar hota hai (10 aur 20 dono output me shamil hote hain).
3. **`NOT IN` Ke Sath `NULL` Ka Dangerous Trap**:
   * *The Classic Trap*:
     ```sql
     SELECT * FROM customers WHERE customer_id NOT IN (1, 2, NULL);
     ```
   * *Catastrophic Result*: **Poori query 0 rows return karegi!**
   * *Why?*: `x NOT IN (1, 2, NULL)` internally expand hokar banta hai: `x != 1 AND x != 2 AND x != NULL`. Kyunki `x != NULL` ka result `UNKNOWN` hota hai, to poori composite `AND` condition ka final result `UNKNOWN` (ya `FALSE`) ban jata hai. Is wajah se har ek row discard ho jaati hai.
   * *Rule*: Hamesha ensure karein ki `NOT IN` ke andar aane wali subquery ya list me kabhi `NULL` na ho, ya iski jagah `NOT EXISTS` ka use karein.
4. **`LIKE` Me Leading Wildcards (`'%term'`) Lagana**:
   * *Problem*: `WHERE email LIKE '%@company.com'` likhne se MySQL index tree ke root se traverse nahi kar pata, jiski wajah se B+ Tree index completely bypass ho jata hai aur slow full table scan execute hota hai.

---

## 9. Best Practices

1. **Sirf Zaroori Columns Hi Project Karein**:
   * Production applications me `SELECT *` kabhi mat chalayein. Explicit column names specify karne se unnecessary `TEXT` ya `BLOB` fields read nahi hote, network bandwidth bachti hai, aur queries covering indexes ke through satisfy ho sakti hain.
2. **Filter Predicates Ko Hamesha SARGable Rakhein (Search Argument Able)**:
   * Indexed columns ko kabhi bhi functions ke andar wrap mat kijiye:
     * *Non-SARGable (Index use nahi ho sakta)*:
       ```sql
       WHERE YEAR(order_date) = 2023;
       ```
     * *SARGable (Direct B+ Tree index seek)*:
       ```sql
       WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
       ```
3. **`DISTINCT` Ko Samajhkar Use Karein**:
   * Galat join conditions ki wajah se aane wale duplicate rows ko hide karne ke liye `DISTINCT` ko short-cut ki tarah mat lagaiye. `DISTINCT` remove karne ke liye database engine ko memory me poore result set ko sort ya hash karna padta hai, jo heavy performance degradation create karta hai.

---

## 10. Practice Questions

### Easy
1. Aise sabhi products ke `product_name` aur `unit_price` select karne ke liye query likhiye jinka `unit_price` $500.00 se zyada ho.
2. `'2021-01-01'` ko ya uske baad hire hue sabhi employees ko find karne ke liye query likhiye.
3. Aise sabhi orders find karne ke liye query likhiye jinka status `'Delivered'` hai.

### Medium
4. Aise sabhi customers find karne ke liye query likhiye jinka `email` address `'@gmail.com'` par end hota hai.
5. Aise sabhi products retrieve karne ke liye query likhiye jinki `stock_quantity` 20 aur 60 ke beech (inclusive) ho, lekin jinki `category_id` 1 ke barabar NA ho.
6. August 2023 ke month (`2023-08-01` se `2023-08-31`) me place kiye gaye aise sabhi orders find kijiye jinka `shipping_fee` $0.00 se zyada ho.

### Difficult
7. Aise sabhi customers find karne ke liye query likhiye jinka `state` recorded hai (yani `state IS NOT NULL`), jinka `first_name` 'S' ya 'E' se start hota ho aur jinki name length kam se kam 5 characters ho.
8. Is query ke exact boolean results predict kijiye: `SELECT (5 = NULL), (NULL = NULL), (NULL IS NULL), (5 > NULL);`. Query run karne se pehle har ek column ki predicted value explain kijiye.

---

## 11. Interview Questions

### Q1: `SELECT * FROM table WHERE column = NULL;` NULL values wali rows ko kyun return nahi karta?
**Answer**: SQL me standard boolean logic ke bajaye Three-Valued Logic (3VL) use hota hai jisme teen states hoti hain: `TRUE`, `FALSE`, aur `UNKNOWN`. `NULL` ka matlab hota hai missing ya unknown value. Jab equality operator kisi value ko `NULL` se compare karta hai (even `NULL = NULL`), to engine ye decide nahi kar sakta ki do unknown cheezein barabar hain ya nahi, isliye result hamesha `UNKNOWN` aata hai. Aur kyunki `WHERE` clause sirf aur sirf strictly `TRUE` rows ko admit karta hai, isliye row filter out ho jaati hai. Missing values ko match karne ke liye SQL ne special unary operator **`IS NULL`** provide kiya hai.

### Q2: SARGable query kya hoti hai, aur `WHERE LOWER(email) = 'user@example.com'` likhne se performance kyun drop hoti hai?
**Answer**: SARGable ka full form hota hai *Search Argument Able*. Ek query predicate tab SARGable kehlata hai jab database engine ka query optimizer table ke B+ Tree index seek ka use karke directly matching keys par navigate kar sake bina saare data pages ko scan kiye. Jab aap indexed column ko kisi function ke andar wrap kar dete hain (jaise `LOWER(email)`), to engine ko pehle runtime par har ek row ki value par function evaluate karna padta hai. Is transformation ki wajah se index ka sorted order render ho jata hai aur engine index seek nahi kar pata, majbooran poori table scan (full table scan) karni padti hai.

### Q3: `NOT IN` ke sath aisi subquery use karne me kya risk hai jo ek `NULL` value return kar sakti ho?
**Answer**: Expression `column NOT IN (val1, val2, NULL)` logically expand hokar banta hai:
`column != val1 AND column != val2 AND column != NULL`.
Kyunki kisi bhi value ka `NULL` ke sath comparison `UNKNOWN` deta hai, isliye ek single `NULL` aate hi poori `AND` chain ka result `UNKNOWN` ban jata hai. Result ye hota hai ki `WHERE` clause har candidate row ko reject kar deta hai aur poori query silently 0 rows return karti hai. Ye production applications me ek bohot hi silent aur critical bug create karta hai. Iska solution ye hai ki subquery me `WHERE col IS NOT NULL` filter lagaya jaye ya phir `NOT EXISTS` clause ka use kiya jaye.

---

## 12. Quick Revision

* **`SELECT`** columns ki projection ko control karta hai; **`WHERE`** rows ki filtering ko control karta hai.
* SQL me **Three-Valued Logic** chalta hai: `TRUE`, `FALSE`, aur `UNKNOWN`.
* Kabhi bhi `= NULL` mat likhiye; missing values check karne ke liye hamesha **`IS NULL`** ya **`IS NOT NULL`** use karein.
* **`BETWEEN`** hamesha inclusive hota hai (upper aur lower dono limits included rehti hain).
* **`LIKE`** pattern matching do wildcards support karta hai: `%` (zero ya more characters) aur `_` (exactly ek character).
* Queries ko hamesha **SARGable** rakhein: `WHERE` clause me indexed columns ko functions ke andar wrap karne se bachein.
