# Chapter 02 — Database और Table Management (DDL)

---

## 1. What is it? (यह क्या है?)

**Data Definition Language (DDL)** SQL कमांड्स का वह महत्वपूर्ण सेट है जो किसी डेटाबेस और उसके ऑब्जेक्ट्स (objects) के स्ट्रक्चरल आर्किटेक्चर यानी पूरे ढाँचे को बनाने (define), बदलने (alter) और मिटाने (deconstruct) के लिए जिम्मेदार होता है।

सीधे शब्दों में कहें तो, DDL कमांड्स आपके डेटाबेस का "कंकाल" (skeleton) या ब्लूप्रिंट तैयार करती हैं, जिसके अंदर आपके डेटा रिकॉर्ड्स सुरक्षित रहते हैं। जब भी आप MySQL में कोई DDL कमांड चलाते हैं (जैसे नया डेटाबेस बनाना, किसी टेबल में नया कॉलम जोड़ना, या कोई इंडेक्स डिलीट करना), तो MySQL सीधे डेटा डिक्शनरी और स्टोरेज इंजन के मेटाडेटा में बदलाव करता है।

MySQL के डिफ़ॉल्ट **InnoDB** स्टोरेज इंजन में ज़्यादातर DDL ऑपरेशन्स **Implicit Commit** की तरह काम करते हैं। इसका मतलब यह है कि DDL कमांड चलते ही आपके मौजूदा सेशन का खुला हुआ ट्रांजेक्शन अपने आप Commit हो जाता है, और किए गए स्ट्रक्चरल बदलाव को सामान्य `ROLLBACK` कमांड से वापस (undo) नहीं किया जा सकता।

मुख्य DDL स्टेटमेंट्स ये हैं:
* `CREATE`: नया डेटाबेस, टेबल, व्यू या इंडेक्स तैयार करता है।
* `ALTER`: किसी पहले से मौजूद डेटाबेस ऑब्जेक्ट के ढाँचे को बदलता है (बिना उसके अंदर मौजूद डेटा को डिलीट किए)।
* `DROP`: किसी ऑब्जेक्ट (टेबल या डेटाबेस) और उसके डिस्क पर मौजूद सारे डेटा पेजों को हमेशा के लिए पूरी तरह नष्ट कर देता है।
* `TRUNCATE`: टेबल के सारे रिकॉर्ड्स को बिजली की तेज़ी से साफ़ (purge) कर देता है, उसके स्टोरेज पेजों को खाली कर देता है और `AUTO_INCREMENT` को रीसेट कर देता है, लेकिन टेबल का स्ट्रक्चर वैसा का वैसा बना रहता है।
* `RENAME`: किसी टेबल या डेटाबेस ऑब्जेक्ट का नाम साफ़-सुथरे तरीके से बदलने के लिए इस्तेमाल होता है।

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

सॉफ्टवेयर ऍप्लिकेशन्स का आर्किटेक्चर समय के साथ लगातार बदलता और बड़ा होता रहता है:

1. **Initial Provisioning (शुरुआती सेटअप)**: जब भी कोई नया फीचर बनता है, तो हमें नए आइसोलेटेड स्कीमा और रिलेशनल टेबल्स बनानी पड़ती हैं, जिनमें सही कैरेक्टर एन्कोडिंग (`utf8mb4`) और स्टोरेज इंजन (`InnoDB`) कॉन्फ़िगर किया जाता है।
2. **Schema Migration & Evolution (स्कीमा में बदलाव)**: जैसे-जैसे प्रोडक्ट ग्रो करता है, डेटाबेस एडमिनिस्ट्रेटर को नए कॉलम्स जोड़ने पड़ते हैं, फील्ड साइज बढ़ाना पड़ता है (जैसे `VARCHAR(50)` से बढ़ाकर `VARCHAR(100)` करना), या अनचाहे कॉलम्स को हटाना पड़ता है — वो भी बिना पुराने डेटा को नुकसान पहुँचाए।
3. **Safe Script Automation (ऑटोमेशन और CI/CD)**: `IF EXISTS` और `IF NOT EXISTS` जैसे गार्ड क्लॉज़ेस का इस्तेमाल करने से हमारी ऑटोमेटेड CI/CD डिप्लॉयमेंट स्क्रिप्ट्स idempotently चलती हैं — यानी स्क्रिप्ट दोबारा चलने पर कभी क्रैश नहीं होतीं।
4. **Storage & Lifecycle Management (स्टोरेज की बचत)**: जब टेस्टिंग खत्म हो जाती है या स्टेजिंग टेबल्स का काम पूरा हो जाता है, तो `DROP` और `TRUNCATE` की मदद से हम डिस्क स्पेस तुरंत खाली (reclaim) कर लेते हैं।

---

## 3. Syntax (सिंटैक्स)

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

## 4. Basic Example (बेसिक उदाहरण)

आइए एक अस्थायी सैंडबॉक्स (staging table) बनाकर उस पर DDL ऑपरेशन्स का अभ्यास करें:

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

## 5. Real-World Example (रियल-वर्ल्ड उदाहरण)

मान लीजिए हमारे ई-कॉमर्स बिजनेस में मार्केटिंग टीम की मांग आती है कि `customers` टेबल में एक `affiliate_code` जोड़ना है, उसे एक तय स्थान पर रखना है, उसका डिफ़ॉल्ट मान सेट करना है, और बंद हो चुके पुराने कस्टमर्स के लिए एक अलग आर्काइव (archive) टेबल तैयार करनी है:

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

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

1. `ALTER TABLE customers ADD COLUMN affiliate_code VARCHAR(20) DEFAULT NULL AFTER loyalty_points;`:
   * **Metadata Lock**: MySQL सबसे पहले `customers` टेबल पर एक एक्सक्लूसिव मेटाडेटा लॉक (Exclusive Metadata Lock) लेता है ताकि स्ट्रक्चर बदलते समय कोई दूसरा यूज़र टकराव न करे।
   * **Online DDL Engine**: InnoDB स्टोरेज इंजन (`ALGORITHM=INPLACE`) के तहत MySQL टेबल की परिभाषा को अपडेट करता है और पूरी टेबल को दोबारा बनाए (rebuild) बिना, मौजूदा क्लस्टर्ड इंडेक्स के लीफ़ पेजों में कॉलम का ऑफ़सेट जोड़ देता है।
   * **Positional Pointer**: `AFTER loyalty_points` क्लॉज़ स्टोरेज इंजन को बताता है कि नए कॉलम का लॉजिकल क्रम ठीक `loyalty_points` के बाद सेट किया जाए।
2. `CREATE TABLE customers_archive LIKE customers;`:
   * यह कमांड `customers` टेबल का पूरा स्कीमा ढाँचा पढ़ती है — जिसमें सभी डेटा टाइप्स, Primary Key, और Unique इंडेक्सेस शामिल हैं — और बिल्कुल वैसी ही एक खाली क्लोन टेबल `customers_archive` नाम से बना देती है। ध्यान दीजिए, यह सिर्फ स्ट्रक्चर कॉपी करती है, अंदर का डेटा नहीं।
3. `ALTER TABLE customers DROP COLUMN affiliate_code;`:
   * यह स्टोरेज पेजों को स्कैन करके उस कॉलम की जगह को 'reusable' मार्क कर देती है और MySQL के अंदरूनी डेटा कैटलॉग से उस कॉलम का मेटाडेटा डिलीट कर देती है।
4. `DROP TABLE customers_archive;`:
   * यह टेबल की `.ibd` टेबल्सपेस फाइल को डिस्क से हमेशा के लिए डिलीट कर देती है, जिससे मेमोरी और डिस्क ब्लॉक्स तुरंत ऑपरेटिंग सिस्टम को वापस मिल जाते हैं।

---

## 7. Expected Result (अपेक्षित परिणाम / Expected Output)

नया कॉलम जोड़ने के बाद जब आप `DESC customers;` चलाएंगे, तो आउटपुट इस तरह दिखेगा:

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

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **`MODIFY COLUMN` और `CHANGE COLUMN` में कन्फ्यूजन**:
   * *गलती*: `ALTER TABLE customers MODIFY COLUMN old_col new_col VARCHAR(50);`
   * *एरर*: Syntax error!
   * *नियम*: जब आपको कॉलम का नाम **वही रखना हो** और सिर्फ उसका डेटा टाइप, nullability या डिफ़ॉल्ट वैल्यू बदलनी हो, तो `MODIFY` का उपयोग करें। लेकिन जब आपको कॉलम का **नाम बदलना हो**, तब `CHANGE` का उपयोग करें (इसमें पुराना नाम और नया नाम दोनों लिखने पड़ते हैं, साथ में पूरा डेटा टाइप भी)।
2. **`TRUNCATE` और `DELETE FROM table;` को एक जैसा समझना**:
   * *गलती*: `DELETE FROM orders;` चलाकर यह सोचना कि `AUTO_INCREMENT` आईडी फिर से 1 से शुरू हो जाएगी।
   * *फर्क*: `DELETE` एक DML ऑपरेशन है जो एक-एक रो को डिलीट करता है, हर रो पर ट्रिगर चलाता है और ऑटो-इंक्रीमेंट काउंटर को रीसेट नहीं करता। जबकि `TRUNCATE` एक DDL ऑपरेशन है जो पूरे डेटा पेजों को एक झटके में खाली करता है, कोई ट्रिगर नहीं चलाता और `AUTO_INCREMENT` को वापस 1 पर रीसेट कर देता है।
3. **Foreign Key से जुड़ी टेबल को सीधे `DROP` करना**:
   * *गलती*: `DROP TABLE customers;` चलाना जबकि `orders` टेबल में Foreign Key अभी भी `customers(customer_id)` को पॉइंट कर रही हो।
   * *एरर*: `ERROR 3730 (HY000): Cannot drop table 'customers' referenced by a foreign key constraint 'fk_orders_customer' on table 'orders'.`
   * *नियम*: हमेशा पहले चाइल्ड टेबल (orders) को ड्रॉप करें या उसकी Foreign Key हटाएं, उसके बाद ही पैरेंट टेबल (customers) को ड्रॉप किया जा सकता है।
4. **कॉलम की पोजीशन तय न करना**:
   * MySQL में यदि आप `ADD COLUMN` करते समय `FIRST` या `AFTER col` नहीं लिखते हैं, तो नया कॉलम डिफ़ॉल्ट रूप से टेबल के सबसे आखिरी स्थान पर जुड़ता है।

---

## 9. Best Practices (बेस्ट प्रैक्टिसेस)

1. **हमेशा `utf8mb4` Character Set का उपयोग करें**:
   * नया डेटाबेस बनाते समय हमेशा `CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci` का इस्तेमाल करें। पुराना MySQL `utf8` डिप्रिकेट हो चुका है क्योंकि वह केवल 3 बाइट्स तक सपोर्ट करता था, जिससे मॉडर्न इमोजी और चार-बाइट वाले अंतरराष्ट्रीय कैरेक्टर्स सेव नहीं हो पाते थे।
2. **DDL स्क्रिप्ट्स में हमेशा Guard Clauses का इस्तेमाल करें**:
   * ऑटोमेशन और माइग्रेशन स्क्रिप्ट्स में हमेशा `CREATE DATABASE IF NOT EXISTS`, `CREATE TABLE IF NOT EXISTS`, और `DROP TABLE IF EXISTS` लिखें ताकि स्क्रिप्ट्स बिना एरर दिए बार-बार सुरक्षित रूप से चल सकें।
3. **Constraints और Foreign Keys को हमेशा नाम दें**:
   * कंस्ट्रेंट्स को हमेशा स्पष्ट नाम दें (जैसे `CONSTRAINT fk_orders_customer`, `CONSTRAINT chk_price_positive`), MySQL को ऑटो-जेनरेटेड नाम (`orders_ibfk_1`) न बनाने दें। इससे भविष्य में स्कीमा बदलने और डिबग करने में बहुत आसानी होती है।
4. **प्रोडक्शन में बड़ी टेबल्स पर DDL लॉकिंग का ध्यान रखें**:
   * करोड़ों रोज़ वाली बड़ी टेबल्स पर सीधे `ALTER TABLE` चलाने से टेबल लॉक हो सकती है और प्रोडक्शन ट्रैफिक रुक सकता है। इसके लिए MySQL 8.0 के `ALGORITHM=INPLACE, LOCK=NONE` या `pt-online-schema-change` जैसे टूल्स का उपयोग करें।

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. `corporate_hr` नाम से एक नया डेटाबेस बनाने के लिए SQL स्टेटमेंट लिखें जो `utf8mb4` कैरेक्टर सेट का उपयोग करता हो।
2. `job_titles` नाम से एक टेबल बनाने की स्टेटमेंट लिखें जिसमें `title_id INT AUTO_INCREMENT PRIMARY KEY` और `title_name VARCHAR(50) NOT NULL` हो।
3. `job_titles` टेबल को केवल तभी डिलीट करने की कमांड लिखें जब वह पहले से मौजूद हो।

### Medium (मध्यम)
4. `job_titles` टेबल में `title_name` के ठीक बाद `min_salary DECIMAL(10,2) NOT NULL DEFAULT 30000.00` नाम का कॉलम जोड़ने के लिए `ALTER TABLE` स्टेटमेंट लिखें।
5. एक ऐसी `ALTER TABLE` स्टेटमेंट लिखें जो `title_name` को `VARCHAR(50)` से बढ़ाकर `VARCHAR(100)` कर दे और साथ ही `NOT NULL` कंस्ट्रेंट भी बरकरार रखे।
6. `job_titles` टेबल का नाम बदलकर `company_roles` करने के लिए सिंगल स्टेटमेंट लिखें।

### Difficult (कठिन)
7. एक ऐसा SQL सीक्वेंस लिखें जो `inventory_staging` नाम की टेबल बनाए, उसमें तय क्रम में तीन कॉलम्स जोड़े (`sku` सबसे पहले FIRST, `quantity` sku के बाद, `warehouse_code` quantity के बाद), `CHECK` कंस्ट्रेंट लगाकर सुनिश्चित करे कि quantity नेगेटिव न हो सके, और अंत में टेबल को truncate करे।
8. `CREATE TABLE t2 AS SELECT * FROM t1;` और `CREATE TABLE t2 LIKE t1;` के बीच मुख्य अंतर समझाइए। इनमें से कौन सा तरीका इंडेक्स और ऑटो-इंक्रीमेंट प्रॉपर्टीज को सुरक्षित रखता है?

---

## 11. Interview Questions (इंटरव्यू प्रश्न और उत्तर)

### Q1: `TRUNCATE TABLE`, `DROP TABLE`, और `DELETE FROM TABLE` में क्या तकनीकी अंतर है?
**Answer**:
* `DELETE` एक **DML** ऑपरेशन है। यह एक-एक करके पंक्तियों (rows) को हटाता है, हर डिलीशन को ट्रांजेक्शन के Undo और Redo लॉग में लिखता है, `DELETE` ट्रिगर्स को फायर करता है, और इसे `ROLLBACK` किया जा सकता है। यह कभी भी ऑटो-इंक्रीमेंट काउंटर को रीसेट नहीं करता।
* `TRUNCATE` एक **DDL** ऑपरेशन है। यह सीधे स्टोरेज पेजों को deallocate (खाली) कर देता है, रो ट्रिगर्स को बायपास करता है, `AUTO_INCREMENT` को तुरंत 1 पर रीसेट करता है, और करोड़ों रोज़ वाली टेबल्स पर भी पलक झपकते ही चल जाता है।
* `DROP` भी एक **DDL** ऑपरेशन है। यह टेबल के स्कीमा, कंस्ट्रेंट्स, ट्रिगर्स, इंडेक्स और डिस्क पर मौजूद पूरी फिजिकल फाइल्स को हमेशा के लिए मिटा देता है।

### Q2: MySQL में किसी ट्रांजेक्शन के अंदर चलाए गए DDL स्टेटमेंट्स (जैसे `ALTER TABLE` या `CREATE TABLE`) को `ROLLBACK` क्यों नहीं किया जा सकता?
**Answer**: MySQL के आर्किटेक्चर में सभी DDL ऑपरेशन्स **Implicit Commit** ट्रिगर करते हैं। यानी जब भी आप कोई DDL कमांड चलाते हैं, तो MySQL सर्वर उस स्टेटमेंट को चलाने से ठीक पहले और ठीक बाद अपने आप अंदरूनी तौर पर `COMMIT` कॉल कर देता है। यह डेटा डिक्शनरी की कंसिस्टेंसी बनाए रखने के लिए ज़रूरी है, लेकिन इसका नतीजा यह होता है कि DDL के बाद `ROLLBACK` चलाने पर भी स्ट्रक्चरल बदलाव वापस नहीं हो सकते।

### Q3: `ALTER TABLE ... MODIFY` और `ALTER TABLE ... CHANGE` में क्या अंतर है?
**Answer**: `MODIFY` कॉलम के डेटा टाइप, nullability, डिफ़ॉल्ट वैल्यू या उसकी पोजीशन को उसी जगह बदल सकता है, लेकिन यह कॉलम का नाम **नहीं बदल सकता**। दूसरी तरफ, `CHANGE` के सिंटैक्स में आपको पहले पुराना कॉलम नाम और फिर नया कॉलम नाम दोनों देने पड़ते हैं, जिससे आप कॉलम का नाम भी बदल सकते हैं और साथ ही उसका डेटा टाइप और एट्रीब्यूट्स भी री-डिफाइन कर सकते हैं।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* **DDL** स्टेटमेंट्स (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`) डेटाबेस के स्ट्रक्चर को बदलते हैं और MySQL में implicit transaction commit ट्रिगर करते हैं।
* सभी अंतरराष्ट्रीय भाषाओं और इमोजी के पूर्ण समर्थन के लिए हमेशा `utf8mb4` स्कीमा डिक्लेयर करें।
* कॉलम्स को अपनी मनचाही पोजीशन में जोड़ने के लिए `ALTER TABLE ... ADD COLUMN ... FIRST | AFTER <col>` का उपयोग करें।
* कॉलम के टाइप और कंस्ट्रेंट्स को इन-प्लेस बदलने के लिए `MODIFY` का और नाम बदलने के लिए `CHANGE` का इस्तेमाल करें।
* `TRUNCATE` डेटा पेजों को खाली करके बिजली की गति से रिकॉर्ड्स हटाता है और ऑटो-इंक्रीमेंट रीसेट करता है; `DROP` पूरी टेबल को ही जड़ से खत्म कर देता है।
