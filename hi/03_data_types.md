# Chapter 03 — MySQL Data Types और Storage Architecture

---

## 1. What is it? (यह क्या है?)

MySQL में एक **Data Type** किसी टेबल के कॉलम से जुड़ा वह नियम या विशेषता (attribute) है जो यह तय करता है कि उस कॉलम में किस प्रकार का डेटा स्टोर हो सकता है, डिस्क और मेमोरी में उसे किस बाइनरी फॉर्मेट में एनकोड किया जाएगा, उसकी मान्य वैल्यू रेंज क्या होगी, और उस पर कौन-से गणितीय (arithmetic) या स्ट्रिंग ऑपरेशन्स किए जा सकते हैं।

डेटाबेस इंजीनियरिंग में सही Data Type का चुनाव करना सबसे बुनियादी और महत्वपूर्ण फैसला होता है। **InnoDB** जैसे मॉडर्न स्टोरेज इंजन में डेटा की हर एक पंक्ति (row) फिक्स्ड-साइज के डिस्क ब्लॉक्स में पैक की जाती है (जो आमतौर पर 16 KB के डेटा पेज होते हैं)। अगर आप ज़रूरत से बड़ा या गलत डेटा टाइप चुनते हैं (जैसे सिर्फ Yes/No के लिए `BIGINT` लेना), तो इससे डिस्क स्पेस की भारी बर्बादी होती है, ऑपरेटिंग सिस्टम का I/O परफॉरमेंस धीमा हो जाता है, MySQL के Buffer Pool (RAM) में कम डेटा आ पाता है, और आपकी क्वेरीज की स्पीड बहुत गिर जाती है।

MySQL डेटा टाइप्स को मुख्य रूप से 5 परिवारों (families) में बाँटता है:
1. **Numeric Types**: Integers (पूर्ण संख्याएँ), Fixed-Point (सटीक दशमलव), Floating-Point (अनुमानित दशमलव), और Bit वैल्यूज।
2. **String / Character Types**: Fixed-length (`CHAR`), Variable-length (`VARCHAR`), Large Text ब्लॉक्स (`TEXT`), और Enumerations (`ENUM`, `SET`)।
3. **Binary Types**: रॉ बाइट्स, फाइल्स, इमेजेस या सीरियलाइज्ड ऑब्जेक्ट्स (`BINARY`, `VARBINARY`, `BLOB`)।
4. **Temporal / Date & Time Types**: कैलेंडर तारीखें, टाइमस्टैम्प्स, टाइम ड्यूरेशन और साल (`DATE`, `DATETIME`, `TIMESTAMP`, `TIME`, `YEAR`)।
5. **Semi-Structured Document Types**: नेटिव बाइनरी JSON डाक्यूमेंट्स (`JSON`)।

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Storage Optimization & Cache Density (मेमोरी और डिस्क की बचत)**: अगर आप किसी `is_active` फ्लैग के लिए `BIGINT` (8 बाइट्स) की जगह `TINYINT` (1 बाइट) इस्तेमाल करते हैं, तो हर रो पर 7 बाइट्स बचते हैं। 10 करोड़ (100 million) रोज़ वाली टेबल में इसका मतलब है सीधे 700 MB रैम और डिस्क स्पेस की बचत! जितनी कम जगह डेटा लेगा, MySQL Buffer Pool में उतने ही ज़्यादा डेटा पेज समा सकेंगे और क्वेरीज सुपरफास्ट चलेंगी।
2. **Domain Integrity & Automatic Validation (गलत डेटा की रोकथाम)**: कॉलम को `DATE` घोषित करने से गलत वैल्यूज (जैसे `"2023-02-31"` या `"hello"`) डेटाबेस में घुस ही नहीं सकतीं। डेटाबेस खुद गेटकीपर का काम करता है।
3. **Mathematical & Financial Accuracy (पैसों के हिसाब में 100% सटीकता)**: पैसों और अकाउंटिंग के लिए `DECIMAL(10,2)` का इस्तेमाल करने से फ्लोटिंग-पॉइंट (`FLOAT`/`DOUBLE`) में होने वाली राउंडिंग गलतियों (rounding drift) से बचा जा सकता है।
4. **Index Performance (इंडेक्स की तेज़ स्पीड)**: छोटे और फिक्स्ड-विड्थ डेटा टाइप्स कॉम्पैक्ट B+ Tree इंडेक्स बनाते हैं, जिससे रैंडम डिस्क रीड्स (disk I/O) बहुत कम हो जाते हैं।

---

## 3. Comprehensive Data Type Taxonomy & Storage Reference (डेटा टाइप्स और स्टोरेज का विस्तृत वर्गीकरण)

### 3.1. Integer Data Types (पूर्णांक डेटा प्रकार)

| Type | Storage | Signed Range | Unsigned Range (`UNSIGNED`) | Typical Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `TINYINT` | 1 Byte | -128 to 127 | 0 to 255 | Status codes, booleans (`TINYINT(1)`), उम्र (ages) |
| `SMALLINT` | 2 Bytes | -32,768 to 32,767 | 0 to 65,535 | Year numbers, छोटे काउंटर्स, department IDs |
| `MEDIUMINT` | 3 Bytes | -8,388,608 to 8,388,607 | 0 to 16,777,215 | Postal codes, मध्यम आकार के कैटलॉग |
| `INT` / `INTEGER` | 4 Bytes | -2,147,483,648 to 2,147,483,647 | 0 to 4,294,967,295 | स्टैंडर्ड Primary Keys, customer IDs |
| `BIGINT` | 8 Bytes | $\approx -9.22 \times 10^{18}$ to $9.22 \times 10^{18}$ | 0 to $\approx 1.84 \times 10^{19}$ | ग्लोबल ट्रांजेक्शन IDs, हाई-थ्रूपुट लॉग्स |

> [!NOTE]
> MySQL में `BOOLEAN` और `BOOL` असल में `TINYINT(1)` के ही पर्यायवाची (synonyms) हैं। यहाँ `0` का मतलब `FALSE` होता है, और नॉन-ज़ीरो वैल्यू (आमतौर पर `1`) का मतलब `TRUE` होता है।

### 3.2. Fixed-Point vs Floating-Point Types (सटीक बनाम फ्लोटिंग-पॉइंट)

| Type | Syntax | Storage | Precision Behavior | Appropriate Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `DECIMAL(M, D)` / `NUMERIC` | `DECIMAL(10, 2)` | Variable (~4 bytes per 9 digits) | **Exact (सटीक)**। फिक्स्ड डेसिमल निरूपण; राउंडिंग की कोई गलती नहीं। | **करेंसी, कीमतें, एकाउंटिंग, बैंकिंग** |
| `FLOAT` | `FLOAT` | 4 Bytes | **Approximate (अनुमानित)**। Single-precision IEEE 754 floating-point। | वैज्ञानिक गणनाएँ, सेंसर रीडिंग्स |
| `DOUBLE` | `DOUBLE` | 8 Bytes | **Approximate (अनुमानित)**। Double-precision IEEE 754 floating-point। | हाई-रेंज स्टैटिस्टिकल सिमुलेशन |

> [!WARNING]
> **फाइनेंशियल डेटा या पैसों के लिए कभी भी `FLOAT` या `DOUBLE` का इस्तेमाल न करें।** IEEE 754 बाइनरी सिस्टम में `0.1` जैसे नंबर्स को बाइनरी में सटीक रूप से स्टोर नहीं किया जा सकता, जिससे पाई-पाई का अंतर (e.g., `0.1 + 0.2 = 0.30000000000000004`) आने लगता है। पैसों के लिए हमेशा `DECIMAL(M, D)` का ही उपयोग करें।

### 3.3. String & Text Types (स्ट्रिंग और टेक्स्ट प्रकार)

| Type | Maximum Size | Storage Mechanics | Trailing Space Behavior | Best Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `CHAR(M)` | $M \le 255$ chars | Fixed-length; तय साइज़ $M$ तक खाली जगह में स्पेस भरता है। | डेटा रिट्रीव करते समय पीछे के स्पेसेस हटा दिए जाते हैं। | फिक्स्ड-लेंथ कोड्स: ISO करेंसी (`'USD'`), स्टेट कोड्स (`'CA'`), MD5/SHA256 हैश। |
| `VARCHAR(M)` | $M \le 65,535$ bytes | Variable-length; वास्तविक कैरेक्टर्स + 1 या 2 बाइट्स की लेंथ प्रीफ़िक्स स्टोर करता है। | पीछे के स्पेसेस सुरक्षित रखता है (MySQL 5.0.3+)। | वैरिएबल-लेंथ टेक्स्ट: नाम, ईमेल पते, URLs, पते की लाइनें। |
| `TEXT` | 65,535 bytes (64 KB) | Variable-length; पेज थ्रेशोल्ड से अधिक होने पर InnoDB ऑफ-पेज LOB पॉइंटर बनाता है। | स्पेसेस सुरक्षित रखता है। | ब्लॉग पोस्ट्स, यूज़र बायो, विस्तृत विवरण। |
| `MEDIUMTEXT` | 16,777,215 bytes (16 MB)| Off-page storage। | स्पेसेस सुरक्षित रखता है। | बड़े दस्तावेज़, XML पेलोड्स। |
| `LONGTEXT` | 4,294,967,295 bytes (4 GB) | Off-page storage। | स्पेसेस सुरक्षित रखता है। | बहुत बड़े सिस्टम लॉग्स, किताबें, डेटाबेस डंप्स। |
| `ENUM('v1','v2')`| 65,535 distinct elements | अंदरूनी तौर पर 1 या 2 बाइट इंटीजर्स के रूप में स्टोर होता है जो स्ट्रिंग से मैप होते हैं। | तय सेट के विरुद्ध सख्त वैलिडेशन। | सीमित स्थिर विकल्प: आर्डर स्टेटस, हफ्ते के दिन, जेंडर। |

### 3.4. Date & Time Types (दिनांक और समय प्रकार)

| Type | Format | Storage | Valid Range | Time Zone Handling |
| :--- | :--- | :--- | :--- | :--- |
| `DATE` | `YYYY-MM-DD` | 3 Bytes | `1000-01-01` to `9999-12-31` | कोई टाइमज़ोन नहीं |
| `TIME` | `HH:MM:SS[.fraction]` | 3 Bytes | `-838:59:59` to `838:59:59` | कोई नहीं (बीता हुआ समय भी दर्शा सकता है) |
| `DATETIME` | `YYYY-MM-DD HH:MM:SS` | 5 Bytes | `1000-01-01 00:00:00` to `9999-12-31 23:59:59` | **Static (स्थिर)**। बिना UTC कन्वर्शन के जैसा है वैसा स्टोर होता है। |
| `TIMESTAMP` | `YYYY-MM-DD HH:MM:SS` | 4 Bytes | `1970-01-01 00:00:01` UTC to `2038-01-19 03:14:07` UTC | **Dynamic (गतिशील)**। क्लाइंट टाइमज़ोन से UTC में बदलकर स्टोर करता है, रिट्रीव पर वापस बदलता है। |
| `YEAR` | `YYYY` | 1 Byte | `1901` to `2155` | कोई नहीं |

> [!IMPORTANT]
> **The Year 2038 Problem (2038 की समस्या)**: स्टैंडर्ड 32-बिट `TIMESTAMP` की वैल्यू **19 जनवरी 2038** को ओवरफ्लो हो जाएगी। भविष्य के बिज़नेस रिकॉर्ड्स (जैसे होम लोन, जन्मतिथि, लॉन्ग-टर्म कॉन्ट्रैक्ट्स) के लिए `TIMESTAMP` के बजाय हमेशा `DATETIME(6)` का उपयोग करें।

---

## 4. Syntax (सिंटैक्स)

अलग-अलग डेटा टाइप्स के साथ टेबल तैयार करने का सिंटैक्स:

```sql
CREATE TABLE product_specifications (
    spec_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_code CHAR(8) NOT NULL,               -- Exactly 8 chars, e.g. 'PRD-1001'
    product_name VARCHAR(120) NOT NULL,          -- Variable text up to 120 characters
    cost_price DECIMAL(8, 2) NOT NULL,           -- Exact: max 999,999.99
    weight_kg FLOAT DEFAULT NULL,                -- Approximate weight
    in_stock BOOLEAN NOT NULL DEFAULT TRUE,      -- 1 or 0
    release_date DATE NOT NULL,                  -- Calendar date YYYY-MM-DD
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Auto UTC timestamp
    metadata JSON DEFAULT NULL                   -- Flexible JSON document
) ENGINE = InnoDB;
```

---

## 5. Real-World Example (रियल-वर्ल्ड उदाहरण)

आइए हमारे `sql_mastery` डेटाबेस की `products` टेबल के डेटा टाइप्स को देखें और सटीक `DECIMAL` और आधुनिक `JSON` डेटा टाइप का लाइव डेमो टेस्ट करें:

```sql
USE sql_mastery;

-- Inspect the data type definitions in products
DESC products;

-- Test data type behavior: Insert a row with exact DECIMAL precision and JSON metadata
CREATE TABLE product_catalogue_demo (
    item_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sku CHAR(10) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    condition_grade ENUM('New', 'Refurbished', 'Used') NOT NULL DEFAULT 'New',
    technical_specs JSON NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert a record demonstrating strict typing and JSON validation
INSERT INTO product_catalogue_demo (sku, title, base_price, condition_grade, technical_specs)
VALUES (
    'SKU-990011',
    'UltraPort USB-C Hub 8-in-1',
    49.99,
    'New',
    '{"ports": 8, "hdmi_4k": true, "max_wattage": 100, "compatibility": ["Windows", "macOS", "Linux"]}'
);

-- Query the JSON attributes using MySQL JSON path extraction operators (-> and ->>)
SELECT 
    sku,
    title,
    base_price,
    condition_grade,
    technical_specs->>'$.max_wattage' AS max_watts,
    technical_specs->>'$.compatibility[0]' AS primary_os
FROM product_catalogue_demo;

-- Clean up demo table
DROP TABLE product_catalogue_demo;
```

---

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

1. `cost_price DECIMAL(8, 2)`:
   * **Precision (8)** कुल महत्वपूर्ण अंकों (digits) की संख्या दर्शाता है (दशमलव के पहले और बाद के सभी अंकों को मिलाकर)।
   * **Scale (2)** दशमलव बिंदु के दाईं ओर के अंकों की संख्या बताता है।
   * इसका मतलब यह कॉलम `-999999.99` से लेकर `999999.99` तक की सटीक वैल्यूज स्टोर कर सकता है।
2. `sku CHAR(10)`:
   * InnoDB में, `utf8mb4` के तहत `CHAR(10)` फिक्स्ड-साइज आइडेंटिफायर्स के लिए कैरेक्टर लेंथ कैलकुलेशन का ओवरहेड खत्म कर देता है और पढ़ने में सुपरफास्ट होता है।
3. `condition_grade ENUM('New', 'Refurbished', 'Used')`:
   * MySQL इन स्ट्रिंग्स को अंदरूनी तौर पर 1-बाइट इंटीजर ऑफ़सेट में बदल देता है (`'New'` $\rightarrow 1$, `'Refurbished'` $\rightarrow 2$, `'Used'` $\rightarrow 3$)। जब भी आप इस पर फ़िल्टर लगाते हैं, तो बैकएंड में बहुत तेज़ इंटीजर तुलना होती है, जबकि आपके ऍप्लिकेशन को साफ़ स्ट्रिंग दिखाई देती है।
4. `technical_specs JSON`:
   * यह सुनिश्चित करता है कि डाला गया डेटा वैलिड RFC 8259 JSON फॉर्मेट में हो। अमान्य JSON डालने पर तुरंत `ERROR 3140 (22032): Invalid JSON text` आता है। यह डाक्यूमेंट्स को ऑप्टिमाइज़्ड बाइनरी फॉर्मेट में रखता है जिससे पूरी स्ट्रिंग पढ़े बिना सीधे अंदरूनी कीज़ निकाली जा सकती हैं।
5. `technical_specs->>'$.max_wattage'`:
   * `->>` ऑपरेटर वास्तव में `JSON_UNQUOTE(JSON_EXTRACT(doc, path))` का शॉर्टहैंड है। यह JSON के अंदर से सीधे बिना कोट्स वाली साफ़ SQL स्ट्रिंग निकालता है।

---

## 7. Expected Result (अपेक्षित परिणाम / Expected Output)

डेमो क्वेरी चलाने पर प्राप्त आउटपुट:

```
+------------+----------------------------+------------+-----------------+-----------+------------+
| sku        | title                      | base_price | condition_grade | max_watts | primary_os |
+------------+----------------------------+------------+-----------------+-----------+------------+
| SKU-990011 | UltraPort USB-C Hub 8-in-1 |      49.99 | New             | 100       | Windows    |
+------------+----------------------------+------------+-----------------+-----------+------------+
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **फिक्स्ड-लेंथ कोड्स के लिए `VARCHAR` का उपयोग करना**:
   * *गलती*: 2-अक्षर के कंट्री कोड (जैसे IN, US) को `country_code VARCHAR(2)` बनाना।
   * *समस्या*: `VARCHAR` हर एंट्री के साथ 1-बाइट का लेंथ प्रीफ़िक्स जोड़ता है। तो 2 कैरेक्टर + 1 बाइट प्रीफ़िक्स = कुल 3 बाइट्स खर्च होते हैं। ऐसे फिक्स्ड कोड्स के लिए `CHAR(2)` हमेशा साफ़ और तेज़ होता है।
2. **करेंसी के लिए Floating-Point (`FLOAT`/`DOUBLE`) इस्तेमाल करना**:
   * *गलती*: `price FLOAT NOT NULL` बनाना।
   * *नतीजा*: जब आप टैक्स या डिस्काउंट जोड़ेंगे, तो `19.99 * 3 = 59.9700012` जैसे फ्लोटिंग एरर्स आएँगे और ऑडिट फेल हो जाएगा। पैसों के लिए हमेशा `DECIMAL` का ही इस्तेमाल करें।
3. **हर जगह आँख बंद करके `VARCHAR(255)` लगाना**:
   * *गलती*: छोटे कोड्स या स्टेट्स के लिए भी `VARCHAR(255)` डिक्लेयर कर देना।
   * *समस्या*: भले ही डिस्क पर `VARCHAR` सिर्फ लिखे गए अक्षरों की जगह लेता है, लेकिन जब MySQL मेमोरी में जटिल `GROUP BY` या `ORDER BY` क्वेरीज के लिए Internal Temporary Tables बनाता है, तो वह पूरे घोषित आकार (declared width) के हिसाब से रैम रिज़र्व करता है, जिससे मेमोरी जल्दी भर जाती है और क्वेरी डिस्क पर स्पिल हो जाती है।
4. **`TIMESTAMP` और `DATETIME` के टाइमज़ोन अंतर को नजरअंदाज करना**:
   * *गलती*: यह मान लेना कि `TIMESTAMP` और `DATETIME` दोनों एक जैसे हैं।
   * *आश्चर्य*: अगर न्यूयॉर्क (`UTC-5`) का सर्वर `TIMESTAMP` में `2023-01-01 12:00:00` लिखता है, तो लंदन (`UTC+0`) का क्लाइंट कनेक्ट करने पर `2023-01-01 17:00:00` देखेगा, क्योंकि `TIMESTAMP` क्लाइंट टाइमज़ोन के अनुसार बदल जाता है। जबकि `DATETIME` में जो लिखा गया है, हर जगह वही दिखेगा।

---

## 9. Best Practices (बेस्ट प्रैक्टिसेस)

1. **बिज़नेस ज़रूरत के हिसाब से इंटीजर्स का सही साइज़ चुनें**:
   * अगर किसी टेबल में 100 से ज़्यादा कैटेगरी कभी नहीं होंगी, तो `TINYINT UNSIGNED` (रेंज: 0 से 255) का उपयोग करें। हर नंबर वाले कॉलम को डिफ़ॉल्ट रूप से `INT` या `BIGINT` न बनाएं।
2. **Primary Keys को हमेशा `UNSIGNED` घोषित करें**:
   * प्राइमरी की ID काउंटर्स कभी भी नेगेटिव नहीं होते। `INT UNSIGNED` लिखने से बिना 1 बाइट भी अतिरिक्त खर्च किए आपकी अधिकतम ID रेंज ~2.14 अरब से बढ़कर ~4.29 अरब हो जाती है!
3. **फोटोज, वीडियो और फाइल्स को क्लाउड ऑब्जेक्ट स्टोरेज (S3) में रखें, `BLOB` में नहीं**:
   * बाइनरी फाइल्स को कभी भी MySQL के `BLOB` कॉलम में सीधे स्टोर न करें। इमेज या PDF को AWS S3 या Google Cloud Storage में अपलोड करें और डेटाबेस में केवल उसका CDN `VARCHAR` URL सेव करें।
4. **JSON के साथ Virtual Generated Columns का लाभ उठाएं**:
   * जब आप JSON डाक्यूमेंट्स स्टोर करते हैं, तो जिन नेस्टेड कीज़ पर बार-बार सर्च करना हो, उन पर Virtual Generated Column बनाकर इंडेक्स जोड़ दें ताकि सर्चिंग सुपरफास्ट हो सके।

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. इंसानी उम्र (0 से 120 साल) को स्टोर करने के लिए सबसे कम बाइट्स खर्च करने वाला कौन-सा न्यूमेरिक डेटा टाइप चुनना चाहिए?
2. स्ट्रिंग `'SQL'` को स्टोर करते समय `CHAR(10)` और `VARCHAR(10)` के स्टोरेज में क्या अंतर होगा?
3. बैंक अकाउंट बैलेंस स्टोर करते समय राउंडिंग गलतियों से बचने के लिए किस डेटा टाइप का उपयोग अनिवार्य है?

### Medium (मध्यम)
4. `employee_timesheets` नाम की टेबल के लिए `CREATE TABLE` स्टेटमेंट लिखें, जिसमें एक auto-increment primary key, कर्मचारी ID, क्लॉक-इन टाइम (`DATETIME`), क्लॉक-आउट टाइम (`DATETIME`), और काम के घंटे दर्शाने वाला `hours_worked` कॉलम (`DECIMAL(4,2)`) शामिल हो।
5. यदि किसी कॉलम को `ENUM('Draft', 'Published', 'Archived')` के रूप में परिभाषित किया गया है, और उसमें `'Pending Approval'` डालने की कोशिश की जाए, तो क्या होगा?
6. `DATETIME` और `TIMESTAMP` की अधिकतम मान्य तारीख की तुलना कीजिए। इनमें से किसमें 'Year 2038' बग का खतरा है?

### Difficult (कठिन)
7. `sensor_telemetry` नाम की टेबल डिज़ाइन करें जिसमें एक unsigned integer डिवाइस ID, 4 दशमलव स्थानों वाला सटीक तापमान (`DECIMAL`), माइक्रोसेकंड प्रिसिजन वाला टाइमस्टैम्प (`TIMESTAMP(6)`), और किसी भी प्रकार के डायग्नोस्टिक पेलोड के लिए एक `JSON` कॉलम हो।
8. जब रो साइज़ की सीमा पार हो जाती है, तो InnoDB स्टोरेज इंजन के अंदर `VARCHAR(500)` और `TEXT` कॉलम को कैसे स्टोर किया जाता है, इसका आंतरिक मैकेनिज्म समझाइए।

---

## 11. Interview Questions (इंटरव्यू प्रश्न और उत्तर)

### Q1: MySQL में `CHAR` और `VARCHAR` के बीच बुनियादी अंतर क्या है?
**Answer**: `CHAR(M)` एक फिक्स्ड-लेंथ डेटा टाइप है जो डाले गए मान की लंबाई चाहे जो भी हो, हमेशा पूरे $M$ कैरेक्टर्स के बराबर स्टोरेज घेरता है (छोटी स्ट्रिंग्स के पीछे स्पेस जोड़कर पैड कर दिया जाता है, जो पढ़ने पर हटा दिए जाते हैं)। इसके विपरीत, `VARCHAR(M)` एक वैरिएबल-लेंथ डेटा टाइप है जो केवल वास्तविक कैरेक्टर्स और 1 या 2 बाइट्स का लेंथ प्रीफ़िक्स स्टोर करता है। फिक्स्ड-साइज कोड्स (जैसे हैश, पिन कोड, स्टेट कोड) के लिए लेंथ प्रीफ़िक्स का ओवरहेड बचाने के लिए `CHAR` का इस्तेमाल करें, और नाम/ईमेल जैसे अनिश्चित लंबाई वाले टेक्स्ट के लिए `VARCHAR` का उपयोग करें।

### Q2: वित्तीय (Financial) डेटा के लिए `FLOAT` या `DOUBLE` के मुकाबले `DECIMAL` को प्राथमिकता क्यों दी जाती है?
**Answer**: `FLOAT` और `DOUBLE` कंप्यूटर के IEEE 754 बाइनरी फ्लोटिंग-पॉइंट फॉर्मेट पर काम करते हैं। बेस-2 बाइनरी सिस्टम में इंसानी दशमलव संख्याएँ (जैसे `0.10` या `0.05`) सटीक रूप से स्टोर नहीं की जा सकतीं, जिससे जोड़-घटाव में फ्लोटिंग-पॉइंट का मामूली अंतर (precision drift) जमा होने लगता है। दूसरी ओर, `DECIMAL(M, D)` एक फिक्स्ड-पॉइंट डेटा टाइप है जो दशमलव के हर अंक को डिस्क पर बिल्कुल सटीक रूप से पैक करके स्टोर करता है, जिससे शून्य प्रतिशत एरर की गारंटी मिलती है।

### Q3: टाइमज़ोन के संदर्भ में `DATETIME` और `TIMESTAMP` में क्या अंतर होता है?
**Answer**: 
* `DATETIME` टाइमज़ोन से पूरी तरह बेअसर (static) होता है: इसमें साल, महीना, दिन, घंटा, मिनट और सेकंड हूबहू वैसे ही स्टोर होते हैं जैसे आपने लिखे हैं। अगर इसमें `14:00` स्टोर किया गया है, तो दुनिया के किसी भी कोने का यूज़र इसे `14:00` ही देखेगा।
* `TIMESTAMP` टाइमज़ोन अवेयर (dynamic) होता है: जब आप डेटा इंसर्ट करते हैं, तो MySQL क्लाइंट के मौजूदा टाइमज़ोन से समय को बदलकर UTC में स्टोर करता है। और जब कोई दूसरा क्लाइंट इसे पढ़ता है, तो MySQL उस UTC वैल्यू को उस क्लाइंट के लोकल टाइमज़ोन में बदलकर दिखाता है।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* हमेशा बिज़नेस स्केल के अनुसार सबसे छोटा सुरक्षित इंटीजर टाइप चुनें (`TINYINT` $\rightarrow 1\text{B}$, `SMALLINT` $\rightarrow 2\text{B}$, `INT` $\rightarrow 4\text{B}$, `BIGINT` $\rightarrow 8\text{B}$)।
* IDs, काउंटर्स और क्वांटिटी के लिए हमेशा `UNSIGNED` का इस्तेमाल करें।
* पैसों के लेन-देन और कीमतों के लिए केवल `DECIMAL(M, D)` का उपयोग करें; `FLOAT` और `DOUBLE` से बचें।
* फिक्स्ड लंबाई वाले कोड्स के लिए `CHAR` और सामान्य टेक्स्ट के लिए `VARCHAR` चुनें।
* `TIMESTAMP` केवल 4 बाइट्स लेता है और UTC में कन्वर्ट होता है (2038 में एक्सपायर होगा); `DATETIME` 5 बाइट्स लेता है, 1000–9999 साल तक मान्य है और टाइमज़ोन न्यूट्रल है।
* MySQL में नेटिव `JSON` सपोर्ट उपलब्ध है, जिसमें वैलिडेशन और इंडेक्स्ड वर्चुअल कॉलम्स की सुविधा मिलती है।
