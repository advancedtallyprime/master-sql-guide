# Chapter 32 — High-Yield Rapid Revision Guide & Knowledge Checkpoints

Core SQL aur MySQL domains ke across modular checkpoints mein organized ek rapid-review study guide. Is chapter ka use last-minute interview preparation, pre-exam review, ya quick refresher checks ke liye karein.

---

## Checkpoint 1: Database & Table Management (DDL)

### What You Should Know
* DDL commands (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`) schema structures ko manage karte hain aur MySQL mein **implicit transaction commits** trigger karte hain.
* `TRUNCATE` table pages ko deallocate karta hai aur auto-increment sequences reset karta hai; `DELETE` rows ko one-by-one remove karta hai; `DROP` poore table schema aur files ko permanently destroy karta hai.
* Full multi-byte Unicode aur emojis support karne ke liye hamesha `utf8mb4` encoding ke saath databases declare karein.

### What You Should Be Able to Write
```sql
CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(100) NOT NULL UNIQUE);
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;
ALTER TABLE users MODIFY COLUMN phone VARCHAR(30) NOT NULL;
ALTER TABLE users CHANGE COLUMN phone contact_phone VARCHAR(30) NOT NULL;
DROP TABLE IF EXISTS users;
```

### Common Failure Traps
* **Trap**: Kisi transaction block ke andar `DROP TABLE` ya `TRUNCATE` ko rollback karne ki koshish karna (`ROLLBACK` ka DDL par koi effect nahi hota).
* **Trap**: `MODIFY` (jo column name preserve karta hai) aur `CHANGE` (jisme old aur new dono column names dene padte hain) ke beech confuse hona.

### 5-Question Checkpoint Quiz
1. *Jab table TRUNCATE hoti hai vs jab saari rows DELETE hoti hain, tab AUTO_INCREMENT counter ka kya hota hai?* $\rightarrow$ Truncate ise 1 par reset karta hai; Delete current counter ko preserve rakhta hai.
2. *Kya ek table mein multiple primary keys ho sakti hain?* $\rightarrow$ Nahi, sirf ek primary key (halanki wo composite ho sakti hai).
3. *MySQL mein `utf8` ke muqable `utf8mb4` kyun preferred hai?* $\rightarrow$ MySQL ka legacy `utf8` sirf 3-byte characters support karta hai, jo emojis aur 4-byte Unicode characters par fail ho jaata hai.
4. *Aap table ke bilkul start mein column kaise add karte hain?* $\rightarrow$ `FIRST` keyword ka use karke: `ALTER TABLE t ADD COLUMN col INT FIRST;`.
5. *Agar aap kisi aisi parent table ko drop karne ki koshish karein jise active foreign key reference kar rahi ho toh kaun sa error aata hai?* $\rightarrow$ Error 3730: Cannot drop table referenced by a foreign key constraint.

### Practical Challenge
Ek idempotent DDL script likhein jo safely ek `order_archive` table create kare, ek indexed `archived_at` timestamp add kare, aur agar koi deprecated `notes` column exist karta ho toh use drop kare.

---

## Checkpoint 2: Data Types & Integrity Constraints

### What You Should Know
* Money/currency ke liye hamesha `DECIMAL(M, D)` use karein; IEEE 754 rounding drift ki wajah se kabhi `FLOAT` ya `DOUBLE` use na karein.
* InnoDB mein `PRIMARY KEY` physically **clustered index** define karti hai; wide, random UUID strings ke muqable compact integer keys (`INT UNSIGNED`) strongly preferred hain.
* MySQL mein `UNIQUE` constraints multiple `NULL` values allow karte hain jab tak unhe explicitly `NOT NULL` na declare kiya gaya ho.
* MySQL 8.0.16+ mein `CHECK` constraints fully enforced hote hain.

### What You Should Be Able to Write
```sql
CREATE TABLE accounts (
    account_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_number CHAR(10) NOT NULL UNIQUE,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_positive_balance CHECK (balance >= 0.00)
);
```

### Common Failure Traps
* **Trap**: Country codes jaise fixed-length strings ke liye `VARCHAR` use karna (`CHAR(2)` zyada efficient hota hai).
* **Trap**: January 19, 2038 se aage ki dates ke liye 32-bit `TIMESTAMP` par rely karna (iski jagah `DATETIME` use karein).

### 5-Question Checkpoint Quiz
1. *Precise monetary amounts store karne ke liye kaun sa data type use karna chahiye?* $\rightarrow$ `DECIMAL(M, D)` ya `NUMERIC(M, D)`.
2. *Kya UNIQUE marked column NULL values allow karta hai?* $\rightarrow$ Haan, multiple NULLs permit hote hain jab tak `NOT NULL` specify na kiya gaya ho.
3. *`ON DELETE CASCADE` aur `ON DELETE RESTRICT` ke beech kya difference hai?* $\rightarrow$ Cascade child rows ko automatically delete kar deta hai; Restrict parent row deletion ko block karta hai agar child rows exist karti hon.
4. *MySQL mein boolean ke corresponding kaun sa type hota hai?* $\rightarrow$ `TINYINT(1)`.
5. *Primary Keys ko `UNSIGNED` kyun mark karna chahiye?* $\rightarrow$ Primary key counters mein kabhi negative numbers nahi hote, aur `UNSIGNED` extra storage bytes consume kiye bina positive addressable range ko double kar deta hai.

### Practical Challenge
`accounts` ko reference karne wali foreign keys ke saath ek `transactions` table construct karein, named `CHECK` constraint ke through ensure karein ki `amount > 0` ho, aur `(account_id, transaction_ref)` par composite unique constraint laga kar duplicate transactions prevent karein.

---

## Checkpoint 3: Filtering, Sorting & Functions

### What You Should Know
* SQL **Three-Valued Logic (3VL)** use karta hai: `TRUE`, `FALSE`, `UNKNOWN`. `NULL` ke saath kisi bhi comparison se `UNKNOWN` milta hai, jise `WHERE` filter out kar deta hai. Hamesha `IS NULL` use karein.
* `AND` ki precedence `OR` se higher hoti hai; logical expressions ko group karne ke liye hamesha parentheses use karein.
* `BETWEEN val1 AND val2` dono boundary values ke liye inclusive hota hai.
* MySQL mein `NULL` lowest possible value sort hota hai (`ASC` mein first, `DESC` mein last).
* Saare aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) `NULL`s ko ignore karte hain; sirf `COUNT(*)` physical rows count karta hai.

### What You Should Be Able to Write
```sql
SELECT 
    CONCAT_WS(', ', last_name, first_name) AS full_name,
    COALESCE(phone, 'No Phone') AS contact_phone,
    ROUND(salary * 1.10, 2) AS projected_salary,
    DATE_FORMAT(hire_date, '%Y-%m-%d') AS formatted_hire_date
FROM employees
WHERE (department_id = 1 OR department_id = 2)
  AND salary >= 90000.00
  AND hire_date BETWEEN '2020-01-01' AND '2023-12-31'
ORDER BY salary DESC, last_name ASC
LIMIT 10 OFFSET 0;
```

### Common Failure Traps
* **Trap**: `WHERE email = NULL` likhna (ye empty set return karta hai; hamesha `WHERE email IS NULL` likhna chahiye).
* **Trap**: `WHERE col NOT IN (1, 2, NULL)` likhna (empty set return karta hai kyunki NULL ke against comparison UNKNOWN produce karta hai).
* **Trap**: `WHERE` clause mein indexed columns ko functions mein wrap karna (e.g., `WHERE YEAR(date_col) = 2023` SARGability break karta hai aur full table scan force karta hai).

### 5-Question Checkpoint Quiz
1. *`SELECT (NULL = NULL)` kya evaluate karta hai?* $\rightarrow$ `NULL` (UNKNOWN).
2. *MySQL mein NULL-Safe equality check kaise likhte hain?* $\rightarrow$ `<=>` ka use karke (e.g., `NULL <=> NULL` returns 1/TRUE).
3. *`LENGTH()` aur `CHAR_LENGTH()` ke beech kya difference hai?* $\rightarrow$ `LENGTH()` bytes count karta hai; `CHAR_LENGTH()` UTF-8 characters count karta hai.
4. *Agar `CONCAT()` ka koi ek argument `NULL` ho toh ye kaise behave karta hai?* $\rightarrow$ Ye poori string ke liye `NULL` return karta hai.
5. *MySQL mein ascending sort mein NULL values ko last mein kaise appear karwayein?* $\rightarrow$ `ORDER BY col IS NULL ASC, col ASC`.

### Practical Challenge
`customers` ke against ek aisi query likhein jo un sabhi customers ko select kare jinka last name kisi vowel se start hota ho, unki registration date ko `'Month Day, Year'` mein format kare, aur `CASE` statement ka use karke unka customer tier compute kare.

---

## Checkpoint 4: Grouping, Aggregation & Relational Joins

### What You Should Know
* Logical execution order: `FROM` $\rightarrow$ `WHERE` $\rightarrow$ `GROUP BY` $\rightarrow$ `HAVING` $\rightarrow$ `SELECT` $\rightarrow$ `DISTINCT` $\rightarrow$ `ORDER BY` $\rightarrow$ `LIMIT`.
* `WHERE` grouping se *pehle* rows filter karta hai; `HAVING` grouping ke *baad* aggregated buckets filter karta hai.
* `ONLY_FULL_GROUP_BY` ke under har projected column ya toh `GROUP BY` clause mein appear hona chahiye ya aggregate function ke andar wrapped hona chahiye.
* `INNER JOIN` matching rows return karta hai; `LEFT JOIN` left-table ki saari rows preserve karta hai; Anti-Join (`LEFT JOIN ... WHERE right.key IS NULL`) missing links find karta hai.
* Hierarchies model karne ke liye `Self JOIN` table ko apne hi saath do distinct aliases ka use karke join karta hai.

### What You Should Be Able to Write
```sql
-- Aggregation with HAVING
SELECT department_id, COUNT(*) AS headcount, ROUND(AVG(salary), 2) AS avg_sal
FROM employees
WHERE is_active = TRUE
GROUP BY department_id
HAVING COUNT(*) >= 2 AND AVG(salary) > 80000;

-- Multi-table Join with Anti-Join
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

### Common Failure Traps
* **Trap**: `WHERE` clause ke andar aggregate functions place karna (`WHERE AVG(salary) > 50000` invalid syntax hai).
* **Trap**: `LEFT JOIN` ke right table filter ko `WHERE` clause mein place karna (ye silently `LEFT JOIN` ko `INNER JOIN` mein convert kar deta hai).
* **Trap**: Join conditions omit karna, jisse Cartesian product (`CROSS JOIN`) produce ho jaata hai.

### 5-Question Checkpoint Quiz
1. *WHERE clause ke andar aggregate functions kyun nahi use kiye ja sakte?* $\rightarrow$ Kyunki `WHERE` groups aur aggregates form hone se pehle execute hota hai.
2. *`UNION` aur `UNION ALL` ke beech kya difference hai?* $\rightarrow$ `UNION` rows ko deduplicate karta hai (sorting involve hoti hai); `UNION ALL` saari rows directly preserve karta hai.
3. *`GROUP_CONCAT()` kya karta hai?* $\rightarrow$ Har group ki non-null values ko concatenate karke ek single string banata hai.
4. *Self JOIN kaise kaam karta hai?* $\rightarrow$ Table ko do distinct aliases ke through apne aap se join karke.
5. *MySQL mein FULL OUTER JOIN ko kaun sa pattern emulate karta hai?* $\rightarrow$ `LEFT JOIN` aur `RIGHT JOIN` ko `UNION` ke saath combine karna.

### Practical Challenge
Har product category dwara generate hua total revenue calculate karne wali query likhein, jisme category name, total quantity sold, gross revenue, aur average discount applied display ho. Sirf un categories ko include karne ke liye filter karein jinhone $1,000 se zyada gross revenue generate kiya ho.

---

## Checkpoint 5: Subqueries, Window Functions & CTEs

### What You Should Know
* Subqueries scalar values (1x1), values ke columns, ya derived tables (jinka alias zaroori hai) return karti hain.
* Correlated subqueries outer query ke columns reference karti hain aur outer row ke mutabiq evaluate hoti hain.
* `EXISTS` subquery `IN` se faster aur safer hoti hai kyunki ye first match par short-circuit ho jaati hai aur NULLs ko safely handle karti hai.
* Window functions related rows ke across **bina rows ko collapse kiye** calculations perform karti hain.
* `OVER()` clause partitions (`PARTITION BY`), ordering (`ORDER BY`), aur frames (`ROWS BETWEEN ...`) define karta hai.
* CTEs (`WITH ...`) complex queries ko modular banati hain aur recursion (`WITH RECURSIVE`) support karti hain.

### What You Should Be Able to Write
```sql
-- CTE with Window Functions
WITH RankedOrders AS (
    SELECT 
        customer_id,
        order_id,
        order_date,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS recency_rank,
        SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_spend
    FROM orders
)
SELECT * FROM RankedOrders WHERE recency_rank = 1;
```

### Common Failure Traps
* **Trap**: `FROM` clause mein derived table ko alias karna bhool jaana (`ERROR 1248: Every derived table must have its own alias`).
* **Trap**: Window function ko directly `WHERE` clause ke andar use karne ki koshish karna (ise pehle CTE ya subquery mein wrap karna padta hai).
* **Trap**: `RANK()` (jo ties par numbers skip karta hai) aur `DENSE_RANK()` (jo ties par koi gaps nahi chhodta) ke beech confuse hona.

### 5-Question Checkpoint Quiz
1. *`ROW_NUMBER()` aur `DENSE_RANK()` ke beech kya difference hai?* $\rightarrow$ `ROW_NUMBER()` kabhi ties produce nahi karta ($1, 2, 3$); `DENSE_RANK()` ties ko same rank deta hai bina numbers skip kiye ($1, 2, 2, 3$).
2. *`LAG(col, 1)` kya karta hai?* $\rightarrow$ Turant preceding row se `col` ki value access karta hai.
3. *Recursive CTE mein kaun se do parts required hote hain?* $\rightarrow$ Anchor Member aur Recursive Member, jo `UNION ALL` se combine hote hain.
4. *Kya multiple rows return karne wali subquery ko `=` operator ke saath use kiya ja sakta hai?* $\rightarrow$ Nahi, ye `ERROR 1242: Subquery returns more than 1 row` trigger karta hai. `IN` ya `ANY` use karein.
5. *MySQL JSON column se unquoted string kaun sa operator extract karta hai?* $\rightarrow$ `->>` operator.

### Practical Challenge
Pure SQL mein Fibonacci sequence ke pehle 10 numbers generate karne wali ek Recursive CTE likhein.

---

## Checkpoint 6: Transactions, Concurrency & Locking

### What You Should Know
* ACID guarantees: **Atomicity** (Undo log), **Consistency** (schema invariants), **Isolation** (MVCC & locks), **Durability** (Redo log / WAL).
* MySQL ka default isolation level **`REPEATABLE READ`** hai, jo Dirty, Non-Repeatable, aur Phantom reads prevent karta hai.
* `SELECT ... FOR UPDATE` Exclusive Lock (X-lock) acquire karta hai, jo doosre transactions ko un rows ko modify ya lock karne se block karta hai.
* InnoDB Deadlocks ko automatically detect karta hai, sabse kam rollback cost wale transaction ko abort karta hai (Error 1213), aur rollback kar deta hai.

### What You Should Be Able to Write
```sql
START TRANSACTION;

SELECT stock_quantity FROM products WHERE product_id = 1 FOR UPDATE;

UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
INSERT INTO orders (customer_id, order_date, total_amount) VALUES (1, CURDATE(), 1299.99);

COMMIT;
```

### Common Failure Traps
* **Trap**: External third-party HTTP API responses ka wait karte waqt database transactions ko open hold karke rakhna (heavy lock wait timeouts cause karta hai).
* **Trap**: Transaction ke andar DDL statement (`ALTER TABLE`) run karna, jo implicit commit trigger karke atomicity break kar deta hai.

### 5-Question Checkpoint Quiz
1. *Dirty Read kya hota hai, aur kaun sa isolation level ise allow karta hai?* $\rightarrow$ Kisi doosre transaction ka uncommitted data read karna jo baad mein rollback ho jaye; ye sirf `READ UNCOMMITTED` mein permit hota hai.
2. *System crashes ke dauran kaun sa InnoDB log Durability guarantee karta hai?* $\rightarrow$ Redo Log.
3. *Rollback ke dauran kaun sa InnoDB log Atomicity guarantee karta hai?* $\rightarrow$ Undo Log.
4. *`SELECT ... FOR UPDATE` ke through acquire kiya gaya exclusive row lock kaise release hota hai?* $\rightarrow$ `COMMIT` ya `ROLLBACK` issue karke.
5. *MySQL deadlocks ko kaise handle karta hai?* $\rightarrow$ Deadlock detector Error 1213 ke saath sabse chhoti rollback cost wale transaction ko abort aur rollback kar deta hai.

### Practical Challenge
Do bank accounts ke beech concurrent balance transfer ko stored transaction mein wrap karke simulate karein, jisme savepoints aur error rollback handlers included hon.

---

## Checkpoint 7: Query Optimization & Security

### What You Should Know
* Execution plans inspect karne ke liye `EXPLAIN` aur `EXPLAIN ANALYZE` use karein. Badi tables par access type `ALL` (full table scans) eliminate karein.
* Ek **Covering Index** query ke saare requested columns contain karta hai, jisse query directly secondary index leaf nodes se satisfy ho jaati hai (`Extra: Using index`).
* **Leftmost Prefix Rule**: `(A, B, C)` par bana index tabhi use ho sakta hai agar query pehle `A` par filter kare.
* SQL Injection ke defense ke liye hamesha **Prepared Statements (Parameterized Queries)** use karein.
* **Principle of Least Privilege (PoLP)** adhere karein; permissions management ke liye MySQL 8.0 Roles ka use karein.
* Dedicated database instances par `innodb_buffer_pool_size` ko **physical RAM ka 70%–80%** size karein.

### What You Should Be Able to Write
```sql
-- SARGable Index Query
EXPLAIN ANALYZE
SELECT customer_id, order_date, total_amount
FROM orders
WHERE order_date >= '2023-08-01' AND order_date < '2023-09-01';

-- Role-Based Access Control
CREATE ROLE 'role_app_writer';
GRANT SELECT, INSERT, UPDATE ON sql_mastery.orders TO 'role_app_writer';
CREATE USER 'app_svc'@'10.0.1.%' IDENTIFIED BY 'Vault_Secret_2026!';
GRANT 'role_app_writer' TO 'app_svc'@'10.0.1.%';
SET DEFAULT ROLE ALL TO 'app_svc'@'10.0.1.%';
```

### Common Failure Traps
* **Trap**: Low-cardinality boolean columns par indexes add karna (optimizer unhe ignore karke table scan hi karta hai).
* **Trap**: Tables ko over-index karna (`INSERT`, `UPDATE`, aur `DELETE` par heavy write penalties lagti hain).
* **Trap**: Parameterized queries ke bajaye user inputs ko directly SQL strings mein concatenate karna.

### 5-Question Checkpoint Quiz
1. *EXPLAIN output mein `Using filesort` ka kya matlab hota hai?* $\rightarrow$ MySQL ko memory ya disk par explicit sorting pass perform karna pada kyunki index required order provide nahi kar saka.
2. *SARGable query predicate kya hota hai?* $\rightarrow$ Ek aisa predicate jo directly index seek utilize kar sakta hai.
3. *Prepared statements SQL injection se immune kyun hote hain?* $\rightarrow$ Kyunki user parameters bind hone se pehle query template fixed syntax tree mein compile ho jaata hai, jisse parameters query structure alter nahi kar sakte.
4. *InnoDB tables ka online, non-blocking logical backup kaun si command perform karti hai?* $\rightarrow$ `mysqldump --single-transaction`.
5. *Production application queries mein `SELECT *` kyun avoid karna chahiye?* $\rightarrow$ Ye network bandwidth waste karta hai, covering index optimizations prevent karta hai, aur memory usage badhata hai.

### Practical Challenge
Ek slow multi-table join query par `EXPLAIN ANALYZE` run karein, sabse lamba execution time lene wale stage ko identify karein, aur ek composite covering index design karein jo execution time ko 75% se zyada reduce kar de.
