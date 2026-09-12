# Chapter 29 — Technical Interview Mastery: 150 Curated Questions & Answers

Is chapter mein **150 production-grade SQL aur MySQL interview questions** provide kiye gaye hain, jo teen professional competency tiers mein structured hain:

* **Tier 1: Beginner Questions (1–50)** — Relational Fundamentals, CRUD, Basic Filtering, aur Core Functions.
* **Tier 2: Intermediate Questions (51–100)** — Joins, Subqueries, GROUP BY/HAVING, Indexes, aur Normalization.
* **Tier 3: Advanced Questions (101–150)** — Window Functions, CTEs, Transactions, Locking, MVCC, aur Query Optimization.

---

## Tier 1: Beginner SQL Interview Questions (1–50)

### 1. Relational Database Management System (RDBMS) kya hota hai?
**Answer**: RDBMS ek aisa database system hai jo Edgar F. Codd ke relational model par based hota hai. Ye data ko mathematically defined tables (relations) mein organize karta hai jo rows (tuples) aur columns (attributes) se milkar banti hain. Data relationships shared keys ke through enforce hoti hain, aur database operations ACID properties ko adhere karte hain. Examples: MySQL, PostgreSQL, aur Oracle.

### 2. SQL aur NoSQL databases ke beech primary differences kya hain?
**Answer**: SQL databases relational aur table-based hote hain, strict predefined schemas enforce karte hain, vertically scale hote hain, aur ACID consistency ko prioritize karte hain. NoSQL databases non-relational hote hain (document, key-value, column-family, ya graph-based), dynamic ya schema-less hote hain, clusters par horizontally scale hote hain, aur eventual consistency (BASE model) prioritize karte hain.

### 3. SQL ki five sub-languages kaun-kaun si hain?
**Answer**:
1. **DDL (Data Definition Language)**: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`.
2. **DQL (Data Query Language)**: `SELECT`.
3. **DML (Data Manipulation Language)**: `INSERT`, `UPDATE`, `DELETE`.
4. **DCL (Data Control Language)**: `GRANT`, `REVOKE`.
5. **TCL (Transaction Control Language)**: `COMMIT`, `ROLLBACK`, `SAVEPOINT`.

### 4. `CHAR` aur `VARCHAR` ke beech kya difference hai?
**Answer**: `CHAR(M)` fixed-length data type hai, jo values ko length $M$ tak spaces se right-pad karta hai. `VARCHAR(M)` variable-length data type hai, jo sirf actual characters aur unke saath ek 1- ya 2-byte length prefix store karta hai.

### 5. SQL mein `NULL` kya represent karta hai, aur comparisons mein iski evaluation kaise hoti hai?
**Answer**: `NULL` missing, unknown, ya inapplicable data ko represent karta hai. Three-Valued Logic (3VL) ke andar, `NULL` ke saath kisi bhi cheez ko compare karne par (jaise `col = NULL` ya `NULL = NULL`) hamesha `UNKNOWN` result aata hai. Nullability check karne ke liye `IS NULL` ya `IS NOT NULL` ka use kiya jaata hai.

### 6. Primary Key kya hoti hai?
**Answer**: Primary Key ek aisa column (ya columns ka set) hota hai jo table ke har ek row ko uniquely identify karta hai. Primary key implicitly `UNIQUE` aur `NOT NULL` constraints enforce karti hai, aur MySQL InnoDB mein physically table ke clustered index ko organize karti hai.

### 7. Kya ek table mein multiple Primary Keys ho sakti hain?
**Answer**: Nahi. Ek table mein sirf **ek** Primary Key ho sakti hai. Lekin, wo primary key multiple columns se milkar ban sakti hai, jise **Composite Primary Key** kehte hain.

### 8. Primary Key aur Unique Key ke beech kya difference hai?
**Answer**: Ek table mein sirf ek hi Primary Key ho sakti hai, jo kabhi `NULL` allow nahi karti. Ek table mein multiple Unique Keys ho sakti hain, aur MySQL mein Unique Keys multiple `NULL` values allow karti hain (jab tak unpar explicitly `NOT NULL` na lagaya gaya ho).

### 9. Foreign Key kya hoti hai?
**Answer**: Child table ka ek aisa column jo parent table ki primary key ko reference karta hai, relational link establish karta hai aur referential integrity enforce karta hai.

### 10. `TRUNCATE` aur `DELETE` ke beech kya difference hai?
**Answer**: `DELETE` ek DML command hai jo rows ko one-by-one delete karti hai, har deletion ko transaction log mein record karti hai, row-level triggers fire karti hai, aur rollback ho sakti hai. `TRUNCATE` ek DDL command hai jo data pages ko directly deallocate karti hai, auto-increment counter reset karti hai, triggers bypass karti hai, aur bohot fast execute hoti hai.

### 11. `DROP TABLE` aur `TRUNCATE TABLE` ke beech kya difference hai?
**Answer**: `TRUNCATE TABLE` table schema, columns, aur constraints ko preserve rakhte hue table ke saare data rows ko purge kar deta hai. `DROP TABLE` table schema, constraints, indexes, aur physical disk files ko permanently destroy kar deta hai.

### 12. MySQL mein `AUTO_INCREMENT` attribute kaise kaam karta hai?
**Answer**: Jab column value omit ki jaati hai ya `NULL` pass ki jaati hai, toh ye automatically newly inserted rows ke liye unique, sequential integer identifier generate karta hai.

### 13. `DEFAULT` constraint ka purpose kya hai?
**Answer**: Agar koi `INSERT` statement kisi column ke liye explicitly value provide nahi karta, toh `DEFAULT` constraint ek automatic fallback value supply karta hai.

### 14. MySQL 8.0 mein `CHECK` constraint kya karta hai?
**Answer**: Ye inserted ya updated row values par boolean expression evaluate karta hai, aur agar expression `FALSE` evaluate hota hai toh transaction ko reject kar deta hai (e.g., `CHECK (salary > 0)`).

### 15. `COUNT(*)` aur `COUNT(column)` ke beech kya difference hai?
**Answer**: `COUNT(*)` result set ki saari physical rows ko count karta hai chahe unme nulls hon ya na hon. `COUNT(column)` sirf un rows ko count karta hai jahan specified column non-NULL value contain karta hai.

### 16. Logical precedence mein `AND` aur `OR` operators kaise differ karte hain?
**Answer**: `AND` operator ki precedence `OR` se higher hoti hai. Bina parentheses ke expression `A OR B AND C` mein, engine pehle `(B AND C)` evaluate karta hai.

### 17. `DISTINCT` keyword ka purpose kya hai?
**Answer**: Ye projected result set se duplicate rows ko remove karta hai, aur sirf unique value combinations return karta hai.

### 18. Boundary values ke saath `BETWEEN` operator kaise behave karta hai?
**Answer**: SQL mein, `BETWEEN val1 AND val2` dono boundary values ke liye strictly **inclusive** hota hai (equivalent to `col >= val1 AND col <= val2`).

### 19. `LIKE` operator kaun se wildcards support karta hai?
**Answer**: Percent sign (`%`) zero ya usse zyada arbitrary characters match karta hai; underscore (`_`) exactly ek single character match karta hai.

### 20. `NOW()` aur `CURDATE()` ke beech kya difference hai?
**Answer**: `NOW()` current date aur time dono return karta hai (`YYYY-MM-DD HH:MM:SS`). `CURDATE()` sirf current date return karta hai (`YYYY-MM-DD`).

### 21. `COALESCE()` function kya karta hai?
**Answer**: Ye arguments ki list ko left to right evaluate karta hai aur pehli non-NULL value return karta hai.

### 22. `COALESCE()` aur `IFNULL()` ke beech kya difference hai?
**Answer**: `IFNULL(a, b)` proprietary MySQL function hai jo sirf do arguments accept karta hai. `COALESCE(...)` standard ANSI SQL function hai jo arbitrary number of arguments accept karta hai.

### 23. `CONCAT_WS()` aur `CONCAT()` mein kya difference hai?
**Answer**: `CONCAT()` agar koi bhi argument `NULL` ho toh `NULL` return karta hai. `CONCAT_WS()` (Concatenate With Separator) pehle argument ko delimiter banata hai aur `NULL` values ko cleanly skip karta hai.

### 24. MySQL mein `LENGTH()` aur `CHAR_LENGTH()` ke beech kya difference hai?
**Answer**: `LENGTH()` string ka size **bytes** mein measure karta hai, jabki `CHAR_LENGTH()` **characters** ki sankhya measure karta hai (jo multi-byte UTF-8 encodings ke liye bohot matter karta hai).

### 25. MySQL mein `LIMIT` clause kya karta hai?
**Answer**: Ye query dwara return ki jaane wali rows ki maximum sankhya restrict karta hai, jo commonly pagination ke liye use hota hai (e.g., `LIMIT 10 OFFSET 20`).

### 26. Results ko descending order mein kaise sort kiya jaata hai?
**Answer**: `ORDER BY` clause mein column ke aage `DESC` keyword append karke (e.g., `ORDER BY salary DESC`).

### 27. Alias kya hota hai, aur kaun sa keyword ise define karta hai?
**Answer**: Alias ek temporary label hota hai jo table ya column ko readability improve karne ke liye assign kiya jaata hai, jise `AS` keyword se define karte hain (e.g., `SELECT salary AS base_pay`).

### 28. `USE` statement ka purpose kya hai?
**Answer**: Ye current client connection ke liye active database schema context establish karta hai.

### 29. Existing table mein column kaise add karte hain?
**Answer**: `ALTER TABLE table_name ADD COLUMN column_name data_type;` syntax ka use karke.

### 30. Column ko rename kiye bina uska data type kaise modify karte hain?
**Answer**: `ALTER TABLE table_name MODIFY COLUMN column_name new_data_type;` syntax ka use karke.

### 31. `ALTER TABLE ... MODIFY` aur `ALTER TABLE ... CHANGE` ke beech kya difference hai?
**Answer**: `MODIFY` column ke attributes ya data types ko in-place change karta hai. `CHANGE` purana name aur naya name dono maangta hai, jisse column rename aur type change ek saath possible hota hai.

### 32. Bina `WHERE` clause ke `UPDATE` execute karne ka kya consequence hota hai?
**Answer**: Table ki har ek single row specified values ke saath update ho jaati hai.

### 33. MySQL ka `sql_safe_updates` mode kya hota hai?
**Answer**: Ek safety setting jo un `UPDATE` ya `DELETE` statements ke execution ko prevent karti hai jinme key column reference karne wala `WHERE` clause ya explicit `LIMIT` na ho.

### 34. `INSERT INTO ... SELECT` ka purpose kya hai?
**Answer**: Ek single statement mein ek table se data directly doosri existing table mein copy karne ke liye use hota hai.

### 35. Duplicate keys aane par `INSERT IGNORE` kaise behave karta hai?
**Answer**: Ye primary key ya unique constraints violate karne wali rows ko bina kisi error ya batch abort kiye silently skip kar deta hai.

### 36. UPSERT kya hota hai, aur MySQL mein ise kaise implement karte hain?
**Answer**: Ek aisi operation jo naya row insert karti hai agar key match na ho, ya agar duplicate key already exist karti ho toh use update karti hai; MySQL mein ise `INSERT ... ON DUPLICATE KEY UPDATE` ke through implement karte hain.

### 37. `UNION` aur `UNION ALL` ke beech kya difference hai?
**Answer**: `UNION` query results ke beech se duplicate rows eliminate karta hai (jisme sorting overhead hota hai); `UNION ALL` duplicates samet saari rows preserve karta hai.

### 38. `UNION` ke through combine kiye jaane wale columns par kaun se rules apply hote hain?
**Answer**: Saari participating queries ko exactly same number of columns project karne hote hain, aur corresponding positions par compatible data types hone chahiye.

### 39. Scalar Function kya hota hai?
**Answer**: Ek aisa function jo individual row inputs par operate karta hai aur per row ek single scalar value return karta hai (e.g., `ROUND()`, `UPPER()`).

### 40. Aggregate Function kya hota hai?
**Answer**: Ek aisa function jo multiple rows par operate karta hai aur ek single consolidated value return karta hai (e.g., `SUM()`, `AVG()`).

### 41. Aggregate functions `NULL` values ko kaise treat karte hain?
**Answer**: Saare aggregate functions (`SUM`, `AVG`, `MIN`, `MAX`, `COUNT(col)`) `NULL` values ko ignore karte hain. Sirf ek exception `COUNT(*)` hai, jo physical rows count karta hai.

### 42. `GROUP BY` clause ka purpose kya hai?
**Answer**: Matching values wali rows ko aggregate metrics calculate karne ke liye summary buckets mein collapse karna.

### 43. `WHERE` aur `HAVING` ke beech kya difference hai?
**Answer**: `WHERE` aggregation se *pehle* raw rows ko filter karta hai; `HAVING` aggregation ke *baad* summary groups ko filter karta hai.

### 44. Kya `SELECT` mein define kiye gaye column aliases ko `WHERE` clause mein use kiya ja sakta hai?
**Answer**: Nahi, kyunki query execution plan mein engine `WHERE` ko `SELECT` se pehle process karta hai.

### 45. `ORDER BY` ka purpose kya hai?
**Answer**: Final result set ko ascending (`ASC`) ya descending (`DESC`) sequence mein deterministically sort karna.

### 46. `DATE`, `DATETIME`, aur `TIMESTAMP` ke beech kya difference hai?
**Answer**: `DATE` sirf calendar dates store karta hai (3 bytes). `DATETIME` bina timezone conversion ke statically date aur time store karta hai (5 bytes). `TIMESTAMP` date aur time ko UTC mein convert karke store karta hai (4 bytes, year 2038 tak range).

### 47. `DATEDIFF(date1, date2)` kya return karta hai?
**Answer**: Days mein difference calculate karke return karta hai (`date1 - date2`).

### 48. `EXISTS` operator ka purpose kya hai?
**Answer**: Subquery mein rows ki existence test karta hai, aur pehla matching row milte hi turant `TRUE` return kar deta hai (short-circuit evaluation).

### 49. SQL mein code comment kaise karte hain?
**Answer**: Single-line comment ke liye `-- ` (trailing space ke saath) ya `#` use hota hai; multi-line comments ke liye `/* ... */` use hota hai.

### 50. MySQL server par existing databases kaise dekhte hain?
**Answer**: `SHOW DATABASES;` command ka use karke.

---

## Tier 2: Intermediate SQL Interview Questions (51–100)

### 51. `INNER JOIN` aur `LEFT JOIN` ke operational difference ko explain karein.
**Answer**: `INNER JOIN` sirf wahi rows return karta hai jinke paas dono tables mein matching values hon. `LEFT JOIN` left table ki saari rows return karta hai, plus right table se matched rows; agar right table mein koi match na mile toh right-table columns ke liye `NULL` populate karta hai.

### 52. `RIGHT JOIN` kya hota hai, aur practice mein ye rarely kyun use hota hai?
**Answer**: `RIGHT JOIN` right table ki saari rows aur left table ki matching rows return karta hai. Ye rarely use hota hai kyunki kisi bhi `RIGHT JOIN` ko table order switch karke intuitively `LEFT JOIN` ke roop mein rewrite kiya ja sakta hai.

### 53. Anti-Join kya hota hai, aur aap ise kaise likhte hain?
**Answer**: Anti-Join ek aisi query hai jo ek table ki un rows ko find karti hai jinka doosri table mein koi match nahi hai; ise `LEFT JOIN ... WHERE right_table.key IS NULL` ya `WHERE NOT EXISTS (...)` ke through likha jaata hai.

### 54. `CROSS JOIN` kya hota hai?
**Answer**: Ek aisa join jo do tables ka Cartesian Product produce karta hai, yaani Table A ke har row ko Table B ke har row ke saath pair karta hai ($N \times M$ rows).

### 55. Self JOIN kya hota hai, aur ye kab required hota hai?
**Answer**: Ek aisa join jahan table khud apne aap se do distinct aliases ke through join hoti hai; ye hierarchical ya recursive relationships ke liye zaroori hota hai (jaise employees ko unke managers se match karna).

### 56. MySQL mein `FULL OUTER JOIN` kaise emulate karte hain?
**Answer**: Ek `LEFT JOIN` aur ek `RIGHT JOIN` ko `UNION` set operator ke through combine karke.

### 57. Correlated aur Non-Correlated subquery ke beech kya difference hai?
**Answer**: Non-correlated subquery independent hoti hai aur sirf ek baar execute hoti hai. Correlated subquery outer query ke columns ko reference karti hai aur conceptually outer query dwara process kiye jaane wale har row ke liye evaluate hoti hai.

### 58. Subqueries ke saath `NOT IN` ke muqable `NOT EXISTS` zyada safe kyun hai?
**Answer**: Agar subquery ek bhi `NULL` return kare, toh `NOT IN` sabhi rows ke liye `UNKNOWN` evaluate ho jaata hai aur empty result set return karta hai. `NOT EXISTS` row existence check karta hai aur `NULL` values se negatively affect nahi hota.

### 59. Common Table Expression (CTE) kya hoti hai?
**Answer**: `WITH` clause ka use karke query ke start mein define kiya gaya ek temporary named result set, jo readability improve karta hai aur query mein multiple times reference kiya ja sakta hai.

### 60. Recursive CTE kaise kaam karti hai?
**Answer**: Ye ek **Anchor Member** (base query), ek `UNION ALL`, aur ek **Recursive Member** se consist karti hai jo CTE ko tab tak self-reference karta hai jab tak termination condition meet na ho jaye.

### 61. `ONLY_FULL_GROUP_BY` SQL mode kya hai?
**Answer**: MySQL ka ek standard SQL enforcement mode jo un queries ko reject karta hai jinme `SELECT` list ke columns na toh `GROUP BY` clause mein hote hain aur na hi aggregate functions mein wrapped hote hain.

### 62. `GROUP BY` query mein `WITH ROLLUP` kya karta hai?
**Answer**: Ye grouping dimensions across right-to-left hierarchical subtotals aur grand total rows generate karta hai.

### 63. Genuine NULL aur ROLLUP summary NULL ke beech kaise distinguish karte hain?
**Answer**: `GROUPING(column)` function ka use karke, jo rollup summary NULL ke liye `1` aur genuine data value ke liye `0` return karta hai.

### 64. Database Normalization kya hai?
**Answer**: Relational tables ko systematically structure karne ka process jisse data redundancy minimize ho aur insertion, update, aur deletion anomalies eliminate ho sakein.

### 65. First Normal Form (1NF) ko define karein.
**Answer**: Ek aisi table jahan saari column values atomic hoti hain (koi arrays ya comma-separated lists nahi), koi repeating groups nahi hote, aur ek primary key har row ko uniquely identify karti hai.

### 66. Second Normal Form (2NF) ko define karein.
**Answer**: Ek aisi table jo 1NF mein ho aur jisme koi **partial dependency** na ho — yaani har non-key attribute poori composite primary key par depend kare.

### 67. Third Normal Form (3NF) ko define karein.
**Answer**: Ek aisi table jo 2NF mein ho aur jisme koi **transitive dependency** na ho — yaani non-key attributes sirf primary key par depend karein, kisi doosre non-key attribute par nahi.

### 68. Boyce-Codd Normal Form (BCNF) kya hai?
**Answer**: 3NF ka ek stricter version jahan har functional dependency $X \rightarrow Y$ ke liye, determinant $X$ hamesha ek Super Key hona chahiye.

### 69. Denormalization kya hai, aur ye kab appropriate hoti hai?
**Answer**: Read performance ko improve karne aur read-heavy analytics ya data warehouses mein join overhead kam karne ke liye intentional tareeqe se normalized schema mein redundancy add karna.

### 70. View kya hota hai, aur kya ye disk par data store karta hai?
**Answer**: Saved SQL query dwara defined ek virtual table. MySQL mein standard views disk par physical data store nahi karte; ye underlying base tables ke against dynamically execute hote hain.

### 71. MySQL mein koi View updatable kab banta hai?
**Answer**: View tabhi updatable hota hai jab view rows aur base table rows ke beech direct 1:1 relationship ho, aur view mein `GROUP BY`, `DISTINCT`, aggregates, ya `UNION` na ho.

### 72. View par `WITH CHECK OPTION` ka purpose kya hai?
**Answer**: View ke through un inserts ya updates ko block karna jo aisi rows produce karein jo view ke apne `WHERE` clause ko violate karti hon.

### 73. Index kya hota hai, aur ye queries ko kaise accelerate karta hai?
**Answer**: Ek B+ Tree data structure jo column values ko order karta hai taaki fast $O(\log N)$ binary searches enable ho sakein, jisse full table scan avoid hota hai.

### 74. InnoDB mein Clustered Index kya hota hai?
**Answer**: Primary B+ Tree index jo apne leaf nodes mein actual row data physically store karta hai; ye table ki Primary Key se define hota hai.

### 75. InnoDB mein Secondary Index kya hota hai?
**Answer**: Ek non-clustered index jiske leaf nodes indexed key value aur corresponding row ki Primary Key value store karte hain.

### 76. Bookmark Lookup kya hota hai?
**Answer**: Jab query secondary index use karke row search karti hai, toh use pehle Primary Key milti hai, aur fir row ke baaki columns retrieve karne ke liye use Clustered Index mein second lookup karna padta hai.

### 77. Covering Index kya hota hai?
**Answer**: Ek aisa index jo query dwara requested saare columns contain karta hai, jisse MySQL bina kisi bookmark lookup ke seedhe index tree se hi query satisfy kar leta hai (`Extra: Using index`).

### 78. Composite indexes ke liye Leftmost Prefix Rule kya hota hai?
**Answer**: Composite index `(A, B, C)` sirf un queries dwara use kiya ja sakta hai jo `A`, `(A, B)`, ya `(A, B, C)` par filter karti hain. Ye sirf `B` ya `C` par filter karne wali queries dwara use nahi ho sakta.

### 79. Index Cardinality kya hoti hai?
**Answer**: Index mein unique values ki count. High-cardinality columns (jaise email) index karne par maximum benefit dete hain; low-cardinality columns (jaise boolean flags) generally index ke liye effective nahi hote.

### 80. Indexing ke performance costs kya hain?
**Answer**: Indexes disk space consume karte hain, Buffer Pool mein memory occupy karte hain, aur `INSERT`, `UPDATE`, `DELETE` operations ko slow karte hain kyunki har index tree ko update karna padta hai.

### 81. Transaction kya hota hai?
**Answer**: Ek logical unit of work jisme ek ya ek se zyada SQL statements shamil hoti hain aur jo atomic, all-or-nothing operation ke roop mein execute hota hai.

### 82. ACID mein Atomicity ka kya matlab hai?
**Answer**: Transaction ke saare statements ek saath commit aur succeed hote hain, ya kisi failure par Undo Log ke through saare changes rollback ho jaate hain.

### 83. ACID mein Consistency ka kya matlab hai?
**Answer**: Transaction database ko sirf ek valid state se doosre valid state mein transition kar sakta hai jo schema ke saare rules aur constraints ko satisfy karti ho.

### 84. ACID mein Isolation ka kya matlab hai?
**Answer**: Concurrent transactions ek doosre ke intermediate, uncommitted states ko observe kiye bina independently execute hote hain.

### 85. ACID mein Durability ka kya matlab hai?
**Answer**: Commit ho chuke transactions Redo Log ke through permanently disk par write hote hain aur system crash ya power failure ke baad bhi survive karte hain.

### 86. Dirty Read kya hota hai?
**Answer**: Jab Transaction A un uncommitted modifications ko read kar leta hai jo Transaction B ne kiye the aur jo baad mein rollback ho jaate hain.

### 87. Non-Repeatable Read kya hota hai?
**Answer**: Jab Transaction A ek row read karta hai, Transaction B us row ko update karke commit kar deta hai, aur Transaction A dobara read karne par different values pata hai.

### 88. Phantom Read kya hota hai?
**Answer**: Jab Transaction A range query run karta hai, Transaction B us range mein naya row insert karke commit karta hai, aur Transaction A dobara query run karne par naya phantom row pata hai.

### 89. MySQL mein default isolation level kya hota hai?
**Answer**: `REPEATABLE READ`.

### 90. `REPEATABLE READ` mein MySQL InnoDB Phantom Reads ko kaise prevent karta hai?
**Answer**: Regular queries ke liye consistent non-locking snapshot reads (MVCC) ka use karke, aur locking reads ke liye Next-Key Locking (record locks + gap locks) ka use karke.

### 91. Savepoint kya hota hai?
**Answer**: Transaction ke andar ek designated marker jo poore transaction ko abort kiye bina partial rollback (`ROLLBACK TO SAVEPOINT`) allow karta hai.

### 92. MySQL mein DDL statements ko rollback kyun nahi kiya ja sakta?
**Answer**: DDL statements execution se pehle aur baad mein **implicit commit** trigger karte hain, jisse prior DML changes permanently save ho jaate hain.

### 93. Stored Procedure kya hota hai?
**Answer**: Pre-compiled SQL statements aur control-flow logic ka set jo database mein store hota hai aur `CALL` statement ke through execute hota hai.

### 94. Stored Procedure aur Stored Function ke beech kya difference hai?
**Answer**: Procedure `CALL` ke through invoke hota hai, multiple result sets return kar sakta hai, aur transactions manage kar sakta hai. Function SQL expressions ke andar inline call hota hai, strictly ek scalar value return karta hai, aur transactions manage nahi kar sakta.

### 95. Function mein `DETERMINISTIC` keyword kya signify karta hai?
**Answer**: Ye guarantee karta hai ki given input arguments ke liye function hamesha exact same output return karega.

### 96. Trigger kya hota hai?
**Answer**: Ek aisa database program jo kisi specific table par `INSERT`, `UPDATE`, ya `DELETE` event ke response mein automatically execute hota hai.

### 97. Triggers mein `NEW` aur `OLD` ke beech kya difference hai?
**Answer**: `NEW` incoming row values represent karta hai (`INSERT` aur `UPDATE` mein available). `OLD` pre-modification row values represent karta hai (`UPDATE` aur `DELETE` mein available).

### 98. Trigger apni triggering table ko directly modify kyun nahi kar sakta?
**Answer**: Infinite recursive execution loops ko prevent karne ke liye (MySQL Error 1442).

### 99. Trigger ke andar custom error kaise raise karte hain?
**Answer**: `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error description';` ka use karke.

### 100. Surrogate Key kya hoti hai?
**Answer**: Ek artificial, system-generated identifier (e.g., `INT AUTO_INCREMENT`) jiska koi business meaning nahi hota; primary key stability ke liye ise natural keys ke upar prefer kiya jaata hai.

---

## Tier 3: Advanced SQL Interview Questions (101–150)

### 101. Window Function kya hota hai, aur ye `GROUP BY` se kaise differ karta hai?
**Answer**: Window function rows ko collapse kiye bina current row se related rows ke set par calculations perform karta hai. Har individual row apni identity preserve rakhti hai jabki calculated window values display karti hai.

### 102. `ROW_NUMBER()`, `RANK()`, aur `DENSE_RANK()` ke beech kya difference hai?
**Answer**: `ROW_NUMBER()` bina ties ke strictly sequential numbers assign karta hai ($1, 2, 3$). `RANK()` ties ko identical ranks deta hai aur agle numbers ko skip karta hai ($1, 2, 2, 4$). `DENSE_RANK()` ties ko identical ranks deta hai lekin numbers skip nahi karta ($1, 2, 2, 3$).

### 103. `LAG()` aur `LEAD()` functions kiske liye use hote hain?
**Answer**: `LAG()` bina self-join kiye specified offset par preceding row se value read karta hai; `LEAD()` subsequent row se value read karta hai.

### 104. SQL mein Window Frame kya hota hai?
**Answer**: Partition ke andar rows ka ek subset jo evaluation ki boundary define karta hai, jise `ROWS` (physical row count) ya `RANGE` (logical value range) `BETWEEN ... AND ...` se specify karte hain.

### 105. Window functions ko `WHERE` clause mein kyun use nahi kiya ja sakta?
**Answer**: Kyunki query processing pipeline mein `WHERE` Step 2 par evaluate hota hai, jabki window functions Step 5 par `SELECT` projection phase mein calculate hote hain.

### 106. `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` aur `RANGE BETWEEN ...` mein kya difference hai?
**Answer**: `ROWS` physical row position ke basis par tied rows ko individually treat karta hai. `RANGE` identical sort values wali sabhi tied rows ko ek single collective set ke roop mein treat karta hai.

### 107. `NTILE(n)` window function kya karta hai?
**Answer**: Partitioned result set ko $n$ roughly equal buckets mein divide karta hai aur 1 se $n$ tak bucket numbers assign karta hai.

### 108. MySQL 8.0 mein JSON document ko kaise query karte hain?
**Answer**: Path extraction operators ke through: `column->'$.path'` (quoted JSON return karta hai) ya `column->>'$.path'` (unquoted text return karta hai).

### 109. MySQL mein JSON attribute ko kaise index kiya ja sakta hai?
**Answer**: Ek **Virtual Generated Column** create karke jo JSON path extract kare, aur fir us generated column par standard B+ Tree index build karke.

### 110. SARGability kya hoti hai, aur ye query performance ke liye essential kyun hai?
**Answer**: SARGable (*Search Argument Able*) un query predicates ko describe karta hai jo query optimizer ko full table scan ke bajaye fast index seek use karne allow karte hain.

### 111. `WHERE YEAR(date_col) = 2023` query performance ko kyun degrade karta hai?
**Answer**: Indexed column ko function mein wrap karne se engine B+ Tree index navigate nahi kar paata, aur har row ke liye function evaluate karne ke chakkar mein full table scan force hota hai.

### 112. Implicit type conversion full table scan kaise cause karta hai?
**Answer**: Agar `VARCHAR` column ko integer se compare kiya jaye (`WHERE string_col = 123`), toh MySQL har row ke liye column ko number mein convert karta hai, jisse index lookup disable ho jaata hai.

### 113. `EXPLAIN` aur `EXPLAIN ANALYZE` ke beech kya difference hai?
**Answer**: `EXPLAIN` static optimizer plan aur cost estimates show karta hai. `EXPLAIN ANALYZE` query ko actually execute karta hai, real execution time aur row counts measure karta hai, aur iterator tree display karta hai.

### 114. `EXPLAIN` report mein access type `ALL` kya indicate karta hai?
**Answer**: Full table scan; engine table ke har single disk page ya buffer page ko read karta hai.

### 115. `EXPLAIN` report mein access type `ref` kya indicate karta hai?
**Answer**: Ek non-unique index seek jo indexed value ke liye multiple matching rows retrieve karta hai.

### 116. `EXPLAIN` report mein `Using filesort` ka kya matlab hota hai?
**Answer**: MySQL `ORDER BY` clause ko index se satisfy nahi kar paya aur usne memory (`sort_buffer_size`) ya disk par ek explicit sorting pass perform kiya.

### 117. Hash Join kya hota hai, aur MySQL 8.0 ise kab use karta hai?
**Answer**: Ek aisi algorithm jo smaller table ka in-memory hash table build karti hai aur larger table se rows ko uske against stream karti hai; ye un joins ke liye use hoti hai jinme indexes absent hote hain.

### 118. InnoDB mein Multi-Version Concurrency Control (MVCC) kya hota hai?
**Answer**: Ek aisi concurrency technique jahan readers rows ko lock nahi karte. Jab row modify hoti hai, toh InnoDB puraana version Undo Log mein write karta hai. Concurrent readers transaction IDs ke basis par ek consistent historical snapshot view karte hain.

### 119. InnoDB mein Next-Key Lock kya hota hai?
**Answer**: Specific row par lagne wale record lock aur us record se pehle aane wale open space par lagne wale **Gap Lock** ka combination, jo `REPEATABLE READ` mein phantom insertions ko prevent karta hai.

### 120. MySQL mein Deadlock kya hota hai?
**Answer**: Ek circular dependency jahan Transaction 1 Lock A hold karke Lock B ka wait karta hai, jabki Transaction 2 Lock B hold karke Lock A ka wait karta hai.

### 121. MySQL deadlocks ko kaise detect aur resolve karta hai?
**Answer**: InnoDB ka Deadlock Detector circular dependencies detect karta hai, sabse kam rollback cost wale transaction ko select karke Error 1213 ke saath abort aur rollback kar deta hai, jisse doosra transaction proceed kar sake.

### 122. `SELECT ... FOR UPDATE` aur `SELECT ... FOR SHARE` ke beech kya difference hai?
**Answer**: `FOR UPDATE` Exclusive Lock (X-lock) acquire karta hai, jo doosre transactions ko rows read (`FOR UPDATE`) ya modify karne se block karta hai. `FOR SHARE` Shared Lock (S-lock) acquire karta hai, jo doosron ko read karne allow karta hai lekin modifications block karta hai.

### 123. `LIMIT offset, count` ke saath Deep Paging problem kya hoti hai?
**Answer**: `LIMIT 1000000, 20` jaisi queries ke liye engine ko 1,000,020 rows read aur process karni padti hain, jisme se shuru ki 1,000,000 discard karke sirf 20 deliver hoti hain, jisse heavy I/O aur CPU waste hota hai.

### 124. Keyset Pagination (Cursor Pagination) Deep Paging ko kaise solve karta hai?
**Answer**: `OFFSET` use karne ke bajaye, ye last seen row ke indexed unique column par filter karta hai (`WHERE id < last_id ORDER BY id DESC LIMIT 20`), jo instant index seek ke through execute hota hai.

### 125. InnoDB Buffer Pool kya hota hai, aur iska size kaise decide karna chahiye?
**Answer**: Main in-memory cache jahan InnoDB data aur index pages cache karta hai. Dedicated database server par ise **total physical RAM ka 70%–80%** allocate karna chahiye.

### 126. Write-Ahead Log (WAL) protocol kya hota hai?
**Answer**: Ek reliability rule jiske mutabiq memory mein data pages tablespace disk files par write hone se pehle modifications ko disk par persistent append-only log (Redo Log) mein write hona lazmi hai.

### 127. InnoDB mein Redo Log aur Undo Log ke beech kya difference hai?
**Answer**: **Redo Log** Durability guarantee karta hai (crash recovery ke dauran committed changes replay karta hai). **Undo Log** Atomicity guarantee karta hai (rollback ke dauran uncommitted changes revert karta hai) aur MVCC snapshots support karta hai.

### 128. SQL Injection (SQLi) kya hota hai?
**Answer**: Ek security vulnerability jahan untrusted user input ko directly SQL string mein concatenate kiya jaata hai, jisse attacker query syntax tree manipulate karke unauthorized commands execute kar sakta hai.

### 129. SQL Injection ke against Prepared Statements hi ekmatra true defense kyun hain?
**Answer**: Prepared statements user input lene se pehle query template ko fixed syntax tree mein compile kar dete hain. User parameters literal data values ke roop mein bind hote hain aur query structure ko alter nahi kar sakte.

### 130. MySQL 8.0 mein Role-Based Access Control (RBAC) kya hota hai?
**Answer**: Ek security model jahan permissions named Roles ko grant kiye jaate hain, aur fir wo roles user accounts ko assign kiye jaate hain, jisse permission management streamline ho jaati hai.

### 131. `mysqldump --single-transaction` non-blocking backups kaise achieve karta hai?
**Answer**: Ye transaction isolation level ko `REPEATABLE READ` par set karta hai aur explicit transaction shuru karke InnoDB tables ka consistent MVCC snapshot read karta hai bina unhe lock kiye.

### 132. Execution Plan kya hota hai?
**Answer**: Cost-Based Optimizer dwara kisi SQL statement ko execute karne ke liye choose kiye gaye physical operations ka set (index seeks, scans, joins, filters, sorts).

### 133. Views mein `ALGORITHM=MERGE` aur `ALGORITHM=TEMPTABLE` ke beech kya difference hai?
**Answer**: `MERGE` view ki query ko outer query ke saath combine karke single execution plan banata hai. `TEMPTABLE` outer query run karne se pehle view results ko ek internal temporary table mein materialize karta hai.

### 134. Clustered Index Page Split kya hota hai?
**Answer**: Jab kisi full index leaf page mein naya row insert hota hai, toh InnoDB ko ek naya page allocate karke aadhe rows naye page par move karne padte hain. Random primary keys (jaise UUID v4) frequent page splits aur disk fragmentation cause karti hain.

### 135. InnoDB Primary Keys ke liye random UUIDs ke muqable auto-increment integers kyun prefer kiye jaate hain?
**Answer**: Monotonically increasing integers rows ko clustered index B+ Tree ke end mein sequentially append karte hain, jisse page splits avoid hote hain, fragmentation minimize hoti hai, aur secondary indexes mein memory footprint kafi kam rehta hai.

### 136. Relational Division kya hoti hai?
**Answer**: Ek aisi relational operation jo Table A ki un rows ko find karti hai jo Table B ki **saari** rows se associated hon (e.g., un customers ko find karna jinhone kisi category ka *har ek* product khareeda ho).

### 137. SQL mein Relational Division kaise implement karte hain?
**Answer**: `GROUP BY` aur `HAVING COUNT(DISTINCT item) = (SELECT COUNT(*) FROM target_items)` pattern ka use karke.

### 138. Data Warehousing mein Star Schema kya hota hai?
**Answer**: Ek denormalized multidimensional schema jisme ek central **Fact Table** (numeric metrics wali) hoti hai aur uske charo taraf denormalized **Dimension Tables** (descriptive attributes wali) hoti hain.

### 139. Snowflake Schema kya hota hai?
**Answer**: Star Schema ka ek variation jahan dimension tables multiple related tables mein further normalize ki jaati hain.

### 140. MySQL mein `information_schema` ka purpose kya hai?
**Answer**: Ek read-only metadata database jo database tables, columns, indexes, constraints, aur privileges ki details provide karta hai.

### 141. MySQL mein unused indexes kaise detect kiye ja sakte hain?
**Answer**: `sys.schema_unused_indexes` view ko query karke.

### 142. Optimistic aur Pessimistic concurrency control ke beech kya difference hai?
**Answer**: **Pessimistic locking** rows ko explicitly lock karta hai (`FOR UPDATE`) ye assume karke ki conflicts honge. **Optimistic locking** read par rows lock nahi karta; balki update karte waqt version column check karta hai, aur agar interim mein kisi doosre transaction ne row modify kar di ho toh fail ho jaata hai.

### 143. Composite Index kya hota hai, aur columns ko kis order mein arrange karna chahiye?
**Answer**: Do ya do se zyada columns par bana index. Columns ko generally highest selectivity (sabse zyada distinct values) se lowest selectivity ke order mein arrange karna chahiye, matching `WHERE` equality filters first.

### 144. MySQL mein `GROUP_CONCAT` large strings ko kaise handle karta hai?
**Answer**: Agar output `@@group_concat_max_len` (default: 1024 bytes) se exceed karta hai toh truncate ho jaata hai. Badi output ke liye session variable increase karna padta hai: `SET SESSION group_concat_max_len = 1000000;`.

### 145. Subqueries ke liye `EXISTS` aur `IN` ke beech kya difference hai?
**Answer**: `EXISTS` match milte hi short-circuit ho jaata hai aur `NULL` values ko safely handle karta hai. `IN` subquery results ko temporary set mein materialize kar sakta hai aur `NOT IN` mein `NULL` hone par empty result deta hai.

### 146. MySQL 8.0 mein `SELECT ... FOR UPDATE SKIP LOCKED` kya karta hai?
**Answer**: Ye un matching rows ko lock karta hai jo currently unlocked hain aur doosre transactions dwara already locked rows ko silently skip kar deta hai; ye high-throughput job queues implement karne ke liye ideal hai.

### 147. MySQL 8.0 mein Index Skip Scan kya hota hai?
**Answer**: Ek aisi optimization jo MySQL ko composite index `(A, B)` use karne allow karti hai bhale hi query leading column `A` par filter na kare, by scanning each distinct value of `A` aur fir `B` par index seek perform karke.

### 148. Table Lock aur Row Lock ke beech kya difference hai?
**Answer**: Table Lock poori table ko lock kar deta hai, jisse baaki sabhi write access block ho jaate hain. Row Lock (jo InnoDB use karta hai) sirf specific affected row ko lock karta hai, jisse concurrent transactions usi table ki doosri rows ko simultaneously read aur write kar sakte hain.

### 149. MySQL 8.0 mein Lateral Derived Table (LATERAL Join) kya hota hai?
**Answer**: `FROM` clause mein ek aisi derived table jo usi `FROM` clause ki preceding tables ke columns ko reference kar sakti hai, similar to a correlated subquery in the `FROM` clause.

### 150. Zero-downtime database migrations kaise design ki jaati hain?
**Answer**: **Expand-Contract (Parallel Run)** pattern adopt karke:
1. *Expand*: Purane structure ke parallel naya column ya table add karein.
2. *Dual-Write*: Application code update karein taaki wo purane aur naye dono structures par simultaneously write kare.
3. *Backfill*: Background batches mein historical data migrate karein.
4. *Switch*: Application reads ko naye structure par point karein.
5. *Contract*: Purane deprecated structure ko safe tareeqe se drop karein.
