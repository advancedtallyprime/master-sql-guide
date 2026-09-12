# Chapter 03 — MySQL Data Types & Storage Architecture (Data Types aur Storage Architecture)

---

## 1. What is it? (Ye Kya Hai?)

MySQL me **Data Type** ek aisa rule ya attribute hota hai jo table ke kisi column ke sath associate kiya jata hai. Ye define karta hai ki us column me kis category ka data store hoga, disk aur memory (RAM) me data ka physical binary encoding format kya hoga, values ki valid range kya hogi, aur us par kaun-kaun se mathematical ya string operations perform kiye ja sakte hain.

Right data type choose karna database engineering ka sabse critical decision mana jata hai. Relational storage engines jaise **InnoDB** me har data row fixed-size disk blocks me pack hoti hai (jinhe hum 16 KB pages kehte hain). Agar aap unnecessary oversized data types choose karenge, to disk space waste hogi, operating system ka I/O throughput slow hoga, MySQL Buffer Pool (RAM) me kam rows fit hongi, aur overall query execution speed kafi degrade ho jayegi.

MySQL ke data types ko primarily 5 major families me divide kiya gaya hai:
1. **Numeric Types**: Integers (exact whole numbers), Fixed-Point (exact decimals jaise currency), Floating-Point (approximate real numbers), aur Bit values.
2. **String / Character Types**: Fixed-length (`CHAR`), Variable-length (`VARCHAR`), Large Text blocks (`TEXT`), aur Predefined sets (`ENUM`, `SET`).
3. **Binary Types**: Raw byte streams, files, images ya serialized objects (`BINARY`, `VARBINARY`, `BLOB`).
4. **Temporal / Date & Time Types**: Calendar dates, timestamps, time durations aur years (`DATE`, `DATETIME`, `TIMESTAMP`, `TIME`, `YEAR`).
5. **Semi-Structured Document Types**: Native binary JSON documents (`JSON`).

---

## 2. Why do we use it? (Hum Iska Use Kyun Karte Hain?)

Sahi data type select karne ke 4 zabardast technical fayde hote hain:

1. **Storage Optimization & Cache Density (RAM Ka Behtar Use)**: Maan lijiye aap ek `is_active` flag ke liye `BIGINT` (8 bytes) ke bajaye `TINYINT` (1 byte) use karte hain. Isse har row me 7 bytes bachte hain. Agar aapke table me 100 million rows hain, to seedhe 700 MB disk space aur RAM bachegi, jisse MySQL Buffer Pool me zyada data pages fit ho sakenge.
2. **Domain Integrity & Automatic Validation (Invalid Data Se Protection)**: Agar aap kisi column ko `DATE` declare karte hain, to database engine `"2023-02-31"` ya `"hello"` jaise impossible values ko insert hone se pehle hi block kar deta hai.
3. **Mathematical & Financial Accuracy (Paison Ka Exact Calculation)**: Financial balances aur prices ko `DECIMAL(10,2)` declare karne se binary floating-point (`FLOAT`/`DOUBLE`) ke rounding errors se bacha ja sakta hai.
4. **Index Performance (Tez Search)**: Chhote aur fixed-width data types par banaye gaye B+ Tree indexes shallow aur compact hote hain, jisse disk par random I/O reads kafi kam ho jaate hain.

---

## 3. Syntax & Storage Reference (Taxonomy aur Storage Details)

### 3.1. Integer Data Types

| Type | Storage | Signed Range | Unsigned Range (`UNSIGNED`) | Typical Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `TINYINT` | 1 Byte | -128 to 127 | 0 to 255 | Status codes, booleans (`TINYINT(1)`), ages |
| `SMALLINT` | 2 Bytes | -32,768 to 32,767 | 0 to 65,535 | Year numbers, small counts, department IDs |
| `MEDIUMINT` | 3 Bytes | -8,388,608 to 8,388,607 | 0 to 16,777,215 | Postal codes, medium category catalogues |
| `INT` / `INTEGER` | 4 Bytes | -2,147,483,648 to 2,147,483,647 | 0 to 4,294,967,295 | Standard primary keys, customer IDs |
| `BIGINT` | 8 Bytes | $\approx -9.22 \times 10^{18}$ to $9.22 \times 10^{18}$ | 0 to $\approx 1.84 \times 10^{19}$ | Global transaction IDs, high-throughput logs |

> [!NOTE]
> MySQL me `BOOLEAN` aur `BOOL` internally `TINYINT(1)` ke synonyms hote hain. Zero (`0`) ko `FALSE` mana jata hai aur non-zero values (typically `1`) ko `TRUE`.

### 3.2. Fixed-Point vs Floating-Point Types

| Type | Syntax | Storage | Precision Behavior | Appropriate Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `DECIMAL(M, D)` / `NUMERIC` | `DECIMAL(10, 2)` | Variable (~4 bytes per 9 digits) | **Exact**. Fixed decimal representation; zero rounding drift. | **Currency, pricing, accounting, banking** |
| `FLOAT` | `FLOAT` | 4 Bytes | **Approximate**. Single-precision IEEE 754 floating-point. | Scientific measurements, sensor readings |
| `DOUBLE` | `DOUBLE` | 8 Bytes | **Approximate**. Double-precision IEEE 754 floating-point. | High-range statistical simulations |

> [!WARNING]
> **Paison aur monetary values ke liye kabhi `FLOAT` ya `DOUBLE` ka use mat kijiye.** IEEE 754 standard me `0.1` jaise fractional numbers ko binary me exactly represent nahi kiya ja sakta, jiski wajah se cumulative rounding drift aati hai (jaise `0.1 + 0.2 = 0.30000000000000004`). Financial calculations ke liye hamesha `DECIMAL(M, D)` use karein.

### 3.3. String & Text Types

| Type | Maximum Size | Storage Mechanics | Trailing Space Behavior | Best Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `CHAR(M)` | $M \le 255$ chars | Fixed-length; padded with spaces to size $M$. | Trailing spaces stripped upon retrieval. | Fixed-width codes: ISO currency (`'USD'`), state codes (`'CA'`), MD5/SHA256 hashes. |
| `VARCHAR(M)` | $M \le 65,535$ bytes | Variable-length; stores actual characters + 1 or 2 prefix length bytes. | Preserves trailing spaces (MySQL 5.0.3+). | Variable-length strings: names, email addresses, URLs, street lines. |
| `TEXT` | 65,535 bytes (64 KB) | Variable-length; off-page LOB pointers in InnoDB if exceeding page threshold. | Preserves spaces. | Blog posts, user bios, descriptions. |
| `MEDIUMTEXT` | 16,777,215 bytes (16 MB)| Off-page storage. | Preserves spaces. | Large documents, XML payloads. |
| `LONGTEXT` | 4,294,967,295 bytes (4 GB) | Off-page storage. | Preserves spaces. | Massive logs, books, system dumps. |
| `ENUM('v1','v2')`| 65,535 distinct elements | Stored internally as 1 or 2 byte integers mapping to string constants. | Strict validation against allowed set. | Finite static choices: order statuses, days of week, gender. |

### 3.4. Date & Time Types

| Type | Format | Storage | Valid Range | Time Zone Handling |
| :--- | :--- | :--- | :--- | :--- |
| `DATE` | `YYYY-MM-DD` | 3 Bytes | `1000-01-01` to `9999-12-31` | None |
| `TIME` | `HH:MM:SS[.fraction]` | 3 Bytes | `-838:59:59` to `838:59:59` | None (elapsed duration store kar sakta hai) |
| `DATETIME` | `YYYY-MM-DD HH:MM:SS` | 5 Bytes | `1000-01-01 00:00:00` to `9999-12-31 23:59:59` | **Static**. Bina UTC conversion ke as-it-is store hota hai. |
| `TIMESTAMP` | `YYYY-MM-DD HH:MM:SS` | 4 Bytes | `1970-01-01 00:00:01` UTC to `2038-01-19 03:14:07` UTC | **Dynamic**. Connection timezone se UTC me convert hota hai storage ke liye, retrieval par wapas convert hota hai. |
| `YEAR` | `YYYY` | 1 Byte | `1901` to `2155` | None |

> [!IMPORTANT]
> **Year 2038 Problem (Y2038 Bug)**: Standard 32-bit `TIMESTAMP` values **January 19, 2038** ko integer overflow kar jayengi. Isliye long-term business records (jaise loans, mortgages, birth dates, long contracts) ke liye `TIMESTAMP` ke bajaye `DATETIME(6)` ka use karein.

---

## 4. Basic Example

Aaiye ek aisi table create karte hain jisme alag-alag categories ke data types ka proper use demonstrate kiya gaya ho:

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

## 5. Real-World Example

Aaiye hamare `sql_mastery` database ke real schema ko dekhein aur strict typing ke sath ek modern table banakar JSON path extraction operators ka use karein:

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

## 6. Step-by-Step Explanation

Aaiye data type mechanisms ko deep technical level par samajhte hain:

1. `cost_price DECIMAL(8, 2)`:
   * **Precision (8)**: Poore number me total kitne significant digits ho sakte hain (decimal point ke pehle aur baad dono ko milakar).
   * **Scale (2)**: Decimal point ke right side me kitne fractional digits honge.
   * Iska matlab ye column `-999999.99` se lekar `999999.99` tak ke values ko bina kisi rounding error ke exact store kar sakta hai.
2. `sku CHAR(10)`:
   * `utf8mb4` encoding me `CHAR(10)` fixed-length space reserve karta hai, lekin fixed-width identifiers ke liye length byte read/calculate karne ka overhead bachta hai.
3. `condition_grade ENUM('New', 'Refurbished', 'Used')`:
   * MySQL in string values ko internally 1-byte integer offsets me store karta hai (`'New'` $\rightarrow 1$, `'Refurbished'` $\rightarrow 2$, `'Used'` $\rightarrow 3$). Isse queries me fast numeric comparison ka benefit milta hai aur readability bhi maintain rehti hai.
4. `technical_specs JSON`:
   * Engine ye validate karta hai ki insert hone wali string valid RFC 8259 JSON format me ho. Agar JSON invalid ho to engine turant `ERROR 3140 (22032): Invalid JSON text` return kar deta hai. Data binary format me store hota hai jisse bina poore document ko parse kiye specific keys ko query kiya ja sakta hai.
5. `technical_specs->>'$.max_wattage'`:
   * `->>` operator asal me `JSON_UNQUOTE(JSON_EXTRACT(doc, path))` ka syntactic shortcut hai, jo JSON document me se `max_wattage` value ko ek clean unquoted SQL string ke roop me extract karta hai.

---

## 7. Expected Result

Demo query run karne ke baad terminal output:

```
+------------+----------------------------+------------+-----------------+-----------+------------+
| sku        | title                      | base_price | condition_grade | max_watts | primary_os |
+------------+----------------------------+------------+-----------------+-----------+------------+
| SKU-990011 | UltraPort USB-C Hub 8-in-1 |      49.99 | New             | 100       | Windows    |
+------------+----------------------------+------------+-----------------+-----------+------------+
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes

1. **Fixed-Length Codes Ke Liye `VARCHAR` Use Karna**:
   * *Mistake*: 2-character country code ko `country_code VARCHAR(2)` define karna.
   * *Problem*: `VARCHAR` har entry ke sath 1-byte length prefix add karta hai. To 2 characters + 1 length byte milakar 3 bytes lagte hain. Fixed-length data ke liye `CHAR(2)` zyada efficient aur clean hota hai.
2. **Monetary Values Ke Liye `FLOAT`/`DOUBLE` Use Karna**:
   * *Mistake*: `price FLOAT NOT NULL`.
   * *Consequence*: Tax ya order totals calculate karte waqt rounding issues aate hain (jaise `19.99 * 3 = 59.9700012`). Financial audits me mismatch ho jayega. Hamesha `DECIMAL` use karein.
3. **Har Jagah Blindly `VARCHAR(255)` Likh Dena**:
   * *Mistake*: Short codes ya state abbreviations ke liye bhi `VARCHAR(255)` assign kar dena.
   * *Problem*: Halanki disk par `VARCHAR` sirf actual text ka space leta hai, lekin complex `GROUP BY` aur `ORDER BY` operations ke dauran MySQL ke internal in-memory temporary tables column ke declared width (`255`) ke hisab se memory allocate karte hain, jisse memory jaldi bhar jaati hai aur temporary tables disk par swap hone lagti hain.
4. **`TIMESTAMP` Ke Time Zone Conversion Ko Ignore Karna**:
   * *Mistake*: `TIMESTAMP` aur `DATETIME` ko identical samajhna.
   * *Surprise*: Agar New York (`UTC-5`) me koi client `2023-01-01 12:00:00` likhta hai, to London (`UTC+0`) ka client wahi row read karne par `2023-01-01 17:00:00` dekhega, kyunki `TIMESTAMP` connection timezone ke according dynamic conversion karta hai. Jabki `DATETIME` static rehta hai.

---

## 9. Best Practices

1. **Business Domain Ke According Integer Size Chhota Rakhein**:
   * Agar kisi table me categories kabhi 100 se zyada nahi hongi, to `TINYINT UNSIGNED` (range: 0 to 255) use karein. Har jagah bina soche `INT` ya `BIGINT` mat lagaiye.
2. **Primary Keys Ko Hamesha `UNSIGNED` Declare Karein**:
   * Primary key IDs me kabhi negative numbers nahi hote. `INT UNSIGNED` use karne se bina extra disk space lagaye aapki addressable ID range 2.14 billion se double hokar 4.29 billion ho jaati hai.
3. **Images, Videos Aur Files Ko Object Storage (S3) Me Rakhein, `BLOB` Me Nahi**:
   * Database tables ke andar binary media files store mat kijiye. Unhe cloud object storage (jaise AWS S3, Google Cloud Storage) me upload karein aur database me sirf unka CDN `VARCHAR` URL save karein.
4. **JSON Ke Sath Virtual Generated Columns Ka Use Karein**:
   * Agar JSON documents ke andar ki kisi nested key par baar-baar search ya filter karna ho, to us par ek virtual generated column banayein aur us generated column par index create karein.

---

## 10. Practice Questions

### Easy
1. Human age (0 to 120) store karne ke liye minimum byte consumption wala kaun sa numeric data type best rahega?
2. `'SQL'` string store karte waqt `CHAR(10)` aur `VARCHAR(10)` ke physical storage consumption me kya difference hoga?
3. Bank account balance store karte waqt rounding issues se bachne ke liye kaun sa data type strictly required hai?

### Medium
4. `employee_timesheets` table ke liye ek `CREATE TABLE` statement likhiye jisme auto-increment primary key, employee ID, clock-in time (`DATETIME`), clock-out time (`DATETIME`), aur `hours_worked` column `DECIMAL(4,2)` ke sath ho.
5. Agar koi column `ENUM('Draft', 'Published', 'Archived')` define hai, to usme `'Pending Approval'` insert karne par kya hoga?
6. `DATETIME` aur `TIMESTAMP` ki maximum date capacity me kya farq hai? Kaun sa data type Year 2038 problem se affected hai?

### Difficult
7. `sensor_telemetry` naam ki ek table design kijiye jisme unsigned integer device ID, 4 decimal places wala high-precision temperature reading, microsecond precision wala timestamp (`TIMESTAMP(6)`), aur arbitrary diagnostic data ke liye ek JSON document ho.
8. Jab InnoDB storage engine me row size limits exceed ho jaati hain, to MySQL internally `VARCHAR(500)` column ko `TEXT` column ke comparison me kaise store karta hai?

---

## 11. Interview Questions

### Q1: MySQL me `CHAR` aur `VARCHAR` ke beech fundamental difference kya hota hai?
**Answer**: `CHAR(M)` ek fixed-length data type hai jo inserted string ki actual length chahe jo bhi ho, disk par exactly $M$ characters ki memory allocate karta hai (shorter strings ke right me spaces pad kar deta hai, jo retrieval ke waqt strip ho jaate hain). `VARCHAR(M)` ek variable-length data type hai, jo sirf actual characters aur sath me 1-byte (agar $M \le 255$) ya 2-byte (agar $M > 255$) length prefix store karta hai. Fixed-width data (jaise MD5 hashes, currency codes) ke liye `CHAR` better hai kyunki length calculation nahi karni padti; variable text (jaise names, emails) ke liye `VARCHAR` space save karta hai.

### Q2: Financial systems me `FLOAT` ya `DOUBLE` ke bajaye `DECIMAL` kyun use karna chahiye?
**Answer**: `FLOAT` aur `DOUBLE` IEEE 754 binary floating-point representation use karte hain. Base-2 binary format me fractional base-10 numbers jaise `0.10` ya `0.05` ko exactly represent nahi kiya ja sakta, jiski wajah se arithmetic operations me cumulative truncation aur rounding drift aati hai. Dusri taraf, `DECIMAL(M, D)` ek fixed-point data type hai jo packed binary format me store hota hai aur har digit ko exactly waise hi preserve karta hai jaise likha gaya ho. Is wajah se isme zero precision loss hota hai, jo financial accounting ke liye compulsory hai.

### Q3: Time zone handling ke mamle me `DATETIME` aur `TIMESTAMP` me kya farq hai?
**Answer**:
* `DATETIME` timezone-agnostic (static) hota hai: ye exact year, month, day, hour, minute, second store karta hai. Agar server par `14:00` likha gaya hai, to kisi bhi timezone ka client query kare, use `14:00` hi milega.
* `TIMESTAMP` timezone-aware hota hai: insert karte waqt MySQL client ke current connection timezone se UTC (Coordinated Universal Time) me convert karke disk par store karta hai. Read karte waqt MySQL dynamically us UTC value ko requesting client ke connection timezone ke mutabiq convert karke return karta hai.

---

## 12. Quick Revision

* Hamesha business domain ke hisab se smallest possible integer use karein (`TINYINT` $\rightarrow 1\text{B}$, `SMALLINT` $\rightarrow 2\text{B}$, `INT` $\rightarrow 4\text{B}$, `BIGINT` $\rightarrow 8\text{B}$).
* IDs, quantities aur counters ke liye hamesha `UNSIGNED` attribute specify karein.
* Sabhi monetary aur currency values ke liye `DECIMAL(M, D)` use karein; `FLOAT` aur `DOUBLE` strictly avoid karein.
* Fixed-length strings ke liye `CHAR` aur variable-length strings ke liye `VARCHAR` use karein.
* `TIMESTAMP` 4 bytes leta hai aur UTC me convert hota hai (2038 me overflow hoga); `DATETIME` 5 bytes leta hai, years 1000–9999 cover karta hai, aur static rehta hai.
* MySQL native `JSON` support deta hai jisme validation, path extraction operators (`->`, `->>`) aur indexed generated columns available hain.
