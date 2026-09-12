# Chapter 05 — Data Manipulation: CRUD Operations (Data Manipulation: CRUD Operations)

---

## 1. What is it? (Ye Kya Hai?)

**CRUD** software development industry ka ek universal acronym hai jo persistent applications ke chaar sabse fundamental data operations ko represent karta hai:
* **C**reate $\rightarrow$ `INSERT` (aur advanced forms: `INSERT IGNORE`, `ON DUPLICATE KEY UPDATE`, `REPLACE`)
* **R**ead $\rightarrow$ `SELECT`
* **U**pdate $\rightarrow$ `UPDATE`
* **D**elete $\rightarrow$ `DELETE`

Relational database systems me CRUD operations ko **Data Manipulation Language (DML)** kaha jata hai. DDL commands jahan database ke structural blueprint (skeletons) par kaam karte hain, wahi DML statements tables ke andar store hone wale actual records (data) ko manipulate karte hain.

MySQL ke default InnoDB engine me sabhi DML operations strictly transactional boundaries ke andar execute hote hain: koi bhi data modification permanent hone se pehle active transaction ke **Undo Log** (taki zaroorat padne par rollback ho sake) aur **Redo Log** (taki system crash hone par recovery ho sake) me likha jata hai, jiske baad hi changes disk pages par commit hote hain.

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Transactional Record Ingestion (Data Store Karna)**: Modern applications me single user signups se lekar massive bulk imports tak, billions of events ko bina indexes corrupt kiye reliably table me insert karna padta hai.
2. **Idempotent Data Synchronization (UPSERT Mechanism)**: Jab aap external third-party APIs ya message queues se data sync karte hain, to aksar aisi zaroorat hoti hai ki agar record naya hai to insert ho jaye, aur agar already exist karta hai to uske attributes atomically update ho jayein.
3. **Targeted State Mutation (Live Status Badalna)**: E-commerce aur fintech systems me continuously order statuses change hote hain (`Pending` se `Delivered`), account balances update hote hain ya shipping addresses correct kiye jaate hain.
4. **Data Lifecycle Hygiene (Purana Data Hatana)**: Expired shopping cart sessions, test orders ya cancelled subscriptions ko delete karke disk space aur database memory ko optimize rakha jata hai.

---

## 3. Syntax

### INSERT Operations
```sql
-- 1. Explicit Column Insert (Production Best Practice)
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);

-- 2. Bulk Multi-Row Insert (Efficient batch loading)
INSERT INTO table_name (column1, column2, column3)
VALUES 
    (valA1, valA2, valA3),
    (valB1, valB2, valB3),
    (valC1, valC2, valC3);

-- 3. Insert from Existing Query (INSERT INTO ... SELECT)
INSERT INTO target_table (col1, col2)
SELECT colA, colB FROM source_table WHERE condition;

-- 4. Insert Ignore (Silently skip rows violating PRIMARY KEY or UNIQUE constraints)
INSERT IGNORE INTO table_name (id, email, name)
VALUES (1, 'user@example.com', 'Alex');

-- 5. UPSERT (Insert or Update on Duplicate Key)
INSERT INTO table_name (id, counter_value, updated_at)
VALUES (1, 10, NOW())
ON DUPLICATE KEY UPDATE 
    counter_value = counter_value + VALUES(counter_value),
    updated_at = NOW();

-- Note on MySQL 8.0.20+ UPSERT alias syntax:
-- INSERT INTO table_name (id, counter_value) VALUES (1, 10) AS new_data
-- ON DUPLICATE KEY UPDATE counter_value = counter_value + new_data.counter_value;
```

### Basic SELECT Retrieval
```sql
SELECT column1, column2 AS custom_alias, (column1 * 1.10) AS calculated_tax
FROM table_name;
```

### UPDATE Operations
```sql
-- Standard Update with Filter
UPDATE table_name
SET column1 = new_value1,
    column2 = new_value2
WHERE primary_key_col = target_id;

-- Multi-table Update (Updating based on a relational join)
UPDATE customers c
JOIN orders o ON c.customer_id = o.customer_id
SET c.loyalty_points = c.loyalty_points + 50
WHERE o.total_amount > 1000.00;
```

### DELETE Operations
```sql
-- Targeted Row Deletion
DELETE FROM table_name
WHERE filter_column = value;

-- Delete with Order and Limit (e.g., delete oldest 100 failed logs)
DELETE FROM table_name
WHERE status = 'Failed'
ORDER BY created_at ASC
LIMIT 100;
```

---

## 4. Basic Example

Aaiye ek temporary sandbox table bana kar complete CRUD lifecycle ko practically execute karke dekhte hain:

```sql
USE sql_mastery;

CREATE TABLE audit_notes (
    note_id INT AUTO_INCREMENT PRIMARY KEY,
    author VARCHAR(50) NOT NULL,
    note_text VARCHAR(255) NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE
);

-- CREATE (Insert single and bulk)
INSERT INTO audit_notes (author, note_text)
VALUES ('Security Bot', 'Routine port scan passed');

INSERT INTO audit_notes (author, note_text, is_resolved)
VALUES 
    ('DevOps', 'Disk alert 85%', FALSE),
    ('DBA', 'Index maintenance scheduled', TRUE);

-- READ
SELECT note_id, author, note_text, is_resolved 
FROM audit_notes;

-- UPDATE
UPDATE audit_notes
SET is_resolved = TRUE
WHERE note_id = 2;

-- DELETE
DELETE FROM audit_notes
WHERE note_id = 1;

-- Clean up
DROP TABLE audit_notes;
```

---

## 5. Real-World Example

Hamare production `sql_mastery` database me, aaiye ek complete end-to-end business transaction walk-through karte hain:
1. Ek naye customer ko register karna.
2. `ON DUPLICATE KEY UPDATE` use karke product inventory sync karna.
3. Delivered orders ke basis par customer ko loyalty points award karna.
4. Demo customer ko cleanly remove karna.

```sql
USE sql_mastery;

-- 1. CREATE: Register a new customer with explicit columns
INSERT INTO customers (first_name, last_name, email, phone, city, state, country, loyalty_points, registered_at)
VALUES ('Vikram', 'Sharma', 'vikram.sharma@example.in', '555-0399', 'Mumbai', 'MH', 'India', 100, CURDATE());

-- Verify insertion and check the auto-generated customer_id
SELECT customer_id, first_name, last_name, email, loyalty_points, registered_at
FROM customers
WHERE email = 'vikram.sharma@example.in';

-- 2. ADVANCED CREATE / UPSERT: Sync product catalog inventory
-- If Product ID 1 exists, add 10 to stock_quantity; if not, insert new product
INSERT INTO products (product_id, product_name, category_id, supplier_id, unit_price, stock_quantity, reorder_level, is_active)
VALUES (1, 'Quantum Pro 15 Laptop', 1, 1, 1299.99, 10, 10, TRUE)
ON DUPLICATE KEY UPDATE 
    stock_quantity = stock_quantity + 10;

-- 3. UPDATE: Award 50 bonus loyalty points to customers who have placed an order over $1,000
UPDATE customers c
JOIN orders o ON c.customer_id = o.customer_id
SET c.loyalty_points = c.loyalty_points + 50
WHERE o.total_amount > 1000.00 AND o.status = 'Delivered';

-- 4. DELETE: Remove the newly added demo customer
DELETE FROM customers
WHERE email = 'vikram.sharma@example.in';

-- Restore Product 1 stock back to initial 45 units
UPDATE products
SET stock_quantity = 45
WHERE product_id = 1;
```

---

## 6. Step-by-Step Explanation

Aaiye upar diye gaye transaction flow ke execution steps ko detail me samajhte hain:

1. `INSERT INTO customers (...) VALUES (...)`:
   * SQL parser check karta hai ki sabhi required non-nullable columns jinki default values nahi hain (`first_name`, `last_name`, `email`, `city`, `country`, `registered_at`) query me provided hain ya nahi.
   * Storage engine verify karta hai ki `vikram.sharma@example.in` email table ke `UNIQUE (email)` constraint ko violate na kare.
   * Auto-increment lock (`innodb_autoinc_lock_mode`) customer ko agla sequential integer ID (jaise `11`) assign karta hai, record ko clustered index leaf page me append karta hai, aur transaction ko Redo Log me flush karta hai.
2. `INSERT ... ON DUPLICATE KEY UPDATE`:
   * MySQL pehle `product_id = 1` par index lookup karta hai.
   * Clustered index me record pehle se maujood milne par, MySQL duplicate key error `1062` throw nahi karta; balki wo product 1 ki row par exclusive lock leta hai aur assignment execute karta hai: `stock_quantity = stock_quantity + 10`.
3. `UPDATE customers c JOIN orders o ...`:
   * Query optimizer `customers` aur `orders` tables ke beech join plan banata hai.
   * Sirf wahi customer rows filter aur lock hoti hain jinke matching orders `total_amount > 1000.00 AND status = 'Delivered'` condition satisfy karte hain. Fir `SET` clause unke `loyalty_points` ko in-place increment kar deta hai.
4. `DELETE FROM customers WHERE email = 'vikram.sharma@example.in'`:
   * Unique index ki madad se engine customer row ko directly locate karta hai. Kyunki customer 11 ka koi child record `orders` table me nahi tha, isliye ye row bina foreign key restriction ke safely delete ho jaati hai.

---

## 7. Expected Result

Customer insert karne ke baad verification query ka output:

```
+-------------+------------+-----------+--------------------------+----------------+---------------+
| customer_id | first_name | last_name | email                    | loyalty_points | registered_at |
+-------------+------------+-----------+--------------------------+----------------+---------------+
|          11 | Vikram     | Sharma    | vikram.sharma@example.in |            100 | 2026-09-09    |
+-------------+------------+-----------+--------------------------+----------------+---------------+
1 row in set (0.00 sec)
```

`ON DUPLICATE KEY UPDATE` run karne ke baad product stock ka output:

```
+------------+-----------------------+----------------+
| product_id | product_name          | stock_quantity |
+------------+-----------------------+----------------+
|          1 | Quantum Pro 15 Laptop |             55 |
+------------+-----------------------+----------------+
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Bina `WHERE` Clause Ke `UPDATE` Ya `DELETE` Run Kar Dena**:
   * *The Nightmare Scenario*:
     ```sql
     UPDATE employees SET salary = 50000;
     ```
   * *Consequence*: Agar aap `WHERE` lagana bhool gaye, to table ki **ek-ek row update ho jayegi!** Poori company ke har employee ki salary badal kar 50,000 ho jayegi.
   * *Protection*: Hamesha MySQL Safe Updates mode enable rakhein (`SET sql_safe_updates = 1;`). Ye aisi kisi bhi `UPDATE` ya `DELETE` query ko block kar deta hai jisme key-based `WHERE` ya `LIMIT` clause na ho.
2. **`INSERT` Me Column Lists Na Likhna**:
   * *Fragile Syntax*:
     ```sql
     INSERT INTO categories VALUES (6, 'Apparel', 'Clothing');
     ```
   * *Problem*: Agar future me koi DBA table me naya column add kar de (`ALTER TABLE categories ADD COLUMN icon_url VARCHAR(255);`), to purani saari queries turant fail ho jayengi:
     `ERROR 1136 (21S01): Column count doesn't match value count at row 1.`
   * *Rule*: Hamesha explicit column list likhein: `INSERT INTO categories (category_id, category_name, description) VALUES (...)`.
3. **Loop Me Single-Row INSERTs Chalana (Bulk Insert Ke Bajaye)**:
   * *Bad Practice*: Application code me loop chalakar 1,000 baar alag-alag `INSERT INTO ... VALUES (...)` queries bhejna.
   * *Problem*: Har query apna network round-trip, statement parsing aur transaction log disk flush leti hai.
   * *Solution*: Multi-row bulk insert use karein (`INSERT INTO table VALUES (...), (...), (...)`), jo 50x se 100x tak fast execute hota hai.
4. **`REPLACE INTO` Ko `ON DUPLICATE KEY UPDATE` Ke Sath Confuse Karna**:
   * `REPLACE INTO` internally pehle purani row ko `DELETE` karta hai aur fir nayi row `INSERT` karta hai. Iske dangerous side effects hote hain: auto-increment ID change ho jata hai, unmentioned columns default values par reset ho jaate hain, aur child tables me `ON DELETE CASCADE` configured ho to related child records delete ho sakte hain! Isliye hamesha `ON DUPLICATE KEY UPDATE` prefer karein.

---

## 9. Best Practices

1. **Development Me Hamesha `sql_safe_updates` On Rakhein**:
   ```sql
   SET sql_safe_updates = 1;
   ```
2. **`UPDATE` Aur `DELETE` Chalane Se Pehle Hamesha `SELECT` Karke Check Karein**:
   * Is query ko execute karne se pehle:
     ```sql
     DELETE FROM orders WHERE status = 'Cancelled' AND order_date < '2022-01-01';
     ```
   * Pehle count check karein:
     ```sql
     SELECT COUNT(*) FROM orders WHERE status = 'Cancelled' AND order_date < '2022-01-01';
     ```
   * Record count inspect karne ke baad hi mutation run karein.
3. **Multi-Step Updates Ke Liye Transactions Use Karein**:
   * Jab ek table ka modification doosre table par depend kare (jaise naya order create karke product ki `stock_quantity` ghatana), to dono statements ko transaction me wrap karein: `START TRANSACTION; ... COMMIT;`.
4. **Large Datasets Par Deletions Ko `LIMIT` Ke Sath Batch Karein**:
   * Millions of rows ek sath delete karne se table lock ho jaati hai aur Undo Log blow up ho jata hai. Isliye batching karein:
     ```sql
     DELETE FROM application_logs WHERE log_date < '2022-01-01' LIMIT 5000;
     ```
     Is query ko loop me tab tak chalayein jab tak 0 rows affected na ho jayein.

---

## 10. Practice Questions

### Easy
1. `departments` table me `'London'` city me situated `'Legal'` naam ka ek naya department insert karne ke liye SQL query likhiye.
2. `employees` table se sirf `first_name`, `last_name`, aur `salary` fetch karne ke liye statement likhiye.
3. Customer jiska `customer_id = 1` hai, uska phone number update karke `'555-9999'` set karne ke liye query likhiye.

### Medium
4. Ek single bulk `INSERT` statement likhiye jo `products` table me ek hi command ke andar teen alag-alag office supply products add kare.
5. Ek `UPDATE` statement likhiye jo department 1 (`Engineering`) ke har employee ki `salary` 8% badha de.
6. Aisi sabhi payments ko delete karne ke liye query likhiye jinka `payment_status` value `'Failed'` hai.

### Difficult
7. `suppliers` table ke liye ek idempotent `INSERT ... ON DUPLICATE KEY UPDATE` statement likhiye. Agar `supplier_name` ya `contact_email` already exist karta hai to `contact_name` aur `contact_phone` ko nayi values se update karein; warna naya supplier insert karein.
8. Ek multi-table `DELETE` statement likhiye jo un customers ke orders ko remove kare jinhone `2021-01-01` se pehle register kiya tha aur jinke `loyalty_points = 0` hain (aur `ON DELETE CASCADE` ke through unke order items bhi delete ho jayein).

---

## 11. Interview Questions

### Q1: 1,000 individual row inserts ke comparison me 1,000 tuples ka ek single batch insert chalane me kya performance difference hota hai?
**Answer**: Agar aap 1,000 alag-alag `INSERT` statements bhejte hain, to database 1,000 alag-alag network round-trips face karta hai, query parser 1,000 baar execute hota hai, aur agar `autocommit` on hai to InnoDB Redo Log disk par 1,000 baar flush hota hai. Jabki ek single multi-row `INSERT INTO table VALUES (...), (...), ...` statement saari rows ko ek hi network packet me bundle karta hai, ek baar parse hota hai, aur batch ko single log write me commit karta hai. Isse aksar 20x se 100x tak massive performance speedup milta hai.

### Q2: `REPLACE INTO` aur `INSERT ... ON DUPLICATE KEY UPDATE` me kya farq hota hai?
**Answer**:
* `REPLACE INTO` ka internal mechanism ye hota hai ki duplicate key milne par purani row physically `DELETE` hoti hai aur bilkul nayi row `INSERT` hoti hai. Is wajah se auto-increment counter aage badh jata hai, statement me mention na kiye gaye columns default values par reset ho jaate hain, aur dependent child tables me `ON DELETE CASCADE` laga ho to child records permanently delete ho jaate hain.
* `INSERT ... ON DUPLICATE KEY UPDATE` existing row par ek in-place `UPDATE` perform karta hai. Purani row ki identity, auto-increment counter aur unmentioned columns intact rehte hain, aur foreign key cascade delete hone ka koi risk nahi rehta.

### Q3: MySQL ka `sql_safe_updates` mode kya hota hai aur ye kyun important hai?
**Answer**: `sql_safe_updates` ek safety configuration variable hai (`SET sql_safe_updates = 1;`). Jab ye mode enabled hota hai, to MySQL aisi kisi bhi `UPDATE` ya `DELETE` query ko execute karne se strictly refuse kar deta hai jisme key column (primary key ya indexed column) par based `WHERE` clause na ho ya explicit `LIMIT` clause missing ho. Iska sabse bada benefit ye hai ki developers ya DBAs ki accidental galti se poori table ka data wipe out ya overwrite hone se bacha rehta hai.

---

## 12. Quick Revision

* **CRUD** operations directly SQL ke char main verbs se map hote hain: `INSERT`, `SELECT`, `UPDATE`, aur `DELETE`.
* Future schema alterations se code ko safe rakhne ke liye `INSERT` me hamesha **explicit column lists** mention karein.
* Large data volumes ko fast ingest karne ke liye single inserts ke bajaye hamesha **bulk inserts** use karein.
* Bina `WHERE` clause check kiye kabhi bhi `UPDATE` ya `DELETE` mat chalayein, aur development me hamesha `sql_safe_updates` mode on rakhein.
* Idempotent data synchronization ke liye hamesha `INSERT ... ON DUPLICATE KEY UPDATE` (UPSERT) use karein; `REPLACE INTO` ko delete-and-reinsert side effects ki wajah se avoid karein.
