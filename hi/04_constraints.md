# Chapter 04 — Integrity Constraints और Validation Rules

---

## 1. What is it? (यह क्या है?)

**Integrity Constraints** (डेटा अखंडता नियम) RDBMS इंजन द्वारा स्कीमा लेवल पर लागू किए गए ऐसे अनिवार्य नियम (rules) हैं जो स्टोर किए जाने वाले डेटा की शुद्धता, वैधता, स्थिरता और विश्वसनीयता (accuracy, validity, consistency, reliability) की गारंटी देते हैं।

जब भी कोई ऍप्लिकेशन डेटाबेस में `INSERT`, `UPDATE` या `DELETE` चलाता है, तो स्टोरेज इंजन डिस्क पर डेटा लिखने से पहले इन सभी कंस्ट्रेंट्स के खिलाफ डेटा की जाँच करता है। अगर एक भी नियम टूटता है, तो डेटाबेस इंजन तुरंत ऑपरेशन रोक देता है, पूरी क्वेरी को रिजेक्ट कर देता है, एक स्पष्ट एरर कोड देता है, और डेटाबेस की पुरानी स्थिति में एक तिनके का भी बदलाव नहीं होने देता।

अक्सर नए डेवलपर्स सोचते हैं: *"हम तो यह वैलिडेशन React या Node.js/Python के कोड में कर ही रहे हैं, तो डेटाबेस में कंस्ट्रेंट्स क्यों लगाएं?"*
जवाब सीधा है: ऍप्लिकेशन कोड में बग्स हो सकते हैं, कोई डेवलपर सीधे टर्मिनल से डेटा डाल सकता है, या भविष्य में 10 अलग-अलग माइक्रो-सर्विसेज उसी डेटाबेस से जुड़ सकती हैं। अगर नियम डेटाबेस के स्कीमा में दर्ज हैं, तो दुनिया की कोई भी ताकत डेटाबेस के अंदर गलत या करप्ट डेटा नहीं घुसा सकती!

मुख्य SQL कंस्ट्रेंट्स ये हैं:
1. **`PRIMARY KEY`**: टेबल की प्रत्येक रो (पंक्ति) की विशिष्ट पहचान (unique identity) करता है। यह अपने आप `UNIQUE` और `NOT NULL` दोनों को लागू कर देता है। MySQL के InnoDB इंजन में, प्राइमरी की सीधे तौर पर डिस्क पर डेटा स्टोर करने वाले फिजिकल **Clustered Index** का निर्माण करती है।
2. **`FOREIGN KEY`**: दो टेबल्स के बीच **Referential Integrity** (संदर्भ अखंडता) बनाए रखता है। यह सुनिश्चित करता है कि चाइल्ड टेबल का कोई भी रिकॉर्ड किसी ऐसे पैरेंट को पॉइंट न करे जो मौजूद ही न हो।
3. **`NOT NULL`**: किसी कॉलम में `NULL` (खाली मान) आने पर रोक लगाता है; उस कॉलम में कोई ठोस वैल्यू होना अनिवार्य हो जाता है।
4. **`UNIQUE`**: यह गारंटी देता है कि उस कॉलम (या कई कॉलम्स के कॉम्बिनेशन) में कोई भी दो वैल्यूज एक जैसी (डुप्लीकेट) नहीं हो सकतीं।
5. **`CHECK`**: हर रो पर एक बूलियन कंडीशन चेक करता है; अगर कंडीशन `FALSE` होती है तो डेटा रिजेक्ट हो जाता है (MySQL 8.0+ में पूरी तरह लागू)।
6. **`DEFAULT`**: अगर `INSERT` करते समय किसी कॉलम की वैल्यू छोड़ दी जाए, तो यह अपने आप एक तय डिफ़ॉल्ट मान भर देता है।
7. **`AUTO_INCREMENT`**: नए रिकॉर्ड्स जुड़ने पर अपने आप 1, 2, 3... जैसे क्रमबद्ध इंटीजर आईडी जेनरेट करने वाला ऑटोमैटिक काउंटर।

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Defensive Schema Architecture (डेटा की अभेद्य सुरक्षा)**: फ्रंटएंड फॉर्म या बैकएंड API लेयर में बग्स आना स्वाभाविक है। कंस्ट्रेंट्स एक अटूट सुरक्षा कवच (safety net) की तरह काम करते हैं, जो करप्ट, अनाथ (orphaned), या असंभव डेटा को डेटाबेस में जाने से रोकते हैं।
2. **Referential Stability (टेबल्स के बीच पक्का रिश्ता)**: Foreign Keys अनाथ रोज़ (orphaned records) को खत्म करती हैं — जैसे ऐसा आर्डर जिसका प्रोडक्ट डिलीट हो चुका हो, या ऐसा कर्मचारी जिसका डिपार्टमेंट ही गायब हो।
3. **High-Performance Query Paths (सुपरफास्ट सर्चिंग)**: डेटाबेस इंजन `PRIMARY KEY`, `UNIQUE`, और `FOREIGN KEY` के लिए बैकएंड में अपने आप B+ Tree इंडेक्स बना देता है, जिससे डेटा को खोजना $O(\log N)$ की सुपरफास्ट स्पीड में संभव हो जाता है।
4. **Self-Documenting Schemas (स्पष्ट बिज़नेस लॉजिक)**: टेबल का DDL स्ट्रक्चर देखते ही किसी भी नए डेवलपर को बिज़नेस के बुनियादी नियम समझ आ जाते हैं (जैसे "सैलरी 0 से अधिक होनी चाहिए", "डिस्काउंट 0.00 और 1.00 के बीच ही हो सकता है")।

---

## 3. Syntax (सिंटैक्स)

### Defining Constraints During Table Creation (टेबल बनाते समय कंस्ट्रेंट्स लगाना)
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

## 4. Basic Example (बेसिक उदाहरण)

आइए एक साधारण सब्सक्रिप्शन मैनेजमेंट टेबल के ज़रिए कंस्ट्रेंट्स का व्यावहारिक उपयोग देखें:

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

## 5. Real-World Example (रियल-वर्ल्ड उदाहरण)

हमारे `sql_mastery` प्रोडक्शन डेटाबेस में, आइए `order_items` टेबल में लागू की गई मजबूत कंस्ट्रेंट व्यवस्था की जाँच करें और देखें कि इंजन नियमों का उल्लंघन होने पर कैसे रोकता है:

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

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

1. `CONSTRAINT chk_item_quantity CHECK (quantity > 0)`:
   * जब भी कोई `INSERT` या `UPDATE` क्वेरी `order_items` टेबल पर आती है, तो डेटा क्लस्टर्ड इंडेक्स में सेव होने से ठीक पहले MySQL का रनटाइम कंस्ट्रेंट इवैल्यूएटर चलता है।
   * यदि `quantity <= 0` होती है, तो इंजन तुरंत ट्रांजेक्शन स्टेटमेंट को रोक देता है और यह एरर फेंकता है:
     `ERROR 3819 (HY000): Check constraint 'chk_item_quantity' is violated.`
2. `CONSTRAINT uq_order_product UNIQUE (order_id, product_id)`:
   * MySQL इन दोनों कॉलम्स को मिलाकर एक Composite Unique B+ Tree Index बनाता है।
   * जब हम `(1001, 1)` वाली रो इंसर्ट करने की कोशिश करते हैं, तो MySQL इंडेक्स में चेक करता है। यह कॉम्बिनेशन पहले से मौजूद होने के कारण, वह इंसर्ट रिजेक्ट कर देता है ताकि एक ही आर्डर में एक ही प्रोडक्ट दो बार अलग-अलग लाइन आइटम बनकर न जुड़ सके।
3. `CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)`:
   * यहाँ चाइल्ड टेबल `order_items` पैरेंट टेबल `products` को पॉइंट कर रही है।
   * जब प्रोडक्ट `9999` इंसर्ट करने की कोशिश की गई, तो InnoDB स्टोरेज इंजन ने `products` टेबल के क्लस्टर्ड इंडेक्स में `9999` की खोज की। जब वह आईडी कहीं नहीं मिली, तो इंजन ने तुरंत ऑपरेशन को फेल करके स्टेटमेंट को रोलबैक कर दिया।

---

## 7. Expected Result (अपेक्षित परिणाम / Expected Output)

टर्मिनल में कंस्ट्रेंट वॉयलेशन के वास्तविक एरर मैसेज:

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

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **यह मानना कि `UNIQUE` में `NULL` नहीं आ सकता**:
   * *गलती*: यह सोचना कि अगर कॉलम पर `UNIQUE` लगा है, तो उसमें खाली (`NULL`) वैल्यू नहीं आ सकती।
   * *सच्चाई*: ANSI SQL और MySQL में `NULL` का मतलब "अज्ञात" (unknown) होता है। चूँकि एक अज्ञात वैल्यू दूसरी अज्ञात वैल्यू के बराबर नहीं मानी जा सकती (`NULL = NULL` का रिजल्ट `TRUE` नहीं बल्कि `NULL` होता है), इसलिए MySQL एक `UNIQUE` कॉलम में **कई सारे `NULL` वैल्यूज** डालने की अनुमति देता है (जब तक कि आपने साथ में स्पष्ट रूप से `NOT NULL` न लगाया हो)।
2. **Primary Key और Unique Constraint को एक जैसा समझना**:
   * एक टेबल में **केवल एक ही** `PRIMARY KEY` हो सकती है (जिसमें कभी `NULL` नहीं आ सकता), लेकिन एक टेबल में **कई सारे** `UNIQUE` कंस्ट्रेंट्स हो सकते हैं।
3. **यह सोचना कि MySQL 5.7 में `CHECK` कंस्ट्रेंट काम करता था**:
   * MySQL 5.7 और उससे पुराने वर्जन्स में SQL पार्सर `CHECK` सिंटैक्स को बिना एरर के स्वीकार तो कर लेता था, लेकिन रनटाइम पर डेटा डालते समय उसे पूरी तरह अनदेखा (ignore) कर देता था! वास्तविक `CHECK` एनफोर्समेंट **MySQL 8.0.16** से शुरू हुआ है।
4. **Foreign Key वाले कॉलम को सीधे ड्रॉप करने की कोशिश करना**:
   * सीधे `ALTER TABLE order_items DROP COLUMN product_id;` चलाने पर एरर आएगा। नियम यह है कि पहले आपको Foreign Key कंस्ट्रेंट हटाना होगा (`ALTER TABLE order_items DROP FOREIGN KEY fk_items_product;`), उसके बाद ही वह कॉलम ड्रॉप हो सकेगा।
5. **कंस्ट्रेंट्स को स्पष्ट नाम न देना**:
   * बिना नाम दिए सिर्फ `CHECK (salary > 0)` लिखने पर MySQL उसे `employees_chk_1` जैसा ऑटोमैटिक नाम दे देता है। भविष्य में जब आप स्कीमा माइग्रेट करेंगे या डिबग करेंगे, तो यह पहचानना मुश्किल हो जाएगा कि कौन-सा कंस्ट्रेंट किस नियम के लिए था।

---

## 9. Best Practices (बेस्ट प्रैक्टिसेस)

1. **हमेशा वर्णनात्मक (Descriptive) नामकरण परंपरा अपनाएं**:
   * कंस्ट्रेंट्स के नाम में उनका प्रकार ज़रूर जोड़ें:
     * Primary Keys: `pk_tablename`
     * Foreign Keys: `fk_childtable_parenttable`
     * Unique Constraints: `uq_tablename_column`
     * Check Constraints: `chk_tablename_rule`
2. **Foreign Key Deletion Actions को सोच-समझकर चुनें**:
   * `ON DELETE RESTRICT` (डिफ़ॉल्ट): इसका उपयोग तब करें जब तक बच्चे मौजूद हों तब तक पैरेंट रिकॉर्ड डिलीट नहीं होना चाहिए (जैसे अगर ग्राहक के पुराने ऑर्डर्स हैं, तो ग्राहक को डिलीट न होने दें)।
   * `ON DELETE CASCADE`: इसका उपयोग तब करें जब पैरेंट के बिना चाइल्ड रिकॉर्ड का कोई अस्तित्व ही न हो (जैसे `orders` डिलीट होते ही उसके सारे `order_items` अपने आप डिलीट हो जाने चाहिए)।
   * `ON DELETE SET NULL`: इसका उपयोग तब करें जब संबंध वैकल्पिक (optional) हो (जैसे अगर कोई मैनेजर कंपनी छोड़ दे, तो उसके कर्मचारियों का `manager_id` अपने आप `NULL` हो जाए)।
3. **हाई-वॉल्यूम टेबल्स में Composite Primary Key से बचें**:
   * यद्यपि नेचुरल कम्पोजिट कीज़ `(order_id, product_id)` मान्य हैं, लेकिन अगर भविष्य में अन्य टेबल्स को इस टेबल से जोड़ना हो, तो एक सिंगल कॉलम सेरोगेट की (`item_id INT AUTO_INCREMENT PRIMARY KEY`) बनाएं और साथ में `UNIQUE (order_id, product_id)` लगाएं ताकि बाद में मल्टी-कॉलम फॉरेन कीज़ का भारी बोझ न उठाना पड़े।

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. जब किसी कॉलम को `PRIMARY KEY` घोषित किया जाता है, तो कौन-से दो कंस्ट्रेंट्स अपने आप उस पर लागू हो जाते हैं?
2. एक टेबल के अंदर अधिकतम कितने `PRIMARY KEY` कंस्ट्रेंट्स हो सकते हैं?
3. एक टेबल के अंदर अधिकतम कितने `UNIQUE` कंस्ट्रेंट्स बनाए जा सकते हैं?

### Medium (मध्यम)
4. `bank_accounts` टेबल के लिए एक `CREATE TABLE` स्टेटमेंट लिखें जिसमें `account_id INT AUTO_INCREMENT PRIMARY KEY`, `account_number VARCHAR(20) NOT NULL UNIQUE`, और `balance DECIMAL(12,2) NOT NULL DEFAULT 0.00` हो, और साथ में यह सुनिश्चित करने के लिए CHECK कंस्ट्रेंट हो कि `balance >= 0.00` रहे।
5. मान लीजिए दो टेबल्स हैं `students` और `enrollments`। `enrollments(student_id)` पर `students(student_id)` को रेफरेंस करने वाला `fk_enrollment_student` नाम का फॉरेन की कंस्ट्रेंट कैस्केडिंग डिलीट (`ON DELETE CASCADE`) के साथ जोड़ने के लिए SQL स्टेटमेंट लिखें।
6. MySQL 8.0 में `employees` टेबल से `chk_employee_salary` नाम का चेक कंस्ट्रेंट हटाने की सटीक कमांड लिखें।

### Difficult (कठिन)
7. आंतरिक रूप से क्या घटित होता है जब आप `UNIQUE` कंस्ट्रेंट वाले कॉलम में दो बार `NULL` डालने की कोशिश करते हैं, बनाम जब आप `PRIMARY KEY` वाले कॉलम में दो बार `NULL` डालने की कोशिश करते हैं? दोनों का व्यवहार विस्तार से समझाइए।
8. एक ऐसी `ALTER TABLE` स्टेटमेंट लिखें जो `events` टेबल में मल्टी-कॉलम चेक कंस्ट्रेंट जोड़ती हो, जो यह पक्का करे कि `end_time` हमेशा `start_time` से बाद का ही होना चाहिए।

---

## 11. Interview Questions (इंटरव्यू प्रश्न और उत्तर)

### Q1: `PRIMARY KEY` और `UNIQUE` कंस्ट्रेंट में क्या अंतर होता है?
**Answer**:
1. **संख्या (Quantity)**: एक टेबल में केवल एक ही `PRIMARY KEY` हो सकती है, जबकि आप जितनी चाहें उतनी `UNIQUE` कंस्ट्रेंट्स बना सकते हैं।
2. **Nullability**: `PRIMARY KEY` में `NULL` वैल्यू कभी भी स्वीकार नहीं की जाती। इसके विपरीत, `UNIQUE` कंस्ट्रेंट में `NULL` वैल्यूज आ सकती हैं (और MySQL में जब तक `NOT NULL` न लगा हो, कई सारे `NULL` डाले जा सकते हैं)।
3. **Clustering (क्लस्टरिंग)**: MySQL के InnoDB स्टोरेज इंजन में, `PRIMARY KEY` टेबल के फिजिकल स्टोरेज को B+ Tree **Clustered Index** के रूप में व्यवस्थित करती है (यानी लीफ नोड्स में पूरा डेटा रो स्टोर होता है)। जबकि सेकेंडरी `UNIQUE` कंस्ट्रेंट्स नॉन-क्लस्टर्ड इंडेक्स बनाते हैं जिनके लीफ नोड्स प्राइमरी की को पॉइंट करते हैं।

### Q2: `ON DELETE CASCADE`, `ON DELETE SET NULL`, और `ON DELETE RESTRICT` में क्या अंतर है?
**Answer**:
* `ON DELETE RESTRICT` (या `NO ACTION`): अगर चाइल्ड टेबल में कोई भी संबंधित रिकॉर्ड मौजूद है, तो यह पैरेंट रो को डिलीट होने से सख्ती से रोक देता है और एरर देता है।
* `ON DELETE CASCADE`: पैरेंट रो डिलीट होते ही उससे जुड़े सभी चाइल्ड रिकॉर्ड्स को बैकएंड में अपने आप डिलीट कर देता है।
* `ON DELETE SET NULL`: पैरेंट रो डिलीट होने पर चाइल्ड रिकॉर्ड्स को डिलीट नहीं करता, बल्कि उनके फॉरेन की वाले कॉलम की वैल्यू को `NULL` सेट कर देता है (इसके लिए चाइल्ड कॉलम का nullable होना ज़रूरी है)।

### Q3: MySQL के अलग-अलग वर्जन्स में `CHECK` कंस्ट्रेंट को कैसे हैंडल किया गया है?
**Answer**: MySQL 8.0.16 से पहले के सभी वर्जन्स में SQL पार्सर `CHECK` कंस्ट्रेंट के सिंटैक्स को बिना किसी एरर के स्वीकार तो कर लेता था, लेकिन रनटाइम पर डेटा डालते (`INSERT`/`UPDATE`) समय स्टोरेज इंजन उसे पूरी तरह नजरअंदाज (ignore) कर देता था। MySQL 8.0.16 से इसे पूरी तरह लागू (enforce) कर दिया गया है, और कंडीशन गलत (`FALSE`) साबित होने पर क्वेरी तुरंत `ERROR 3819 (HY000)` के साथ फेल हो जाती है।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* **Integrity Constraints** स्टोरेज इंजन स्तर पर अमान्य डेटा को रिजेक्ट करके डेटाबेस की विश्वसनीयता की रक्षा करते हैं।
* एक टेबल में ठीक एक **`PRIMARY KEY`** होती है, जो कभी `NULL` नहीं हो सकती और InnoDB में फिजिकल क्लस्टर्ड इंडेक्स बनाती है।
* **`UNIQUE`** डुप्लीकेट डेटा रोकता है, लेकिन स्पष्ट रूप से `NOT NULL` न होने पर MySQL में एक से अधिक `NULL` वैल्यूज स्वीकार करता है।
* **`FOREIGN KEY`** पैरेंट-चाइल्ड रिलेशनशिप की रक्षा करती है और इसमें विभिन्न एक्शन्स (`RESTRICT`, `CASCADE`, `SET NULL`) कॉन्फ़िगर किए जा सकते हैं।
* **`CHECK`** कस्टम वैलिडेशन रूल्स लागू करता है (MySQL 8.0.16+ में पूरी तरह सक्रिय)।
* स्कीमा के बेहतर मेंटेनेंस के लिए हमेशा वर्णनात्मक नाम (`fk_...`, `chk_...`, `uq_...`) का उपयोग करें।
