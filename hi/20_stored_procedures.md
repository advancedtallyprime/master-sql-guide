# Chapter 20 — Database Programmability: Stored Procedures & Control Flow (स्टोर्ड प्रोसीजर्स और कण्ट्रोल फ्लो)

---

## 1. What is it? (यह क्या है? — स्टोर्ड प्रोसीजर्स और DELIMITER)

MySQL mein **Stored Procedure** ek pre-compiled subroutine (ya functions ka block) hota hai jisme ek ya ek se zyada SQL statements aur procedural control-flow logic (`IF`, `CASE`, `WHILE`, `LOOP`) shamil hote hain, jo seedhe database dictionary ke andar permanently store rehte hain.

Application servers database ko sirf ek single command bhejkar procedure call karte hain: **`CALL procedure_name(...)`**. Kyunki ye routine database server par pehle se maujood rehti hai, isliye SQL queries pehle se parsed, validated aur compiled hoti hain, jisse execution speed kaafi tez ho jaati hai.

### The `DELIMITER` Command: Iski Zaroorat Kyu Padti Hai?
By default, MySQL client terminal ek semicolon (`;`) ko SQL statement ka ending point (termination delimiter) maanta hai. Lekin ek Stored Procedure ke andar kayi saare internal SQL statements hote hain jo har line ke aage semicolon (`;`) lagate hain. Agar aap client delimiter nahi badlenge, toh MySQL parser pehli internal line ke semicolon par hi procedure ko tod dega aur poora procedure banne se pehle hi syntax error throw kar dega!

Isliye MySQL CLI mein procedure likhte waqt hum temporary roop se statement delimiter ko kisi doosre symbol (aamtaur par `//` ya `$$`) par switch karte hain, poora procedure compile karte hain, aur fir delimiter ko wapas standard semicolon (`;`) par reset kar dete hain:

```sql
DELIMITER //
CREATE PROCEDURE my_procedure()
BEGIN
    -- Internal statements standard semicolon ; se end honge
    SELECT * FROM employees;
END //
DELIMITER ;
```

---

## 2. Why do we use it? (हम इसका उपयोग क्यों करते हैं?)

1. **Reduced Network Traffic**: Agar kisi complex business process ke liye 15 alag-alag queries run karni hain, toh application aur database server ke beech 15 baar network round-trip lene ke bajaye, app sirf ek `CALL` command bhejti hai. Poora 15-step execution database ke andar hi fast local memory mein execute ho jata hai, jisse network latency drastic roop se kam ho jaati hai.
2. **Encapsulation & Strong Security**: Aap users aur applications ko stored procedure par `EXECUTE` privilege de sakte hain aur base tables par direct `SELECT`, `UPDATE`, ya `DELETE` permissions poori tarah revoke kar sakte hain. Stored procedure ek secure API gateway ban jata hai jo kisi ko bhi sensitive raw tables chhoone nahi deta.
3. **Centralized Business Logic**: Agar aapki company mein alag-alag technology stacks hain (jaise Python backend, Java enterprise microservice, aur React Native mobile app), toh business logic (jaise checkout rules ya salary calculation) har jagah duplicate likhne ke bajaye stored procedure mein daal dijiye. Sabhi clients ke liye bilkul identical rules chalenge!
4. **Pre-Compiled Efficiency**: Repeated queries ke liye query parsing aur optimization plan memory mein cache ho jata hai.

---

## 3. Syntax & Parameter Modes (सिंटैक्स और पैरामीटर मोड्स — IN, OUT, INOUT)

Stored procedures calling application ke sath teen tarah ke parameter modes ke zariye communicate karte hain:

| Parameter Mode | Direction | Behavior Description |
| :--- | :--- | :--- |
| **`IN`** (Default) | Caller $\rightarrow$ Procedure | Procedure ke andar data pass karta hai. Procedure is variable ko andar read aur modify kar sakta hai, lekin caller ke original variable par koi asar nahi padta. |
| **`OUT`** | Procedure $\rightarrow$ Caller | Procedure ke andar ek blank variable bheja jata hai. Procedure calculation karta hai aur result isme set karke caller ko wapas return karta hai. |
| **`INOUT`** | Caller $\leftrightarrow$ Procedure | Ek initial value procedure ke andar aati hai; procedure use read karta hai, modify karta hai, aur badli hui value caller ko wapas bhej deta hai. |

### Procedural Control-Flow Constructs
```sql
DELIMITER //

CREATE PROCEDURE sp_demo_flow(
    IN p_employee_id INT,
    OUT p_bonus_amount DECIMAL(10,2)
)
BEGIN
    -- 1. Local Variable Declarations (BEGIN block ke bilkul top par aana zaroori hai!)
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_tenure_years INT;

    -- 2. Populate variables from table queries using INTO
    SELECT salary, TIMESTAMPDIFF(YEAR, hire_date, CURDATE())
    INTO v_salary, v_tenure_years
    FROM employees
    WHERE employee_id = p_employee_id;

    -- 3. Conditional Flow: IF - ELSEIF - ELSE
    IF v_tenure_years >= 5 THEN
        SET p_bonus_amount = v_salary * 0.20;
    ELSEIF v_tenure_years >= 2 THEN
        SET p_bonus_amount = v_salary * 0.10;
    ELSE
        SET p_bonus_amount = v_salary * 0.05;
    END IF;

END //

DELIMITER ;
```

### Managing Stored Procedures
```sql
-- Execute a Stored Procedure
CALL procedure_name(arg1, @out_var);

-- View Procedure Definition
SHOW CREATE PROCEDURE procedure_name;

-- Drop Procedure
DROP PROCEDURE IF EXISTS procedure_name;
```

---

## 4. Basic Example (बेसिक उदाहरण)

Ek simple stored procedure banate hain aur call karke dekhte hain:

```sql
USE sql_mastery;

DELIMITER //

CREATE PROCEDURE sp_get_department_employees(IN p_dept_id INT)
BEGIN
    SELECT employee_id, first_name, last_name, salary
    FROM employees
    WHERE department_id = p_dept_id
    ORDER BY salary DESC;
END //

DELIMITER ;

-- Call the procedure for Department 1 (Engineering)
CALL sp_get_department_employees(1);

-- Clean up
DROP PROCEDURE sp_get_department_employees;
```

---

## 5. Real-World Example (रियल-वर्ल्ड उदाहरण — एंटरप्राइज चेकआउट ऑर्डर प्रोसेसर)

Chaliye ek production-ready enterprise stored procedure `sp_process_order_checkout` banate hain jo complete business transaction handle karta hai:
1. Product ki existence aur stock availability verify karta hai.
2. Error aane par poore transaction ko automatic `ROLLBACK` karne ke liye `SQLEXCEPTION` handler declare karta hai.
3. Managed transaction ke andar naya order generate karta hai.
4. Line item create karta hai aur inventory ko automatically decrement karta hai.
5. Naya generated `order_id` aur status message `OUT` parameters ke roop mein caller ko safely return karta hai.

```sql
USE sql_mastery;

DELIMITER //

CREATE PROCEDURE sp_process_order_checkout(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_new_order_id INT,
    OUT p_status_message VARCHAR(100)
)
BEGIN
    -- Local variables
    DECLARE v_current_stock INT;
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE v_total_cost DECIMAL(12, 2);

    -- Declare an exception handler for SQLEXCEPTION: rollback on any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_new_order_id = NULL;
        SET p_status_message = 'ERROR: Transaction rolled back due to internal database failure.';
    END;

    -- Step 1: Check product stock and price
    SELECT stock_quantity, unit_price
    INTO v_current_stock, v_unit_price
    FROM products
    WHERE product_id = p_product_id;

    -- Validate product existence
    IF v_unit_price IS NULL THEN
        SET p_new_order_id = NULL;
        SET p_status_message = 'REJECTED: Product does not exist.';
    -- Validate stock quantity
    ELSEIF v_current_stock < p_quantity THEN
        SET p_new_order_id = NULL;
        SET p_status_message = CONCAT('REJECTED: Insufficient stock. Only ', v_current_stock, ' available.');
    -- If valid, process the order
    ELSE
        -- Step 2: Begin Transaction
        START TRANSACTION;

        SET v_total_cost = v_unit_price * p_quantity;

        -- Insert Order
        INSERT INTO orders (customer_id, order_date, status, shipping_fee, total_amount)
        VALUES (p_customer_id, CURDATE(), 'Pending', 15.00, v_total_cost + 15.00);

        -- Capture auto-generated order_id
        SET p_new_order_id = LAST_INSERT_ID();

        -- Insert Line Item
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
        VALUES (p_new_order_id, p_product_id, p_quantity, v_unit_price, 0.00);

        -- Decrement stock
        UPDATE products
        SET stock_quantity = stock_quantity - p_quantity
        WHERE product_id = p_product_id;

        -- Commit changes
        COMMIT;

        SET p_status_message = 'SUCCESS: Order placed and inventory updated successfully.';
    END IF;

END //

DELIMITER ;
```

---

## 6. Step-by-Step Explanation (स्टेप-बाय-स्टेप व्याख्या)

Chaliye procedure ko test karke execution steps verify karte hain:

```sql
USE sql_mastery;

-- Test 1: Successful Order (Customer 1 orders 2 units of Product 3 TrueSound Headphones)
CALL sp_process_order_checkout(1, 3, 2, @order_id, @status_msg);

-- Inspect output parameters
SELECT @order_id AS generated_order_id, @status_msg AS execution_result;

-- Test 2: Insufficient Stock Rejection (Customer 1 tries to order 9999 units of Product 3)
CALL sp_process_order_checkout(1, 3, 9999, @failed_order_id, @failed_msg);

-- Inspect rejection output
SELECT @failed_order_id AS failed_order_id, @failed_msg AS rejection_reason;

-- Clean up demo order
DELETE FROM order_items WHERE order_id = @order_id;
DELETE FROM orders WHERE order_id = @order_id;
UPDATE products SET stock_quantity = stock_quantity + 2 WHERE product_id = 3;
DROP PROCEDURE sp_process_order_checkout;
```

---

## 7. Expected Result (अपेक्षित परिणाम)

Stored procedure call karne par terminal output:

```
mysql> SELECT @order_id AS generated_order_id, @status_msg AS execution_result;
+--------------------+---------------------------------------------------------------+
| generated_order_id | execution_result                                              |
+--------------------+---------------------------------------------------------------+
|               1011 | SUCCESS: Order placed and inventory updated successfully.     |
+--------------------+---------------------------------------------------------------+
1 row in set (0.01 sec)

mysql> SELECT @failed_order_id AS failed_order_id, @failed_msg AS rejection_reason;
+-----------------+----------------------------------------------------+
| failed_order_id | rejection_reason                                   |
+-----------------+----------------------------------------------------+
|            NULL | REJECTED: Insufficient stock. Only 118 available.  |
+-----------------+----------------------------------------------------+
1 row in set (0.00 sec)
```

---

## 8. Common Mistakes (सामान्य गलतियाँ और Pitfalls)

1. **`DELIMITER` ko Wapas Reset karna bhool jana**:
   * *Mistake*: `DELIMITER //` karke procedure compile kar liya aur aakhiri line mein `DELIMITER ;` run karna bhool gaye.
   * *Natija*: Iske baad aapki koi bhi aam query (jaise `SELECT * FROM employees;`) run nahi hogi aur terminal freeze hokar `//` symbol aane ka intezaar karta rahega!
2. **Variable Shadowing (Name Collisions ka Khatarnak Jaal)**:
   * *The Nightmare Trap*:
     ```sql
     CREATE PROCEDURE get_emp(IN employee_id INT)
     BEGIN
         SELECT * FROM employees WHERE employee_id = employee_id; -- AMBIGUOUS!
     END;
     ```
   * *Result*: MySQL parser `employee_id = employee_id` ko ek tautology (`WHERE 1 = 1`) samajh leta hai aur specific employee ke bajaye **company ke sabhi employees ka data ek sath return kar deta hai**! Massive security aur privacy leak!
   * *Rule*: Hamesha parameters ke aage `p_` lagayein (`p_employee_id`) aur local variables ke aage `v_` lagayein (`v_salary`).
3. **`DECLARE` Statements ko Galat Jagah Likhna**:
   * MySQL stored procedures mein sabhi `DECLARE` statements (variables, handlers, cursors) ko `BEGIN ... END` block ke **bilkul shuruat** mein likhna anivarya hota hai. Kisi bhi executable statement (jaise `SET` ya `SELECT`) ke baad `DECLARE` likhne par syntax error aata hai.

---

## 9. Best Practices (बेस्ट प्रैक्टिसेज)

1. **Strict Naming Conventions apnayein**:
   * Procedures ke aage `sp_` ya `usp_` lagayein.
   * Parameters ke aage hamesha `p_` aur local variables ke aage `v_` lagayein taaki column name collisions ka koi chance na rahe.
2. **Transactions ke sath hamesha Exception Handlers lagayein**:
   * Multi-statement transactional procedures mein hamesha `DECLARE EXIT HANDLER FOR SQLEXCEPTION` use karein taaki runtime error aane par uncommitted locks na fasein aur database automatically `ROLLBACK` ho jaye.
3. **Procedural Loops ke bajaye Set-Based SQL use karein**:
   * Beginners aksar row-by-row data process karne ke liye `WHILE` loops aur `CURSORS` likhne lagte hain. Relational database engines set-based operations (`UPDATE table SET col = ... WHERE ...`) par 100 guna zyada tez chalte hain. Loops ka prayog sirf tabhi karein jab koi task pure SQL mein solve karna namumkin ho.

---

## 10. Practice Questions (अभ्यास प्रश्न)

### Easy (सरल)
1. MySQL mein stored procedure banate waqt client `DELIMITER` ko change karna kyu zaroori hota hai?
2. `IN` parameter aur `OUT` parameter ke beech kya mukhya antar hai?
3. Kisi stored procedure ko execute karne ke liye kaun si SQL command use ki jaati hai?

### Medium (मध्यम)
4. `sp_update_product_price` naam ka ek stored procedure likhiye jo `p_product_id INT` aur `p_percentage_increase DECIMAL(4,2)` ko `IN` parameters ke roop mein le aur product ke `unit_price` ko us percentage se update kare.
5. Ek procedure `sp_get_customer_metrics` likhiye jo `customer_id` ko `IN` parameter ke roop mein le, aur customer ke total orders count ko ek `OUT` parameter mein aur total kharch (spend) ko doosre `OUT` parameter mein return kare.
6. Ek aisa stored procedure likhiye jo `WHILE` loop ka use karke kisi test table ke andar 5 test records sequentially insert kare.

### Difficult (कठिन)
7. Ek enterprise procedure `sp_transfer_department` likhiye jo kisi employee ko uske current department se naye department mein move kare, uska salary naye department ke average salary ke basis par update kare, aur is event ko ek audit table mein log kare. Is poore logic ko ek atomic transaction mein wrap kijiye jisme `EXIT HANDLER FOR SQLEXCEPTION` maujood ho.
8. MySQL stored procedures ke andar heavy business logic likhne aur wahi logic application backend service layer (jaise Go, Java, ya Python microservices) mein likhne ke beech kya architectural tradeoffs hote hain? Horizontal scaling par iska kya asar padta hai?

---

## 11. Interview Questions (इंटरव्यू सवाल और जवाब)

### Q1: Stored Procedures use karne ke mukhya fayde aur nuksan kya hain?
**Answer**:
* **Fayde (Advantages)**:
  1. **Reduced Network Traffic**: Multiple queries ko ek single network call (`CALL`) mein bundle karke application aur database ke beech latency khatam karta hai.
  2. **Security & Abstraction**: Users ko direct tables ka access diye bina sirf procedure execute karne ki permission di ja sakti hai (Principle of Least Privilege).
  3. **Centralized Logic**: Alag-alag platforms (web, mobile, backend services) ke liye business rules ek hi central jagah maintain hote hain.
* **Nuksan (Disadvantages)**:
  1. **Database CPU Load**: Heavy computations database server ke CPU ko consume karti hain. Database ko horizontally scale karna stateless app servers ko scale karne ke mukable bohot mushkil aur mehenga hota hai.
  2. **CI/CD & Version Control**: Stored procedures ke code ko version control, automated testing aur migration pipelines mein manage karna standard application code ke mukable zyada complex hota hai.
  3. **Vendor Lock-in**: Procedural SQL (MySQL PL/SQL, Oracle PL/SQL, SQL Server T-SQL) proprietary hoti hai aur ek database se dusre database par port nahi hoti.

### Q2: `IN`, `OUT`, aur `INOUT` parameters ke beech kya antar hota hai?
**Answer**:
* **`IN`**: Procedure ke andar data pass karta hai. Procedure is data ko read kar sakta hai lekin bahar caller ke variable ki original value ko overwrite nahi kar sakta.
* **`OUT`**: Ek khali variable procedure ke andar bheja jata hai. Procedure calculation karta hai aur result is variable mein assign karke caller ko return karta hai.
* **`INOUT`**: Ek initialized value procedure ke andar aati hai; procedure use read karta hai, modify karta hai, aur update ki gayi nayi value caller ko wapas return karta hai.

### Q3: Stored Procedure mein Variable Shadowing kya hoti hai aur isse kaise bacha jata hai?
**Answer**: Variable Shadowing tab hoti hai jab kisi procedure parameter ya local variable ka naam kisi table ke column name ke bilkul identical hota hai (jaise `WHERE employee_id = employee_id`). MySQL parser ye distinguish nahi kar pata ki column kaun sa hai aur variable kaun sa hai, aur wo clause ko har row ke liye `true` (`WHERE 1 = 1`) evaluate kar deta hai. Iska natija ye hota hai ki specific user ke bajaye table ka saara data accidentally update ya expose ho jata hai.
Isse bachne ka standard niyam ye hai ki sabhi parameters ke aage `p_` prefix (jaise `p_employee_id`) aur sabhi local variables ke aage `v_` prefix (jaise `v_salary`) lagana anivarya banaya jaye.

---

## 12. Quick Revision (क्विक रिविजन)

* Client terminal par early termination rokne ke liye procedure banate waqt **`DELIMITER //`** ka prayog karein.
* **`IN`** data andar lata hai, **`OUT`** result wapas bhejta hai, aur **`INOUT`** dono kaam karta hai.
* Sabhi **`DECLARE`** statements ko `BEGIN ... END` block ke bilkul top par likhein.
* Variable shadowing aur data corruption se bachne ke liye parameters ke aage **`p_`** aur variables ke aage **`v_`** lagayein.
* Runtime errors aane par transaction ko automatic rollback karne ke liye **`DECLARE EXIT HANDLER FOR SQLEXCEPTION`** ka use karein.
