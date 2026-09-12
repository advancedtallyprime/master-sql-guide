# Chapter 04 — Integrity Constraints & Validation Rules (Integrity Constraints aur Validation Rules)

---

## 1. What is it? (Ye Kya Hai?)

**Integrity Constraints** SQL ke wo declarative rules hote hain jo database schema level par enforce kiye jaate hain, taki table me store hone wale records ki accuracy, validity, consistency aur reliability 100% guaranteed rahe.

Jab bhi koi application `INSERT`, `UPDATE` ya `DELETE` query run karti hai, to MySQL ka storage engine disk par bytes commit karne se pehle incoming data ko in constraints ke against check karta hai. Agar ek bhi constraint rule violate hota hai, to engine execution ko turant rok deta hai, poore operation ko reject kar deta hai, ek informative error code throw karta hai, aur database ke state me koi bhi unwanted change nahi hone deta.

Business logic aur validation rules ko sirf application layer code (jaise Python, Node.js, Go) par chhodne ke bajaye seedhe database schema ke andar enforce karne ka sabse bada fayda ye hai ki **kabhi bhi corrupted ya invalid data database me enter nahi ho sakta** — chahe kitni bhi microservices, cron jobs ya third-party scripts database se directly connect karein.

SQL ke primary constraints ye hain:
1. **`PRIMARY KEY`**: Table ke har record (row) ko uniquely identify karta hai. Ye internally `UNIQUE` aur `NOT NULL` dono rules ko implicitly enforce karta hai. MySQL ke InnoDB engine me primary key hi physical **clustered index** define karti hai jo disk par rows ke layout ko arrange karta hai.
2. **`FOREIGN KEY`**: Do tables ke beech **referential integrity** maintain karta hai. Iska rule hai ki child table ki value parent table ki kisi existing primary key se match honi hi chahiye.
3. **`NOT NULL`**: Column me `NULL` (empty/unknown) marker ko forbid karta hai, yani us field me concrete valid value hona compulsory hai.
4. **`UNIQUE`**: Ye ensure karta hai ki kisi column (ya columns ke combination) me koi bhi do rows same non-NULL value hold na karein.
5. **`CHECK`**: Row ki values par ek custom boolean condition evaluate karta hai. Agar condition `FALSE` evaluate hoti hai, to insert/update fail ho jata hai (MySQL 8.0.16+ me fully supported).
6. **`DEFAULT`**: Agar `INSERT` query me koi specific column mention nahi kiya gaya hai, to ye usme ek predefined fallback value automatically daal deta hai.
7. **`AUTO_INCREMENT`**: Ek system-managed counter jo nayi aane wali har row ke liye automatically sequential integer IDs generate karta hai.

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

1. **Defensive Schema Architecture (Safety Net)**: Frontend forms ya backend APIs me software bugs aana natural hai. Constraints database level par ek unbreakable defensive wall ki tarah kaam karte hain, jo kisi bhi corrupt ya incomplete record ko database me aane se rokte hain.
2. **Referential Stability (Orphan Records Se Bachav)**: Foreign keys **orphaned rows** ki problem ko jad se khatam karti hain (jaise ek aisa order item jiska product delete ho chuka ho, ya ek aisa employee jiska department exist hi na karta ho).
3. **High-Performance Query Paths (Automatic Indexes)**: Jab aap `PRIMARY KEY`, `UNIQUE` ya `FOREIGN KEY` define karte hain, to database engine background me automatically B+ Tree indexes construct karta hai, jisse queries ko instant $O(\log N)$ search speed milti hai.
4. **Self-Documenting Schemas (Clean Architecture)**: Kisi table ka DDL padhte hi developer ko core business rules crystal-clear samajh aa jaate hain (jaise "salary 0 se badi honi chahiye", "discount 0.00 se 1.00 ke beech hona chahiye").

---

## 3. Syntax

### Defining Constraints During Table Creation
```sql
CREATE TABLE table_name (
    -- Column-level constraints
    column_id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    amount DECIMAL(10, 2) NOT NULL,
    parent_id INT,

    -- Explicitly named table-level constraints
    CONSTRAINT chk_positive_amount CHECK (amount >= 0.00),
    CONSTRAINT fk_table_parent FOREIGN KEY (parent_id)
        REFERENCES parent_table(parent_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Composite Primary Key (Multiple Columns Combined)
CREATE TABLE composite_demo (
    tenant_id INT NOT NULL,
    user_id INT NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (tenant_id, user_id)
);
```

### Adding, Modifying, and Dropping Constraints via `ALTER TABLE`
```sql
-- Add NOT NULL constraint
ALTER TABLE table_name
MODIFY COLUMN column_name data_type NOT NULL;

-- Remove NOT NULL (Allow NULLs)
ALTER TABLE table_name
MODIFY COLUMN column_name data_type NULL;

-- Add a UNIQUE constraint
ALTER TABLE table_name
ADD CONSTRAINT uq_column_name UNIQUE (column_name);

-- Add a CHECK constraint
ALTER TABLE table_name
ADD CONSTRAINT chk_rule_name CHECK (boolean_expression);

-- Add a FOREIGN KEY constraint
ALTER TABLE child_table
ADD CONSTRAINT fk_child_parent FOREIGN KEY (parent_id)
    REFERENCES parent_table(parent_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Drop constraints:
ALTER TABLE table_name DROP PRIMARY KEY;
ALTER TABLE table_name DROP INDEX uq_column_name;         -- Drops UNIQUE in MySQL
ALTER TABLE table_name DROP CHECK chk_rule_name;           -- Drops CHECK in MySQL 8.0+
ALTER TABLE child_table DROP FOREIGN KEY fk_child_parent;  -- Drops FOREIGN KEY
```

---

## 4. Basic Example

Aaiye ek subscription management table banakar constraints ka basic behavior check karte hain:

```sql
USE sql_mastery;

CREATE TABLE subscriptions_demo (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    monthly_rate DECIMAL(6, 2) NOT NULL DEFAULT 9.99,
    discount_rate DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_rate CHECK (monthly_rate > 0.00),
    CONSTRAINT chk_discount CHECK (discount_rate >= 0.00 AND discount_rate <= 1.00)
);

-- Valid Insert
INSERT INTO subscriptions_demo (user_email, monthly_rate, discount_rate)
VALUES ('subscriber@example.com', 19.99, 0.15);

-- Clean up
DROP TABLE subscriptions_demo;
```

---

## 5. Real-World Example

Hamare production `sql_mastery` database me, aaiye `order_items` table ki architecture inspect karte hain aur intentionally constraints ko violate karke dekhte hain ki MySQL engine kaise behave karta hai:

```sql
USE sql_mastery;

-- Inspect the table creation definition and constraints
SHOW CREATE TABLE order_items\G

-- Let us test the enforcement of each constraint:

-- TEST 1: Violation of CHECK constraint (quantity must be > 0)
-- This will trigger ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES (1001, 2, 0, 999.00, 0.00);

-- TEST 2: Violation of UNIQUE composite constraint (uq_order_product)
-- Order 1001 already contains product_id 1. Inserting it again should fail:
-- This will trigger ERROR 1062 (23000): Duplicate entry '1001-1' for key 'order_items.uq_order_product'
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES (1001, 1, 2, 1299.99, 0.00);

-- TEST 3: Violation of FOREIGN KEY constraint (Referencing non-existent product)
-- Product 9999 does not exist in the products table.
-- This triggers ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
VALUES (1001, 9999, 1, 49.99, 0.00);
```

---

## 6. Step-by-Step Explanation

Aaiye dekhein ki upar diye gaye teen tests me database internally kya kar raha tha:

1. `CONSTRAINT chk_item_quantity CHECK (quantity > 0)`:
   * Jab bhi `order_items` par koi `INSERT` ya `UPDATE` aata hai, to clustered index me data commit hone se pehle MySQL ka runtime constraint evaluator check karta hai ki `quantity > 0` hai ya nahi.
   * Kyunki Test 1 me `quantity` 0 di gayi thi, to expression `FALSE` ho gaya aur engine ne transaction statement abort karke error throw kiya:
     `ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.`
2. `CONSTRAINT uq_order_product UNIQUE (order_id, product_id)`:
   * MySQL dono columns ko cover karne wala ek composite unique B+ Tree index banata hai.
   * Jab Test 2 me `(1001, 1)` dobara insert karne ki koshish hui, to index lookup ne detect kiya ki ye pair already exist karta hai. Is wajah se insert immediately reject ho gaya, taki ek hi order me same product ki duplicate line items na ban sakein.
3. `CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)`:
   * Child table `order_items` parent table `products` ko reference karti hai.
   * Test 3 me jab `product_id = 9999` insert karne ki koshish ki gayi, to InnoDB storage engine ne `products` table ke clustered index me key `9999` search ki. Key na milne par usne statement ko roll back karke foreign key failure error throw kiya.

---

## 7. Expected Result

Terminal me constraint enforcement ke actual output messages:

```
mysql> INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -> VALUES (1001, 2, 0, 999.00, 0.00);
ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.

mysql> INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -> VALUES (1001, 1, 2, 1299.99, 0.00);
ERROR 1062 (23000): Duplicate entry '1001-1' for key 'order_items.uq_order_product'

mysql> INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -> VALUES (1001, 9999, 1, 49.99, 0.00);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`sql_mastery`.`order_items`, CONSTRAINT `fk_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE)
```

---

## 8. Common Mistakes

1. **`UNIQUE` Me `NULL` Values Allow Nahi Hongi Aisa Maan Lena**:
   * *Mistake*: Sochna ki agar column `UNIQUE` hai to usme `NULL` nahi aa sakta.
   * *Reality*: ANSI SQL aur MySQL me `NULL` ka matlab hota hai "unknown value". Kyunki do unknown values ko equal nahi mana ja sakta (`NULL = NULL` ka result `NULL` hota hai, `TRUE` nahi), isliye MySQL ek `UNIQUE` column me **multiple `NULL` values** allow karta hai (jab tak ki us column par explicitly `NOT NULL` na lagaya gaya ho).
2. **Primary Key Aur Unique Constraint Me Confuse Hona**:
   * Ek table me **sirf ek** `PRIMARY KEY` ho sakti hai (jo kabhi `NULL` nahi ho sakti), jabki ek table me **multiple** `UNIQUE` constraints ho sakte hain.
3. **MySQL 5.7 Me `CHECK` Constraints Ka Kaam Karna Maan Lena**:
   * MySQL 5.7 aur uske purane versions me parser `CHECK` syntax ko accept to kar leta tha lekin insert/update ke time silently ignore kar deta tha. Full runtime `CHECK` enforcement **MySQL 8.0.16** se introduce hua hai.
4. **Foreign Key Se Linked Column Ko Seedhe Drop Karne Ki Koshish Karna**:
   * Agar aap directly `ALTER TABLE order_items DROP COLUMN product_id;` chalayenge to error aayega. Rule ye hai ki pehle foreign key constraint drop karein (`ALTER TABLE order_items DROP FOREIGN KEY fk_items_product;`), aur uske baad hi column drop karein.
5. **Constraints Ke Names Specify Na Karna**:
   * Sirf `CHECK (salary > 0)` likhne se MySQL use `employees_chk_1` jaisa internal anonymous name de deta hai. Aage chalkar migration scripts me us constraint ko identify aur drop karna behad mushkil ho jata hai.

---

## 9. Best Practices

1. **Descriptive Naming Conventions Follow Karein**:
   * Constraints ko unke functional type ke according prefix karein:
     * Primary Keys: `pk_tablename`
     * Foreign Keys: `fk_childtable_parenttable`
     * Unique Constraints: `uq_tablename_column`
     * Check Constraints: `chk_tablename_rule`
2. **Foreign Key Deletion Actions Ko Samajhdari Se Chunein**:
   * `ON DELETE RESTRICT` (default): Agar parent row ke sath child records linked hain, to parent ko delete nahi hone deta (jaise agar customer ke active orders hain to customer delete nahi hoga).
   * `ON DELETE CASCADE`: Jab child records ka parent ke bina koi standalone existence na ho (jaise `orders` delete hone par uske sare `order_items` bhi cascade delete ho jane chahiye).
   * `ON DELETE SET NULL`: Jab relationship optional ho (jaise agar employee ka manager company chhod deta hai, to `manager_id` ko `NULL` set kar diya jaye).
3. **High-Volume Foreign Keys Ke Liye Composite Primary Keys Avoid Karein**:
   * Halanki natural composite keys (jaise `(order_id, product_id)`) valid hoti hain, lekin agar doosri child tables ko use reference karna ho to surrogate key (`item_id INT AUTO_INCREMENT PRIMARY KEY`) ke sath composite `UNIQUE (order_id, product_id)` constraint prefer karein. Isse multi-column foreign key bloat se bacha ja sakta hai.

---

## 10. Practice Questions

### Easy
1. Jab kisi column ko `PRIMARY KEY` define kiya jata hai, to kaun se do constraints automatically enforce ho jaate hain?
2. Ek single table ke andar maximum kitni `PRIMARY KEY` constraints define ki ja sakti hain?
3. Ek single table ke andar kitni `UNIQUE` constraints banayi ja sakti hain?

### Medium
4. `bank_accounts` table ke liye ek `CREATE TABLE` statement likhiye jisme `account_id INT AUTO_INCREMENT PRIMARY KEY`, `account_number VARCHAR(20) NOT NULL UNIQUE`, aur `balance DECIMAL(12,2) NOT NULL DEFAULT 0.00` ho, sath me ek CHECK constraint ho jo ensure kare ki `balance >= 0.00`.
5. Maan lijiye do tables hain `students` aur `enrollments`. Ek SQL statement likhiye jo `enrollments(student_id)` par named foreign key `fk_enrollment_student` add kare jo cascading deletes ke sath `students(student_id)` ko reference kare.
6. MySQL 8.0 me `employees` table se check constraint `chk_employee_salary` ko drop karne ke liye exact command likhiye.

### Difficult
7. Internally kya hota hai jab aap kisi `UNIQUE` constraint wale column me do rows me `NULL` insert karte hain versus jab aap `PRIMARY KEY` wale column me do rows me `NULL` insert karne ki koshish karte hain?
8. Ek `ALTER TABLE` statement likhiye jo `events` table par ek multi-column check constraint add kare jo guarantee kare ki `end_time` hamesha `start_time` se bada hona chahiye.

---

## 11. Interview Questions

### Q1: `PRIMARY KEY` aur `UNIQUE` constraint me kya core difference hota hai?
**Answer**:
1. **Quantity**: Ek table me sirf ek `PRIMARY KEY` ho sakti hai, jabki `UNIQUE` constraints multiple banaye ja sakte hain.
2. **Nullability**: `PRIMARY KEY` me `NULL` values strictly forbidden hoti hain. `UNIQUE` constraint me `NULL` values permitted hoti hain (aur MySQL me multiple rows `NULL` rakh sakti hain jab tak `NOT NULL` na ho).
3. **Clustered Storage**: MySQL InnoDB me `PRIMARY KEY` table data ke physical disk layout ko define karti hai jise **clustered index** kaha jata hai (leaf nodes par actual data store hota hai). Jabki secondary `UNIQUE` constraints non-clustered secondary indexes banate hain jinke leaf nodes primary key ko point karte hain.

### Q2: `ON DELETE CASCADE`, `ON DELETE SET NULL`, aur `ON DELETE RESTRICT` me kya farq hota hai?
**Answer**:
* `ON DELETE RESTRICT` (ya `NO ACTION`): Agar parent row ke under koi bhi child row maujood hai, to parent row ko delete hone se rok deta hai aur foreign key violation error raise karta hai.
* `ON DELETE CASCADE`: Jab parent row delete hoti hai, to engine automatically usse linked sabhi child rows ko bhi table se delete kar deta hai.
* `ON DELETE SET NULL`: Parent row delete hone par child rows delete nahi hoti, balki unki foreign key column ki value ko `NULL` set kar diya jata hai (iski requirement ye hai ki child column nullable hona chahiye).

### Q3: MySQL ke alag-alag versions me `CHECK` constraints ka behavior kaise evolve hua hai?
**Answer**: MySQL version 8.0.16 se pehle, SQL parser `CHECK` constraint syntax ko parse to kar leta tha bina error ke, lekin storage engine runtime DML operations (`INSERT`/`UPDATE`) ke dauran use completely ignore kar deta tha. Starting with MySQL 8.0.16, engine runtime par `CHECK` constraints ko strictly enforce karta hai. Agar evaluated boolean condition `FALSE` nikalti hai, to query execute nahi hoti aur engine `ERROR 3819 (HY000)` emit karta hai.

---

## 12. Quick Revision

* **Integrity constraints** storage engine level par invalid data modifications ko reject karke database ki reliability protect karte hain.
* Har table me exactly ek **`PRIMARY KEY`** hoti hai, jo kabhi `NULL` nahi ho sakti aur InnoDB me physical clustered index banati hai.
* **`UNIQUE`** duplicates ko prevent karta hai lekin MySQL me multiple `NULL` values allow karta hai (agar `NOT NULL` na ho).
* **`FOREIGN KEY`** parent-child relational integrity maintain karta hai, configurable delete rules ke sath (`RESTRICT`, `CASCADE`, `SET NULL`).
* **`CHECK`** constraints custom business rules ko enforce karte hain (MySQL 8.0.16+ me fully active).
* Schema maintenance aur clean debugging ke liye hamesha explicit descriptive names use karein (`fk_...`, `chk_...`, `uq_...`).
