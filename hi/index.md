---
layout: home

hero:
  name: "Master SQL & MySQL Guide"
  text: "Production-Grade Database Engineering"
  tagline: "34 विस्तृत मॉड्यूल्स, 300 प्रैक्टिस एक्सरसाइज, 5 रियल-वर्ल्ड प्रोजेक्ट्स, 150 इंटरव्यू सवाल, और कम्पलीट एंटरप्राइज सैंडबॉक्स — आसान और स्पष्ट हिंग्लिश (Hinglish) में।"
  actions:
    - theme: brand
      text: पूरा सिलेबस देखें
      link: /hi/00_master_table_of_contents
    - theme: alt
      text: 300 प्रैक्टिस प्रश्न
      link: /hi/27_exercises
    - theme: alt
      text: SQL चीट शीट
      link: /hi/30_sql_cheat_sheet
    - theme: alt
      text: लर्निंग रोडमैप्स
      link: /hi/31_learning_roadmaps

features:
  - icon: 🗄️
    title: यूनिफाइड एंटरप्राइज डेटाबेस (Unified Sandbox)
    details: पूरा 9-टेबल रिलेशनल डेटाबेस (sql_mastery) जो ई-कॉमर्स, एचआर, और सप्लाई-चेन के रियल डेटा पर आधारित है।
  - icon: ⚡
    title: मॉडर्न MySQL 8.0 और ANSI SQL
    details: Window functions, recursive CTEs, JSON operators, EXPLAIN ANALYZE, और InnoDB concurrency लॉकिंग का डीप-डाइव।
  - icon: 🎯
    title: 300 ग्रेडेड प्रैक्टिस सवाल (Tiered Exercises)
    details: Beginner, Intermediate, Advanced, और Challenge स्तर के 300 प्रश्न, पूरे SQL समाधान और विस्तृत व्याख्या के साथ।
  - icon: 💼
    title: 150 इंटरव्यू सवाल और 5 लाइव प्रोजेक्ट्स
    details: Junior, Mid-level, और Senior Database Architect इंटरव्यू सवाल और 5 एंड-टू-एंड प्रोडक्शन स्कीमा।
---

## पाठ्यक्रम नेविगेशन (Curriculum Navigation)

| लर्निंग ट्रैक | रेकमेंडेड मॉड्यूल्स | मुख्य उद्देश्य |
| :--- | :--- | :--- |
| **फाउंडेशन (Days 1–7)** | `01` से `10` तक | DDL, DML, Data Types, Constraints, 3VL Filtering, और Aggregations में महारत |
| **रिलेशनल और क्वेरीज (Days 8–15)** | `11` से `14` तक | Multi-table JOINs, Set operations (UNION), Subqueries, और CTEs |
| **आर्किटेक्चर और इंटरनल्स (Days 16–25)** | `15` से `25` तक | स्कीमा डिज़ाइन, 1NF से BCNF नॉर्मलाइजेशन, B+ Trees, ट्रांजेक्शन्स, और ऑप्टिमाइज़ेशन |
| **करियर और प्रोजेक्ट्स (Days 26–30)** | `26` से `33` तक | 5 पूरे प्रोजेक्ट्स, 300 सवाल, 150 इंटरव्यू सवाल, और प्रोडक्शन चीट शीट्स |

```sql
-- हमारे यूनिफाइड डेटाबेस से जुड़ें:
USE sql_mastery;

SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_headcount,
    ROUND(AVG(e.salary), 2) AS avg_department_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_department_salary DESC;
```
