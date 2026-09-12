# अध्याय 32 — हाई-यील्ड रैपिड रिविजन गाइड और नॉलेज चेकपॉइंट्स (Rapid Revision Guide)

कोर SQL और MySQL डोमेन्स के मॉड्युलर चेकपॉइंट्स में व्यवस्थित एक रैपिड-रिव्यू स्टडी गाइड। इस अध्याय का उपयोग लास्ट-मिनट इंटरव्यू की तैयारी, परीक्षा से पहले रिविजन, या क्विक रिफ्रेशर चेक के लिए करें।

---

## Checkpoint 1: डेटाबेस और टेबल मैनेजमेंट (DDL)

### आपको क्या पता होना चाहिए (What You Should Know)
* DDL कमांड्स (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`) स्कीमा स्ट्रक्चर्स को मैनेज करते हैं और MySQL में **इंप्लिसिट ट्रांजैक्शन कमिट्स (implicit transaction commits)** ट्रिगर करते हैं।
* `TRUNCATE` टेबल पेजेज को डीएलोकेट करता है और ऑटो-इन्क्रीमेंट सीक्वेंसेस को रीसेट करता है; `DELETE` रो-दर-रो (one-by-one) डेटा हटाता है; `DROP` पूरी टेबल स्कीमा और फाइल्स को नष्ट कर देता है।
* फुल मल्टी-बाइट यूनिकोड और इमोजीस को सपोर्ट करने के लिए हमेशा `utf8mb4` एन्कोडिंग के साथ डेटाबेस डिक्लेयर करें।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
```sql
CREATE DATABASE IF NOT EXISTS app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(100) NOT NULL UNIQUE);
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;
ALTER TABLE users MODIFY COLUMN phone VARCHAR(30) NOT NULL;
ALTER TABLE users CHANGE COLUMN phone contact_phone VARCHAR(30) NOT NULL;
DROP TABLE IF EXISTS users;
```

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: ट्रांजैक्शन ब्लॉक के अंदर `DROP TABLE` या `TRUNCATE` को रोलबैक करने का प्रयास करना (`ROLLBACK` का DDL पर कोई प्रभाव नहीं पड़ता)।
* **Trap**: `MODIFY` (जो नाम सुरक्षित रखता है) और `CHANGE` (जिसमें पुराने और नए दोनों कॉलम नामों की आवश्यकता होती है) के बीच भ्रमित होना।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *जब किसी टेबल को TRUNCATE किया जाता है बनाम जब सभी पंक्तियों को DELETE किया जाता है, तो AUTO_INCREMENT काउंटर का क्या होता है?* $\rightarrow$ Truncate इसे 1 पर रीसेट करता है; Delete मौजूदा काउंटर को बनाए रखता है।
2. *क्या किसी टेबल में एकाधिक (multiple) प्राइमरी की हो सकती हैं?* $\rightarrow$ नहीं, केवल एक प्राइमरी की हो सकती है (हालाँकि यह कई कॉलम्स की कम्पोजिट की हो सकती है)।
3. *MySQL में `utf8` की तुलना में `utf8mb4` को प्राथमिकता क्यों दी जाती है?* $\rightarrow$ MySQL का लीगेसी `utf8` केवल 3-बाइट कैरेक्टर्स को सपोर्ट करता है, जिससे इमोजी और 4-बाइट यूनिकोड कैरेक्टर्स पर एरर आता है।
4. *आप टेबल की शुरुआत में सबसे पहला कॉलम कैसे जोड़ते हैं?* $\rightarrow$ `FIRST` कीवर्ड का उपयोग करके: `ALTER TABLE t ADD COLUMN col INT FIRST;`।
5. *यदि आप किसी एक्टिव फॉरेन की द्वारा संदर्भित पैरेंट टेबल को ड्रॉप करने का प्रयास करते हैं तो कौन सा एरर आता है?* $\rightarrow$ Error 3730: Cannot drop table referenced by a foreign key constraint.

### प्रैक्टिकल चैलेंज (Practical Challenge)
एक आइडम्पोटेंट (idempotent) DDL स्क्रिप्ट लिखें जो सुरक्षित रूप से एक `order_archive` टेबल बनाए, एक इंडेक्स्ड `archived_at` टाइमस्टैम्प जोड़े, और यदि डिप्रिकेटेड `notes` कॉलम मौजूद हो तो उसे ड्रॉप करे।

---

## Checkpoint 2: डेटा टाइप्स और इंटीग्रिटी कंस्ट्रेंट्स (Data Types & Constraints)

### आपको क्या पता होना चाहिए (What You Should Know)
* मनी/करेंसी के लिए हमेशा `DECIMAL(M, D)` का उपयोग करें; IEEE 754 फ्लोटिंग-पॉइंट राउंडिंग ड्रिफ्ट के कारण कभी भी `FLOAT` या `DOUBLE` का उपयोग न करें।
* InnoDB में, `PRIMARY KEY` फिजिकल **क्लस्टर इंडेक्स (clustered index)** को परिभाषित करती है; बड़े, रैंडम UUID स्ट्रिंग्स की तुलना में कॉम्पैक्ट इंटीजर कीज (`INT UNSIGNED`) अत्यधिक बेहतर हैं।
* MySQL में `UNIQUE` कंस्ट्रेंट्स कई `NULL` वैल्यूज की अनुमति देते हैं, जब तक कि उन्हें स्पष्ट रूप से `NOT NULL` डिक्लेयर न किया गया हो।
* MySQL 8.0.16+ में `CHECK` कंस्ट्रेंट्स पूरी तरह से एनफोर्स किए जाते हैं।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
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

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: कंट्री कोड्स जैसी फिक्स्ड-लेंथ स्ट्रिंग्स के लिए `VARCHAR` का उपयोग करना (`CHAR(2)` बहुत अधिक कुशल और स्पेस-ऑप्टिमाइज्ड है)।
* **Trap**: 19 जनवरी 2038 के बाद की तारीखों के लिए 32-बिट `TIMESTAMP` पर निर्भर रहना (इसके बजाय `DATETIME` का उपयोग करें)।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *सटीक मौद्रिक राशियों (monetary amounts) को स्टोर करने के लिए आपको किस डेटा टाइप का उपयोग करना चाहिए?* $\rightarrow$ `DECIMAL(M, D)` या `NUMERIC(M, D)`।
2. *क्या UNIQUE मार्क किया गया कॉलम NULL मानों की अनुमति देता है?* $\rightarrow$ हाँ, जब तक कि `NOT NULL` भी निर्दिष्ट न किया गया हो, एकाधिक NULLs की अनुमति होती है।
3. *`ON DELETE CASCADE` और `ON DELETE RESTRICT` के बीच क्या अंतर है?* $\rightarrow$ Cascade चाइल्ड पंक्तियों को स्वचालित रूप से हटा देता है; Restrict पैरेंट रो को डिलीट होने से रोकता है यदि संबंधित चाइल्ड पंक्तियाँ मौजूद हैं।
4. *बूलियन के लिए कौन सा MySQL प्रकार उपयोग होता है?* $\rightarrow$ `TINYINT(1)`।
5. *प्राइमरी कीज को `UNSIGNED` क्यों मार्क किया जाना चाहिए?* $\rightarrow$ प्राइमरी की काउंटर्स में कभी भी नेगेटिव नंबर्स नहीं होते हैं, और `UNSIGNED` अतिरिक्त स्टोरेज बाइट्स का उपभोग किए बिना पॉजिटिव एड्रेसेबल रेंज को दोगुना कर देता है।

### प्रैक्टिकल चैलेंज (Practical Challenge)
एक `transactions` टेबल बनाएं जिसमें `accounts` को संदर्भित करने वाली फॉरेन की हो, एक नामित `CHECK` कंस्ट्रेंट के माध्यम से `amount > 0` सुनिश्चित करें, और `(account_id, transaction_ref)` पर कम्पोजिट यूनिक कंस्ट्रेंट का उपयोग करके डुप्लीकेट ट्रांजेक्शन्स को रोकें।

---

## Checkpoint 3: फिल्टरिंग, सॉर्टिंग और फंक्शन्स (Filtering, Sorting & Functions)

### आपको क्या पता होना चाहिए (What You Should Know)
* SQL **थ्री-वैल्यूड लॉजिक (3VL)** का उपयोग करता है: `TRUE`, `FALSE`, `UNKNOWN`। `NULL` से किसी भी चीज़ की तुलना करने पर `UNKNOWN` प्राप्त होता है, जिसे `WHERE` क्लॉज बाहर कर देता है। हमेशा `IS NULL` का उपयोग करें।
* `AND` की प्राथमिकता `OR` से अधिक होती है; लॉजिकल एक्सप्रेशन्स को ग्रुप करने के लिए हमेशा कोष्ठक (parentheses) का उपयोग करें।
* `BETWEEN val1 AND val2` दोनों बाउंड्री वैल्यूज को शामिल (inclusive) करता है।
* MySQL में, `NULL` को सबसे छोटे मान के रूप में माना जाता है (`ASC` में सबसे पहले, `DESC` में सबसे अंत में)।
* सभी एग्रीगेट फंक्शन्स (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) `NULL`s को अनदेखा करते हैं; केवल `COUNT(*)` भौतिक पंक्तियों की गिनती करता है।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
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

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: `WHERE email = NULL` लिखना (यह एम्प्टी सेट लौटाता है; आपको `WHERE email IS NULL` लिखना चाहिए)।
* **Trap**: `WHERE col NOT IN (1, 2, NULL)` लिखना (यह एम्प्टी सेट लौटाता है क्योंकि NULL के विरुद्ध तुलना UNKNOWN उत्पन्न करती है)।
* **Trap**: `WHERE` क्लॉज में इंडेक्स्ड कॉलम्स को फंक्शन्स में रैप करना (जैसे `WHERE YEAR(date_col) = 2023` SARGability को नष्ट करता है और फुल टेबल स्कैन करने पर मजबूर करता है)।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *`SELECT (NULL = NULL)` का परिणाम क्या होगा?* $\rightarrow$ `NULL` (UNKNOWN)।
2. *MySQL में NULL-Safe समानता जांच कैसे लिखते हैं?* $\rightarrow$ `<=>` ऑपरेटर का उपयोग करके (उदा. `NULL <=> NULL` 1/TRUE लौटाता है)।
3. *`LENGTH()` और `CHAR_LENGTH()` में क्या अंतर है?* $\rightarrow$ `LENGTH()` बाइट्स की गिनती करता है; `CHAR_LENGTH()` UTF-8 कैरेक्टर्स की गिनती करता है।
4. *यदि `CONCAT()` का कोई एक तर्क (argument) `NULL` हो तो यह कैसा व्यवहार करता है?* $\rightarrow$ यह पूरी स्ट्रिंग के लिए `NULL` लौटाता है।
5. *MySQL में आरोही (ascending) क्रम में सॉर्ट करते समय NULL मानों को सबसे अंत में कैसे लाएं?* $\rightarrow$ `ORDER BY col IS NULL ASC, col ASC`।

### प्रैक्टिकल चैलेंज (Practical Challenge)
`customers` टेबल पर एक क्वेरी लिखें जो उन सभी कस्टमर्स को सेलेक्ट करे जिनका लास्ट नेम किसी वोवेल (स्वर) से शुरू होता है, उनकी रजिस्ट्रेशन डेट को `'Month Day, Year'` में फॉर्मेट करे, और `CASE` स्टेटमेंट का उपयोग करके उनके कस्टमर टियर की गणना करे।

---

## Checkpoint 4: ग्रुपिंग, एग्रीगेशन और रिलेशनल जॉइन्स (Grouping & Joins)

### आपको क्या पता होना चाहिए (What You Should Know)
* लॉजिकल एग्जीक्यूशन ऑर्डर: `FROM` $\rightarrow$ `WHERE` $\rightarrow$ `GROUP BY` $\rightarrow$ `HAVING` $\rightarrow$ `SELECT` $\rightarrow$ `DISTINCT` $\rightarrow$ `ORDER BY` $\rightarrow$ `LIMIT`।
* `WHERE` ग्रुपिंग से *पहले* पंक्तियों को फिल्टर करता है; `HAVING` ग्रुपिंग के *बाद* एग्रीगेटेड बकेट्स को फिल्टर करता है।
* `ONLY_FULL_GROUP_BY` के तहत, प्रत्येक प्रोजेक्टेड कॉलम को या तो `GROUP BY` क्लॉज में दिखाई देना चाहिए या किसी एग्रीगेट फंक्शन के अंदर रैप होना चाहिए।
* `INNER JOIN` मैचिंग पंक्तियों को लौटाता है; `LEFT JOIN` सभी लेफ्ट-टेबल पंक्तियों को सुरक्षित रखता है; एंटी-जॉइन (`LEFT JOIN ... WHERE right.key IS NULL`) मिसिंग लिंक्स को खोजता है।
* एक `Self JOIN` हायरार्कीज को मॉडल करने के लिए दो अलग-अलग एलियास का उपयोग करके किसी टेबल को खुद से जोड़ता है।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
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

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: `WHERE` क्लॉज के अंदर एग्रीगेट फंक्शन्स रखना (`WHERE AVG(salary) > 50000` अमान्य सिंटैक्स है)।
* **Trap**: `LEFT JOIN` के `WHERE` क्लॉज में राइट टेबल पर फिल्टर लगाना (यह साइलेंटली `LEFT JOIN` को `INNER JOIN` में बदल देता है)।
* **Trap**: जॉइन कंडीशन्स को छोड़ देना, जिससे कार्टेशियन प्रोडक्ट (`CROSS JOIN`) बन जाता है।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *आप WHERE क्लॉज के अंदर एग्रीगेट फंक्शन्स का उपयोग क्यों नहीं कर सकते?* $\rightarrow$ क्योंकि `WHERE` ग्रुप्स और एग्रीगेट्स बनने से पहले निष्पादित होता है।
2. *`UNION` और `UNION ALL` में क्या अंतर है?* $\rightarrow$ `UNION` डुप्लिकेट पंक्तियों को हटाता है (सॉर्टिंग ओवरहेड शामिल होता है); `UNION ALL` सभी पंक्तियों को सीधे सुरक्षित रखता है।
3. *`GROUP_CONCAT()` क्या करता है?* $\rightarrow$ प्रत्येक ग्रुप के नॉन-नल मानों को एक एकल स्ट्रिंग में संयोजित करता है।
4. *Self JOIN कैसे काम करता है?* $\rightarrow$ दो अलग-अलग टेबल एलियास का उपयोग करके किसी टेबल को खुद से जोड़कर।
5. *MySQL में FULL OUTER JOIN का एम्यूलेशन कौन सा क्लॉज करता है?* $\rightarrow$ `UNION` के साथ `LEFT JOIN` और `RIGHT JOIN` को मिलाकर।

### प्रैक्टिकल चैलेंज (Practical Challenge)
प्रत्येक प्रोडक्ट कैटेगरी द्वारा जनरेट किए गए कुल रेवेन्यू की गणना करने वाली एक क्वेरी लिखें, जिसमें कैटेगरी का नाम, बेची गई कुल मात्रा, सकल राजस्व (gross revenue), और लागू किया गया औसत डिस्काउंट प्रदर्शित हो। केवल उन्हीं कैटेगरीज को शामिल करने के लिए फ़िल्टर करें जिन्होंने सकल राजस्व में $1,000 से अधिक उत्पन्न किया है।

---

## Checkpoint 5: सबक्वेरीज, विंडो फंक्शन्स और CTEs (Subqueries & CTEs)

### आपको क्या पता होना चाहिए (What You Should Know)
* सबक्वेरीज स्केलर वैल्यूज (1x1), वैल्यूज के कॉलम्स, या डिराइव्ड टेबल्स (जिन्हें एलियास की आवश्यकता होती है) लौटाती हैं।
* कोरिलेटेड सबक्वेरीज आउटर क्वेरी कॉलम्स को संदर्भित करती हैं और प्रत्येक बाहरी पंक्ति के लिए निष्पादित होती हैं।
* `EXISTS` ऑपरेटर `IN` की तुलना में अधिक सुरक्षित और तेज़ है क्योंकि यह पहले मैच पर ही शॉर्ट-सर्किट हो जाता है और NULLs को सुरक्षित रूप से हैंडल करता है।
* विंडो फंक्शन्स संबंधित पंक्तियों को **कोलैप्स किए बिना** गणना करते हैं।
* `OVER()` क्लॉज पार्टीशन्स (`PARTITION BY`), ऑर्डरिंग (`ORDER BY`), और फ्रेम्स (`ROWS BETWEEN ...`) को परिभाषित करता है।
* CTEs (`WITH ...`) जटिल क्वेरीज को मॉड्यूलर बनाते हैं और रिकर्शन (`WITH RECURSIVE`) को सपोर्ट करते हैं।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
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

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: `FROM` क्लॉज में डिराइव्ड टेबल को एलियास देना भूल जाना (`ERROR 1248: Every derived table must have its own alias`)।
* **Trap**: `WHERE` क्लॉज के अंदर सीधे विंडो फंक्शन का उपयोग करने का प्रयास करना (इसे पहले CTE या सबक्वेरी में लपेटना होगा)।
* **Trap**: `RANK()` (जो बराबरी होने पर नंबर स्किप करता है) और `DENSE_RANK()` (बराबरी पर कोई गैप नहीं छोड़ता) के बीच भ्रमित होना।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *`ROW_NUMBER()` और `DENSE_RANK()` में क्या अंतर है?* $\rightarrow$ `ROW_NUMBER()` कभी भी टाई (बराबरी) उत्पन्न नहीं करता ($1, 2, 3$); `DENSE_RANK()` टाई होने पर नंबर स्किप किए बिना समान रैंक प्रदान करता है ($1, 2, 2, 3$)।
2. *`LAG(col, 1)` क्या करता है?* $\rightarrow$ ठीक पिछली पंक्ति से `col` के मान को एक्सेस करता है।
3. *रिकर्सिव CTE में किन दो भागों की आवश्यकता होती है?* $\rightarrow$ एंकर मेंबर (Anchor Member) और रिकर्सिव मेंबर (Recursive Member), जो `UNION ALL` से जुड़े होते हैं।
4. *क्या एकाधिक पंक्तियाँ लौटाने वाली सबक्वेरी का उपयोग `=` ऑपरेटर के साथ किया जा सकता है?* $\rightarrow$ नहीं, यह `ERROR 1242: Subquery returns more than 1 row` ट्रिगर करता है। इसके बजाय `IN` या `ANY` का उपयोग करें।
5. *MySQL JSON कॉलम से अनकोटेड स्ट्रिंग निकालने के लिए कौन सा ऑपरेटर उपयोग होता है?* $\rightarrow$ `->>` ऑपरेटर।

### प्रैक्टिकल चैलेंज (Practical Challenge)
प्योर SQL में फाइबोनैचि सीक्वेंस की पहली 10 संख्याओं को जनरेट करने वाला एक रिकर्सिव CTE लिखें।

---

## Checkpoint 6: ट्रांजेक्शन्स, कॉनकरेंसी और लॉकिंग (Transactions & Locking)

### आपको क्या पता होना चाहिए (What You Should Know)
* ACID गारंटियाँ: **Atomicity** (Undo log), **Consistency** (स्कीमा इनवेरिएंट्स), **Isolation** (MVCC और लॉक्स), **Durability** (Redo log / WAL)।
* MySQL का डिफॉल्ट आइसोलेशन लेवल **`REPEATABLE READ`** है, जो डर्टी, नॉन-रिपीटेबल और फैंटम रीड्स को रोकता है।
* `SELECT ... FOR UPDATE` एक एक्सक्लूसिव लॉक (X-lock) हासिल करता है, जो अन्य ट्रांजेक्शन्स को उन पंक्तियों को संशोधित या लॉक करने से रोकता है।
* InnoDB स्वचालित रूप से डेडलॉक्स (Deadlocks) का पता लगाता है, सबसे कम रोलबैक लागत वाले ट्रांजैक्शन को निरस्त करता है (Error 1213), और उसे रोलबैक कर देता है।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
```sql
START TRANSACTION;

SELECT stock_quantity FROM products WHERE product_id = 1 FOR UPDATE;

UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
INSERT INTO orders (customer_id, order_date, total_amount) VALUES (1, CURDATE(), 1299.99);

COMMIT;
```

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: बाहरी थर्ड-पार्टी HTTP API रिस्पॉन्स का इंतजार करते समय डेटाबेस ट्रांजेक्शन्स को खुला रखना (गंभीर लॉक वेट टाइमआउट का कारण बनता है)।
* **Trap**: ट्रांजैक्शन के अंदर DDL स्टेटमेंट (`ALTER TABLE`) चलाना, जिससे इंप्लिसिट कमिट ट्रिगर होता है और एटॉमिसीटी टूट जाती है।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *डर्टी रीड क्या है, और कौन सा आइसोलेशन लेवल इसकी अनुमति देता है?* $\rightarrow$ किसी अन्य ट्रांजैक्शन द्वारा किए गए अनकमिटेड डेटा को पढ़ना जिसे बाद में रोलबैक कर दिया जाता है; यह केवल `READ UNCOMMITTED` में अनुमत है।
2. *सिस्टम क्रैश के दौरान कौन सा InnoDB लॉग ड्यूरेबिलिटी की गारंटी देता है?* $\rightarrow$ रेडो लॉग (Redo Log)।
3. *रोलबैक के दौरान कौन सा InnoDB लॉग एटॉमिसीटी की गारंटी देता है?* $\rightarrow$ अनडू लॉग (Undo Log)।
4. *`SELECT ... FOR UPDATE` के माध्यम से हासिल किए गए एक्सक्लूसिव रो लॉक को कैसे रिलीज़ किया जाता है?* $\rightarrow$ `COMMIT` या `ROLLBACK` जारी करके।
5. *MySQL डेडलॉक्स को कैसे संभालता है?* $\rightarrow$ डेडलॉक डिटेक्टर सबसे कम रोलबैक लागत वाले ट्रांजैक्शन को Error 1213 के साथ निरस्त करता है और उसे रोलबैक कर देता है।

### प्रैक्टिकल चैलेंज (Practical Challenge)
एक स्टोर्ड ट्रांजैक्शन में दो बैंक खातों के बीच समवर्ती बैलेंस ट्रांसफर का अनुकरण (simulate) करें, जिसमें सेवपॉइंट्स और एरर रोलबैक हैंडलर्स शामिल हों।

---

## Checkpoint 7: क्वेरी ऑप्टिमाइज़ेशन और सिक्योरिटी (Optimization & Security)

### आपको क्या पता होना चाहिए (What You Should Know)
* एग्जीक्यूशन प्लान्स का निरीक्षण करने के लिए `EXPLAIN` और `EXPLAIN ANALYZE` का उपयोग करें। बड़ी टेबल्स पर एक्सेस टाइप `ALL` (फुल टेबल स्कैन) को एलिमिनेट करें।
* एक **कवरिंग इंडेक्स (Covering Index)** में क्वेरी द्वारा अनुरोधित सभी कॉलम्स शामिल होते हैं, जिससे क्वेरी सीधे सेकेंडरी इंडेक्स लीफ नोड्स (`Extra: Using index`) से संतुष्ट हो जाती है।
* **लेफ्टमोस्ट प्रीफिक्स नियम (Leftmost Prefix Rule)**: `(A, B, C)` पर इंडेक्स का उपयोग केवल तभी किया जा सकता है जब क्वेरी पहले `A` पर फिल्टर करे।
* SQL इंजेक्शन से बचाव के लिए हमेशा **प्रिपेयर्ड स्टेटमेंट्स (पैरामीटरयुक्त क्वेरीज)** का उपयोग करें।
* **प्रिंसिपल ऑफ लीस्ट प्रिविलेज (PoLP)** का पालन करें; परमिशन मैनेजमेंट के लिए MySQL 8.0 रोल्स का उपयोग करें।
* डेडिकेटेड डेटाबेस इंस्टेंसेस पर `innodb_buffer_pool_size` को **फिजिकल रैम का 70%–80%** आकार दें।

### आपको क्या लिखना आना चाहिए (What You Should Be Able to Write)
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

### सामान्य गलतियाँ और ट्रैप्स (Common Failure Traps)
* **Trap**: कम-कार्डिनैलिटी वाले बूलियन कॉलम्स पर इंडेक्स जोड़ना (ऑप्टिमाइज़र उन्हें अनदेखा करता है और वैसे भी टेबल स्कैन करता है)।
* **Trap**: टेबल्स को ओवर-इंडेक्स करना (`INSERT`, `UPDATE`, और `DELETE` पर गंभीर राइट पेनल्टी लगती है)।
* **Trap**: पैरामीटरयुक्त क्वेरीज का उपयोग करने के बजाय यूजर इनपुट को सीधे SQL स्ट्रिंग्स में जोड़ना।

### 5-प्रश्नों का चेकपॉइंट क्विज़ (5-Question Checkpoint Quiz)
1. *EXPLAIN आउटपुट में `Using filesort` का क्या अर्थ है?* $\rightarrow$ MySQL को मेमोरी या डिस्क पर एक स्पष्ट सॉर्टिंग पास करना पड़ा क्योंकि इंडेक्स आवश्यक क्रम प्रदान नहीं कर सका।
2. *SARGable क्वेरी प्रेडिकेट क्या है?* $\rightarrow$ एक ऐसा प्रेडिकेट जो सीधे इंडेक्स सीक का उपयोग करने में सक्षम हो।
3. *प्रिपेयर्ड स्टेटमेंट्स SQL इंजेक्शन से सुरक्षित क्यों हैं?* $\rightarrow$ क्योंकि यूजर पैरामीटर्स बाइंड होने से पहले क्वेरी टेम्प्लेट एक निश्चित सिंटैक्स ट्री में संकलित (compile) हो जाता है, जिससे पैरामीटर्स क्वेरी स्ट्रक्चर को नहीं बदल सकते।
4. *कौन सा कमांड InnoDB टेबल्स का ऑनलाइन, नॉन-ब्लॉकिंग लॉजिकल बैकअप निष्पादित करता है?* $\rightarrow$ `mysqldump --single-transaction`।
5. *प्रोडक्शन एप्लीकेशन क्वेरीज में `SELECT *` से क्यों बचना चाहिए?* $\rightarrow$ यह नेटवर्क बैंडविड्थ बर्बाद करता है, कवरिंग इंडेक्स ऑप्टिमाइज़ेशन को रोकता है, और मेमोरी उपयोग को बढ़ाता है।

### प्रैक्टिकल चैलेंज (Practical Challenge)
धीमी मल्टी-टेबल जॉइन क्वेरी पर `EXPLAIN ANALYZE` चलाएं, सबसे लंबा निष्पादन समय लेने वाले चरण की पहचान करें, और एक कम्पोजिट कवरिंग इंडेक्स डिज़ाइन करें जो निष्पादन समय को 75% से अधिक कम कर दे।
