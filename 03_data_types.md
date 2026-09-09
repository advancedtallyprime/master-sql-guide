# Chapter 03 — MySQL Data Types & Storage Architecture

---

## 1. What is it?

A **data type** in MySQL is an attribute attached to a table column that specifies the exact category of data the column can hold, the physical binary format used to encode it on disk and in memory, the valid range of values, and the mathematical or string operations that can be performed on it.

Choosing the correct data type is a fundamental database engineering decision. In relational storage engines like **InnoDB**, every data row is packed into fixed-size disk blocks (typically 16 KB pages). Oversized or inappropriate data types waste disk space, degrade operating system I/O throughput, diminish the number of rows that fit into the MySQL Buffer Pool (RAM), and severely impede query execution speeds.

MySQL categorizes data types into five primary families:
1. **Numeric Types**: Integers (exact whole numbers), Fixed-Point (exact decimals), Floating-Point (approximate real numbers), and Bit values.
2. **String / Character Types**: Fixed-length (`CHAR`), Variable-length (`VARCHAR`), Large Text blocks (`TEXT`), and Enumerations (`ENUM`, `SET`).
3. **Binary Types**: Raw byte streams, files, images, or serialized objects (`BINARY`, `VARBINARY`, `BLOB`).
4. **Temporal / Date & Time Types**: Calendar dates, timestamps, time spans, and years (`DATE`, `DATETIME`, `TIMESTAMP`, `TIME`, `YEAR`).
5. **Semi-Structured Document Types**: Native binary JSON documents (`JSON`).

---

## 2. Why do we use it?

1. **Storage Optimization & Cache Density**: Using `TINYINT` (1 byte) instead of `BIGINT` (8 bytes) for an `is_active` flag saves 7 bytes per row. Across a table with 100 million rows, this saves 700 MB of disk space and RAM, allowing more data pages to fit inside the MySQL Buffer Pool.
2. **Domain Integrity & Automatic Validation**: Declaring a column as `DATE` physically prevents impossible values (such as `"2023-02-31"` or `"hello"`) from entering the database.
3. **Mathematical & Financial Accuracy**: Declaring financial balances as `DECIMAL(10,2)` avoids the rounding errors inherent in binary floating-point types (`FLOAT`/`DOUBLE`).
4. **Index Performance**: Smaller, fixed-width keys create shallower, more compact B+ Tree index structures, drastically reducing random disk reads.

---

## 3. Comprehensive Data Type Taxonomy & Storage Reference

### 3.1. Integer Data Types

| Type | Storage | Signed Range | Unsigned Range (`UNSIGNED`) | Typical Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `TINYINT` | 1 Byte | -128 to 127 | 0 to 255 | Status codes, booleans (`TINYINT(1)`), ages |
| `SMALLINT` | 2 Bytes | -32,768 to 32,767 | 0 to 65,535 | Year numbers, small counts, department IDs |
| `MEDIUMINT` | 3 Bytes | -8,388,608 to 8,388,607 | 0 to 16,777,215 | Postal codes, medium category catalogues |
| `INT` / `INTEGER` | 4 Bytes | -2,147,483,648 to 2,147,483,647 | 0 to 4,294,967,295 | Standard primary keys, customer IDs |
| `BIGINT` | 8 Bytes | $\approx -9.22 \times 10^{18}$ to $9.22 \times 10^{18}$ | 0 to $\approx 1.84 \times 10^{19}$ | Global transaction IDs, high-throughput logs |

> [!NOTE]
> `BOOLEAN` and `BOOL` in MySQL are synonyms for `TINYINT(1)`. Zero (`0`) evaluates to `FALSE`, and non-zero values (typically `1`) evaluate to `TRUE`.

### 3.2. Fixed-Point vs Floating-Point Types

| Type | Syntax | Storage | Precision Behavior | Appropriate Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `DECIMAL(M, D)` / `NUMERIC` | `DECIMAL(10, 2)` | Variable (~4 bytes per 9 digits) | **Exact**. Fixed decimal representation; zero rounding drift. | **Currency, pricing, accounting, banking** |
| `FLOAT` | `FLOAT` | 4 Bytes | **Approximate**. Single-precision IEEE 754 floating-point. | Scientific measurements, sensor readings |
| `DOUBLE` | `DOUBLE` | 8 Bytes | **Approximate**. Double-precision IEEE 754 floating-point. | High-range statistical simulations |

> [!WARNING]
> **Never use `FLOAT` or `DOUBLE` for monetary values.** In IEEE 754, numbers like `0.1` cannot be represented precisely in binary, resulting in accumulative cent-rounding drift (e.g., `0.1 + 0.2 = 0.30000000000000004`). Always use `DECIMAL(M, D)`.

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
| `TIME` | `HH:MM:SS[.fraction]` | 3 Bytes | `-838:59:59` to `838:59:59` | None (can represent elapsed time) |
| `DATETIME` | `YYYY-MM-DD HH:MM:SS` | 5 Bytes | `1000-01-01 00:00:00` to `9999-12-31 23:59:59` | **Static**. Stored as-is without UTC conversion. |
| `TIMESTAMP` | `YYYY-MM-DD HH:MM:SS` | 4 Bytes | `1970-01-01 00:00:01` UTC to `2038-01-19 03:14:07` UTC | **Dynamic**. Converted from connection time zone to UTC for storage, converted back on retrieval. |
| `YEAR` | `YYYY` | 1 Byte | `1901` to `2155` | None |

> [!IMPORTANT]
> **The Year 2038 Problem**: Standard 32-bit `TIMESTAMP` values will overflow on **January 19, 2038**. For future-proof business records (e.g., mortgages, birthdates, contracts), use `DATETIME(6)` rather than `TIMESTAMP`.

---

## 4. Syntax

Creating a table utilizing diverse data type specifications:

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

Let us examine the data types chosen for the `products` and `orders` tables in our `sql_mastery` database:

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

1. `cost_price DECIMAL(8, 2)`:
   * **Precision (8)** represents the total count of significant digits across the entire number (both before and after the decimal point).
   * **Scale (2)** represents the number of digits to the right of the decimal point.
   * This column can hold values from `-999999.92` to `999999.99`.
2. `sku CHAR(10)`:
   * In InnoDB, `CHAR(10)` under `utf8mb4` reserves up to $10 \times 4 = 40$ bytes in variable-length rows, but eliminates character length calculations for fixed-size identifiers.
3. `condition_grade ENUM('New', 'Refurbished', 'Used')`:
   * MySQL converts string inputs into 1-byte integer offsets (`'New'` $\rightarrow 1$, `'Refurbished'` $\rightarrow 2$, `'Used'` $\rightarrow 3$). Queries filtering on `condition_grade` benefit from fast integer-level comparisons while presenting readable text to the application.
4. `technical_specs JSON`:
   * Validates that inserted strings conform to standard RFC 8259 JSON format. Invalid JSON generates `ERROR 3140 (22032): Invalid JSON text`. The document is stored in an optimized binary format allowing path lookups without full string deserialization.
5. `technical_specs->>'$.max_wattage'`:
   * The `->>` operator is syntactic shorthand for `JSON_UNQUOTE(JSON_EXTRACT(doc, path))`, which pulls the value from the key `max_wattage` directly as an unquoted SQL string.

---

## 7. Expected Result

Result from the demo query:

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

1. **Using `VARCHAR` for Fixed-Length Codes**:
   * *Mistake*: Defining a 2-character country code as `country_code VARCHAR(2)`.
   * *Problem*: `VARCHAR` adds a 1-byte length prefix to every single entry. For a 2-character code, storing 2 characters plus 1 length byte consumes 3 bytes. `CHAR(2)` is cleaner and eliminates length calculation overhead.
2. **Using Floating-Point (`FLOAT`/`DOUBLE`) for Currency**:
   * *Mistake*: `price FLOAT NOT NULL`.
   * *Consequence*: Calculating sales tax or totals produces rounding anomalies (e.g., `19.99 * 3 = 59.9700012`). Financial audits will fail. Always use `DECIMAL`.
3. **Using `VARCHAR(255)` Blindly Everywhere**:
   * *Mistake*: Assigning `VARCHAR(255)` to columns containing short codes or states.
   * *Problem*: While `VARCHAR` only consumes space for the characters actually stored on disk, the MySQL in-memory internal temporary tables (used for complex `GROUP BY` and `ORDER BY` operations) often allocate memory based on the *declared* column width, quickly causing temporary tables to spill to disk.
4. **Ignoring `TIMESTAMP` Time Zone Conversions**:
   * *Mistake*: Assuming `TIMESTAMP` and `DATETIME` behave identically.
   * *Surprise*: If a server in New York (`UTC-5`) writes `2023-01-01 12:00:00` to a `TIMESTAMP` column, a client connecting from London (`UTC+0`) will see `2023-01-01 17:00:00` because `TIMESTAMP` adjusts for the active connection timezone. `DATETIME` preserves literal values regardless of timezone.

---

## 9. Best Practices

1. **Size Down Integers Based on Business Domains**:
   * If a table will never exceed 100 categories, use `TINYINT UNSIGNED` (range: 0 to 255). Do not default every numeric column to `INT` or `BIGINT`.
2. **Always Qualify Primary Keys as `UNSIGNED`**:
   * Primary key ID counters never contain negative numbers. Declaring `INT UNSIGNED` doubles your addressable range from ~2.14 billion to ~4.29 billion IDs without consuming a single extra byte of storage.
3. **Store Images, Videos, and Files in Object Storage (S3), Not `BLOB`**:
   * Never store binary image or video payloads directly in MySQL `BLOB` columns. Store the binary asset in cloud object storage (e.g., Amazon S3, Google Cloud Storage) and save only the resulting CDN `VARCHAR` URL in the database.
4. **Leverage Virtual Generated Columns with JSON**:
   * When storing JSON documents, extract frequently queried nested keys into generated columns and add an index to that generated column for fast search capabilities.

---

## 10. Practice Questions

### Easy
1. Which numeric data type should you choose to store human ages (0 to 120) with minimum byte consumption?
2. What is the storage difference between `CHAR(10)` and `VARCHAR(10)` when storing the string `'SQL'`?
3. Which data type is strictly required when storing bank account balances to avoid rounding drift?

### Medium
4. Write a `CREATE TABLE` statement for `employee_timesheets` that includes an auto-increment primary key, an employee ID, a clock-in time (`DATETIME`), a clock-out time (`DATETIME`), and an `hours_worked` column using `DECIMAL(4,2)`.
5. Explain what happens if you attempt to insert `'Pending Approval'` into a column defined as `ENUM('Draft', 'Published', 'Archived')`.
6. Contrast the maximum date capability of `DATETIME` versus `TIMESTAMP`. Which one is susceptible to the Year 2038 bug?

### Difficult
7. Design a table `sensor_telemetry` that holds an unsigned integer device ID, a high-precision decimal temperature reading with 4 decimal places, a timestamp with microsecond precision (`TIMESTAMP(6)`), and a JSON document for arbitrary diagnostic payloads.
8. Explain how MySQL stores a `VARCHAR(500)` column internally versus a `TEXT` column in the InnoDB storage engine when row size limits are exceeded.

---

## 11. Interview Questions

### Q1: What is the fundamental difference between `CHAR` and `VARCHAR` in MySQL?
**Answer**: `CHAR(M)` is a fixed-length data type that allocates storage for exactly $M$ characters regardless of the inserted value's length, right-padding shorter strings with spaces (which are stripped upon retrieval). `VARCHAR(M)` is variable-length, storing only the actual characters inserted plus a 1-byte (for $M \le 255$) or 2-byte (for $M > 255$) length prefix. Use `CHAR` for predictably fixed values (hashes, postal codes, state abbreviations) to avoid length prefix calculations; use `VARCHAR` for variable text to save storage.

### Q2: Why should `DECIMAL` be preferred over `FLOAT` or `DOUBLE` for financial data?
**Answer**: `FLOAT` and `DOUBLE` use binary floating-point representation defined by IEEE 754. In base-2 binary, fractional base-10 numbers such as `0.10` or `0.05` cannot be represented precisely, causing cumulative truncation and rounding errors during arithmetic. In contrast, `DECIMAL(M, D)` is a fixed-point type stored as packed binary decimal representations where each digit is preserved exactly as written, guaranteeing zero precision loss.

### Q3: How do `DATETIME` and `TIMESTAMP` differ with respect to time zones?
**Answer**: 
* `DATETIME` is static: it stores the exact year, month, day, hour, minute, and second without time zone awareness. A value entered as `14:00` returns as `14:00` across all client time zones.
* `TIMESTAMP` is time-zone aware: upon insertion, MySQL converts the value from the client's current connection time zone to Coordinated Universal Time (UTC) for physical storage. When retrieved, MySQL dynamically converts the UTC value back into the requesting client's active connection time zone.

---

## 12. Quick Revision

* Use the smallest integer that safely accommodates business scale (`TINYINT` $\rightarrow 1\text{B}$, `SMALLINT` $\rightarrow 2\text{B}$, `INT` $\rightarrow 4\text{B}$, `BIGINT` $\rightarrow 8\text{B}$).
* Always use `UNSIGNED` for IDs, quantities, and counters.
* Use `DECIMAL(M, D)` for all monetary figures; avoid `FLOAT` and `DOUBLE` in financial contexts.
* Use `CHAR` for fixed-width strings; use `VARCHAR` for variable strings.
* `TIMESTAMP` uses 4 bytes and converts to/from UTC (expires in 2038); `DATETIME` uses 5 bytes, covers years 1000–9999, and is timezone-agnostic.
* MySQL provides native `JSON` support with validation and indexed generated columns.
