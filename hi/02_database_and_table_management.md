# Chapter 02 — Database & Table Management (DDL) (Database aur Table Management)

---

## 1. What is it? (Ye Kya Hai?)

**Data Definition Language (DDL)** SQL commands ka wo core set hai jo kisi database aur uske database objects ke structural architecture (dhancha) ko define karne, alter (modify) karne aur delete karne ke liye use hota hai.

Agar ek line me kahein, to DDL commands database ke un "skeletons" ya blueprints ko manage karte hain jinke andar hamara actual data rows ke form me rehta hai. Jab bhi aap MySQL me koi DDL command execute karte hain (jaise naya database banana, table me column add karna ya koi index drop karna), to MySQL seedhe apne internal data dictionary aur storage engine ke metadata ko update karta hai.

MySQL ke default **InnoDB** storage engine me, lagbhag sabhi DDL operations **implicit commit semantics** ke sath execute hote hain: iska matlab hai ki agar aapke current connection session me koi open transaction chal raha tha, to DDL run hote hi wo transaction automatically commit ho jata hai. Aur sabse important baat — DDL se kiye gaye structural changes ko standard `ROLLBACK` statement se undo nahi kiya ja sakta!

Core DDL statements ye hain:
* `CREATE`: Naya database, table, view ya index instantiate (create) karne ke liye.
* `ALTER`: Kisi existing database object ke structure ko bina data delete kiye in-place modify karne ke liye.
* `DROP`: Kisi object aur uske sath associated sabhi data pages ko disk se permanently destroy karne ke liye.
* `TRUNCATE`: Table ke sabhi records ko superfast speed se purge (delete) karne ke liye. Ye storage pages ko deallocate karke high-water mark aur auto-increment ko reset kar deta hai, jabki table ka structure intact rehta hai.
* `RENAME`: Kisi table ya database object ka naam cleanly change karne ke liye.

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

Real-world software applications lagatar evolve hoti rehti hain, jiske liye DDL ka use mandatory ho jata hai:

1. **Initial Provisioning (Naya Setup Banana)**: Jab aap naye application features build karte hain, to aapko isolated schemas aur proper character encoding wa storage engine ke sath relational tables banani padti hain.
2. **Schema Migration & Evolution (Live Database Update Karna)**: Jaise-jaise application scale hoti hai, database engineers ko existing data ko lose kiye bina naye columns add karne padte hain, column data types expand karne padte hain (jaise `VARCHAR(50)` ko badhakar `VARCHAR(100)` karna) ya unused columns ko deprecate karna padta hai.
3. **Safe Script Automation (CI/CD Deployment)**: Automated deployment scripts me `IF EXISTS` aur `IF NOT EXISTS` jaise guard clauses use karne se scripts idempotent ban jaate hain, yani agar wo dobara execute hon to system crash nahi hota.
4. **Storage & Lifecycle Management (Disk Space Bachana)**: Staging tables ko discard karne ya testing databases ko clean karne ke liye `DROP` aur `TRUNCATE` ka use karke disk storage ko instantly reclaim kiya jata hai.

---

## 3. Syntax

### Database Management
```sql
-- Create a database with UTF-8 character encoding and case-insensitive collation
CREATE DATABASE [IF NOT EXISTS] database_name
  [CHARACTER SET utf8mb4]
  [COLLATE utf8mb4_0900_ai_ci];

-- Delete a database and all its contents
DROP DATABASE [IF EXISTS] database_name;
```

### Table Creation & Duplication
```sql
-- Basic Table Creation
CREATE TABLE [IF NOT EXISTS] table_name (
    column_name_1 data_type [CONSTRAINTS],
    column_name_2 data_type [CONSTRAINTS],
    ...
    [TABLE_CONSTRAINTS]
) ENGINE = InnoDB;

-- Create Table As Select (CTAS) - creates table and copies matching rows
CREATE TABLE new_table_name AS
SELECT column1, column2 FROM existing_table WHERE condition;

-- Create an empty structural clone of an existing table
CREATE TABLE cloned_table LIKE existing_table;
```

### Altering Tables
```sql
-- 1. Add a new column (optionally specifying position: FIRST or AFTER existing_col)
ALTER TABLE table_name
ADD COLUMN new_column_name data_type [CONSTRAINTS] [FIRST | AFTER existing_column];

-- 2. Drop an existing column
ALTER TABLE table_name
DROP COLUMN column_name;

-- 3. Modify a column's datatype or constraints without changing its name
ALTER TABLE table_name
MODIFY COLUMN column_name new_data_type [CONSTRAINTS];

-- 4. Change (rename) a column and optionally alter its datatype
ALTER TABLE table_name
CHANGE COLUMN old_column_name new_column_name new_data_type [CONSTRAINTS];

-- 5. Rename a table
RENAME TABLE old_table_name TO new_table_name;
-- Alternative syntax:
-- ALTER TABLE old_table_name RENAME TO new_table_name;
```

### Purging & Destroying Tables
```sql
-- Purge all records, reset auto-increment, retain structure (Fast DDL)
TRUNCATE TABLE table_name;

-- Permanently destroy table structure and all data
DROP TABLE [IF EXISTS] table_name;
```

---

## 4. Basic Example

Aaiye ek temporary sandbox staging table create karte hain aur uske structure ko alter karke dekhte hain:

```sql
USE sql_mastery;

-- Create a simple staging table
CREATE TABLE IF NOT EXISTS staging_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Add a column after username
ALTER TABLE staging_users
ADD COLUMN is_verified BOOLEAN DEFAULT FALSE AFTER username;

-- Modify the email column length
ALTER TABLE staging_users
MODIFY COLUMN email VARCHAR(150) NOT NULL;

-- Rename the username column to handle
ALTER TABLE staging_users
CHANGE COLUMN username user_handle VARCHAR(50) NOT NULL;

-- Clean up
DROP TABLE staging_users;
```

---

## 5. Real-World Example

Maan lijiye ek business requirement aati hai jisme `customers` table ke andar `affiliate_code` add karna hai, uski position `loyalty_points` ke baad rakhni hai, default value set karni hai aur decommissioned (inactive) users ke liye ek archive clone table taiyar karni hai:

```sql
USE sql_mastery;

-- Step 1: Add affiliate_code to customers table, positioned after loyalty_points
ALTER TABLE customers
ADD COLUMN affiliate_code VARCHAR(20) DEFAULT NULL AFTER loyalty_points;

-- Step 2: Modify affiliate_code to ensure it defaults to 'STANDARD'
ALTER TABLE customers
MODIFY COLUMN affiliate_code VARCHAR(20) NOT NULL DEFAULT 'STANDARD';

-- Step 3: Create an archive clone of the customers table for decommissioned users
CREATE TABLE customers_archive LIKE customers;

-- Step 4: Verify the schema of both the active table and its clone
DESC customers;
DESC customers_archive;

-- Step 5: Remove the temporary affiliate_code from customers to maintain base state
ALTER TABLE customers
DROP COLUMN affiliate_code;

-- Step 6: Drop the archive clone
DROP TABLE customers_archive;
```

---

## 6. Step-by-Step Explanation

Aaiye upar diye gaye real-world workflow ke har step ki internal working ko deeply samajhte hain:

1. `ALTER TABLE customers ADD COLUMN affiliate_code VARCHAR(20) DEFAULT NULL AFTER loyalty_points;`:
   * **Metadata Lock**: MySQL table par ek Exclusive Metadata Lock acquire karta hai taki alter hone ke dauran schema state consistent rahe.
   * **Online DDL Engine**: InnoDB (`ALGORITHM=INPLACE`) ke under, MySQL table metadata ko update karta hai aur clustered index leaf pages me column offset add karta hai bina poori table ko rewrite ya rebuild kiye.
   * **Positional Pointer**: `AFTER loyalty_points` clause storage engine ko batata hai ki naye column ka logical order table me exactly `loyalty_points` ke right baad set karna hai.
2. `CREATE TABLE customers_archive LIKE customers;`:
   * Ye statement parent table `customers` ke structural schema definition ko read karta hai — including sabhi column data types, primary keys, auto-increment settings aur unique indexes — aur ek completely empty replica table `customers_archive` create kar deta hai. Dhyan rahe, ye data rows ko copy nahi karta, sirf structure copy karta hai.
3. `ALTER TABLE customers DROP COLUMN affiliate_code;`:
   * Storage engine data pages ko scan karta hai, us column ki storage space ko reusable mark kar deta hai aur internal system catalog se column metadata ko delete kar deta hai.
4. `DROP TABLE customers_archive;`:
   * Disk par maujood table ki physical `.ibd` tablespace file ko delete kar deta hai (ya shared tablespace se pages free karta hai), jisse memory aur disk storage turant operating system ko wapas mil jaati hai.

---

## 7. Expected Result

Column add karne ke baad `DESC customers;` ka output:

```
+----------------+---------------+------+-----+-----------+-------------------+
| Field          | Type          | Null | Key | Default   | Extra             |
+----------------+---------------+------+-----+-----------+-------------------+
| customer_id    | int           | NO   | PRI | NULL      | auto_increment    |
| first_name     | varchar(50)   | NO   |     | NULL      |                   |
| last_name      | varchar(50)   | NO   |     | NULL      |                   |
| email          | varchar(100)  | NO   | UNI | NULL      |                   |
| phone          | varchar(20)   | YES  |     | NULL      |                   |
| city           | varchar(50)   | NO   |     | NULL      |                   |
| state          | varchar(50)   | YES  |     | NULL      |                   |
| country        | varchar(50)   | NO   |     | NULL      |                   |
| loyalty_points | int           | YES  |     | 0         |                   |
| affiliate_code | varchar(20)   | NO   |     | STANDARD  |                   |
| registered_at  | date          | NO   |     | NULL      |                   |
| is_active      | tinyint(1)    | YES  |     | 1                 |                   |
| created_at     | timestamp     | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+----------------+---------------+------+-----+-----------+-------------------+
```

---

## 8. Common Mistakes

1. **`MODIFY COLUMN` Aur `CHANGE COLUMN` Me Confuse Hona**:
   * *Mistake*: `ALTER TABLE customers MODIFY COLUMN old_col new_col VARCHAR(50);`
   * *Error*: Syntax error!
   * *Rule*: Agar aapko sirf data type, nullability ya default value change karni hai aur column ka naam wahi rakhna hai, to `MODIFY` use karein. Agar aapko column rename karna hai, to `CHANGE` use karein (jisme old name aur new name dono ke sath poora data type specify karna zaroori hota hai).
2. **`TRUNCATE` Aur `DELETE FROM table;` Ko Ek Jaisa Samajhna**:
   * *Mistake*: `DELETE FROM orders;` chalakar ye expect karna ki auto-increment counter reset ho jayega.
   * *Distinction*: `DELETE` ek DML command hai jo rows ko one-by-one delete karta hai, row-level triggers execute karta hai aur auto-increment counter ko reset nahi karta. Jabki `TRUNCATE` ek DDL command hai jo physical storage pages ko deallocate karta hai, `DELETE` triggers fire nahi karta aur `AUTO_INCREMENT` sequence ko wapas 1 par reset kar deta hai.
3. **Foreign Key Se Referenced Table Ko Directly Drop Karna**:
   * *Mistake*: `DROP TABLE customers;` execute karna jabki child table `orders` me active foreign key `customers(customer_id)` ko point kar rahi ho.
   * *Error*: `ERROR 3730 (HY000): Cannot drop table 'customers' referenced by a foreign key constraint 'fk_orders_customer' on table 'orders'.`
   * *Rule*: Parent table ko drop karne se pehle child table ko drop karein, ya pehle child table ki foreign key constraint ko drop karein.
4. **Column Ki Position Specify Na Karna**:
   * MySQL me agar aap `ADD COLUMN` karte waqt `FIRST` ya `AFTER existing_col` mention nahi karte, to default behavior ke according naya column table ke sabse last me append ho jata hai.

---

## 9. Best Practices

1. **Hamesha `utf8mb4` Character Set Use Karein**:
   * Naye databases hamesha `CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci` ke sath create karein. MySQL ka purana `utf8` character set deprecated ho chuka hai kyunki wo max 3 bytes support karta tha, jiski wajah se emojis aur complete Unicode characters store karne par error aata tha.
2. **DDL Scripts Me Hamesha Guard Clauses Use Karein**:
   * Scripts ko re-run safe aur idempotent banane ke liye hamesha `CREATE DATABASE IF NOT EXISTS`, `CREATE TABLE IF NOT EXISTS`, aur `DROP TABLE IF EXISTS` syntax ka use karein.
3. **Constraints Aur Foreign Keys Ko Descriptive Names Dein**:
   * Constraints ko explicitly name karein (jaise `CONSTRAINT fk_orders_customer`, `CONSTRAINT chk_price_positive`) bajaye system generated anonymous IDs (`orders_ibfk_1`) par rely karne ke. Isse debugging aur future schema migrations bahut aasan ho jaate hain.
4. **Large Production Tables Par DDL Locking Ka Dhyan Rakhein**:
   * Millions of rows wali active production tables par DDL run karne se table lock ho sakti hai ya high disk I/O ho sakta hai. MySQL 8.0 me `ALGORITHM=INPLACE, LOCK=NONE` options ya production tools jaise `pt-online-schema-change` ka use karein.

---

## 10. Practice Questions

### Easy
1. `corporate_hr` naam ka ek naya database `utf8mb4` character set ke sath create karne ke liye SQL statement likhiye.
2. `job_titles` naam ki table create karne ke liye statement likhiye jisme `title_id INT AUTO_INCREMENT PRIMARY KEY` aur `title_name VARCHAR(50) NOT NULL` ho.
3. `job_titles` table ko delete karne ke liye command likhiye, lekin sirf tabhi jab wo currently exist karti ho.

### Medium
4. `job_titles` table me ek naya column `min_salary DECIMAL(10,2) NOT NULL DEFAULT 30000.00` add karne ke liye `ALTER TABLE` statement likhiye jo directly `title_name` ke baad position ho.
5. Ek `ALTER TABLE` statement likhiye jo `title_name` column ki length `VARCHAR(50)` se badhakar `VARCHAR(100)` kar de aur sath me `NOT NULL` constraint ko barkarar rakhe.
6. `job_titles` table ka naam badalkar `company_roles` karne ke liye ek single SQL statement likhiye.

### Difficult
7. Ek complete SQL sequence likhiye jo: `inventory_staging` table create kare; teen columns specific position me add kare (`sku` as FIRST, `quantity` after `sku`, `warehouse_code` after `quantity`); `quantity` column par CHECK constraint lagaye taki negative numbers allow na hon; aur aakhri me table ko truncate kare.
8. `CREATE TABLE t2 AS SELECT * FROM t1;` aur `CREATE TABLE t2 LIKE t1;` ke beech exact difference explain kijiye. Kaun sa method table ke indexes aur auto-increment properties ko preserve karta hai?

---

## 11. Interview Questions

### Q1: `TRUNCATE TABLE`, `DROP TABLE`, aur `DELETE FROM TABLE` ke beech mechanical difference kya hota hai?
**Answer**:
* `DELETE` ek DML operation hai. Ye rows ko one-by-one delete karta hai, har deletion ko transaction ke Undo aur Redo log me record karta hai, `DELETE` triggers ko invoke karta hai, aur iska operation transaction me rollback kiya ja sakta hai. Ye disk allocation ke high-water mark ya auto-increment counter ko reset nahi karta.
* `TRUNCATE` ek DDL operation hai. Ye table ke underlying data storage pages ko directly deallocate kar deta hai, row-level triggers ko bypass karta hai, auto-increment sequence ko 1 par reset karta hai, aur large tables par superfast execute hota hai.
* `DROP` ek DDL operation hai. Ye table ka schema, constraints, indexes, triggers aur disk par maujood physical files sabhi ko permanently delete kar deta hai.

### Q2: MySQL me transaction ke andar `ALTER TABLE` ya `CREATE TABLE` jaisi DDL statements ko rollback kyun nahi kiya ja sakta?
**Answer**: MySQL ke architecture me sabhi DDL operations **implicit commit** trigger karte hain. Jab bhi koi DDL statement execute hone wala hota hai, to MySQL server us connection ke open transaction par automatically internal `COMMIT` call kar deta hai. Aur statement execute hone ke baad bhi ek implicit `COMMIT` hota hai. Iska reason data dictionary aur system catalog ko crash-consistent rakhna hai, lekin iska consequence ye hai ki DDL changes ko standard `ROLLBACK` statement se undo nahi kiya ja sakta.

### Q3: `ALTER TABLE ... MODIFY` aur `ALTER TABLE ... CHANGE` me kya difference hota hai?
**Answer**: `MODIFY` clause column ke data type, nullability, default value ya relative position ko update kar sakta hai, lekin column ka naam change **nahi** kar sakta. Dusri taraf, `CHANGE` clause me pehle purana column name aur fir naya column name specify karna hota hai, jisse aap column ko rename karne ke sath-sath uska data type aur attributes bhi usi command me modify kar sakte hain.

---

## 12. Quick Revision

* **DDL** statements (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`) database structure ko modify karte hain aur MySQL me implicit transaction commit trigger karte hain.
* Global Unicode aur emoji support ke liye schemas hamesha `utf8mb4` character set ke sath create karein.
* Table me specific column ordering ke liye `ALTER TABLE ... ADD COLUMN ... FIRST | AFTER <col>` syntax ka use karein.
* Column type/constraints in-place modify karne ke liye `MODIFY` use karein; column rename karne ke liye `CHANGE` use karein.
* `TRUNCATE` data pages ko deallocate karke auto-increment reset karta hai; `DROP` poore table structure ko disk se permanently destroy karta hai.
