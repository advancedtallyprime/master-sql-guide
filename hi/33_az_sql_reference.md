# Chapter 33 — The Master A–Z SQL & MySQL Reference Lexicon

SQL keywords, MySQL commands, built-in functions, operators, aur relational database concepts ki ek exhaustive alphabetical dictionary.

---

### A
* **`ABS(X)`**: Built-in mathematical function jo $X$ ka absolute (positive) magnitude return karta hai.
  ```sql
  SELECT ABS(-25.5); -- 25.5
  ```
* **`ACID`**: Relational transaction ki chaar fundamental guarantees: **A**tomicity, **C**onsistency, **I**solation, **D**urability.
* **`ACTION`**: Referential integrity specifications mein use hone wala keyword (`ON DELETE NO ACTION`, `ON UPDATE CASCADE`).
* **`ADD COLUMN`**: Table mein naya column add karne ke liye use hone wala `ALTER TABLE` clause.
  ```sql
  ALTER TABLE employees ADD COLUMN middle_name VARCHAR(50);
  ```
* **`AFTER`**:
  1. `ALTER TABLE ... ADD COLUMN col INT AFTER existing_col;` mein positional modifier.
  2. Database triggers ke liye timing specifier (`CREATE TRIGGER trg AFTER INSERT ...`).
* **`ALL`**:
  1. `UNION ALL` mein set operator modifier jo duplicate rows ko preserve rakhta hai.
  2. Subquery comparison quantifier (`WHERE salary > ALL (SELECT salary FROM ...)`).
* **`ALTER DATABASE`**: Existing database ki characteristics (jaise default character set aur collation) ko modify karta hai.
* **`ALTER TABLE`**: Table columns, indexes, aur constraints ko add, modify, rename, ya drop karne ke liye use hone wala DDL statement.
* **`ALTER VIEW`**: Existing view ko drop kiye bina uski query definition ko modify karta hai.
* **`AND`**: Logical operator jo sirf tabhi `TRUE` return karta hai jab dono boolean conditions `TRUE` hon. Iski precedence `OR` se higher hoti hai.
* **`ANY`**: Subquery comparison operator jo `TRUE` return karta hai agar subquery dwara return ki gayi kam se kam ek row ke liye condition satisfy ho jaye.
* **`AS`**: Column aliases (`SELECT salary AS base_pay`) ya table aliases (`FROM customers AS c`) define karne ke liye use hone wala keyword.
* **`ASC`**: `ORDER BY` mein ascending sort sequence (smallest se largest) indicate karne wala specifier. Ye default hota hai.
* **`AUTO_INCREMENT`**: MySQL column attribute jo nayi rows ke liye automatically sequential integer identifiers generate karta hai.
* **`AVG(X)`**: Aggregate function jo $X$ ki non-null values ka arithmetic mean return karta hai.

---

### B
* **`BCNF` (Boyce-Codd Normal Form)**: Advanced normal form jahan har functional dependency $X \rightarrow Y$ ke liye, determinant $X$ hamesha ek Super Key hona chahiye.
* **`BEFORE`**: Triggers ke liye timing specifier (`CREATE TRIGGER trg BEFORE INSERT ...`), jo data validation aur incoming `NEW` row values modify karne ke liye useful hota hai.
* **`BEGIN`**: Transaction block start karne ka shorthand (`BEGIN;` ya `START TRANSACTION;`), ya procedural code ko enclose karne wala keyword (`BEGIN ... END`).
* **`BETWEEN`**: Range operator jo test karta hai ki koi value inclusive continuous range $[A, B]$ ke andar fall karti hai ya nahi.
  ```sql
  WHERE unit_price BETWEEN 10.00 AND 50.00
  ```
* **`BIGINT`**: 8-byte integer type jo $-9.22 \times 10^{18}$ se $+9.22 \times 10^{18}$ tak (ya `UNSIGNED` hone par $1.84 \times 10^{19}$ tak) values cover karta hai.
* **`BINARY`**: Fixed-length raw byte strings ko bina character set interpretation ke store karne wala data type.
* **`BIT`**: Bit-field values store karne wala data type (e.g., `BIT(8)`).
* **`BLOB`**: Binary Large Object data type jo variable-length binary payloads store karne ke liye use hota hai (standard `BLOB` ke liye 64 KB tak, `LONGBLOB` ke liye 4 GB tak).
* **`BOOLEAN` / `BOOL`**: MySQL mein `TINYINT(1)` ke synonyms. Zero (`0`) `FALSE` represent karta hai; non-zero (typically `1`) `TRUE` represent karta hai.
* **`B+ Tree`**: Balanced tree data structure jise MySQL InnoDB clustered aur secondary indexes store karne ke liye use karta hai.

---

### C
* **`CALL`**: Stored Procedure ko execute karne ke liye use hone wala statement.
  ```sql
  CALL sp_get_employee_payroll(101);
  ```
* **`CASCADE`**: Foreign keys mein referential action (`ON DELETE CASCADE`, `ON UPDATE CASCADE`) jo parent deletions ya updates ko child rows par propagate karta hai.
* **`CASE`**: Boolean evaluations ke basis par values return karne wala multi-branch conditional expression.
  ```sql
  CASE WHEN points > 500 THEN 'Gold' ELSE 'Silver' END
  ```
* **`CAST()`**: Expression ko explicitly ek data type se doosre data type mein convert karne wala function (`CAST('2023-01-01' AS DATE)`).
* **`CEIL()` / `CEILING()`**: Number se greater than ya equal smallest integer return karta hai (rounds up).
* **`CHANGE COLUMN`**: Column ko rename karne aur optionally uska data type aur attributes alter karne ke liye use hone wala `ALTER TABLE` clause.
* **`CHAR()`**: Fixed-length character string type jo 255 characters tak store karta hai aur right side spaces se pad hota hai.
* **`CHAR_LENGTH()`**: String mein characters ki sankhya return karta hai (UTF-8 character-aware).
* **`CHECK`**: Integrity constraint jo validate karta hai ki row values boolean expression ko satisfy karein (MySQL 8.0.16+ mein enforced).
* **`CLUSTERED INDEX`**: InnoDB mein primary physical B+ Tree index jahan leaf pages actual table row data store karte hain.
* **`COALESCE()`**: Arbitrary argument list se pehli non-NULL expression return karne wala function.
* **`COLLATE`**: Character string comparison aur sorting ke liye collation rules (case sensitivity, accent sensitivity) specify karta hai.
* **`COMMIT`**: TCL statement jo active transaction ke dauran kiye gaye saare modifications ko disk par permanently persist karta hai.
* **`CONCAT()`**: Multiple strings ko join karke ek string banata hai. Agar koi bhi argument `NULL` ho toh `NULL` return karta hai.
* **`CONCAT_WS()`**: Concatenate With Separator. Delimiter ka use karke strings join karta hai aur `NULL` arguments ko skip kar deta hai.
* **`CONSTRAINT`**: Schema rule jo relational ya domain validity enforce karta hai (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`).
* **`COUNT()`**: Criteria match karne wali rows ki sankhya return karne wala aggregate function (`COUNT(*)` vs `COUNT(col)`).
* **`CREATE`**: Databases, tables, views, indexes, procedures, functions, ya triggers instantiate karne ke liye use hone wala DDL statement.
* **`CROSS JOIN`**: Do tables ka Cartesian Product ($N \times M$) produce karne wala join.
* **`CTE (Common Table Expression)`**: `WITH` clause ka use karke define kiya gaya temporary named result set.
* **`CURDATE()`**: Current date ko `'YYYY-MM-DD'` format mein return karne wala function.
* **`CURRENT_TIMESTAMP()`**: Current date aur time return karne wala function (`NOW()` ka synonym).
* **`CURTIME()`**: Current time ko `'HH:MM:SS'` format mein return karne wala function.

---

### D
* **`DATABASE()`**: Active default database ka naam return karne wala built-in function.
* **`DATE`**: 3-byte temporal data type jo `'1000-01-01'` se `'9999-12-31'` tak calendar dates store karta hai.
* **`DATETIME`**: 5-byte temporal data type jo bina timezone conversion ke statically date aur time store karta hai.
* **`DATE_ADD()`**: Date mein temporal interval add karne wala function (`DATE_ADD(CURDATE(), INTERVAL 7 DAY)`).
* **`DATE_FORMAT()`**: Format string ke mutabiq date value ko format karne wala function (`DATE_FORMAT(NOW(), '%Y-%m-%d')`).
* **`DATE_SUB()`**: Date se temporal interval subtract karne wala function.
* **`DATEDIFF()`**: Do dates ke beech days mein difference return karne wala function (`d1 - d2`).
* **`DAY()` / `DAYOFMONTH()`**: Date se day of the month component (1–31) extract karta hai.
* **`DAYNAME()`**: Day of the week ka name return karta hai (e.g., `'Monday'`).
* **`DECIMAL(M, D)`**: Exact numerical values store karne wala fixed-point numeric data type ($M$ total digits aur $D$ decimal places). Currency ke liye mandatory hai.
* **`DECLARE`**: Stored routines mein local variables, conditions, cursors, aur error handlers define karne ke liye use hone wala procedural keyword.
* **`DEFAULT`**: Column ke liye fallback value specify karne wala constraint jab `INSERT` statement use omit kar de.
* **`DELETE`**: Filter condition ke basis par table se existing rows remove karne ke liye use hone wala DML statement.
* **`DELIMITER`**: Stored routines create karte waqt statement termination character change karne ke liye client utility command.
* **`DENSE_RANK()`**: Window function jo ties par numbers skip kiye bina partition ke andar rows ko rank assign karta hai.
* **`DESC` / `DESCRIBE`**:
  1. Table structural metadata inspect karne ke liye statement (`DESC employees;`).
  2. `ORDER BY` mein descending sort order indicate karne wala keyword.
* **`DETERMINISTIC`**: Keyword jo declare karta hai ki stored function identical inputs ke liye hamesha exact same result return karega.
* **`DISTINCT`**: Query results se duplicate rows eliminate karne ke liye `SELECT` mein use hone wala keyword.
* **`DROP`**: Databases, tables, views, indexes, ya stored routines ko permanently destroy karne wala DDL statement.

---

### E
* **`ENUM`**: String object jiska value table creation ke dauran define ki gayi permitted static values ki list mein se choose hota hai.
* **`eq_ref`**: `EXPLAIN` mein high-performance join access type jahan preceding table ke har row combination ke liye table se exactly ek row read hoti hai.
* **`EXISTS`**: Subquery dwara return ki gayi rows ki existence test karne wala boolean operator.
* **`EXPLAIN`**: MySQL Cost-Based Optimizer dwara choose kiye gaye execution plan ko display karne wala statement.
* **`EXPLAIN ANALYZE`**: Profiling statement (MySQL 8.0.18+) jo query execute karta hai aur actual runtime performance aur iterator row counts report karta hai.

---

### F
* **`FIRST`**: `ALTER TABLE ... ADD COLUMN` mein positional keyword jo naye column ko table ke bilkul shuru mein place karta hai.
* **`FIRST_VALUE()`**: Window frame ke andar pehli value return karne wala window function.
* **`FLOOR()`**: Number se less than ya equal largest integer return karne wala mathematical function (rounds down).
* **`FOREIGN KEY`**: Referential constraint jo child table column ko parent table ki primary key se bind karta hai.
* **`FROM`**: SQL clause jo specify karta hai ki records kis table(s) se retrieve karne hain.
* **`FULLTEXT`**: Text columns par natural language keyword searches perform karne ke liye use hone wala specialized index type.
* **`FUNCTION`**: Ek stored routine jo parameters accept karti hai aur strictly ek single scalar value return karti hai.

---

### G
* **`GRANT`**: Database user accounts ko privileges ya roles assign karne ke liye use hone wala DCL statement.
* **`GROUP BY`**: Identical values share karne wali rows ko aggregation ke liye summary buckets mein group karne wala clause.
* **`GROUP_CONCAT()`**: Har group ki non-null strings ko concatenate karke ek single delimited string banane wala aggregate function.
* **`GROUPING()`**: `WITH ROLLUP` ke saath use hone wala function jo generated rollup summary NULLs ke liye `1` aur genuine data values ke liye `0` return karta hai.

---

### H
* **`HASH JOIN`**: MySQL 8.0.18+ mein modern join algorithm jo indexes na hone par tables ko in-memory hash table ke through join karta hai.
* **`HAVING`**: `GROUP BY` execute hone ke baad aggregated summary groups ko filter karne ke liye use hone wala clause.
* **`HOUR()`**: Time ya datetime value se hour component (0–23) extract karne wala function.

---

### I
* **`IF()`**: Inline conditional function: `IF(test_condition, true_value, false_value)`.
* **`IFNULL()`**: Agar target expression `NULL` ho toh fallback value return karne wala function.
* **`IN`**: Operator jo test karta hai ki koi value enumerated list ya subquery ke kisi item se match karti hai ya nahi.
* **`INDEX`**: Data retrieval speed accelerate karne ke liye design kiya gaya B+ Tree data structure.
* **`INNER JOIN`**: Relational join jo sirf wahi rows return karta hai jinke paas dono tables mein matching values hon.
* **`INSERT`**: Table mein naye records insert karne ke liye use hone wala DML statement.
* **`INSTR()`**: String mein kisi substring ke pehle occurrence ka 1-based position return karne wala function.
* **`INT` / `INTEGER`**: 4-byte integer type jo $-2.14 \times 10^9$ se $+2.14 \times 10^9$ tak (ya `UNSIGNED` hone par $4.29 \times 10^9$ tak) numbers store karta hai.
* **`IS NULL` / `IS NOT NULL`**: `NULL` markers ki presence ya absence test karne wale unary operators.
* **`ISOLATION LEVEL`**: Ye define karta hai ki kisi transaction ke operations concurrent transactions ko kis hadd tak visible hain (`READ COMMITTED`, `REPEATABLE READ`, etc.).

---

### J
* **`JOIN`**: Related column ke basis par do ya do se zyada tables ke columns ko combine karne wala operation.
* **`JSON`**: Semi-structured JSON documents ko binary parsing aur validation ke saath store karne wala native data type.
* **`JSON_EXTRACT()`**: JSONPath ka use karke JSON document se values extract karne wala function (operator: `->`).
* **`JSON_UNQUOTE()`**: JSON string se quotes strip karne wala function (operator: `->>`).

---

### K
* **`KEY`**: MySQL table creation syntax mein `INDEX` ka synonym.
* **`Keyset Pagination`**: Pagination technique jo `OFFSET` use karne ke bajaye unique indexed column (`WHERE id < last_id`) par filter karti hai.

---

### L
* **`LAG()`**: Window function jo bina self-join kiye specified offset par preceding row se data access karta hai.
* **`LAST_INSERT_ID()`**: Connection par most recent `INSERT` statement dwara set ki gayi pehli automatically generated `AUTO_INCREMENT` value return karne wala function.
* **`LEAD()`**: Window function jo specified offset par subsequent row se data access karta hai.
* **`LEFT()`**: String se leftmost $N$ characters return karne wala function.
* **`LEFT JOIN`**: Outer join jo left table ki saari rows aur right table ki matching rows return karta hai.
* **`LENGTH()`**: String ki length raw bytes mein return karne wala function.
* **`LIKE`**: Wildcards (`%` aur `_`) support karne wala pattern-matching operator.
* **`LIMIT`**: Query dwara return ki jaane wali rows ki maximum sankhya constrain karne wala clause.
* **`LOWER()` / `LCASE()`**: Character strings ko lowercase mein convert karne wala function.
* **`LPAD()`**: Target length reach karne ke liye string ko left side se specified characters se pad karne wala function.

---

### M
* **`MAX()`**: Column mein highest non-null value return karne wala aggregate function.
* **`MEDIUMINT`**: 3-byte integer type jo $-8,388,608$ se $+8,388,607$ tak values store karta hai.
* **`MIN()`**: Column mein lowest non-null value return karne wala aggregate function.
* **`MINUTE()`**: Time value se minute component (0–59) extract karne wala function.
* **`MOD()`**: Division remainder return karne wala modulo operator/function ($N \pmod M$).
* **`MODIFY COLUMN`**: Column ko rename kiye bina in-place column definition alter karne wala `ALTER TABLE` clause.
* **`MONTH()`**: Date se month component (1–12) extract karne wala function.
* **`MONTHNAME()`**: Month ka full name return karne wala function (e.g., `'August'`).
* **`MVCC` (Multi-Version Concurrency Control)**: Engine architecture jo concurrent readers ko bina read locks acquire kiye Undo logs ke through historical data snapshots access karne allow karti hai.

---

### N
* **`NATURAL JOIN`**: Join jo dono tables mein identical names wale saare columns ko automatically match karta hai (production mein discouraged hai).
* **`NOT`**: Boolean truth value ko invert/reverse karne wala logical operator.
* **`NOT NULL`**: Column mein `NULL` values ko disallow karne wala integrity constraint.
* **`NOW()`**: Query execution shuru hone ke moment par current timestamp return karne wala function.
* **`NTILE()`**: Partition ko $N$ equal-sized buckets mein divide karne wala window function.
* **`NULL`**: Missing, unknown, ya inapplicable data indicate karne wala marker.
* **`NULLIF(A, B)`**: Function jo agar $A = B$ ho toh `NULL` return karta hai; warna $A$ return karta hai.

---

### O
* **`ON`**: `JOIN` mein tables ko link karne ke liye relational condition specify karne wala clause.
* **`ON DELETE`**: Referenced parent row delete hone par referential actions (`CASCADE`, `RESTRICT`, `SET NULL`) specify karta hai.
* **`ON UPDATE`**: Referenced parent key modify hone par referential actions specify karta hai.
* **`OR`**: Logical operator jo `TRUE` return karta hai agar koi bhi ek condition `TRUE` evaluate ho.
* **`ORDER BY`**: Output rows ko ascending ya descending sequence mein sort karne wala clause.
* **`OUT`**: Stored procedures mein parameter mode jo computed values calling client ko wapas return karta hai.
* **`OVER()`**: Window Functions ke liye analytical window (partitioning, ordering, frames) define karne wala clause.

---

### P
* **`PARTITION BY`**: Window Function ke andar rows ko distinct processing buckets mein divide karne wala clause.
* **`POW()` / `POWER()`**: Base number ko specified exponent tak raise karne wala mathematical function ($X^Y$).
* **`PRIMARY KEY`**: Table ke har row ko uniquely identify karne wala column(s); InnoDB mein clustered index define karta hai.
* **`PROCEDURE`**: Pre-compiled database routine jise `CALL` ke through execute kiya jaata hai.

---

### R
* **`RANK()`**: Window function jo rows ko rank numbers assign karta hai, ties ke liye identical ranks aur subsequent gaps produce karta hai.
* **`READ COMMITTED`**: Transaction isolation level jo Dirty Reads prevent karta hai, lekin Non-Repeatable aur Phantom Reads allow karta hai.
* **`REDO LOG`**: Write-Ahead Log (WAL) file jo system crash recovery ke dauran transaction Durability guarantee karti hai.
* **`REFERENCES`**: `FOREIGN KEY` constraint mein parent table aur column define karne wala keyword.
* **`REGEXP` / `RLIKE`**: Regular expressions support karne wala pattern-matching operator.
* **`RENAME TABLE`**: Ek ya multiple database tables ko rename karne wala DDL statement.
* **`REPEATABLE READ`**: MySQL ka default transaction isolation level; Dirty, Non-Repeatable, aur Phantom reads prevent karta hai.
* **`REPLACE()`**: String ke andar kisi substring ke sabhi occurrences ko replace karne wala function.
* **`RESTRICT`**: Referential action jo parent deletion ya modification ko block karti hai agar dependent child records exist karte hon.
* **`REVOKE`**: Database accounts se privileges ya roles remove karne wala DCL statement.
* **`RIGHT()`**: String ke rightmost $N$ characters return karne wala function.
* **`RIGHT JOIN`**: Outer join jo right table ki saari rows aur left table ki matching rows return karta hai.
* **`ROLLBACK`**: TCL statement jo active transaction ke dauran kiye gaye saare uncommitted modifications ko undo/revert karta hai.
* **`ROUND()`**: Numeric value ko specified decimal places tak round karne wala function.
* **`ROW_NUMBER()`**: Window function jo partition ke andar rows ko strict sequential integers ($1, 2, 3, \dots$) assign karta hai.

---

### S
* **`SARGable`**: Search Argument Able. Query predicates jo B+ Tree index seeks utilize karne ke capable hote hain.
* **`SAVEPOINT`**: Transaction ke andar partial rollback enable karne wala marker.
* **`SELECT`**: Tables se records retrieve karne wala core DQL statement.
* **`SET`**:
  1. `UPDATE` statement mein columns ko nayi values assign karne wala clause.
  2. Static list se multiple string choices store karne wala DDL data type.
* **`SIGNAL`**: Stored routines ke andar custom runtime exceptions aur error messages raise karne wala statement.
* **`SMALLINT`**: 2-byte integer type jo $-32,768$ se $+32,767$ tak values store karta hai.
* **`SQRT()`**: Number ka square root return karne wala mathematical function.
* **`START TRANSACTION`**: Explicit atomic transaction block shuru karne wala statement.
* **`SUBSTRING()` / `SUBSTR()`**: Designated 1-based offset se start karke string ka ek portion extract karta hai.
* **`SUM()`**: Non-null values ka cumulative sum return karne wala aggregate function.

---

### T
* **`TEXT`**: Badi character strings store karne wala data type (standard `TEXT` ke liye 64 KB tak, `LONGTEXT` ke liye 4 GB tak).
* **`TIME`**: Time-of-day ya elapsed durations store karne wala 3-byte temporal data type (`'-838:59:59'` se `'838:59:59'`).
* **`TIMESTAMP`**: UTC mein convert karke store hone wala 4-byte temporal data type; Year 2038 boundary ke subject hai.
* **`TIMESTAMPDIFF()`**: Do dates ke beech specified units (years, months, days, etc.) mein elapsed difference calculate karne wala function.
* **`TINYINT`**: 1-byte integer type jo $-128$ se $+127$ tak (ya `UNSIGNED` par 0 se 255 tak) values store karta hai.
* **`TRIGGER`**: Program jo `INSERT`, `UPDATE`, ya `DELETE` event par automatically execute hota hai.
* **`TRIM()`**: Strings se leading aur trailing whitespace remove karne wala function.
* **`TRUNCATE TABLE`**: Table ke saare data pages ko deallocate karne aur auto-increment counters reset karne wala DDL statement.

---

### U
* **`UCASE()` / `UPPER()`**: Strings ko uppercase mein convert karta hai.
* **`UNDO LOG`**: Transaction rollback aur MVCC support karne ke liye pre-modification row versions maintain karne wala InnoDB storage area.
* **`UNION`**: Multiple queries ke results ko deduplication ke saath combine karne wala set operator.
* **`UNION ALL`**: Multiple queries ke results ko bina deduplication ke combine karne wala set operator.
* **`UNIQUE`**: Column ya column group mein saari non-null rows ke across distinct values enforce karne wala constraint.
* **`UNSIGNED`**: Numeric attribute jo negative numbers disallow karta hai aur positive storage range double kar deta hai.
* **`UPDATE`**: Table mein existing column values ko modify karne wala DML statement.
* **`USE`**: Active database schema context set karne wala statement.

---

### V
* **`VALUES`**: `INSERT` mein insert kiye jaane wale row data ko specify karne wala clause.
* **`VARCHAR()`**: 1- ya 2-byte length prefix ke saath 65,535 bytes tak store karne wala variable-length character string.
* **`VIEW`**: Stored SQL query dwara defined virtual table.

---

### W
* **`WHERE`**: Grouping ya aggregation se pehle rows filter karne wala clause.
* **`WINDOW`**: Multiple window functions mein reuse ke liye named window specifications define karne wala clause.
* **`WITH`**: Common Table Expressions (CTEs) define karne wala clause.
* **`WITH CHECK OPTION`**: Views par constraint jo un inserts ya updates ko prevent karta hai jo view ke `WHERE` filter ko violate karein.
* **`WITH ROLLUP`**: Multi-level subtotals aur grand totals generate karne ke liye `GROUP BY` modifier.

---

### X
* **`XOR`**: Logical operator jo `TRUE` return karta hai agar dono conditions mein se exactly ek `TRUE` ho.

---

### Y
* **`YEAR`**: 4-digit calendar years (`1901` se `2155`) store karne wala 1-byte temporal data type.
* **`YEAR()`**: Date se 4-digit year integer extract karne wala function.
