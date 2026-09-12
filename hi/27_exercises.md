# Chapter 27 — Comprehensive Practice System: 300 Progressive Problems

Is practice system ke saare 300 exercises master **`sql_mastery`** database schema ke against execute karne ke liye design kiye gaye hain.

In questions ke saath practice karne ke liye, ensure karein ki aapne [`sql_mastery_schema.sql`](file:///c:/antigravity/master_sql_guide/sql_mastery_schema.sql) script run karke apna local database initialize kar liya hai.

> [!NOTE]
> Self-testing ko facilitate karne ke liye is chapter mein solutions aur query explanations intentionally omit kiye gaye hain. Verified solutions aur step-by-step breakdowns ke liye, [Chapter 28 — The Master Answer Key](file:///c:/antigravity/master_sql_guide/hi/28_answer_key.md) refer karein.

---

## Section 1: Database & Table Management (DDL, Types & Constraints)

### Beginner Questions (1–10)
1. Active `sql_mastery` database ke andar saari tables display karne ke liye ek SQL statement likhein.
2. `departments` table ki schema definition, datatypes, aur nullability inspect karne ke liye ek statement likhein.
3. Ek single integer column `id` ke saath `test_logs` naam ki ek sandbox table create karne ke liye ek command likhein.
4. `test_logs` table ko sirf tabhi drop karne ke liye ek statement likhein agar wo already exist karti ho (`IF EXISTS`).
5. `code VARCHAR(20)` aur `discount_pct DECIMAL(4,2)` (jiska default `0.05` ho) ke saath `coupons` table create karne ke liye query likhein.
6. `coupons` table mein `expiry_date DATE NOT NULL` column add karne wala ek `ALTER TABLE` statement likhein.
7. `coupons` table mein `code` column ko `VARCHAR(30) NOT NULL` mein modify karne wala ek `ALTER TABLE` statement likhein.
8. `coupons` table se `expiry_date` column ko drop karne wala ek `ALTER TABLE` statement likhein.
9. `coupons` table ka naam rename karke `promotional_codes` karne ke liye ek statement likhein.
10. `promotional_codes` table ko cleanly drop karein.

### Intermediate Questions (11–20)
11. Auto-increment primary key `team_id`, ek unique `team_name VARCHAR(50)`, aur `budget >= 1000.00` ensure karne wala check constraint ke saath `project_teams` table create karne ka statement likhein.
12. `project_teams` mein `fk_team_lead` naam ka foreign key add karne wala `ALTER TABLE` statement likhein jo `team_lead_id` ko `employees(employee_id)` se link kare (`ON DELETE SET NULL` ke saath).
13. Bina kisi row ko copy kiye `products` table ka exact structural clone `products_backup` create karne ke liye ek command likhein.
14. `CREATE TABLE ... AS SELECT` ka use karke `employees` se un saari rows aur columns ko include karte hue `high_earners` table banayein jahan `salary > 120000.00` ho.
15. `departments` table mein `department_name` ke turant baad positioned `priority_level ENUM('Low', 'Medium', 'High') DEFAULT 'Medium'` column add karne wala `ALTER TABLE` statement likhein.
16. Schema restore karne ke liye `departments` se `priority_level` column ko remove karein.
17. `high_earners` table ko truncate karne ke liye ek statement likhein.
18. `high_earners` aur `products_backup` tables ko drop karein.
19. MySQL dwara `order_items` table ke liye generate ki gayi complete DDL `CREATE TABLE` script dekhne ke liye ek statement likhein.
20. `departments(department_name, location)` par `uq_dept_loc` naam ka composite unique constraint add karne wala `ALTER TABLE` statement likhein.

### Advanced Questions (21–25)
21. `order_items` se per product sold total units ko aggregate karne wali ek temporary table `temp_sales_summary` create karne ki script likhein. Explain karein ki MySQL is table ko kab purge karta hai.
22. Ek `ALTER TABLE` statement likhein jo foreign key checks ko temporarily disable karta hai, foreign key constraint add karta hai, aur foreign key checks ko re-enable karta hai.
23. `employees` table mein check constraint `salary > 200000` add karne ka attempt karne wala ek statement likhein. Explain karein ki agar existing rows is condition ko violate karti hain toh MySQL is DDL ko reject kyun karta hai.
24. MySQL 8.0 `ALGORITHM=INPLACE, LOCK=NONE` ka use karke `customers.phone` ko `VARCHAR(25)` mein modify karne wala ek `ALTER TABLE` statement construct karein.
25. Demonstrate karein ki InnoDB table par active `AUTO_INCREMENT` attribute wali primary key ko kaise drop kiya ja sakta hai.

### Challenge Questions (26–30)
26. **Schema Migration Challenge**: Ek multi-step migration script likhein jo kisi bhi existing customer data ko lose kiye bina `customers.first_name` aur `customers.last_name` ko ek single `full_name VARCHAR(100)` column mein combine kare, aur puraane columns ko drop kare.
27. **Zero-Downtime Column Addition**: 10 million rows wali table mein bina exclusive table lock liye default value ke saath ek non-null column add karne ka SQL pattern likhein.
28. **Foreign Key Integrity Audit**: `sql_mastery` database ke andar saari foreign keys aur unke corresponding `ON DELETE` rules ko list karne ke liye MySQL ke `information_schema.table_constraints` aur `referential_constraints` ko query karne wali ek query likhein.
29. **Storage Footprint Analysis**: `information_schema.tables` ke against ek query likhein jo `sql_mastery` ki har table ke liye total data size aur index size ko Megabytes (MB) mein calculate kare.
30. **Composite Key Restructuring**: Ek table jisme existing composite primary key `(order_id, product_id)` hai, use ek surrogate primary key `item_id INT AUTO_INCREMENT` wali table mein convert karein jabki composite uniqueness ko preserve rakhein.

---

## Section 2: Data Querying, Filtering & Sorting (SELECT, WHERE, ORDER BY, LIMIT)

### Beginner Questions (31–40)
31. `departments` table se saari rows ke liye sabhi columns retrieve karein.
32. `customers` table se sirf `first_name`, `last_name`, aur `email` retrieve karein.
33. $500.00 se strictly greater `unit_price` wale sabhi products find karein.
34. Un sabhi customers ko find karein jo `'USA'` country mein rehte hain.
35. Un sabhi orders ko find karein jinka status `'Delivered'` hai.
36. $100.00 aur $400.00 (inclusive) ke beech `unit_price` wale sabhi products retrieve karein.
37. Un sabhi customers ko find karein jinka koi `state` recorded nahi hai (`state IS NULL`).
38. Sabhi employees ko `hire_date` ke ascending order mein sort karke retrieve karein (earliest hires pehle).
39. Company mein top 3 highest-earning employees ko retrieve karein.
40. `customers` table se bina kisi duplicate ke distinct countries retrieve karein.

### Intermediate Questions (41–50)
41. Un sabhi customers ko find karein jinka `email` address `'@gmail.com'` par end hota hai.
42. `category_id` 1 ya 2 ke un sabhi products ko retrieve karein jinka `stock_quantity` 20 se greater ho.
43. `'2023-08-01'` aur `'2023-08-15'` ke beech place kiye gaye un sabhi orders ko find karein jahan `total_amount` $300.00 se exceed karta ho.
44. Un sabhi employees ko find karein jinki `salary` $90,000 se greater hai aur jinka `manager_id` NOT NULL hai.
45. Currently active (`is_active = TRUE`) products mein se 5 least expensive products retrieve karein.
46. Un sabhi customers ko find karein jinka `first_name` `'M'` ya `'S'` se start hota hai aur jinki country `'USA'` nahi hai.
47. Status `'Processing'` ya `'Pending'` wale sabhi orders retrieve karein, ordered by `order_date` descending.
48. UI pagination implement karein: `unit_price` descending order mein sorted `products` table ki rows 4 se 6 retrieve karein.
49. Un sabhi products ko find karein jinke product name mein `'Air'` ya `'Pro'` word include hota hai.
50. Sabhi customers ko is tarah sort karke retrieve karein ki `'USA'` wale customers pehle aayein, aur baaki saare countries alphabetically unke neeche sort hon.

### Advanced Questions (51–55)
51. `customers` table ke against ek query likhein jo `loyalty_points` descending order mein sort kare, aur jin customers ke loyalty points `NULL` hain unhe sabse neeche place kare.
52. Ek query likhein jo un sabhi orders ko retrieve kare jahan `shipping_fee` order ke `total_amount` ka 2% se zyada represent karti ho.
53. Ek aisi query construct karein jo `products` table mein un products ko search kare jinka name exactly 15 characters ka ho.
54. Keyset / Cursor Pagination ka use karke, `order_id = 1005` ke baad ke 3 orders ka agla page fetch karne ke liye query likhein bina `OFFSET` keyword ka use kiye.
55. Un sabhi employees ko retrieve karein jo kisi odd-numbered month mein hire hue the.

### Challenge Questions (56–60)
56. **Deterministic Pagination Challenge**: Explain karein ki agar `order_date` mein duplicate/tie values hain toh `ORDER BY order_date LIMIT 5 OFFSET 5` consecutive pages par duplicate rows kyun return kar sakta hai. Iska corrected query likhein.
57. **Complex Pattern Matching**: `customers` ke against ek regular expression query (`REGEXP`) likhein jo un sabhi phone numbers ko find kare jo strictly `555-XXXX` pattern ko adhere nahi karte.
58. **Dynamic Threshold Filtering**: Ek query likhein jo un products ko retrieve kare jinki current inventory value (`stock_quantity * unit_price`) sabhi products ki average inventory value se exceed karti ho.
59. **Multi-Condition Search Filter**: Ek query likhein jo e-commerce search bar ko model kare: diye gaye search keyword `'Pro'` ke liye, ek saath `product_name`, `category_name`, aur `supplier_name` across filter karein.
60. **Safe Range Scanning**: `orders` ko `order_date` ke according filter karne wali query likhein jo pure 2023 year ke liye guaranteed SARGable aur index-seekable ho.

---

## Section 3: Built-in SQL Functions (String, Date, Math & Flow)

### Beginner Questions (61–70)
61. Sabhi employees ke liye `first_name` aur `last_name` ko concatenate karke ek single column `full_name` banayein.
62. Sabhi supplier company names ko uppercase mein convert karein.
63. Har product name ki length (characters count) display karein.
64. Har employee ki salary ko nearest thousand par round karein.
65. MySQL functions ka use karke current date aur time return karein.
66. Sabhi orders ki `order_date` se calendar year extract karein.
67. Ek mathematical function ka use karke 144 ka square root find karein.
68. `customers` table projection mein `'USA'` ke kisi bhi occurrence ko `'United States'` se replace karein.
69. `IFNULL()` ka use karke har customer ka phone number display karein, aur agar phone NULL ho toh `'No Phone Provided'` show karein.
70. $-45.50$ ki absolute value calculate karein.

### Intermediate Questions (71–80)
71. Har customer ki `registered_at` date aur aaj ke beech kitne din bit chuke hain calculate karein.
72. `orders` mein sabhi `order_date` values ko human-readable format `'Month Day, Year'` (e.g. `'August 01, 2023'`) mein format karein.
73. Har customer ke `country` ke pehle 3 characters extract karein.
74. `customers.email` se username portion (`@` symbol se pehle ka sab kuch) extract karein.
75. Sabhi products par 15% promotional discount calculate karne wali query likhein, jo 2 decimal places tak truncated (rounded nahi) ho.
76. `TIMESTAMPDIFF()` ka use karke har employee ka tenure complete elapsed months mein calculate karein.
77. `CONCAT_WS()` ka use karke har customer ka complete address: `city, state, country` format karein. Ensure karein ki missing states double commas produce na karein.
78. `DATE_ADD()` ka use karke sabhi order dates mein 30-day payment grace period add karein.
79. `IF()` function ka use karke har product ko flag karein: agar price > $500 ho toh `'Expensive'`, warna `'Affordable'`.
80. `MOD()` ka use karke order total amounts ko 10 se divide karne par bacha hua remainder calculate karein.

### Advanced Questions (81–85)
81. Searched `CASE` expression ka use karke customers ko tiers mein classify karein: `'Diamond'` (points $\ge 700$), `'Platinum'` (points $\ge 400$), `'Silver'` (points $\ge 100$), aur baaki sabhi ke liye `'Basic'`.
82. `POWER()` function ka use karke SQL mein Compound Annual Growth Rate (CAGR) formula calculate karein.
83. Ek aisi query likhein jo customer ke first names mein sabhi vowels ko dynamically asterisks (`*`) se replace kare.
84. `LAST_DAY()` ka use karke `orders` mein har order ke liye us month ka last day find karne wali query likhein.
85. Ek aisi query likhein jo employees ke liye total payroll, average salary, minimum salary, aur maximum salary compute kare, aur ensure karein ki NULLs 0 mein convert hon.

### Challenge Questions (86–90)
86. **Working Day Calculation Challenge**: Ek SQL expression likhein jo order ki `order_date` aur aaj ke beech business days (Saturdays aur Sundays ko exclude karke) calculate kare.
87. **Email Obfuscation Challenge**: Privacy ke liye customer emails ko mask karne wali query likhein, jisme sirf pehle 2 characters aur domain dikhein (e.g., `emily.watson@gmail.com` transform hokar `em*****@gmail.com` ban jaye).
88. **Safe Division Matrix**: Har customer ke liye `loyalty_points` aur order count ka ratio calculate karne wali query likhein, jo `NULLIF` ka use karke division by zero se protect kare.
89. **Fiscal Quarter Determination**: Ek aisi expression likhein jo har order date ko enterprise fiscal quarter se map kare, jahan Fiscal Year November 1st ko shuru hota hai.
90. **String Parsing Challenge**: Diye gaye comma-delimited string `'alpha,beta,gamma'` se bina procedural loops ke pure SQL string functions ka use karke 2nd element (`'beta'`) extract karein.

---

## Section 4: Grouping & Aggregation (GROUP BY & HAVING)

### Beginner Questions (91–100)
91. Company mein employees ka total count nikalein.
92. `orders` table mein sabhi order amounts ka total sum find karein.
93. Sabhi products ka average unit price find karein.
94. `customers` table mein kitne unique countries represented hain count karein.
95. `employees` table mein maximum salary aur minimum salary find karein.
96. Har `category_id` se belong karne wale products ki sankhya count karein.
97. Har `department_id` ke liye total payroll expenditure calculate karein.
98. Har `customer_id` dwara place kiye gaye orders count karein.
99. `order_items` mein bechi gayi items ki total quantity calculate karein.
100. Har `country` mein rehne wale customers ki sankhya count karein.

### Intermediate Questions (101–110)
101. Wo sabhi `department_id` groups find karein jahan average employee salary $100,000 se exceed karti ho.
102. Un sabhi customers ko find karein jinhone 2 ya usse zyada orders place kiye hain.
103. `orders` table mein har `status` dwara generate kiya gaya total revenue calculate karein.
104. Har us `category_id` ko list karein jisme 1 se zyada active product exist karte hain.
105. Har department ke liye employee first names ki comma-separated list produce karne ke liye `GROUP_CONCAT` ka use karein.
106. Products ko `supplier_id` ke according group karein aur minimum price, maximum price, aur price range (`max - min`) display karein.
107. Wo sabhi order dates find karein jahan ek hi din par 1 se zyada order place kiye gaye the.
108. `order_items` mein per order diya gaya average discount calculate karein, aur sirf un orders ko display karne ke liye filter karein jahan average discount > 0 ho.
109. Customers ko `country` aur `state` ke according group karein, aur count karein ki har combination mein kitne customers rehte hain.
110. Har `payment_method` ke liye successful payments ka total amount find karein.

### Advanced Questions (111–115)
111. Employees ko `department_id` ke according `WITH ROLLUP` ke saath group karne wali query likhein, headcount aur total salary calculate karein, aur ek grand total row ko `'Company Total'` label karein.
112. `GROUP BY` query mein unaggregated column select karne par aane wale `ERROR 1055: only_full_group_by` ke cause ko explain karein. Is error ko demonstrate karne wali query likhein aur use fix karein.
113. `GROUP BY`, `ORDER BY`, aur `LIMIT 1` ka use karke wo department find karein jiska average salary sabse high hai.
114. Un sabhi customers ko find karein jinka cumulative order spend company-wide average order value se exceed karta ho.
115. Orders ko calendar month ke according group karein aur us month ke total sales, shipping costs, aur order count calculate karein.

### Challenge Questions (116–120)
116. **Multi-Dimensional ROLLUP Analysis**: `WITH ROLLUP` ka use karke `products` ko `category_id` aur `supplier_id` ke according group karein, aur subtotal vs grand total rows ko identify karne ke liye `GROUPING()` function ka use karein.
117. **Conditional Aggregation (Pivot)**: Ek aisi single query likhein jo `orders` table ko pivot karke `SUM(CASE ...)` ka use karte hue total revenue ko 5 alag-alag columns mein display kare: `Pending`, `Processing`, `Shipped`, `Delivered`, aur `Cancelled`.
118. **Customer Retention Metric**: Customers ko unki registration date ke year ke according group karein aur calculate karein ki unme se kitne customers ne 2023 mein order place kiya hai.
119. **Pareto Principle Analysis (80/20 Rule)**: Ek aisi query likhein jo top 20% customers ko identify kare jo total revenue ka 80% generate karte hain.
120. **Aggregating Pre-Calculated Line Items**: `order_items` se har order ke liye discounts account mein lete hue total net revenue calculate karein, aur `HAVING` ka use karke un orders ko filter karein jahan net revenue $1,000 se exceed karta ho.

---

## Section 5: Relational JOINs & Set Operations

### Beginner Questions (121–130)
121. Har employee ka name aur department name display karne ke liye `employees` aur `departments` ke beech `INNER JOIN` perform karein.
122. Sabhi departments show karne ke liye `departments` aur `employees` ke beech `LEFT JOIN` perform karein, un departments samet jinme koi employee nahi hai.
123. Order IDs aur customer names show karne ke liye `orders` aur `customers` ko join karein.
124. Har product ka title aur category description show karne ke liye `products` aur `categories` ko join karein.
125. Product names aur supplier contact emails display karne ke liye `products` aur `suppliers` ko join karein.
126. `customers` aur `suppliers` se saari distinct cities ko combine karne ke liye `UNION` ka use karein.
127. `customers` aur `suppliers` se saari cities ko combine karne ke liye `UNION ALL` ka use karein.
128. Har order se belong karne wale sabhi item IDs ko list karne ke liye `orders` aur `order_items` ko join karein.
129. Order IDs aur payment transaction references display karne ke liye `orders` aur `payments` ko join karein.
130. `categories` aur `departments` ke beech `CROSS JOIN` perform karein.

### Intermediate Questions (131–140)
131. Un sabhi customers ko find karne ke liye ek Anti-Join likhein jinhone kabhi koi order place nahi kiya.
132. Un sabhi products ko find karne ke liye ek Anti-Join likhein jo `order_items` mein kabhi purchase nahi kiye gaye.
133. Har employee ke name ke saath unke direct manager ka name display karne ke liye `employees` par ek `Self JOIN` perform karein.
134. Customer Emily Watson dwara khareede gaye sabhi products list karne ke liye `customers`, `orders`, aur `order_items` ko connect karne wala ek 3-table join likhein.
135. `'Japan'` based suppliers dwara supply kiye gaye `'Electronics'` category ke sabhi products list karne ke liye `products`, `categories`, aur `suppliers` ko join karne wali query likhein.
136. Customer phone numbers aur employee phone numbers ko combine karne ke liye `UNION ALL` ka use karein, aur har row ko ek `'Entity_Type'` column ke saath tag karein.
137. Same department mein kaam karne wale employees ke sabhi pairs find karne ke liye ek `Self JOIN` perform karein.
138. Order 1001 ke andar ke items ki total retail value calculate karne ke liye `orders`, `order_items`, aur `products` ko join karein.
139. Wo sabhi departments find karne ke liye query likhein jinme currently zero staff employed hai.
140. `UNION` ka use karke `departments` aur `employees` ke beech ek `FULL OUTER JOIN` emulate karein.

### Advanced Questions (141–145)
141. Per customer per category generate hua total revenue calculate karne ke liye `customers`, `orders`, `order_items`, `products`, aur `categories` ko connect karne wala 5-table join likhein.
142. Ek aisa Non-Equi Join likhein jo un sabhi products ko find kare jinka `unit_price` department 1 ke employees ki average salary se strictly greater ho.
143. `LEFT JOIN` ka use karke ek aisi query likhein jahan right table ka filter `ON` clause ke andar placed ho, aur explain karein ki ye result `WHERE` clause mein filter place karne se kaise different hota hai.
144. Relational joins ka use karke un sabhi customers ko find karein jinhone Product 1 AUR Product 3 dono purchase kiye hain.
145. Individual parenthesized subqueries ke saath `UNION ALL` ka use karke top 2 highest-paid employees aur top 2 lowest-paid employees ko combine karein.

### Challenge Questions (146–150)
146. **Full Outer Join Emulation with Nulls**: `customers` aur `orders` ke beech ek complete `FULL OUTER JOIN` construct karein jo accurately un customers ko return kare jinke paas orders nahi hain AUR bina valid customer wale orders ko bhi return kare (agar orphaned hon).
147. **Self Join Hierarchy Tree**: 3-way Self Join ka use karke employees, unke managers, aur unke manager ke managers (management hierarchy ke 2 levels) display karne wali query likhein.
148. **Relational Division Challenge**: Un sabhi customers ko find karein jinhone Category 1 (`Electronics`) ka **har ek product** purchase kiya ho.
149. **Basket Analysis (Co-Purchased Products)**: `order_items` par ek self-join query likhein jo un product pairs ko identify kare jo same order mein sabse frequently saath khareede jaate hain.
150. **Consolidated Financial Audit**: `UNION ALL` ka use karke completed order revenue, refund deductions, aur shipping costs ko ek chronological general ledger mein merge karne wali ek compound query likhein.

---

## Section 6: Nested Queries & Common Table Expressions (CTEs)

### Beginner Questions (151–160)
151. Company-wide average salary se zyada earn karne wale sabhi employees ko find karne ke liye ek scalar subquery likhein.
152. Un sabhi products ko find karne ke liye `IN` ke saath subquery likhein jo un categories se belong karte hain jinme `'Appliances'` word aata hai.
153. `total_amount` ke hisaab se single largest order place karne wale customer ko find karne ke liye ek subquery likhein.
154. Subquery ka use karke Quantum Pro 15 Laptop se higher priced sabhi products find karein.
155. `FROM` clause mein derived table ka use karke product prices ko alias karne wali query likhein.
156. Table mein sabse earliest registration date par register hone wale sabhi customers find karein.
157. `'San Francisco'` mein rehne wale customers dwara place kiye gaye sabhi orders find karne ke liye subquery ka use karein.
158. Active products ko select karne wali `ActiveProducts` naam ki basic CTE likhein, aur usse query karein.
159. Subquery ka use karke employee David Kim ke saath same manager share karne wale sabhi employees find karein.
160. Subquery ke saath `NOT IN` ka use karke un products ko find karein jo kabhi order nahi kiye gaye.

### Intermediate Questions (161–170)
161. Ek Correlated Subquery likhein jo apne khud ke department ki average salary se zyada earn karne wale sabhi employees ko find kare.
162. Kam se kam ek active product supply karne wale sabhi suppliers ko find karne ke liye `EXISTS` ka use karke query likhein.
163. Kabhi koi order place na karne wale sabhi customers ko find karne ke liye `NOT EXISTS` ka use karke query likhein.
164. Per customer total spending calculate karne wali CTE likhein, aur CTE se query karke un customers ko find karein jinhone $1,000 se zyada spend kiya.
165. Category 3 ke sabhi products ke price se greater price wale products find karne ke liye `ALL` ka use karke query likhein.
166. Department 4 ke kisi bhi employee ki salary se greater salary wale employees find karne ke liye `ANY` ka use karke query likhein.
167. `SELECT` projection list mein ek aisi subquery likhein jo har employee ki salary ke saath company ki maximum salary bhi display kare.
168. Do chained CTEs: `CustomerOrders` aur `OrderTotals` ke saath ek modular query likhein jo per customer average order size calculate kare.
169. Subqueries ka use karke un sabhi customers ko find karein jinhone August 2023 aur September 2023 dono mein order place kiya hai.
170. Ek correlated subquery likhein jo har customer ke liye unki most recent order date display kare.

### Advanced Questions (171–175)
171. 1 se 20 tak integer sequence generate karne wali ek Recursive CTE likhein.
172. CEO se lekar individual staff members tak poore organizational management tree ko model karne wali aur hierarchy level depth compute karne wali Recursive CTE likhein.
173. Ek correlated subquery likhein jo har category ke andar top 1 highest-priced product find kare.
174. CTE ka use karke ek aisi query likhein jo har customer dwara total company revenue mein contribute ki gayi percentage calculate kare.
175. Ek deeply nested subquery ko ek linear 3-stage Common Table Expression mein rewrite karein.

### Challenge Questions (176–180)
176. **Recursive Date Series Generator**: August 2023 month ke sabhi calendar dates generate karne wali Recursive CTE likhein, aur per day orders count karne ke liye `orders` ke against `LEFT JOIN` perform karein (empty days par 0 show karte hue).
177. **BOM (Bill of Materials) Traversal**: Ek hierarchical assembly ke liye total component manufacturing cost calculate karne wali recursive CTE query design karein.
178. **Correlated Subquery Optimization**: Running balances calculate karne wali ek slow correlated subquery lein aur use ek derived table ke saath optimized join mein rewrite karein.
179. **Detecting Circular Management References**: Recursive CTE ka use karke manager hierarchies ko traverse karne wali aur detect karne wali query likhein agar koi employee kisi loop ke through ghalti se khud ko report kar raha ho.
180. **Cumulative Tier Classification**: Customer percentiles calculate karne wali CTE likhein aur top 10% customers ko dynamically `'Key Accounts'` tag karein.

---

## Section 7: Database Design, Normalization & Views

### Beginner Questions (181–190)
181. Agar koi column commas se separated multiple phone numbers store karta hai toh kaun sa normal form violate hota hai?
182. Composite keys par partial dependencies ko eliminate karna kis normal form ki requirement hai?
183. Transitive dependencies ko eliminate karna kis normal form ki requirement hai?
184. Product titles, category names, aur prices display karne wala `v_all_products` naam ka view create karein.
185. $300.00 se kam price wale products ke liye `v_all_products` view ko query karein.
186. Sirf active employees ko show karne wala `v_active_employees` naam ka view create karein.
187. MySQL mein kisi existing view ki definition inspect karne ka tareeqa show karein.
188. View `v_all_products` ko drop karein.
189. Explain karein ki kya koi view table rows ke liye physical disk storage consume karta hai.
190. Agar aap kisi underlying base table column ka naam rename kar dete hain toh view ka kya hota hai?

### Intermediate Questions (191–200)
191. `country = 'Germany'` ke liye filter karne wala updatable view `v_german_customers` create karein.
192. `v_german_customers` mein `WITH CHECK OPTION` add karein aur demonstrate karein ki ye kisi Italian customer ko insert hone se kaise block karta hai.
193. Ek security view `v_employee_directory` create karein jo employee salaries aur personal phone numbers ko mask kare.
194. Ek analytical view `v_monthly_sales_summary` create karein jo month ke according revenue, order count, aur average order value ko aggregate kare.
195. Ek unnormalized relation `R(OrderID, CustomerName, CustomerAddress, ProductID, ProductName, Quantity)` ko 3NF tables mein normalize karein.
196. `courses(course_id, course_code, instructor_id, instructor_office)` mein functional dependencies identify karein.
197. Explain karein ki `orders` table mein `total_amount` store karna ek controlled denormalization decision kyun hai.
198. Updatable view ke through kisi employee ki salary update karke demonstrate karein.
199. Explain karein ki `GROUP BY` contain karne wala view directly update kyun nahi kiya ja sakta.
200. Customer order invoice summary produce karne ke liye 4 tables ko join karne wala ek view create karein.

### Advanced Questions (201–205)
201. MySQL mein ek physical summary table aur scheduled event ka use karke Materialized View emulate karein.
202. Ek Car Rental Agency (Customers, Vehicles, Rentals, Maintenance Logs) ke liye 3NF schema design karein.
203. Ek concrete schema example ke saath Boyce-Codd Normal Form (BCNF) explain karein jahan 3NF satisfy hota hai lekin BCNF violate hota hai.
204. `ALGORITHM = MERGE` ka use karke ek view create karein aur explain karein ki MySQL view query ko outer user query ke saath kaise combine karta hai.
205. `ALGORITHM = TEMPTABLE` ka use karke ek view create karein aur `EXPLAIN` ka use karke iska execution plan analyze karein.

### Challenge Questions (206–210)
206. **Zero-Loss Normalization Decomposition**: Relation $R(A, B, C, D, E)$ jisme functional dependencies $A \rightarrow B, C$, $C \rightarrow D$, aur $D \rightarrow E$ hain, use 3NF mein decompose karein, proving lossless join property.
207. **Security View with Row-Level Tenant Isolation**: MySQL ke `SESSION_USER()` ya `CURRENT_USER()` ka use karke ek security view create karein jo users ko restrict kare taaki wo sirf apne department ke records view kar sakein.
208. **Materialized View Refresh Mechanism**: Ek stored procedure aur trigger architecture likhein jo `order_items` mein nayi rows insert hone par materialized view table ko incrementally maintain kare.
209. **Denormalization Trade-off Audit**: 10 million transactions ke liye ek normalized 3NF schema vs ek denormalized Star Schema ke beech exact byte storage difference calculate karein.
210. **Schema Anti-Pattern Refactor**: Ek existing Entity-Attribute-Value (EAV) schema anti-pattern lein aur use ek hybrid relational + JSON document design mein refactor karein.

---

## Section 8: Indexes, Transactions & Concurrency Control

### Beginner Questions (211–220)
211. `customers(email)` par `idx_cust_email` naam ka index create karne ke liye statement likhein.
212. Index `idx_cust_email` ko drop karne ke liye statement likhein.
213. `orders` table par currently defined sabhi indexes display karein.
214. MySQL mein explicit transaction begin karne ke liye kaun si command hoti hai?
215. Pending transactional changes ko disk par commit karne ke liye kaun si command hoti hai?
216. Uncommitted changes ko rollback karne ke liye kaun si command hoti hai?
217. MySQL InnoDB mein default transaction isolation level kya hai?
218. Clustered Index kya hota hai, aur `customers` table mein kaun sa column ise represent karta hai?
219. Explain karein ki ACID acronym ka kya matlab hota hai.
220. Savepoint kya hota hai, aur aap ise kaise create karte hain?

### Intermediate Questions (221–230)
221. `orders(customer_id, order_date)` par ek composite index create karein.
222. Question 221 ke composite index ko Leftmost Prefix Rule follow karte hue utilize karne wali query likhein.
223. Ek aisi query likhein jo Leftmost Prefix Rule violate karne ki wajah se Question 221 ke composite index ko utilize karne mein fail ho jaati hai.
224. Ek aisa transaction likhein jo Product 1 ke stock ko decrement kare aur order create kare. Agar stock insufficient ho toh rollback karein.
225. Demonstrate karein ki CLI session mein `SET autocommit = 0;` transaction persistence ko kaise alter karta hai.
226. Inventory verification query ke dauran product record ko lock karne ke liye `SELECT ... FOR UPDATE` ka use karein.
227. Read-only validation ke liye customer record ko lock karne ke liye `SELECT ... FOR SHARE` ka use karein.
228. "Dirty Read" ke naam se jaane jaane wale concurrency anomaly ko explain karein aur batayein ki kaun sa isolation level ise permit karta hai.
229. Explain karein ki "Non-Repeatable Read" kya hota hai aur `REPEATABLE READ` ise kaise prevent karta hai.
230. Explain karein ki "Phantom Read" kya hota hai aur InnoDB ka Next-Key Locking ise kaise prevent karta hai.

### Advanced Questions (231–235)
231. `employees` par ek index-covering query demonstrate karein jisme `EXPLAIN` output ke `Extra` column mein `Using index` show ho.
232. MySQL mein do concurrent connections ke beech ek deadlock scenario simulate karein.
233. `SAVEPOINT` ka use karne wala ek transaction likhein jo parent order ko retain rakhte hue order item insert ko partially roll back kare.
234. Explain karein ki InnoDB ka Multi-Version Concurrency Control (MVCC) readers ko writers ko block karne se kaise bachaata hai.
235. MySQL ki `performance_schema.data_locks` table ka use karke active transaction locks inspect karein.

### Challenge Questions (236–240)
236. **Deadlock Resolution Routine**: Application-level retry algorithm (pseudocode ya SQL handler mein) likhein jo MySQL error 1213 (Deadlock found) ko intercept kare aur transaction ko retry kare.
237. **Covering Index Optimization Challenge**: Is query ko sub-millisecond speeds tak accelerate karne ke liye optimal composite index design karein:
   ```sql
   SELECT customer_id, order_date, total_amount FROM orders WHERE status = 'Delivered' ORDER BY order_date DESC LIMIT 10;
   ```
238. **Index Cardinality Analysis**: `customers` par sabhi indexes ka selectivity ratio compute karne wali query likhein taaki decide kiya ja sake ki kaun se indexes drop karne chahiye.
239. **Implicit Commit Disaster Recovery**: Ek aisa scenario construct karein jo demonstrate kare ki transaction ke andar `ALTER TABLE` run karne se prior DML statements commit ho jaate hain aur atomicity break ho jaati hai.
240. **InnoDB Lock Escalation Mechanics**: Explain karein ki InnoDB table-level locking ke bajaye row-level locking kyun use karta hai, aur row locks kab escalate hote hain ya Gap Locks ke through entire ranges ko lock karte hain.

---

## Section 9: Programmability & Advanced Analytics (Procedures, Functions, Triggers, Windows)

### Beginner Questions (241–250)
241. Sabhi departments ko select karne wala ek basic stored procedure `sp_list_departments` likhein.
242. `sp_list_departments` procedure ko execute karne ke liye command likhein.
243. MySQL CLI mein stored routines create karte waqt `DELIMITER` ko change karna kyun zaroori hota hai?
244. Ek deterministic function `fn_add_numbers(a INT, b INT)` create karein jo unka sum return kare.
245. `employees` par ek `BEFORE INSERT` trigger likhein jo `email` ko lowercase mein force kare.
246. Salary descending order mein sorted sabhi employees ko number karne ke liye `ROW_NUMBER()` window function ka use karein.
247. `->>` operator ka use karke `'{"brand": "Sony", "model": "XM4"}'` se JSON value extract karein.
248. `sp_my_proc` naam ke stored procedure ko drop karne ka tareeqa show karein.
249. Procedure mein `IN` parameter aur `OUT` parameter ke beech difference explain karein.
250. `DELETE` trigger mein kaun sa pseudo-record (`OLD` ya `NEW`) available hota hai?

### Intermediate Questions (251–260)
251. Ek procedure `sp_get_customer_spend` likhein jo `IN p_cust_id INT` le aur unka total spend `OUT p_total DECIMAL(12,2)` ke roop mein return kare.
252. Net price return karne wala ek stored function `fn_discounted_price(price DECIMAL(10,2), pct DECIMAL(4,2))` likhein.
253. `orders` par ek `AFTER DELETE` trigger likhein jo deleted `order_id` aur `total_amount` ko `orders_archive` table mein log kare.
254. Category ke andar price ke hisaab se products ko rank karne ke liye `RANK()` aur `DENSE_RANK()` ko side-by-side use karein.
255. Har employee aur unke department ke next lower-paid employee ke beech salary difference calculate karne ke liye `LAG()` ka use karein.
256. `orders` mein har customer ke liye subsequent order date display karne ke liye `LEAD()` ka use karein.
257. `IF-THEN-ELSE` control flow ke saath ek procedure likhein jo performance ratings ke basis par employee salaries update kare.
258. Ek function likhein jo count kare ki diye gaye customer ne kitne orders place kiye hain.
259. Ek `AFTER UPDATE` trigger likhein jo order ka status `'Delivered'` hone ke baad uske `total_amount` ko modify hone se prevent kare.
260. Window function ka use karke `order_date` ke according sorted order amounts ka running cumulative total calculate karein.

### Advanced Questions (261–265)
261. `CURSOR` aur `CONTINUE HANDLER FOR NOT FOUND` ka use karne wala stored procedure likhein jo sabhi active customers par iterate kare aur 50 bonus points award kare.
262. `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` ka use karke daily order revenue par 3-day moving average calculation likhein.
263. Customers ko unke lifetime spend ke basis par 4 equal quartiles mein divide karne ke liye `NTILE(4)` ka use karein.
264. Native `JSON` column ke saath ek table construct karein aur nested string attribute extract karne wala ek indexed virtual generated column build karein.
265. Stored procedure ke andar `EXIT HANDLER FOR SQLEXCEPTION` likhein jo error aane par open transaction ko automatically rollback kar de.

### Challenge Questions (266–270)
266. **Dynamic Pivot Procedure**: Ek stored procedure likhein jo arbitrary years across sales data ko columns mein pivot karne ke liye `GROUP_CONCAT` ka use karke dynamically SQL string construct kare aur use `PREPARE` aur `EXECUTE` ke through run kare.
267. **Year-over-Year (YoY) Growth Window Pipeline**: Window functions ka use karne wali ek single SQL query likhein jo monthly revenue, previous year same-month revenue (`LAG 12`), aur YoY percentage growth rate calculate kare.
268. **Strict Invariant Trigger Guard**: `order_items` par ek `BEFORE UPDATE` trigger likhein jo `orders` mein parent order ke `total_amount` ko recalculate kare aur agar customer ki credit limit exceed hoti hai toh update ko reject kar de.
269. **Advanced JSON Array Aggregation**: `products` table ko query karein aur `JSON_ARRAYAGG` aur `JSON_OBJECT` ka use karke ek single hierarchical JSON document produce karein jisme har category aur uske nested array of products shamil hon.
270. **Audit Trigger with Deep Diffing**: `employees` par ek `AFTER UPDATE` trigger likhein jo `OLD` aur `NEW` ke beech har ek column ko compare kare aur har modified attribute ke liye ek normalized `field_changes_audit` table mein separate log entry insert kare.

---

## Section 10: Performance Optimization & Enterprise Security

### Beginner Questions (271–280)
271. `customers` par query ke liye `EXPLAIN` execution plan generate karne ki command likhein.
272. `EXPLAIN` mein kaun sa access type full table scan indicate karta hai?
273. `EXPLAIN` mein kaun sa access type Primary Key lookup indicate karta hai?
274. Password `'InternPass2026!'` ke saath `'intern'@'localhost'` naam ka MySQL user account create karein.
275. `'intern'@'localhost'` ko `sql_mastery.*` par read-only (`SELECT`) privileges grant karein.
276. `'intern'@'localhost'` ko granted active privileges inspect karein.
277. `'intern'@'localhost'` se `SELECT` privileges revoke karein.
278. User `'intern'@'localhost'` ko drop karein.
279. Query optimization mein SARGable term ka kya matlab hota hai?
280. Explain karein ki web queries mein string concatenation SQL Injection vulnerabilities kyun create karta hai.

### Intermediate Questions (281–290)
281. Is non-SARGable query ko ek SARGable query mein convert karein:
   ```sql
   SELECT * FROM employees WHERE YEAR(hire_date) = 2021;
   ```
282. Is non-SARGable query ko ek SARGable query mein convert karein:
   ```sql
   SELECT * FROM customers WHERE phone LIKE '555%';
   ```
283. `customers` aur `orders` ke beech join ka actual execution time measure karne ke liye `EXPLAIN ANALYZE` ka use karein.
284. `'analyst_role'` naam ka role create karein, use `sql_mastery` ki saari tables par `SELECT` grant karein, aur role ko ek user ko assign karein.
285. Column-level permissions grant karein jo user ko `customers` se sirf `first_name`, `last_name`, aur `city` view karne allow karein.
286. MySQL mein `PREPARE`, `SET`, aur `EXECUTE` ka use karke parameterized query prepare aur execute karne ka tareeqa show karein.
287. Explain karein ki `EXPLAIN` plan ke `Extra` column mein `Using temporary` aur `Using filesort` ka kya matlab hota hai.
288. `--single-transaction` ka use karke `sql_mastery` backup karne ke liye `mysqldump` command likhein.
289. `VARCHAR` column ko integer literal se compare karne (`WHERE phone = 5550100`) ke performance risk ko identify karein.
290. MySQL mein Slow Query Log enable karein aur ise 1.0 second se lambi queries capture karne ke liye configure karein.

### Advanced Questions (291–295)
291. Block Nested Loop (ya Hash Join) show karne wale `EXPLAIN` plan ko analyze karein aur ise Index Nested Loop Join mein convert karne ke liye required index construct karein.
292. Ek multi-column covering index design karein jo `WHERE` filter aur `ORDER BY` clause dono contain karne wali query par Filesort ko completely eliminate kare.
293. MySQL 8.0 mein `caching_sha2_password` aur `mysql_native_password` ke beech security differences explain karein.
294. `sys.schema_unused_indexes` ka use karke ek SQL statement likhein jo `sql_mastery` mein un indexes ko identify kare jo queries dwara kabhi utilize nahi kiye gaye hain.
295. Encrypted SSL/TLS connection (`REQUIRE SSL`) require karne ke liye user account configure karein.

### Challenge Questions (296–300)
296. **Execution Plan Deconstruction**: 4-table join query par `EXPLAIN FORMAT=JSON` execute karein aur cost metrics (`query_cost`, `read_cost`, `eval_cost`) ko interpret karein.
297. **SQL Injection Penetration Scenario**: Demonstrate karein ki attacker authentication ko kaise bypass karta hai jab login query is tarah likhi gayi ho:
   ```sql
   SELECT * FROM users WHERE username = '$user' AND password = '$password';
   ```
   Exact injection payload show karein aur secure parameterized prepared statement equivalent likhein.
298. **Buffer Pool Sizing & Hit Ratio**: `information_schema` aur `performance_schema` ke against ek query likhein jo InnoDB Buffer Pool Read Hit Ratio percentage calculate kare.
299. **Granular Row-Level Access Architecture**: MySQL mein multi-tenant security architecture design karein jahan multiple client companies ek single database share karti hain, lekin database-level roles aur views ensure karein ki Tenant A kabhi bhi Tenant B ka data query na kar sake.
300. **High-Performance Query Refactoring**: 4 subqueries, 2 self-joins, aur ek `DISTINCT` clause contain karne wali legacy reporting query lein, aur use Common Table Expressions aur Window Functions ka use karke optimized pipeline mein refactor karein, jisse query cost 80% se zyada reduce ho jaye.
