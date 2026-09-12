# Chapter 22 — Event-Driven Architecture: MySQL Triggers | इवेंट-ड्रिवन आर्किटेक्चर: MySQL ट्रिगर्स

---

## 1. What is it? (ट्रिगर्स क्या हैं?)

MySQL में एक **Trigger** एक ऐसा स्पेशलाइज्ड स्टोर्ड प्रोग्राम होता है जो किसी खास बेस टेबल पर होने वाले विशिष्ट **Data Manipulation Language (DML)** इवेंट (`INSERT`, `UPDATE`, या `DELETE`) के रिस्पॉन्स में अपने आप (automatically) "फायर" (execute) हो जाता है।

Stored Procedures (जिन्हें एप्लिकेशन या डेवलपर को खुद `CALL` करके चलाना पड़ता है) के विपरीत, ट्रिगर्स को कभी भी सीधे कॉल नहीं किया जा सकता। ये बैकग्राउंड में स्टोरेज इंजन द्वारा मैनेज किए जाने वाले **इम्प्लिसिट इवेंट हैंडलर्स (implicit event handlers)** की तरह काम करते हैं।

एक ट्रिगर मुख्य रूप से दो बातों पर निर्भर करता है:
1. **एक्टिवेशन टाइमिंग (Activation Timing)**:
   * **`BEFORE`**: यह रो मॉडिफिकेशन के स्टोरेज इंजन के डेटा पेजों पर लिखे जाने से *पहले* चलता है। इसका मुख्य उपयोग डेटा वैलिडेशन, डेटा सैनिटाइजेशन (जैसे व्हाइटस्पेस ट्रिम करना या इनपुट क्लीन करना), और डिस्क पर राइट होने से पहले वैल्यूज को मॉडिफाई करने के लिए किया जाता है।
   * **`AFTER`**: यह रो मॉडिफिकेशन के टेबल पर लिखे जाने के *बाद* चलता है। इसका उपयोग मुख्य रूप से ऑडिट लॉगिंग (immutable audit logs), दूसरी टेबल्स के साथ डेटा सिंक्रोनाइज़ेशन, और इवेंट नोटिफिकेशन्स के लिए किया जाता है।
2. **एक्टिवेशन इवेंट (Activation Event)**: `INSERT`, `UPDATE`, या `DELETE`।

चूँकि MySQL में रो-लेवल ट्रिगर्स (`FOR EACH ROW`) होते हैं, इसलिए अगर कोई सिंगल `UPDATE` स्टेटमेंट 50 पंक्तियों को मॉडिफाई करता है, तो ट्रिगर कोड ठीक 50 बार (हर प्रभावित रो के लिए एक बार) रन होगा।

---

## 2. Row Pseudo-Records: NEW vs OLD (स्यूडो-रिकॉर्ड्स: NEW बनाम OLD)

ट्रिगर बॉडी के अंदर, MySQL दो वर्चुअल स्यूडो-रिकॉर्ड्स (pseudo-records) उपलब्ध कराता है जो डेटा रो का प्रतिनिधित्व करते हैं:
* **`NEW`**: यह इंसर्ट या अपडेट किए जा रहे नए रिकॉर्ड को दर्शाता है।
  * यह उपलब्ध होता है: **`INSERT`** और **`UPDATE`** में।
  * `BEFORE` ट्रिगर्स में आप आने वाली वैल्यूज को ओवरराइट कर सकते हैं: `SET NEW.email = LOWER(NEW.email);`।
* **`OLD`**: यह मॉडिफिकेशन या डिलीशन से ठीक पहले के मौजूदा पुराने रिकॉर्ड को दर्शाता है।
  * यह उपलब्ध होता है: **`UPDATE`** और **`DELETE`** में।
  * यह पूरी तरह से रीड-ओनली (read-only) होता है; इसे बदला नहीं जा सकता।

| ट्रिगर इवेंट | `OLD.column` उपलब्ध है? | `NEW.column` उपलब्ध है? | क्या `NEW.column` को मॉडिफाई कर सकते हैं? |
| :--- | :--- | :--- | :--- |
| `INSERT` | नहीं | **हाँ** (इंसर्ट होने वाली वैल्यूज) | **हाँ** (केवल `BEFORE INSERT` में) |
| `UPDATE` | **हाँ** (अपडेट से पहले की वैल्यूज) | **हाँ** (अपडेट के बाद की वैल्यूज) | **हाँ** (केवल `BEFORE UPDATE` में) |
| `DELETE` | **हाँ** (डिलीट होने वाली वैल्यूज) | नहीं | नहीं |

---

## 3. Syntax (सिंटैक्स और स्ट्रक्चर)

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

### `SIGNAL SQLSTATE` से ऑपरेशन्स को अबॉर्ट करना (Aborting Operations)
अगर ट्रिगर के अंदर कोई बिज़नेस रूल टूटता है और आप ऑपरेशन को रिजेक्ट करके पूरे ट्रांजैक्शन को रोलबैक करना चाहते हैं, तो `SIGNAL SQLSTATE '45000'` का उपयोग करके एक कस्टम डेटाबेस एक्सेप्शन रेज़ करें:

```sql
IF NEW.salary <= 0 THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integrity Error: Employee salary must be greater than zero.';
END IF;
```

---

## 4. Basic Example (बेसिक प्रैक्टिकल उदाहरण)

यहाँ हम एक `BEFORE INSERT` ट्रिगर बना रहे हैं जो नए कस्टमर डेटा को ऑटोमैटिकली क्लीन और नॉर्मलाइज़ करता है:

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

## 5. Real-World Business Example: Enterprise Audit Logging & Price Validation (वास्तविक बिज़नेस उदाहरण: ऑडिट लॉगिंग और प्राइस वैलिडेशन)

मान लीजिए कि हमारे `sql_mastery` डेटाबेस में, कंप्लायंस और ऑडिट टीम दो ऑटोमैटिक सुरक्षा नियम लागू करना चाहती है:
1. **वैलिडेशन (`BEFORE UPDATE` on `products`)**: किसी भी प्रोडक्ट की कीमत में एक बार में 50% से अधिक की गिरावट को रोकना, ताकि गलती से कोई भारी नुकसान न हो। नियम टूटने पर ट्रांजैक्शन तुरंत रिजेक्ट (abort) हो जाए।
2. **ऑडिट ट्रेल (`AFTER UPDATE` on `products`)**: जब भी किसी प्रोडक्ट का `unit_price` या `stock_quantity` बदला जाए, तो बदलाव को एक अपरिवर्तनीय (immutable) ऑडिट टेबल में लॉग करना—जिसमें प्रोडक्ट ID, पुरानी वैल्यूज, नई वैल्यूज, बदलाव करने वाला यूज़र, और टाइमस्टैम्प दर्ज हो।

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

## 6. Step-by-Step Explanation & Execution (स्टेप-बाय-स्टेप व्याख्या और टेस्टिंग)

आइए दोनों ट्रिगर्स को चलाकर टेस्ट करते हैं:

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

## 7. Expected Result (अपेक्षित आउटपुट)

टर्मिनल आउटपुट जो ट्रिगर्स के सफल एग्जीक्यूशन की पुष्टि करता है:

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

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **ट्रिगर वाली टेबल को ही ट्रिगर के अंदर मॉडिफाई करना (Error 1442)**:
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
   * *Rule*: एक ट्रिगर उस टेबल पर DML (`INSERT`, `UPDATE`, `DELETE`) नहीं चला सकता जिस पर वह खुद लगा हुआ है! अगर आपको उसी टेबल की आने वाली वैल्यूज बदलनी हैं, तो हमेशा `BEFORE INSERT` या `BEFORE UPDATE` ट्रिगर का इस्तेमाल करें और सीधे असाइन करें: `SET NEW.total_amount = 100;`।
2. **हिडन बिज़नेस लॉजिक और डीबगिंग की मुसीबतें (Debugging Nightmares)**:
   * ट्रिगर्स के अंदर जटिल बिज़नेस लॉजिक छिपाने से एप्लिकेशन का व्यवहार अस्पष्ट हो जाता है। जब कोई API डेवलपर सामान्य `UPDATE` चलाता है और वह अचानक फेल हो जाता है या 20 दूसरी टेबल्स में बदलाव कर देता है, तो बिना डॉक्यूमेंटेशन के इस बग को ढूँढना बहुत मुश्किल हो जाता है।
3. **बल्क DML ऑपरेशन्स पर भारी परफ़ॉर्मेंस पेनाल्टी**:
   * रो-लेवल ट्रिगर्स **हर एक पंक्ति** के लिए चलते हैं। अगर कोई एप्लिकेशन बल्क `INSERT` में 1,000,000 पंक्तियाँ लोड कर रहा है, तो `AFTER INSERT` ट्रिगर 10 लाख बार चलेगा, जिससे 2 सेकंड में होने वाला इंसर्ट 15 मिनट की भारी रुकावट बन सकता है।

---

## 9. Best Practices (सर्वोत्तम तरीके और टिप्स)

1. **ट्रिगर्स को छोटा, तेज़ और गैर-दखलंदाज़ी वाला रखें**:
   * ट्रिगर्स कॉलर के एक्टिव ट्रांजैक्शन के अंदर चलते हैं। भारी कैलकुलेशन वाले ट्रिगर्स रो लॉक्स को लंबे समय तक रोके रखते हैं, जिससे लॉक वेट टाइमआउट और डेडलॉक्स का खतरा बढ़ जाता है।
2. **ट्रिगर्स को केवल ऑडिटिंग, डेटा नॉर्मलाइजेशन, और सख्त इनवेरिएंट्स तक सीमित रखें**:
   * बेहतरीन उपयोग: ऑडिट लॉग्स मेंटेन करना, डेटा ट्रिम करना/हैश बनाना, और क्रॉस-फ़ील्ड स्कीमा रूल्स लागू करना।
   * खराब उपयोग: एक्सटर्नल वेबहुक्स कॉल करना, ईमेल्स भेजना, या मल्टी-टेबल बिज़नेस वर्कफ़्लो चलाना।
3. **स्पष्ट नेमिंग कन्वेंशन का पालन करें**:
   * फ़ॉर्मेट: `trg_<tablename>_<timing>_<event>`
   * उदाहरण: `trg_products_before_update`, `trg_orders_after_insert`।
4. **ऑडिट इंसर्ट्स को हमेशा चेंज डिटेक्शन से सुरक्षित करें**:
   * हमेशा `IF (OLD.col != NEW.col)` चेक करें ताकि ऑडिट टेबल में केवल तभी एंट्री हो जब डेटा वास्तव में बदला हो, जिससे ऑडिट टेबल बेकार के डेटा से न भरे।

---

## 10. Practice Questions (अभ्यास के लिए प्रश्न)

### Easy
1. `BEFORE` ट्रिगर और `AFTER` ट्रिगर के एक्टिवेशन टाइमिंग में क्या अंतर होता है?
2. `DELETE` ट्रिगर के अंदर कौन सा स्यूडो-रिकॉर्ड (`NEW` या `OLD`) उपलब्ध होता है?
3. `INSERT` ट्रिगर के अंदर कौन सा स्यूडो-रिकॉर्ड उपलब्ध होता है?

### Medium
4. `employees` टेबल पर एक `BEFORE INSERT` ट्रिगर लिखें जो यह सुनिश्चित करे कि यदि नए कर्मचारी की `hire_date` को `NULL` दिया गया हो, तो वह अपने आप `CURDATE()` पर सेट हो जाए।
5. `employees` टेबल पर एक `BEFORE UPDATE` ट्रिगर लिखें जो किसी कर्मचारी की `salary` कम करने पर रोक लगाए। यदि कोई अपडेट `NEW.salary < OLD.salary` करने की कोशिश करे, तो एरर स्टेट `'45000'` और मैसेज `'Salaries cannot be reduced.'` रेज़ करें।
6. `sql_mastery` डेटाबेस में वर्तमान में मौजूद सभी ट्रिगर्स की सूची देखने के लिए SQL कमांड लिखें।

### Difficult
7. एक ऑटोमैटिक स्टॉक सिंक्रोनाइज़ेशन ट्रिगर डिज़ाइन करें: जब `order_items` में कोई नया आइटम इंसर्ट हो, तो `AFTER INSERT` ट्रिगर अपने आप `products` टेबल में संबंधित प्रोडक्ट की `stock_quantity` घटा दे। यह आर्किटेक्चर किस प्रकार के कंकरेंसी या डेडलॉक जोखिम पैदा कर सकता है?
8. समझाइए कि यदि टेबल `T` पर लगा ट्रिगर उसी टेबल `T` पर `UPDATE` चलाता है, तो MySQL `ERROR 1442` क्यों फेंकता है? उसी टेबल के डेटा में सुरक्षित म्यूटेशन कैसे किया जाता है?

---

## 11. Interview Questions (इंटरव्यू सवाल और जवाब)

### Q1: MySQL ट्रिगर्स में `NEW` और `OLD` स्यूडो-रिकॉर्ड्स में क्या अंतर होता है?
**उत्तर**:
* **`NEW`**: यह आने वाले नए रो स्टेट का प्रतिनिधित्व करता है। यह `INSERT` और `UPDATE` ट्रिगर्स में उपलब्ध होता है। `BEFORE INSERT` और `BEFORE UPDATE` ट्रिगर्स में, डिस्क पर डेटा लिखे जाने से पहले `NEW` के कॉलम्स को मॉडिफाई किया जा सकता है (`SET NEW.col = value`)।
* **`OLD`**: यह बदलाव या डिलीट होने से ठीक पहले के मौजूदा रो स्टेट का प्रतिनिधित्व करता है। यह `UPDATE` और `DELETE` ट्रिगर्स में उपलब्ध होता है और पूरी तरह से रीड-ओनली होता है।
`UPDATE` ट्रिगर में `OLD` (अपडेट से पहले) और `NEW` (अपडेट के बाद) दोनों एक साथ उपलब्ध होते हैं, जिससे दोनों वैल्यूज की तुलना (delta comparison) की जा सकती है।

### Q2: MySQL किसी ट्रिगर को उसी टेबल को मॉडिफाई करने से क्यों रोकता है जिस पर वह लगा हुआ है?
**उत्तर**: यदि ट्रिगर उसी टेबल को मॉडिफाई करने की अनुमति दे दे, तो **इनफिनिट रिकर्शन (अनंत लूप)** का भारी खतरा पैदा हो जाता है। उदाहरण के लिए, यदि `orders` टेबल पर लगा `AFTER UPDATE` ट्रिगर फिर से `orders` टेबल पर एक `UPDATE` चला दे, तो वह अपडेट दोबारा ट्रिगर को फायर करेगा, और यह प्रक्रिया बार-बार दोहराई जाएगी जिससे सर्वर मेमोरी और स्टैक स्पेस क्रैश हो जाएगा। इसे रोकने के लिए MySQL सख्ती से Error 1442 लागू करता है।

### Q3: अवैध ट्रांजैक्शन को अबॉर्ट करने के लिए MySQL ट्रिगर के अंदर कस्टम रनटाइम एक्सेप्शन कैसे रेज़ किया जाता है?
**उत्तर**: कस्टम एक्सेप्शन रेज़ करने के लिए **`SIGNAL`** स्टेटमेंट और SQLState `'45000'` (यूज़र-डिफाइंड अनहैंडल्ड एक्सेप्शन्स के लिए ANSI स्टैंडर्ड कोड) का उपयोग किया जाता है:
```sql
SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Validation Failed: Custom Error Description';
```
जब `SIGNAL` एग्जीक्यूट होता है, तो MySQL तुरंत एग्जीक्यूशन रोक देता है, एक्टिव स्टेटमेंट को अबॉर्ट कर देता है, ट्रांजैक्शन में हुए अनकमिटेड बदलावों को रोलबैक कर देता है, और कॉलिंग क्लाइंट को एरर कोड 1644 के साथ कस्टम एरर मैसेज लौटाता है।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* **Triggers** ऑटोमेटेड इवेंट हैंडलर्स होते हैं जो `INSERT`, `UPDATE`, या `DELETE` पर रन होते हैं।
* **`BEFORE`** ट्रिगर्स डिस्क राइट्स से पहले चलते हैं (वैलिडेशन और `NEW` को मॉडिफाई करने के लिए बेस्ट); **`AFTER`** ट्रिगर्स डिस्क राइट्स के बाद चलते हैं (ऑडिट लॉगिंग के लिए बेस्ट)।
* **`NEW`** में आने वाली नई रो वैल्यूज होती हैं; **`OLD`** में बदलाव से पहले की पुरानी वैल्यूज होती हैं।
* इनवैलिड ट्रांजैक्शन्स को रिजेक्ट करने के लिए **`SIGNAL SQLSTATE '45000'`** का इस्तेमाल करें।
* ट्रिगर्स **उसी टेबल को मॉडिफाई नहीं कर सकते जिस पर वे लगे हैं** (Error 1442)।
* हाई-थ्रूपुट टेबल्स पर ट्रांजैक्शन लॉक कंटेन्शन से बचने के लिए ट्रिगर्स को हल्का और तेज़ रखें।
* आगे के अध्ययन के लिए अगले मॉड्यूल [Chapter 23 — Modern Analytics: Window Functions & JSON Manipulation](/hi/23_advanced_sql) पर बढ़ें।
