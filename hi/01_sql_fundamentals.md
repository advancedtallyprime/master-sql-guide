# Chapter 01 — SQL और Relational Database के फंडामेंटल्स (SQL & Relational Database Fundamentals)

---

## 1. What is it? (यह क्या है?)

एक **Database** असल में structured information (डेटा) का एक organized और persistent repository (संग्रह) होता है, जिसे इस तरह डिज़ाइन किया जाता है ताकि डेटा को तेज़ी से search, retrieve और एक साथ कई users द्वारा modify (concurrent modification) किया जा सके।

मॉडर्न डेटाबेस्स को गहराई से समझने के लिए, आइए informal data storage और professional database management system के फर्क को एक आसान analogy से समझते हैं:

* **The Spreadsheet / File Analogy (एक्सेल शीट का उदाहरण)**: मान लीजिए आप अपनी दुकान या कॉलेज का डेटा एक Excel spreadsheet या text file में रखते हैं। जब तक सिर्फ आप उस फाइल को खोलकर काम कर रहे हैं, सब कुछ ठीक चलता है। लेकिन सोचिए जब एक साथ 500 लोग उसी फाइल में अलग-अलग rows एडिट करने की कोशिश करेंगे, तो क्या होगा? फाइल corrupt हो जाएगी, duplicate entries भर जाएँगी, और डेटा validation पूरी तरह फेल हो जाएगा। इसे हम concurrency issue कहते हैं।
* **A Database Management System (DBMS)**: यह एक ऐसा समझदार software intermediary (मध्यस्थ) है जो end users, client applications और आपकी physical hard drive/SSD के बीच बैठता है। यह consistency rules लागू करता है, multi-user concurrency को संभालता है, security permissions तय करता है, और यह गारंटी देता है कि अगर सर्वर अचानक क्रैश भी हो जाए, तो आपका commit किया हुआ डेटा कभी गायब न हो।
* **A Relational Database Management System (RDBMS)**: यह E.F. Codd (1970) के relational model पर आधारित एक specialized DBMS है। RDBMS में डेटा को mathematically structured 2D **tables** (relations) के रूप में रखा जाता है, जिनमें **rows** (tuples या records) और **columns** (attributes या fields) होते हैं। अलग-अलग टेबल्स आपस में shared values यानी **keys** (जैसे Primary Key और Foreign Key) के ज़रिए जुड़ी होती हैं। दुनिया के सबसे लोकप्रिय RDBMS engines हैं: **MySQL**, **PostgreSQL**, **Oracle Database**, और **Microsoft SQL Server**।

**Structured Query Language (SQL)** ANSI और ISO द्वारा standardized एक universal, declarative programming language है, जिसका उपयोग RDBMS engines से बातचीत करने के लिए किया जाता है।

Python, Java, या C++ जैसी imperative भाषाओं में आपको कंप्यूटर को step-by-step बताना पड़ता है कि काम *कैसे* (HOW) करना है (लूप चलाओ, कंडीशन चेक करो, एरे में डालो)। लेकिन SQL पूरी तरह **declarative** है — यहाँ आप सिर्फ यह बताते हैं कि आपको *क्या* (WHAT) डेटा चाहिए, और RDBMS का internal **Query Optimizer** खुद तय करता है कि disk से उस डेटा को सबसे तेज़ एल्गोरिदम से कैसे निकाला जाए।

SQL की commands को मुख्य रूप से 5 sub-languages में बाँटा गया है:
1. **DDL (Data Definition Language)**: डेटाबेस का ढाँचा (schema structure) बनाने और बदलने के लिए (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`)।
2. **DQL (Data Query Language)**: स्टोर किए गए डेटा को पढ़ने और फ़िल्टर करने के लिए (`SELECT`)।
3. **DML (Data Manipulation Language)**: टेबल्स के अंदर डेटा रिकॉर्ड्स को जोड़ने, बदलने या हटाने के लिए (`INSERT`, `UPDATE`, `DELETE`)।
4. **DCL (Data Control Language)**: यूज़र्स के permissions और सुरक्षा अधिकार (privileges) मैनेज करने के लिए (`GRANT`, `REVOKE`)।
5. **TCL (Transaction Control Language)**: डेटाबेस ट्रांजेक्शन्स की सीमाओं और डेटा सेव करने की स्थिति को कंट्रोल करने के लिए (`COMMIT`, `ROLLBACK`, `SAVEPOINT`)।

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

Relational databases और SQL आज की पूरी दुनिया के enterprise software की रीढ़ की हड्डी (backbone) हैं। हम इनका उपयोग इन 5 ठोस कारणों से करते हैं:

1. **ACID Guarantees (डेटा की 100% सुरक्षा)**: Relational engines ट्रांजेक्शनल इंटीग्रिटी की गारंटी देते हैं:
   * **Atomicity**: सब कुछ होगा या कुछ भी नहीं होगा (All or nothing)। जैसे बैंक ट्रांसफर में अगर पैसे कट गए लेकिन दूसरे खाते में नहीं पहुंचे, तो पूरा प्रोसेस rollback हो जाएगा।
   * **Consistency**: डेटाबेस के बनाए गए नियम और constraints कभी नहीं टूटेंगे।
   * **Isolation**: एक साथ चलने वाले कई ट्रांजेक्शन्स एक-दूसरे के काम में दखल नहीं देंगे।
   * **Durability**: एक बार ट्रांजेक्शन commit हो गया, तो बिजली जाने या सर्वर क्रैश होने पर भी डेटा हमेशा सुरक्षित रहेगा।
2. **Elimination of Data Redundancy (डेटा दोहराव से मुक्ति)**: Relational links (Foreign Keys) और Normalization की मदद से ग्राहक का पता या डिपार्टमेंट का नाम केवल एक जगह स्टोर होता है, लाखों ऑर्डर्स में बार-बार duplicate नहीं होता। इससे डिस्क स्पेस बचती है और डेटा इनकंसिस्टेंसी नहीं आती।
3. **High-Performance Querying (सुपरफास्ट परफॉरमेंस)**: RDBMS engines में B+ Tree और Hash Indexes जैसे एडवांस्ड डेटा स्ट्रक्चर्स और Cost-Based Optimizers होते हैं, जो करोड़ों रिकॉर्ड्स में से भी आपकी ज़रूरत का डेटा मिलीसेकंड्स (milliseconds) में ढूंढकर निकाल लाते हैं।
4. **Declarative Simplicity & Standardization (यूनिवर्सल स्टैंडर्ड)**: एक बार जब आप SQL के कोर कॉन्सेप्ट्स सीख लेते हैं, तो आप दुनिया के किसी भी रिलेशनल डेटाबेस (चाहे MySQL हो, PostgreSQL हो या Snowflake) पर बिना किसी बड़ी परेशानी के काम कर सकते हैं।
5. **Robust Concurrency & Security (मल्टी-यूज़र स्केलेबिलिटी)**: Row-level locking की मदद से हज़ारों यूज़र्स एक साथ अलग-अलग rows पर लिख सकते हैं, बिना दूसरों के read ऑपरेशन्स को रोके। साथ ही रोल-बेस्ड एक्सेस कंट्रोल (RBAC) से डेटा पूरी तरह सुरक्षित रहता है।

---

## 3. Syntax (सिंटैक्स)

### Client Connection & Database Context Syntax
```sql
-- Connect via MySQL CLI:
-- mysql -h <host> -P <port> -u <username> -p

-- Inspect existing databases on the server instance
SHOW DATABASES;

-- Select a database to establish the active session context
USE database_name;

-- Inspect tables residing inside the active database
SHOW TABLES;

-- Inspect structural definition of a specific table
DESCRIBE table_name;
-- Equivalent shorthand:
DESC table_name;
```

### Basic Query Architecture
```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition_is_true;
```

---

## 4. Basic Example (बेसिक उदाहरण)

आइए देखें कि अपने MySQL एनवायरनमेंट को कैसे चेक करते हैं और टेबल्स की परिभाषा कैसे देखी जाती है:

```sql
-- Switch to the practice database
USE sql_mastery;

-- Show all tables present in the database
SHOW TABLES;

-- Describe the structure of the departments table
DESCRIBE departments;
```

---

## 5. Real-World Example (रियल-वर्ल्ड उदाहरण)

हमारे `sql_mastery` प्रोडक्शन डेटाबेस में, आइए सिस्टम आर्किटेक्चर को सत्यापित करें और `employees` टेबल का स्ट्रक्चरल मेटाडेटा जाँचें:

```sql
-- Establish session context
USE sql_mastery;

-- Display column definitions, types, nullability, keys, and defaults for employees
DESC employees;

-- Query basic workforce metadata to confirm connectivity
SELECT employee_id, first_name, last_name, salary, hire_date
FROM employees
WHERE salary > 100000.00;
```

---

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

1. `USE sql_mastery;`
   * यह कमांड MySQL सर्वर डेमन को निर्देश देती है कि आने वाली सभी अनक्वालिफाइड टेबल क्वेरीज (जैसे `employees`) को `sql_mastery` स्कीमा के अंदर ही ढूंढा और प्रोसेस किया जाए। यह आपके एक्टिव सेशन का कॉन्टेक्स्ट सेट करती है।
2. `DESC employees;`
   * सर्वर MySQL की अंदरूनी डेटा डिक्शनरी (`information_schema.columns`) को क्वेरी करता है और टेबल के सभी कॉलम्स का कच्चा-चिट्ठा पेश करता है: कॉलम का नाम, फिजिकल स्टोरेज टाइप (`INT`, `VARCHAR`, `DECIMAL`), क्या कॉलम में `NULL` आ सकता है, कौन सी Key लगी है (`PRI` = Primary Key, `UNI` = Unique, `MUL` = Multiple/Indexed), डिफ़ॉल्ट वैल्यू क्या है, और `AUTO_INCREMENT` जैसे एक्स्ट्रा फीचर्स।
3. `SELECT employee_id, first_name, last_name, salary, hire_date FROM employees WHERE salary > 100000.00;`
   * **Parsing (पार्सिंग)**: MySQL का SQL Parser सिंटैक्स को वैलिडेट करता है और चेक करता है कि क्या आपके पास `employees` टेबल पर `SELECT` करने की परमिशन है।
   * **Optimization (ऑप्टिमाइज़ेशन)**: Query Optimizer तय करता है कि पूरी टेबल स्कैन (Full Table Scan) करनी है या `salary` कॉलम पर बने इंडेक्स का इस्तेमाल करके डेटा तेज़ी से उठाना है।
   * **Execution (एग्जीक्यूशन)**: स्टोरेज इंजन (`InnoDB`) ज़रूरी डेटा पेजों को डिस्क से मेमोरी (Buffer Pool) में लोड करता है, उन रिकॉर्ड्स को फ़िल्टर करता है जहाँ `salary > 100000.00` है, माँगे गए पाँच कॉलम्स को प्रोजेक्ट करता है, और रिजल्ट सेट आपके क्लाइंट को वापस भेज देता है।

---

## 7. Expected Result (अपेक्षित परिणाम / Expected Output)

`DESC employees;` रन करने पर आउटपुट:

```
+---------------+---------------+------+-----+-------------------+-------------------+
| Field         | Type          | Null | Key | Default           | Extra             |
+---------------+---------------+------+-----+-------------------+-------------------+
| employee_id   | int           | NO   | PRI | NULL              | auto_increment    |
| first_name    | varchar(50)   | NO   |     | NULL              |                   |
| last_name     | varchar(50)   | NO   |     | NULL              |                   |
| email         | varchar(100)  | NO   | UNI | NULL              |                   |
| phone         | varchar(20)   | YES  |     | NULL              |                   |
| hire_date     | date          | NO   |     | NULL              |                   |
| salary        | decimal(10,2) | NO   |     | NULL              |                   |
| department_id | int           | YES  | MUL | NULL              |                   |
| manager_id    | int           | YES  | MUL | NULL              |                   |
| is_active     | tinyint(1)    | YES  |     | 1                 |                   |
| created_at    | timestamp     | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+---------------+---------------+------+-----+-------------------+-------------------+
```

फ़िल्टर की गई `SELECT` क्वेरी का आउटपुट:

```
+-------------+------------+-----------+-----------+------------+
| employee_id | first_name | last_name | salary    | hire_date  |
+-------------+------------+-----------+-----------+------------+
|           1 | Alex       | Morgan    | 145000.00 | 2019-03-15 |
|           2 | Sarah      | Chen      | 125000.00 | 2020-06-01 |
|           4 | Priya      | Patel     | 135000.00 | 2020-02-10 |
|           6 | Elena      | Rostova   | 130000.00 | 2018-11-05 |
|           8 | Jessica    | Taylor    | 110000.00 | 2019-08-12 |
+-------------+------------+-----------+-----------+------------+
5 rows in set (0.00 sec)
```

---

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **Forgetting the Semicolon (`;` भूल जाना)**:
   * *गलती*: टर्मिनल में `SELECT * FROM employees` टाइप करके Enter दबा देना। MySQL का प्रॉम्प्ट बदलकर `->` हो जाता है और ऐसा लगता है जैसे सिस्टम हैंग हो गया।
   * *कारण*: MySQL CLI को जब तक स्टेटमेंट टर्मिनेटर यानी delimiter (डिफ़ॉल्ट रूप से `;` या `\g`) नहीं मिलता, तब तक वह समझता है कि आपकी क्वेरी अभी अधूरी है। बस `;` टाइप करके Enter दबा दीजिए, क्वेरी चल जाएगी।
2. **Omitting the `USE` Command (`USE` कमांड छोड़ देना)**:
   * *गलती*: एक नया टर्मिनल कनेक्शन खोला और सीधे `SELECT * FROM employees;` चला दिया।
   * *एरर*: `ERROR 1046 (3D000): No database selected`.
   * *समाधान*: क्वेरी चलाने से पहले हमेशा डेटाबेस कॉन्टेक्स्ट सेट करें: `USE sql_mastery;` या फिर टेबल का पूरा नाम लिखें: `SELECT * FROM sql_mastery.employees;`।
3. **Confusing Database with Table (डेटाबेस और टेबल में अंतर न समझना)**:
   * *गलती*: सीधे डेटाबेस के अंदर डेटा इंसर्ट करने की कोशिश करना। याद रखिए: डेटाबेस केवल एक कंटेनर (फ़ोल्डर) की तरह है; डेटा हमेशा उसके अंदर बनी टेबल्स में ही स्टोर होता है।
4. **Treating SQL as Case-Sensitive for Keywords**:
   * हालाँकि SQL के कीवर्ड्स (`SELECT`, `FROM`) case-insensitive होते हैं (यानी चाहे आप छोटे अक्षरों में लिखें या बड़े में, फर्क नहीं पड़ता), लेकिन Linux ऑपरेटिंग सिस्टम पर टेबल के नाम case-sensitive हो सकते हैं, जो आपके फ़ाइल सिस्टम और MySQL की `lower_case_table_names` सेटिंग पर निर्भर करता है।

---

## 9. Best Practices (बेस्ट प्रैक्टिसेस)

1. **Adopt a Consistent Uppercase Convention for SQL Keywords**:
   * हमेशा एक साफ़-सुथरी कोडिंग स्टाइल अपनाएँ: SQL कीवर्ड्स (`SELECT`, `FROM`, `WHERE`, `JOIN`, `ORDER BY`) को हमेशा UPPERCASE में लिखें, और स्कीमा आइडेंटिफायर्स (टेबल्स और कॉलम्स के नाम) को हमेशा लोअरकेस में अंडरस्कोर के साथ (`snake_case`) लिखें। इससे कोड पढ़ना और समझना बहुत आसान हो जाता है।
2. **Never Query Unfiltered Datasets in Production (`SELECT *` से बचें)**:
   * प्रोडक्शन एनवायरनमेंट में कभी भी आँख बंद करके `SELECT *` न चलाएँ। हमेशा उन चुनिंदा कॉलम्स के नाम स्पष्ट रूप से लिखें जिनकी आपको सच में ज़रूरत है। `SELECT *` चलाने से डेटाबेस सर्वर पर गैर-ज़रूरी मेमोरी लोड पड़ता है, नेटवर्क बैंडविड्थ बर्बाद होती है, और भविष्य में स्कीमा बदलने पर आपके ऍप्लिकेशन्स टूट सकते हैं।
3. **Keep SQL Scripts Idempotent (सुरक्षित और दोबारा चलाने योग्य स्क्रिप्ट्स)**:
   * जब भी डेटाबेस सेटअप स्क्रिप्ट्स लिखें, हमेशा गार्ड स्टेटमेंट्स का उपयोग करें जैसे `CREATE DATABASE IF NOT EXISTS dbname;` या `DROP TABLE IF EXISTS tablename;` ताकि स्क्रिप्ट को दोबारा चलाने पर एरर न आए।
4. **Maintain Commented Code (कोड में कमेंट्स ज़रूर लिखें)**:
   * सिंगल-लाइन कमेंट के लिए डबल-डैश के साथ स्पेस `-- ` का उपयोग करें और मल्टी-लाइन कमेंट के लिए `/* ... */` सिंटैक्स का इस्तेमाल करें ताकि आपकी टीम को क्वेरी का लॉजिक तुरंत समझ आ सके।

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. अपने MySQL सर्वर पर मौजूद सभी उपलब्ध डेटाबेस्स की लिस्ट देखने के लिए कमांड लिखें।
2. एक्टिव डेटाबेस कॉन्टेक्स्ट को `sql_mastery` पर स्विच करने के लिए स्टेटमेंट लिखें।
3. एक्टिव डेटाबेस के अंदर मौजूद सभी टेबल्स की लिस्ट देखने के लिए क्वेरी लिखें।

### Medium (मध्यम)
4. `customers` टेबल का सटीक कॉलम स्ट्रक्चर, डेटा टाइप्स और nullability रूल्स देखने के लिए कमांड लिखें।
5. `orders` टेबल के स्ट्रक्चर का मुआयना करने के लिए क्वेरी लिखें और पहचानें कि कौन सा कॉलम Primary Key का काम कर रहा है।
6. `customers` टेबल से सभी ग्राहकों के फर्स्ट नेम, लास्ट नेम और ईमेल देखने के लिए बिना किसी फ़िल्टर की क्वेरी लिखें।

### Difficult (कठिन)
7. एक ऐसी सिंगल SQL स्टेटमेंट लिखें जो `sql_mastery` स्कीमा के लिए MySQL की अंदरूनी `information_schema.tables` से टेबल के नाम और टेबल इंजन के प्रकार (engine types) निकालती हो।
8. `DESCRIBE employees;` और `SHOW CREATE TABLE employees;` चलाने पर बैकएंड में क्या अंतर होता है, इसे तकनीकी रूप से समझाइए। अपने टर्मिनल में दोनों कमांड्स को चलाकर आउटपुट का विश्लेषण करें।

---

## 11. Interview Questions (इंटरव्यू प्रश्न और उत्तर)

### Q1: DBMS और RDBMS में क्या अंतर होता है?
**Answer**: DBMS (डेटाबेस मैनेजमेंट सिस्टम) कोई भी ऐसा सॉफ्टवेयर सिस्टम है जो फाइलों में डेटा स्टोर और रिट्रीव करता है (जिसमें hierarchical और NoSQL key-value स्टोर्स भी शामिल हैं)। वहीं RDBMS (रिलेशनल DBMS) रिलेशनल अल्जेब्रा पर आधारित एक एडवांस्ड सिस्टम है, जहाँ डेटा को rows और columns वाली टेबल्स में रखा जाता है, टेबल्स के बीच रिश्तों को Foreign Keys के ज़रिए लागू किया जाता है, और सभी ट्रांजेक्शन्स ACID प्रॉपर्टीज का पूरी तरह पालन करते हैं।

### Q2: SQL की पाँच सब-लैंग्वेज कौन सी हैं, और `TRUNCATE` किस कैटेगरी में आता है?
**Answer**:
1. DDL (Data Definition Language)
2. DML (Data Manipulation Language)
3. DQL (Data Query Language)
4. DCL (Data Control Language)
5. TCL (Transaction Control Language)
`TRUNCATE` असल में **DDL** कैटेगरी में आता है, क्योंकि यह टेबल के रिकॉर्ड्स को एक-एक करके डिलीट करने (DML) के बजाय सीधे स्टोरेज लेवल पर डेटा पेजों को deallocate (खाली) कर देता है और टेबल को रीसेट कर देता है।

### Q3: Imperative प्रोग्रामिंग के मुकाबले SQL की Declarative प्रकृति (nature) को समझाइए।
**Answer**: Python या C++ जैसी Imperative भाषाओं में डेवलपर को कंप्यूटर को हर एक कदम, लूप, मेमोरी एलोकेशन और डेटा ट्रैवर्सल खुद कोड करके बताना पड़ता है। इसके विपरीत, Declarative SQL में डेवलपर सिर्फ यह बताता है कि आउटपुट में क्या चाहिए (कौन से कॉलम्स, कौन सी कंडीशन्स, क्या ग्रुपिंग)। डेटाबेस इंजन का Parser, Catalog और Cost-Based Optimizer खुद तय करते हैं कि सबसे बेहतरीन Execution Plan क्या होगा (जैसे Index Seek चुनना, Hash Join लगाना, या Merge Sort करना)।

---

## 12. Quick Revision (त्वरित सारांश / क्विक रिविजन)

* **डेटाबेस** टेबल्स का एक व्यवस्थित कंटेनर होता है; एक **टेबल** में रोज़ (records) और कॉलम्स (attributes) होते हैं।
* **SQL** रिलेशनल डेटाबेस्स को मैनेज और क्वेरी करने के लिए ANSI-मानकीकृत Declarative लैंग्वेज है।
* अनक्वालिफाइड टेबल्स को क्वेरी करने से पहले हमेशा `USE <database_name>;` चलाकर डेटाबेस कॉन्टेक्स्ट सेट करें।
* एनवायरनमेंट और स्कीमा की जाँच के लिए `SHOW DATABASES;`, `SHOW TABLES;`, और `DESCRIBE <table_name>;` का उपयोग करें।
* स्टैंडर्ड SQL कमांड्स 5 मुख्य श्रेणियों में विभाजित हैं: **DDL**, **DML**, **DQL**, **DCL**, और **TCL**।
