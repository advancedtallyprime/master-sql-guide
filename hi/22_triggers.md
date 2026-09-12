# Chapter 22 — Event-Driven Architecture: MySQL Triggers

---

## 1. What is it?

MySQL mein ek **Trigger** ek aisa specialized stored program hota hai jo kisi specific base table par hone wale specific **Data Manipulation Language (DML)** event (`INSERT`, `UPDATE`, ya `DELETE`) ke response mein automatically execute ("fire") ho jata hai.

Stored Procedures ke opposite (jinhe application ya developer ko khud explicitly `CALL` karke execute karna padta hai), triggers ko kabhi directly call nahi kiya ja sakta. Ye storage engine dwara manage kiye jaane wale **implicit event handlers** ki tarah background mein silently kaam karte hain.

Ek trigger fundamental roop se do axes par define hota hai:
1. **Activation Timing**:
   * **`BEFORE`**: Row modification ke storage engine ke data pages par write hone se *pehle* fire hota hai. Iska use mostly data validation, data sanitization (jaise whitespace trim karna ya passwords hash karna), aur disk par write hone se pehle incoming values modify karne ke liye hota hai.
   * **`AFTER`**: Row modification ke table par write hone ke *baad* fire hota hai. Iska use primarily immutable audit logging, cross-table synchronization, aur event notifications ke liye kiya jata hai.
2. **Activation Event**: `INSERT`, `UPDATE`, ya `DELETE`.

Kyunki MySQL row-level triggers (`FOR EACH ROW`) use karta hai, isliye agar koi single `UPDATE` statement 50 rows modify karta hai, toh trigger code exactly 50 times (har affected row ke liye ek baar) execute hoga.

---

## 2. Row Pseudo-Records: `NEW` vs `OLD`

Trigger body ke andar, MySQL do virtual pseudo-records provide karta hai jo data row ko represent karte hain:
* **`NEW`**: Ye insert ya update hone wale naye record ko represent karta hai.
  * Available hota hai: **`INSERT`** aur **`UPDATE`** mein.
  * `BEFORE` triggers mein aap incoming values ko overwrite kar sakte hain: `SET NEW.email = LOWER(NEW.email);`.
* **`OLD`**: Ye modification ya deletion se pehle ke existing record ko represent karta hai.
  * Available hota hai: **`UPDATE`** aur **`DELETE`** mein.
  * Ye strictly read-only hota hai.

| Trigger Event | `OLD.column` Available? | `NEW.column` Available? | Can Modify `NEW.column`? |
| :--- | :--- | :--- | :--- |
| `INSERT` | No | **Yes** (values to be inserted) | **Yes** (in `BEFORE INSERT` only) |
| `UPDATE` | **Yes** (pre-update values) | **Yes** (post-update values) | **Yes** (in `BEFORE UPDATE` only) |
| `DELETE` | **Yes** (values being removed) | No | No |

---

## 3. Syntax

```sql
DELIMITER //

CREATE TRIGGER trigger_name
[BEFORE | AFTER] [INSERT | UPDATE | DELETE]
ON table_name
FOR EACH ROW
BEGIN
    -- Trigger logic
    -- Access NEW.col or OLD.col
END //

DELIMITER ;

-- Managing Triggers
SHOW TRIGGERS FROM database_name;
DROP TRIGGER IF EXISTS trigger_name;
```

### Aborting Operations with `SIGNAL SQLSTATE`
Kisi illegal operation ko reject karne aur trigger ke andar se enclosing transaction ko rollback karne ke liye, `SIGNAL SQLSTATE '45000'` ka use karke custom database exception raise karein:

```sql
IF NEW.salary <= 0 THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integrity Error: Employee salary must be greater than zero.';
END IF;
```

---

## 4. Basic Example

User data ko automatically normalize karne ke liye ek `BEFORE INSERT` trigger banate hain:

```sql
USE sql_mastery;

DELIMITER //

CREATE TRIGGER trg_customers_before_insert
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    -- Force email addresses to lowercase and trim any whitespace
    SET NEW.email = LOWER(TRIM(NEW.email));
    
    -- Assign default loyalty points if null
    IF NEW.loyalty_points IS NULL THEN
        SET NEW.loyalty_points = 0;
    END IF;
END //

DELIMITER ;

-- Clean up
DROP TRIGGER trg_customers_before_insert;
```

---

## 5. Real-World Example: Enterprise Audit Logging & Price Validation

Hamare `sql_mastery` database mein executive compliance committee ko do automated safeguards ki zaroorat hai:
1. **Validation (`BEFORE UPDATE` on `products`)**: Kisi single update mein product price mein 50% se zyada ki reduction ko prevent karna taaki accidental catastrophic price drop na ho sake, aur agar violation ho toh transaction abort kar dena.
2. **Audit Trail (`AFTER UPDATE` on `products`)**: Jab bhi kisi product ka `unit_price` ya `stock_quantity` modify ho, us change ko ek immutable audit table mein log karna—product ID, purani values, nayi values, update run karne wala user, aur timestamp capture karte hue.

```sql
USE sql_mastery;

-- Step 1: Create the immutable audit trail table
CREATE TABLE product_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    old_stock INT,
    new_stock INT,
    action_type VARCHAR(20) NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

-- Step 2: BEFORE UPDATE Trigger for Business Rule Enforcement
CREATE TRIGGER trg_products_before_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    -- Safeguard: Disallow dropping price by more than 50% in a single update
    IF NEW.unit_price < (OLD.unit_price * 0.50) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'TRANSACTION REJECTED: Price drops exceeding 50% require managerial authorization.';
    END IF;
END //

-- Step 3: AFTER UPDATE Trigger for Immutable Audit Logging
CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Only log if price or stock actually changed
    IF (OLD.unit_price != NEW.unit_price) OR (OLD.stock_quantity != NEW.stock_quantity) THEN
        INSERT INTO product_audit_log (
            product_id,
            old_price,
            new_price,
            old_stock,
            new_stock,
            action_type,
            changed_by
        ) VALUES (
            OLD.product_id,
            OLD.unit_price,
            NEW.unit_price,
            OLD.stock_quantity,
            NEW.stock_quantity,
            'PRICE_STOCK_UPDATE',
            CURRENT_USER()
        );
    END IF;
END //

DELIMITER ;
```

---

## 6. Step-by-Step Explanation & Execution

Aaiye dono triggers ko step-by-step test karke dekhte hain:

```sql
USE sql_mastery;

-- TEST 1: Trigger the Price Drop Guard
-- Quantum Pro 15 Laptop is $1,299.99. Dropping price to $500.00 is a 61% drop!
-- This MUST be rejected by trg_products_before_update!
UPDATE products
SET unit_price = 500.00
WHERE product_id = 1;

-- TEST 2: Authorized Legitimate Price Update
-- Update Laptop price to $1,199.99 (8% drop) and decrement stock by 2
UPDATE products
SET unit_price = 1199.99,
    stock_quantity = stock_quantity - 2
WHERE product_id = 1;

-- Inspect the automatically populated Audit Log!
SELECT * FROM product_audit_log;

-- Restore base state and clean up
UPDATE products SET unit_price = 1299.99, stock_quantity = stock_quantity + 2 WHERE product_id = 1;
DROP TRIGGER trg_products_before_update;
DROP TRIGGER trg_products_after_update;
DROP TABLE product_audit_log;
```

---

## 7. Expected Result

Triggers ke execution ko confirm karne wala terminal output:

```
mysql> UPDATE products SET unit_price = 500.00 WHERE product_id = 1;
ERROR 1644 (45000): TRANSACTION REJECTED: Price drops exceeding 50% require managerial authorization.

mysql> UPDATE products SET unit_price = 1199.99, stock_quantity = stock_quantity - 2 WHERE product_id = 1;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM product_audit_log\G
*************************** 1. row ***************************
   audit_id: 1
 product_id: 1
  old_price: 1299.99
  new_price: 1199.99
  old_stock: 45
  new_stock: 43
action_type: PRICE_STOCK_UPDATE
 changed_by: root@localhost
 changed_at: 2026-09-09 10:13:30
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Mutating the Triggering Table Inside the Trigger (Error 1442)**:
   * *The Critical Mistake*:
     ```sql
     CREATE TRIGGER trg_bad AFTER INSERT ON orders
     FOR EACH ROW
     BEGIN
         UPDATE orders SET total_amount = 100 WHERE order_id = NEW.order_id; -- FATAL!
     END;
     ```
   * *Error*:
     `ERROR 1442 (HY000): Can't update table 'orders' in stored function/trigger because it is already being used by statement which invoked this stored function/trigger.`
   * *Rule*: Ek trigger jis table par attached hota hai, usi table par directly DML (`INSERT`, `UPDATE`, `DELETE`) execute nahi kar sakta! Agar aapko usi table par incoming values modify karni hain, toh `BEFORE INSERT/UPDATE` trigger use karein aur direct values assign karein: `SET NEW.total_amount = 100;`.
2. **Hidden Business Logic & Debugging Nightmares**:
   * Complex business logic ko triggers ke andar daalne se application behavior chhup jata hai. Jab koi backend API developer `UPDATE` run karta hai jo unexpectedly fail ho jata hai ya 20 secondary changes trigger kar deta hai, toh bina documentation ke issue track down karna bahut mushkil ho jata hai.
3. **Severe Bulk DML Performance Penalties**:
   * Row-level triggers **har single row** ke liye execute hote hain. Agar koi application bulk `INSERT` ke zariye 1,000,000 rows load karti hai, toh ek `AFTER INSERT` trigger 1,000,000 baar execute hoga, jo ek 2-second bulk insert ko 15-minute ke bottleneck mein badal dega.

---

## 9. Best Practices

1. **Keep Triggers Small, Fast, and Non-Intrusive**:
   * Triggers caller ke active transaction ke context mein execute hote hain. Heavy trigger computations lock hold time ko badha deti hain, jisse lock wait timeouts aur deadlocks ka risk exponentially badh jata hai.
2. **Restrict Triggers to Auditing, Data Normalization, and Strict Invariants**:
   * Excellent use cases: audit logs maintain karna, hash checksums calculate karna, aur strict cross-field schema rules enforce karna.
   * Poor use cases: external webhooks call karna, emails send karna, ya multi-table business workflows execute karna.
3. **Use Meaningful Trigger Naming Conventions**:
   * Format: `trg_<tablename>_<timing>_<event>`
   * Examples: `trg_products_before_update`, `trg_orders_after_insert`.
4. **Always Guard Audit Inserts with Change Detection**:
   * Hamesha `IF (OLD.col != NEW.col)` check karein taaki aap sirf tabhi audit log records write karein jab values sach mein change hui hon, jisse unnecessary audit table bloat se bacha ja sake.

---

## 10. Practice Questions

### Easy
1. `BEFORE` trigger aur `AFTER` trigger ke activation timing mein kya difference hota hai?
2. `DELETE` trigger ke andar kaun sa pseudo-record (`NEW` ya `OLD`) available hota hai?
3. `INSERT` trigger ke andar kaun sa pseudo-record available hota hai?

### Medium
4. `employees` table par ek `BEFORE INSERT` trigger likhiye jo ye ensure kare ki agar newly inserted employee ki `hire_date` `NULL` supply ki gayi ho, toh use `CURDATE()` par set kar diya jaye.
5. `employees` par ek `BEFORE UPDATE` trigger likhiye jo employee ki `salary` reduce karna forbid kare. Agar koi update `NEW.salary < OLD.salary` karne ki koshish kare, toh error state `'45000'` ke sath message raise karein: `'Salaries cannot be reduced.'`.
6. `sql_mastery` database mein filhal defined saare triggers ko list karne ke liye query likhiye.

### Difficult
7. Ek automatic stock synchronization trigger design karein: Jab `order_items` mein nayi line item add ho, toh ek `AFTER INSERT` trigger automatically `products` table mein corresponding product ki `stock_quantity` ko decrement kar de. Is design se kaun se concurrency ya deadlock risks paida hote hain?
8. Explain karein ki MySQL `ERROR 1442` kyu throw karta hai agar table `T` par laga trigger usi table `T` par `UPDATE` execute kare. Same-table mutation safely kaise achieve kiya ja sakta hai?

---

## 11. Interview Questions

### Q1: What is the difference between the `NEW` and `OLD` pseudo-records in MySQL triggers?
**Answer**:
* **`NEW`** row ke aane wale naye state ko represent karta hai. Ye `INSERT` aur `UPDATE` triggers mein available hota hai. `BEFORE INSERT` aur `BEFORE UPDATE` triggers mein `NEW` ke columns ko modify kiya ja sakta hai (`SET NEW.col = value`) taaki data disk par physically write hone se pehle sanitize ya transform ho sake.
* **`OLD`** modification se pehle ke purane row state ko represent karta hai. Ye `UPDATE` aur `DELETE` triggers mein available hota hai, aur strictly read-only hota hai.
Ek `UPDATE` trigger mein `OLD` (pre-update state) aur `NEW` (post-update state) dono ek sath accessible hote hain, jisse field-level delta comparisons aasani se kiye ja sakte hain.

### Q2: Why does MySQL prohibit a trigger from modifying the table upon which it is defined?
**Answer**: Triggering table ko usi ke trigger ke andar se modify karne se **infinite recursion** ka khatra paida ho jata hai. For example, agar `orders` table ka ek `AFTER UPDATE` trigger `orders` par hi ek aur `UPDATE` statement chala de, toh wo update usi trigger ko dobara fire karega, jo fir ek aur update chalayega. Is tarah ek endless loop ban jayega jo server memory aur stack space ko exhaust kar dega. Is problem ko prevent karne ke liye MySQL strictly Error 1442 enforce karta hai aur triggering table par kisi bhi direct DML operation ko forbid karta hai.

### Q3: How do you raise a custom runtime exception inside a MySQL trigger to abort an illegal transaction?
**Answer**: Custom exception raise karne ke liye **`SIGNAL`** statement ke sath SQLState `'45000'` (jo unhandled user-defined exceptions ke liye ANSI standard code hai) use kiya jata hai:
```sql
SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Validation Failed: Custom Error Description';
```
Jab `SIGNAL` execute hota hai, MySQL immediately execution halt karta hai, active statement ko abort kar deta hai, transaction ke uncommitted changes ko rollback kar deta hai, aur calling client ko custom error message aur error code 1644 return karta hai.

---

## 12. Quick Revision

* **Triggers** automated event handlers hote hain jo `INSERT`, `UPDATE`, ya `DELETE` par execute hote hain.
* **`BEFORE`** triggers write operations se pehle chalte hain (validation aur `NEW` modify karne ke liye best); **`AFTER`** triggers writes ke baad chalte hain (audit logging ke liye best).
* **`NEW`** mein incoming row values hoti hain; **`OLD`** mein pre-modification values hoti hain.
* Invalid transactions ko reject karne ke liye **`SIGNAL SQLSTATE '45000'`** use karein.
* Triggers **usi table ko modify nahi kar sakte jis par wo defined hote hain** (Error 1442).
* High-throughput tables par transaction lock contention se bachne ke liye triggers ko hamesha lightweight rakhein.
