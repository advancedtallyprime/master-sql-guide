# Chapter 21 — Custom Logic: User-Defined Functions (UDFs) | कस्टम लॉजिक और यूज़र-डिफ़ाइंड फ़ंक्शन्स

---

## 1. What is it? (UDFs क्या हैं?)

MySQL में एक **User-Defined Function (UDF)** (या Stored Function) डेटाबेस कैटलॉग में स्टोर किया गया एक ऐसा कस्टम, रियूजेबल (reusable) कम्प्यूटेशनल रूटीन होता है जो शून्य या अधिक इनपुट पैरामीटर्स स्वीकार करता है, उन पर कैलकुलेशन करता है, और एक स्पष्ट `RETURN` स्टेटमेंट के ज़रिए **हमेशा ठीक एक स्केलर वैल्यू (single scalar value)** लौटाता है।

Stored Procedures (जिन्हें हम `CALL` स्टेटमेंट के ज़रिए अलग से रन करते हैं और जो कई रो और कॉलम्स का रिजल्ट सेट लौटा सकते हैं) के विपरीत, Stored Functions को SQL एक्सप्रेशन्स के **अंदर इनलाइन (inline)** इस्तेमाल करने के लिए डिज़ाइन किया गया है—जैसे `SELECT` लिस्ट में, `WHERE` क्लॉज़ में, `ORDER BY` में, या `HAVING` फिल्टर्स में—बिल्कुल वैसे ही जैसे आप MySQL के इनबिल्ट फ़ंक्शन्स (`ROUND()`, `UPPER()`, या `DATEDIFF()`) का इस्तेमाल करते हैं।

### Function Characteristics: Determinism और Data Access (फ़ंक्शन की विशेषताएँ)
जब आप MySQL में कोई स्टोर्ड फ़ंक्शन बनाते हैं, तो MySQL आपसे उसके ऑपरेशनल बिहेवियर को डिक्लेयर करने की माँग करता है:
* **`DETERMINISTIC`**: यह गारंटी देता है कि अगर फ़ंक्शन को बिल्कुल समान इनपुट आर्ग्युमेंट्स दिए जाएँ, तो वह **हमेशा (always)** बिल्कुल समान आउटपुट लौटाएगा (उदाहरण के लिए, सेल्सियस से फारेनहाइट कन्वर्ट करना: `(C * 9/5) + 32`)। डिटरमिनिस्टिक फ़ंक्शन्स को MySQL Generated Virtual Columns के ज़रिए इंडेक्स कर सकता है और क्वेरी ऑप्टिमाइज़र द्वारा बेहतर ढंग से ऑप्टिमाइज़ किया जा सकता है।
* **`NOT DETERMINISTIC`**: यह दर्शाता है कि समान आर्ग्युमेंट्स मिलने पर भी फ़ंक्शन का आउटपुट अलग-अलग कॉल्स में बदल सकता है (उदाहरण के लिए, ऐसे फ़ंक्शन्स जो `NOW()`, `RAND()`, या डायनामिक टेबल डेटा को क्वेरी करते हैं)।
* **Data Access Characteristics**:
  * `NO SQL`: फ़ंक्शन के अंदर कोई SQL स्टेटमेंट नहीं है (शुद्ध गणितीय या स्ट्रिंग मैनिपुलेशन)।
  * `READS SQL DATA`: फ़ंक्शन के अंदर `SELECT` क्वेरीज़ हैं जो टेबल के रिकॉर्ड्स को सिर्फ पढ़ती (read) हैं, लेकिन डेटा में कोई बदलाव नहीं करतीं।
  * `MODIFIES SQL DATA`: टेबल डेटा को मॉडिफाई करता है (जब फ़ंक्शन को किसी स्टैंडर्ड `SELECT` स्टेटमेंट के अंदर कॉल किया जाता है, तो यह पूरी तरह प्रतिबंधित यानी forbidden होता है)।

---

## 2. Stored Procedures vs Stored Functions: The Definitive Comparison (प्रोसीजर्स बनाम फंक्शन्स: विस्तृत तुलना)

| आर्किटेक्चरल डायमेंशन | Stored Procedure (`CREATE PROCEDURE`) | Stored Function (`CREATE FUNCTION`) |
| :--- | :--- | :--- |
| **एग्जीक्यूशन सिंटैक्स (Execution Syntax)** | `CALL sp_name(...)` के ज़रिए अलग से स्वतंत्र रूप से इनवोक किया जाता है। | SQL एक्सप्रेशन्स के **अंदर इनलाइन** कॉल किया जाता है: `SELECT fn_name(...)`। |
| **रिटर्न मैकेनिज़्म (Return Mechanism)** | शून्य, एक, या एकाधिक रिजल्ट सेट्स लौटा सकता है; वैल्यूज को `OUT`/`INOUT` पैरामीटर्स के ज़रिए लौटाता है। | `RETURN data_type` के ज़रिए **हमेशा ठीक एक स्केलर वैल्यू** लौटाना अनिवार्य है। |
| **ट्रांजैक्शन कंट्रोल (Transaction Control)** | ट्रांजैक्शन्स को मैनेज कर सकता है (`START TRANSACTION`, `COMMIT`, `ROLLBACK`)। | **ट्रांजैक्शन कंट्रोल स्टेटमेंट्स रन नहीं कर सकता** (`COMMIT`/`ROLLBACK` पूरी तरह वर्जित हैं)। |
| **DML क्षमताएं (DML Capabilities)** | कोई भी `INSERT`, `UPDATE`, `DELETE`, और DDL स्टेटमेंट्स एग्जीक्यूट कर सकता है। | जब इसे किसी `SELECT` स्टेटमेंट से कॉल किया जाए, तो यह बेस टेबल्स पर DML नहीं चला सकता। |
| **क्लॉज़ेस में उपयोग (Usage in Clauses)** | `WHERE`, `JOIN`, या `ORDER BY` के अंदर इस्तेमाल नहीं किया जा सकता। | सीधे `WHERE`, `SELECT`, `HAVING`, और `JOIN` के अंदर एम्बेड किया जा सकता है। |

---

## 3. Syntax (सिंटैक्स और स्ट्रक्चर)

```sql
DELIMITER //

CREATE FUNCTION function_name (
    param1 data_type,
    param2 data_type
)
RETURNS return_data_type
[DETERMINISTIC | NOT DETERMINISTIC]
[NO SQL | READS SQL DATA]
BEGIN
    -- Local variables
    DECLARE v_result return_data_type;

    -- Business logic
    SET v_result = ...;

    -- Must terminate with a RETURN statement
    RETURN v_result;
END //

DELIMITER ;

-- Manage Functions
DROP FUNCTION IF EXISTS function_name;
SHOW CREATE FUNCTION function_name;
```

---

## 4. Basic Example (बेसिक प्रैक्टिकल उदाहरण)

यहाँ हम एक शुद्ध डिटरमिनिस्टिक स्केलर फ़ंक्शन बना रहे हैं जो टैक्स के साथ टोटल कॉस्ट कैलकुलेट करता है:

```sql
USE sql_mastery;

DELIMITER //

CREATE FUNCTION fn_calculate_sales_tax(
    p_subtotal DECIMAL(10, 2),
    p_tax_rate DECIMAL(4, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_tax_amount DECIMAL(10, 2);
    SET v_tax_amount = ROUND(p_subtotal * p_tax_rate, 2);
    RETURN p_subtotal + v_tax_amount;
END //

DELIMITER ;

-- Test the function inline within a standard SELECT query
SELECT 
    product_name,
    unit_price,
    fn_calculate_sales_tax(unit_price, 0.08) AS price_with_8pct_tax
FROM products
LIMIT 3;

-- Clean up
DROP FUNCTION fn_calculate_sales_tax;
```

---

## 5. Real-World Business Example (वास्तविक बिज़नेस उदाहरण)

मान लीजिए कि हमारी एंटरप्राइज फाइनेंस टीम को एक स्टैंडर्ड कस्टमर क्लासिफिकेशन फ़ंक्शन चाहिए जिसका नाम `fn_get_customer_tier` हो। यह फ़ंक्शन कस्टमर के कुल लॉयल्टी पॉइंट्स और लाइफटाइम नॉन-कैंसिल्ड ऑर्डर वैल्यू का मूल्यांकन करेगा, और एक स्टैंडर्ड टियर लेबल लौटाएगा (`'Platinum'`, `'Gold'`, `'Silver'`, या `'Standard'`):

```sql
USE sql_mastery;

DELIMITER //

CREATE FUNCTION fn_get_customer_tier(p_customer_id INT)
RETURNS VARCHAR(20)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_points INT;
    DECLARE v_total_spend DECIMAL(12, 2);
    DECLARE v_tier VARCHAR(20);

    -- Retrieve customer loyalty points
    SELECT loyalty_points INTO v_points
    FROM customers
    WHERE customer_id = p_customer_id;

    -- Retrieve customer lifetime spending
    SELECT COALESCE(SUM(total_amount), 0.00) INTO v_total_spend
    FROM orders
    WHERE customer_id = p_customer_id AND status != 'Cancelled';

    -- Evaluate customer tier using combined multi-variable logic
    IF v_points >= 600 AND v_total_spend >= 1000.00 THEN
        SET v_tier = 'Platinum';
    ELSEIF v_points >= 300 OR v_total_spend >= 500.00 THEN
        SET v_tier = 'Gold';
    ELSEIF v_points >= 100 THEN
        SET v_tier = 'Silver';
    ELSE
        SET v_tier = 'Standard';
    END IF;

    RETURN v_tier;
END //

DELIMITER ;

-- Query customers using our custom function directly in the SELECT list and WHERE clause!
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    loyalty_points,
    fn_get_customer_tier(customer_id) AS membership_tier
FROM customers
ORDER BY loyalty_points DESC;
```

---

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

1. `CREATE FUNCTION fn_get_customer_tier(...) RETURNS VARCHAR(20)`:
   * यह फ़ंक्शन को कंपाइल करता है और MySQL डेटा डिक्शनरी / `mysql.proc` में रजिस्टर करता है।
2. `NOT DETERMINISTIC READS SQL DATA`:
   * यह MySQL इंजन को बताता है कि यह फ़ंक्शन डायनामिक टेबल डेटा (`customers` और `orders`) को पढ़ता है, जिसका मतलब है कि अगर कोई नया ऑर्डर इंसर्ट होता है तो समान `customer_id` के लिए भी आउटपुट बदल सकता है।
3. `SELECT loyalty_points INTO v_points ...`:
   * यह निर्दिष्ट कस्टमर के मौजूदा लॉयल्टी पॉइंट बैलेंस को लोकल वेरिएबल `v_points` में स्टोर करता है।
4. `SELECT COALESCE(SUM(total_amount), 0.00) INTO v_total_spend ...`:
   * यह कस्टमर के लाइफटाइम नॉन-कैंसिल्ड ऑर्डर्स का कुल खर्च निकालता है, और `COALESCE` के ज़रिए `NULL` को `0.00` में सुरक्षित रूप से बदल देता है।
5. `IF ... ELSEIF ... END IF`:
   * यह बिज़नेस रूल्स का मूल्यांकन करता है और उचित टियर स्ट्रिंग असाइन करता है।
6. `RETURN v_tier;`:
   * यह स्केलर रिजल्ट को वापस बाहरी SQL क्वेरी इंजन को भेजता है, जो इसे सीधे रिजल्ट सेट की स्ट्रीम में शामिल कर लेता है।

---

## 7. Expected Result (अपेक्षित आउटपुट)

कस्टमर टियर क्वेरी का आउटपुट:

```
+-------------+-------------------+----------------+-----------------+
| customer_id | customer_name     | loyalty_points | membership_tier |
+-------------+-------------------+----------------+-----------------+
|          10 | Ethan Hunt        |            940 | Gold            |
|           3 | Sophia Garcia     |            750 | Gold            |
|           5 | Aisha Khan        |            610 | Platinum        |
|           9 | Chloe Dubois      |            480 | Gold            |
|           1 | Emily Watson      |            420 | Platinum        |
|           6 | Lucas Muller      |            310 | Gold            |
|           8 | Mateo Silva       |            290 | Silver          |
|           2 | Michael Brown     |            180 | Silver          |
|           4 | James Wilson      |             90 | Gold            |
|           7 | Hannah Scott      |             50 | Standard        |
+-------------+-------------------+----------------+-----------------+
10 rows in set (0.01 sec)
```
*(ध्यान दें कि Customer 5 [Aisha] और Customer 1 [Emily] प्लेटिनम के योग्य हैं क्योंकि उनके पॉइंट्स 600/300 से अधिक हैं और उनका कुल लाइफटाइम खर्च \$1,000 से अधिक है)।*

---

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **Determinism डिक्लेयर न करना (MySQL Error 1418)**:
   * *The Error*:
     `ERROR 1418 (HY000): This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled`
   * *Why?*: जब MySQL में बाइनरी लॉगिंग इनेबल होती है (जैसे रेप्लिकेशन के लिए), तो MySQL को यह गारंटी चाहिए होती है कि रेप्लिका सर्वर्स पर भी कोड का एग्जीक्यूशन समान डेटा जनरेट करे। इसलिए हर फ़ंक्शन को `DETERMINISTIC` या उचित डेटा एक्सेस क्लॉज़ के साथ मार्क करना अनिवार्य है।
2. **बड़ी क्वेरीज़ में टेबल्स पढ़ने वाले फ़ंक्शन्स कॉल करना ($N+1$ Problem)**:
   * अगर आप 100,000 पंक्तियों वाली किसी क्वेरी में `fn_get_customer_tier(customer_id)` जैसा फ़ंक्शन कॉल करते हैं, तो डेटाबेस हर एक पंक्ति के लिए फ़ंक्शन चलाएगा और 100,000 अलग-अलग सबक्वेरीज़ एग्जीक्यूट करेगा! इससे क्वेरी परफ़ॉर्मेंस क्रैश हो जाएगी। बड़े डेटासेट्स के लिए, पंक्ति-दर-पंक्ति फ़ंक्शन कॉल्स के बजाय सेट-बेस्ड `LEFT JOIN` और `CASE` एक्सप्रेशन्स का उपयोग करें।
3. **फ़ंक्शन के अंदर ट्रांजैक्शन्स चलाने की कोशिश करना**:
   * फ़ंक्शन के अंदर `START TRANSACTION;` या `COMMIT;` लिखने पर कंपाइलेशन एरर आता है:
     `ERROR 1422 (HY000): Explicit or implicit commit is not allowed in stored function`.

---

## 9. Best Practices (सर्वोत्तम तरीके और टिप्स)

1. **फ़ंक्शन्स को छोटा, शुद्ध और तेज़ रखें**:
   * आदर्श फ़ंक्शन्स शुद्ध स्केलर यूटिलिटीज़ होते हैं (जैसे टैक्स कैलकुलेशन, ईमेल पैटर्न वैलिडेशन, फ़ोन नंबर फ़ॉर्मेटिंग, करेंसी कन्वर्ज़न)।
2. **कस्टम फ़ंक्शन्स के नाम के आगे प्रीफ़िक्स लगाएँ**:
   * फ़ंक्शन्स के नाम `fn_` या `udf_` से शुरू करें (जैसे `fn_calculate_tax`), ताकि वे MySQL के नेटिव इनबिल्ट फ़ंक्शन्स से साफ़ अलग दिखें।
3. **Generated Virtual Columns को बैक करने के लिए Deterministic फ़ंक्शन्स का उपयोग करें**:
   * आप किसी टेबल में डिटरमिनिस्टिक फ़ंक्शन का उपयोग करके जनरेटेड कॉलम बना सकते हैं और उस पर इंडेक्स भी लगा सकते हैं:
     ```sql
     ALTER TABLE products ADD COLUMN discounted_price DECIMAL(10,2) 
     AS (fn_calculate_discount(unit_price)) STORED;
     CREATE INDEX idx_discounted_price ON products(discounted_price);
     ```

---

## 10. Practice Questions (अभ्यास के लिए प्रश्न)

### Easy
1. Stored Procedure और User-Defined Function में मूलभूत ऑपरेशनल अंतर क्या है?
2. किसी स्टोर्ड फ़ंक्शन की बॉडी से रिज़ल्ट वापस भेजने के लिए कौन सा कीवर्ड अनिवार्य है?
3. कौन सा कीवर्ड यह घोषित करता है कि एक फ़ंक्शन समान इनपुट के लिए हमेशा समान आउटपुट लौटाएगा?

### Medium
4. `fn_celsius_to_fahrenheit` नाम से एक डिटरमिनिस्टिक फ़ंक्शन लिखें जो सेल्सियस में `DECIMAL(5,2)` टेम्परेचर स्वीकार करे और फ़ारेनहाइट वैल्यू (`(C * 9/5) + 32`) लौटाए।
5. `fn_format_phone` नाम से एक फ़ंक्शन लिखें जो 7-अंकों की स्ट्रिंग (जैसे `'5550100'`) को स्वीकार करे और उसे डैश के साथ फ़ॉर्मेट करे (जैसे `'555-0100'`)।
6. `fn_get_employee_tenure` नाम से एक फ़ंक्शन लिखें जो `employee_id` स्वीकार करे और `employees` टेबल को क्वेरी करके उनकी कुल वर्षों में नौकरी की अवधि (tenure in complete years) लौटाए।

### Difficult
7. समझाइए कि MySQL किसी ऐसे फ़ंक्शन के अंदर ट्रांजैक्शन्स (`COMMIT` / `ROLLBACK`) चलाने या बेस टेबल्स को मॉडिफाई करने पर रोक क्यों लगाता है जिसे `SELECT` स्टेटमेंट में इनवोक किया गया हो?
8. `SELECT fn_get_customer_tier(customer_id) FROM customers;` चलाने बनाम इसके समकक्ष सेट-बेस्ड `LEFT JOIN ... GROUP BY ... CASE` क्वेरी लिखने के एग्जीक्यूशन प्लान और परफ़ॉर्मेंस की तुलना करें। किन परिस्थितियों में सेट-बेस्ड क्वेरी फ़ंक्शन की तुलना में कई गुना बेहतर परफ़ॉर्म करेगी?

---

## 11. Interview Questions (इंटरव्यू सवाल और जवाब)

### Q1: MySQL में Stored Procedure और Stored Function में क्या अंतर होता है?
**उत्तर**:
1. **कॉलिंग कॉन्टेक्स्ट (Calling Context)**: Procedures को `CALL procedure_name(...)` स्टेटमेंट के ज़रिए अलग से रन किया जाता है। Functions को SQL एक्सप्रेशन्स के अंदर इनलाइन कॉल किया जाता है (जैसे `SELECT fn(col) FROM table`)।
2. **रिटर्न बाधाएं (Return Constraints)**: Procedure एक से अधिक रिजल्ट सेट्स लौटा सकता है, या `OUT`/`INOUT` पैरामीटर्स के ज़रिए कई वैल्यूज लौटा सकता है। Function को `RETURN` कीवर्ड का इस्तेमाल करके **ठीक एक स्केलर वैल्यू** लौटाना अनिवार्य होता है।
3. **ट्रांजैक्शन कंट्रोल (Transaction Control)**: Procedures ट्रांजैक्शन्स को मैनेज कर सकते हैं (`START TRANSACTION`, `COMMIT`, `ROLLBACK`)। Functions ट्रांजैक्शन कंट्रोल स्टेटमेंट्स एग्जीक्यूट नहीं कर सकते।
4. **साइड इफेक्ट्स (Side Effects)**: `SELECT` स्टेटमेंट में इनवोक किए जाने वाले फ़ंक्शन्स बेस टेबल्स पर डेटा मॉडिफाई (`INSERT`, `UPDATE`, या `DELETE`) नहीं कर सकते, जिससे यह गारंटी मिलती है कि केवल पढ़ने वाली क्वेरीज़ सिस्टम स्टेट में कोई बदलाव न करें।

### Q2: MySQL फ़ंक्शन्स में `DETERMINISTIC` कीवर्ड का क्या महत्व है?
**उत्तर**: `DETERMINISTIC` कीवर्ड क्वेरी ऑप्टिमाइज़र को सूचित करता है कि यह फ़ंक्शन समान इनपुट पैरामीटर्स मिलने पर हमेशा बिल्कुल समान आउटपुट लौटाएगा।
इसका महत्व:
1. **ऑप्टिमाइज़ेशन**: क्वेरी ऑप्टिमाइज़र फ़ंक्शन के रिज़ल्ट्स को कैश कर सकता है, सबक्वेरीज़ को ऑप्टिमाइज़ कर सकता है, और टेबल स्कैन के दौरान समान वैल्यूज के लिए फ़ंक्शन को बार-बार दोबारा रन करने से बच सकता है।
2. **जनरेटेड कॉलम्स**: केवल डिटरमिनिस्टिक फ़ंक्शन्स का इस्तेमाल करके ही MySQL टेबल्स में वर्चुअल या स्टोर्ड जनरेटेड कॉलम्स डिफाइन किए जा सकते हैं।
3. **रेप्लिकेशन सुरक्षा**: बाइनरी लॉगिंग वाले एनवायरनमेंट में, MySQL यह सुनिश्चित करने के लिए फ़ंक्शन्स को `DETERMINISTIC` घोषित करने की माँग करता है ताकि प्राइमरी और रेप्लिका सर्वर्स के बीच डेटा में कोई विसंगति (inconsistency) पैदा न हो।

### Q3: `SELECT` स्टेटमेंट के अंदर टेबल क्वेरी करने वाले फ़ंक्शन्स का इस्तेमाल करते समय "N+1 Problem" क्या होती है?
**उत्तर**: जब किसी स्टोर्ड फ़ंक्शन में `SELECT` क्वेरी शामिल होती है (जैसे किसी कस्टमर के कुल ऑर्डर खर्च की गणना) और उसे बाहरी क्वेरी के प्रोजेक्शन में कॉल किया जाता है (`SELECT customer_id, fn_get_lifetime_spend(customer_id) FROM customers`), तो डेटाबेस पहले $N$ कस्टमर्स को फेच करने के लिए 1 क्वेरी चलाता है, और फिर प्रत्येक रो के लिए अलग से फ़ंक्शन कॉल करके $N$ अतिरिक्त सबक्वेरीज़ चलाता है। इससे कुल $N+1$ क्वेरीज़ रन होती हैं। बड़े डेटासेट्स (जैसे 100,000 कस्टमर्स) पर यह डिस्क I/O को बहुत ज़्यादा बढ़ा देता है। इसे हमेशा `customers` और `orders` के बीच सेट-बेस्ड `LEFT JOIN` और एग्रीगेशन लिखकर हल करना चाहिए।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* **User-Defined Functions (UDFs)** हमेशा **ठीक एक स्केलर वैल्यू** लौटाते हैं और SQL क्वेरीज़ के अंदर **इनलाइन** रन होते हैं।
* फ़ंक्शन्स **ट्रांजैक्शन्स को मैनेज नहीं कर सकते** (`COMMIT`/`ROLLBACK` वर्जित हैं)।
* अगर समान इनपुट हमेशा समान आउटपुट दे, तो फ़ंक्शन को **`DETERMINISTIC`** मार्क करें।
* बाइनरी लॉगिंग एरर (Error 1418) से बचने के लिए **`READS SQL DATA`** या **`NO SQL`** क्लॉज़ का उपयोग करें।
* बड़े डेटासेट्स पर **N+1 क्वेरी समस्या** से बचने के लिए फ़ंक्शन के अंदर पंक्ति-दर-पंक्ति टेबल क्वेरी करने से बचें।
* आगे के अध्ययन के लिए अगले मॉड्यूल [Chapter 22 — Event-Driven Architecture: MySQL Triggers](/hi/22_triggers) पर बढ़ें।
