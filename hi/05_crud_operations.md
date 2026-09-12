# Chapter 05 — Data Manipulation: CRUD Operations

---

## 1. What is it? (यह क्या है?)

**CRUD** सॉफ्टवेयर डेवलपमेंट इंडस्ट्री का वह सबसे बुनियादी और मशहूर एक्रोनियम (acronym) है जो किसी भी डेटा-आधारित ऍप्लिकेशन के चार मुख्य स्तंभों (pillars) को दर्शाता है:
* **C**reate $\rightarrow$ `INSERT` (और इसके एडवांस्ड रूप: `INSERT IGNORE`, `ON DUPLICATE KEY UPDATE`, `REPLACE`)
* **R**ead $\rightarrow$ `SELECT`
* **U**pdate $\rightarrow$ `UPDATE`
* **D**elete $\rightarrow$ `DELETE`

रिलेशनल डेटाबेस मैनेजमेंट में, CRUD ऑपरेशन्स को **Data Manipulation Language (DML)** कहा जाता है। DDL कमांड्स जहाँ टेबल का ढाँचा (schema blueprint) तैयार करती हैं, वहीं DML स्टेटमेंट्स उन टेबल्स के अंदर मौजूद वास्तविक रिकॉर्ड्स (rows) के साथ छेड़छाड़ या बदलाव करते हैं।

MySQL के डिफ़ॉल्ट InnoDB स्टोरेज इंजन में सभी DML ऑपरेशन्स सख्त Transactional Boundaries के अंदर चलते हैं: जब भी आप कोई रो जोड़ते, बदलते या हटाते हैं, तो डिस्क पर स्थायी रूप से लिखने से पहले उन बदलावों को **Undo Log** (ताकि ज़रूरत पड़ने पर रोलबैक किया जा सके) और **Redo Log** (ताकि सर्वर क्रैश होने पर भी डेटा रिकवर हो सके) में दर्ज किया जाता है।

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Transactional Record Ingestion (डेटा को सुरक्षित जोड़ना)**: हाई-ट्रैफिक ऍप्लिकेशन्स को सिंगल इवेंट्स, बैच लोड्स, या लाखों रिकॉर्ड्स के मास इम्पोर्ट को बिना इंडेक्स करप्ट किए तेज़ी से इंसर्ट करने की ज़रूरत होती है।
2. **Idempotent Data Synchronization / UPSERT (स्मार्ट सिंक)**: जब हम बाहरी APIs या पेमेंट गेटवे से डेटा सिंक करते हैं, तो अक्सर हमें ऐसा ऑपरेशन चाहिए होता है जो रिकॉर्ड नया हो तो जोड़ दे (`INSERT`), और अगर पहले से मौजूद हो तो उसकी वैल्यूज अपडेट कर दे (`UPDATE`) — वो भी एक ही एटॉमिक क्वेरी में!
3. **Targeted State Mutation (सटीक बदलाव)**: बिज़नेस लॉजिक में आर्डर का स्टेटस 'Pending' से 'Delivered' करना हो, वॉलेट बैलेंस काटना हो, या नाम की स्पेलिंग ठीक करनी हो — इसके लिए `UPDATE` ज़रूरी है।
4. **Data Lifecycle Hygiene (डेटा की सफ़ाई)**: कैंसिल हो चुके कार्ट सेशंस, एक्सपायर हो चुके OTPs या टेस्ट रिकॉर्ड्स को `DELETE` करके हम डेटाबेस की स्टोरेज और परफॉरमेंस को हल्का रखते हैं।

---

## 3. Syntax (सिंटैक्स)

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

## 4. Basic Example (बेसिक उदाहरण)

आइए एक सैंडबॉक्स टेबल बनाकर उस पर CRUD का पूरा लाइफसाइकिल चलाकर देखते हैं:

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

## 5. Real-World Example (रियल-वर्ल्ड उदाहरण)

हमारे `sql_mastery` प्रोडक्शन डेटाबेस में, आइए एक पूरा बिज़नेस वर्कफ़्लो चलाकर देखते हैं:
1. नए कस्टमर को रजिस्टर करना (`CREATE`)।
2. `ON DUPLICATE KEY UPDATE` (UPSERT) का इस्तेमाल करके इन्वेंट्री स्टॉक अपडेट करना।
3. $1,000 से बड़े ऑर्डर्स देने वाले कस्टमर्स के लॉयल्टी पॉइंट्स बढ़ाना (`UPDATE`)।
4. डेमो कस्टमर रिकॉर्ड को सुरक्षित हटाना (`DELETE`)।

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

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

1. `INSERT INTO customers (...) VALUES (...)`:
   * SQL Parser यह जाँचता है कि सभी आवश्यक `NOT NULL` कॉलम्स (`first_name`, `last_name`, `email`, `city`, `country`, `registered_at`) क्वेरी में दिए गए हैं या नहीं।
   * स्टोरेज इंजन यह सुनिश्चित करता है कि `vikram.sharma@example.in` ईमेल पहले से टेबल में मौजूद न हो (`UNIQUE` कंस्ट्रेंट)।
   * ऑटो-इंक्रीमेंट लॉक मैकेनिज्म (`innodb_autoinc_lock_mode`) नया क्रमिक नंबर `customer_id` (जैसे `11`) असाइन करता है, रिकॉर्ड को B+ Tree के लीफ पेज में जोड़ता है, और Redo Log में एंट्री लिख देता है।
2. `INSERT ... ON DUPLICATE KEY UPDATE`:
   * MySQL सबसे पहले `product_id = 1` के लिए क्लस्टर्ड इंडेक्स में लुकअप करता है।
   * चूँकि रो पहले से मौजूद है, MySQL डुप्लीकेट की एरर `1062` देने के बजाय, प्रोडक्ट 1 की रो पर एक एक्सक्लूसिव रो-लेवल लॉक लेता है और `stock_quantity = stock_quantity + 10` का असाइनमेंट चलाकर स्टॉक 45 से बढ़ाकर 55 कर देता है।
3. `UPDATE customers c JOIN orders o ...`:
   * Query Optimizer `customers` और `orders` टेबल्स के बीच इनर जॉइन करता है।
   * केवल वही कस्टमर रोज़ लॉक और अपडेट की जाती हैं जिनके आर्डर की कंडीशन `total_amount > 1000.00 AND status = 'Delivered'` सच होती है। `SET` क्लॉज़ मौके पर ही `loyalty_points` बढ़ा देता है।
4. `DELETE FROM customers WHERE email = 'vikram.sharma@example.in'`:
   * ईमेल के यूनिक इंडेक्स के ज़रिए ठीक वही रो पहचानी जाती है। चूँकि इस नए कस्टमर का कोई आर्डर `orders` टेबल में नहीं बना था, इसलिए यह रो बिना किसी Foreign Key एरर के आसानी से डिलीट हो जाती है।

---

## 7. Expected Result (अपेक्षित परिणाम / Expected Output)

नया कस्टमर इंसर्ट करने के बाद `SELECT` क्वेरी का परिणाम:

```
+-------------+------------+-----------+--------------------------+----------------+---------------+
| customer_id | first_name | last_name | email                    | loyalty_points | registered_at |
+-------------+------------+-----------+--------------------------+----------------+---------------+
|          11 | Vikram     | Sharma    | vikram.sharma@example.in |            100 | 2026-09-09    |
+-------------+------------+-----------+--------------------------+----------------+---------------+
1 row in set (0.00 sec)
```

`ON DUPLICATE KEY UPDATE` के बाद प्रोडक्ट स्टॉक का परिणाम:

```
+------------+-----------------------+----------------+
| product_id | product_name          | stock_quantity |
+------------+-----------------------+----------------+
|          1 | Quantum Pro 15 Laptop |             55 |
+------------+-----------------------+----------------+
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **बिना `WHERE` क्लॉज़ के `UPDATE` या `DELETE` चला देना (डेवलपर्स का सबसे बड़ा डरावना सपना!)**:
   * *भयानक गलती*:
     ```sql
     UPDATE employees SET salary = 50000;
     ```
   * *परिणाम*: `WHERE` न लगाने से टेबल की **हर एक रो** अपडेट हो जाएगी! कंपनी के CEO से लेकर इंटर्न तक सबका वेतन 50,000 हो जाएगा!
   * *सुरक्षा उपाय*: हमेशा Safe Updates मोड ऑन रखें: `SET sql_safe_updates = 1;`। यह मोड ऐसी किसी भी `UPDATE` या `DELETE` क्वेरी को चलने से रोक देता है जिसमें प्राइमरी/इंडेक्स्ड की का `WHERE` क्लॉज़ या `LIMIT` न लगा हो।
2. **`INSERT` में कॉलम्स के नाम न लिखना (Implicit Column List)**:
   * *कमज़ोर कोड*:
     ```sql
     INSERT INTO categories VALUES (6, 'Apparel', 'Clothing');
     ```
   * *समस्या*: अगर भविष्य में किसी DBA ने टेबल में एक नया कॉलम जोड़ दिया (`ALTER TABLE categories ADD COLUMN icon_url VARCHAR(255);`), तो आपका पूरा बैकएंड कोड तुरंत क्रैश हो जाएगा:
     `ERROR 1136 (21S01): Column count doesn't match value count at row 1.`
   * *नियम*: हमेशा स्पष्ट रूप से कॉलम्स के नाम लिखें: `INSERT INTO categories (category_id, category_name, description) VALUES (...)`।
3. **लूप में एक-एक रो इंसर्ट करना बनाम बल्क इंसर्ट**:
   * *गलत तरीका*: अपने Python/Node.js कोड में लूप चलाकर 1,000 बार अलग-अलग `INSERT INTO ... VALUES (...)` चलाना।
   * *नुकसान*: हर क्वेरी के लिए अलग नेटवर्क राउंड-ट्रिप होगी, पार्सर चलेगा, और 1,000 बार डिस्क पर Redo Log सिंक होगा। यह बेहद धीमा होता है।
   * *सही तरीका*: एक ही क्वेरी में मल्टी-रो इंसर्ट करें (`INSERT INTO table VALUES (...), (...), (...)`)। यह 50 से 100 गुना तेज़ होता है!
4. **`REPLACE INTO` और `ON DUPLICATE KEY UPDATE` में फर्क न समझना**:
   * `REPLACE INTO` बैकएंड में पहले पुरानी रो को `DELETE` करता है और फिर नई रो को `INSERT` करता है। इसके बहुत खतरनाक साइड इफेक्ट्स होते हैं: ऑटो-इंक्रीमेंट आईडी बदल जाती है, बिना बताए कॉलम्स डिफ़ॉल्ट पर रीसेट हो जाते हैं, और `ON DELETE CASCADE` की वजह से जुड़ी हुई चाइल्ड टेबल्स का डेटा भी डिलीट हो सकता है! हमेशा `ON DUPLICATE KEY UPDATE` को ही प्राथमिकता दें।

---

## 9. Best Practices (बेस्ट प्रैक्टिसेस)

1. **डेवलपमेंट में हमेशा `sql_safe_updates` ऑन रखें**:
   ```sql
   SET sql_safe_updates = 1;
   ```
2. **`UPDATE` या `DELETE` चलाने से पहले हमेशा `SELECT` करके चेक करें**:
   * इसे चलाने से पहले:
     ```sql
     DELETE FROM orders WHERE status = 'Cancelled' AND order_date < '2022-01-01';
     ```
   * हमेशा पहले यह चलाएं:
     ```sql
     SELECT COUNT(*) FROM orders WHERE status = 'Cancelled' AND order_date < '2022-01-01';
     ```
   * संख्या देखकर पुष्टि करें कि सिर्फ वही रिकॉर्ड्स प्रभावित हो रहे हैं जिन्हें आप सच में हटाना चाहते हैं।
3. **मल्टी-स्टेप बदलावों के लिए हमेशा Transactions का उपयोग करें**:
   * जब एक टेबल को अपडेट करना दूसरी टेबल पर निर्भर हो (जैसे आर्डर बनाना और इन्वेंट्री स्टॉक घटाना), तो दोनों को एक ट्रांजेक्शन में लपेटें: `START TRANSACTION; ... COMMIT;` ताकि आधा-अधूरा काम कभी न हो।
4. **बड़ी टेबल्स से डेटा हटाते समय `LIMIT` के साथ बैचिंग करें**:
   * करोड़ों रिकॉर्ड्स को एक साथ डिलीट करने से टेबल लॉक हो जाती है और Undo Log भर जाता है। हमेशा टुकड़ों (batches) में डिलीट करें:
     ```sql
     DELETE FROM application_logs WHERE log_date < '2022-01-01' LIMIT 5000;
     ```
     इसे तब तक लूप में चलाएं जब तक 0 rows affected न आ जाए।

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. `departments` टेबल में `'Legal'` नाम का एक नया डिपार्टमेंट जोड़ने के लिए SQL क्वेरी लिखें जिसकी लोकेशन `'London'` हो।
2. `employees` टेबल से केवल `first_name`, `last_name`, और `salary` निकालने के लिए स्टेटमेंट लिखें।
3. `customers` टेबल में उस कस्टमर का फोन नंबर `'555-9999'` अपडेट करने की क्वेरी लिखें जिसकी `customer_id = 1` है।

### Medium (मध्यम)
4. एक ही बल्क `INSERT` स्टेटमेंट में `products` टेबल के अंदर स्टेशनरी से जुड़े तीन अलग-अलग प्रोडक्ट्स एक साथ जोड़ने की क्वेरी लिखें।
5. एक ऐसी `UPDATE` स्टेटमेंट लिखें जो डिपार्टमेंट 1 (`Engineering`) के सभी कर्मचारियों की सैलरी में 8% की बढ़ोतरी कर दे।
6. `payments` टेबल से उन सभी पेमेंट्स को डिलीट करने के लिए क्वेरी लिखें जिनका `payment_status` `'Failed'` है।

### Difficult (कठिन)
7. `suppliers` टेबल के लिए एक ऐसा `INSERT ... ON DUPLICATE KEY UPDATE` स्टेटमेंट लिखें जो यदि सप्लायर पहले से मौजूद हो, तो उसके `contact_name` और `contact_phone` को नए मानों से अपडेट कर दे, अन्यथा नया सप्लायर इंसर्ट करे।
8. एक मल्टी-टेबल `DELETE` स्टेटमेंट लिखें जो उन कस्टमर्स के सभी ऑर्डर्स को हटा दे जो `2021-01-01` से पहले रजिस्टर हुए थे और जिनके `loyalty_points = 0` हैं (और मान लें कि `order_items` कैस्केडिंग डिलीट से हट जाएंगे)।

---

## 11. Interview Questions (इंटरव्यू प्रश्न और उत्तर)

### Q1: 1,000 अलग-अलग सिंगल इंसर्ट्स चलाने और 1,000 टुपल्स वाले एक सिंगल बल्क इंसर्ट में परफॉरमेंस का क्या फर्क होता है?
**Answer**: अलग-अलग 1,000 `INSERT` स्टेटमेंट्स चलाने का मतलब है 1,000 अलग-अलग नेटवर्क राउंड-ट्रिप्स, 1,000 बार क्वेरी पार्सिंग और ऑप्टिमाइज़ेशन, और यदि `autocommit` ऑन है, तो InnoDB ट्रांजेक्शन Redo Log में 1,000 बार डिस्क राइट (I/O flush)। इसके विपरीत, एक सिंगल मल्टी-रो `INSERT INTO table VALUES (...), (...), ...` सारा डेटा एक नेटवर्क पैकेट में भेजता है, एक बार पार्स होता है, और एक ही लॉग राइट में पूरा बैच कमिट हो जाता है। यह अक्सर 20x से 100x गुना तेज़ परफॉरमेंस देता है।

### Q2: `REPLACE INTO` और `INSERT ... ON DUPLICATE KEY UPDATE` में क्या अंतर है?
**Answer**:
* `REPLACE INTO` अंदरूनी तौर पर पहले `DELETE` और फिर `INSERT` करता है। अगर डुप्लीकेट की मिलती है, तो पुरानी रो को मिटाकर नई रो बनाई जाती है। इसका नतीजा यह होता है कि `AUTO_INCREMENT` आईडी आगे बढ़ जाती है, जो कॉलम्स क्वेरी में नहीं दिए गए वे डिफ़ॉल्ट पर रीसेट हो जाते हैं, और यदि किसी टेबल पर `ON DELETE CASCADE` लगा है तो उससे जुड़े चाइल्ड रिकॉर्ड्स भी डिलीट हो सकते हैं।
* `INSERT ... ON DUPLICATE KEY UPDATE` (UPSERT) उसी पुरानी रो पर इन-प्लेस `UPDATE` करता है। इससे रो की पहचान, ऑटो-इंक्रीमेंट आईडी और बाकी सभी अनछुए कॉलम्स सुरक्षित रहते हैं, और कोई खतरनाक कैस्केड डिलीट ट्रिगर नहीं होता।

### Q3: MySQL का `sql_safe_updates` मोड क्या होता है और यह क्यों ज़रूरी है?
**Answer**: `sql_safe_updates` एक सेशन और ग्लोबल कॉन्फ़िगरेशन वेरिएबल है (`SET sql_safe_updates = 1;`)। जब यह सक्रिय होता है, तो MySQL ऐसी किसी भी `UPDATE` या `DELETE` स्टेटमेंट को चलाने से साफ मना कर देता है जिसमें प्राइमरी की या इंडेक्स्ड कॉलम वाला `WHERE` क्लॉज़ न हो, या explicit `LIMIT` न लगा हो। यह डेवलपर्स को उन जानलेवा मानवीय गलतियों से बचाता है जहाँ बिना `WHERE` क्लॉज़ के पूरी टेबल का डेटा अनजाने में बदल या उड़ जाता है।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* **CRUD** का सीधा संबंध SQL की चार मुख्य क्रियाओं से है: `INSERT`, `SELECT`, `UPDATE`, और `DELETE`।
* भविष्य के स्कीमा बदलावों से अपने कोड को सुरक्षित रखने के लिए `INSERT` में हमेशा **Explicit Column Lists** लिखें।
* बड़े डेटासेट्स को बिजली की तेज़ी से लोड करने के लिए हमेशा **Bulk Inserts** का इस्तेमाल करें।
* कभी भी बिना पहले `SELECT` करके चेक किए `UPDATE` या `DELETE` न चलाएं, और डेवलपमेंट में `sql_safe_updates = 1` हमेशा ऑन रखें।
* डेटा सिंक करने के लिए हमेशा `INSERT ... ON DUPLICATE KEY UPDATE` (UPSERT) का उपयोग करें; `REPLACE INTO` से बचें क्योंकि यह डेटा डिलीट करके फिर से इंसर्ट करता है।
