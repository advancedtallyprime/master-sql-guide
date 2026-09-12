---
layout: home

hero:
  name: "Master SQL & MySQL Guide"
  text: "Production-Grade Database Engineering"
  tagline: "34 comprehensive modules, 300 practice exercises, 5 real-world projects, 150 interview questions, aur complete enterprise database sandbox — natural aur clear Roman Hinglish mein."
  actions:
    - theme: brand
      text: Browse Syllabus
      link: /hi/00_master_table_of_contents
    - theme: alt
      text: 300 Practice Exercises
      link: /hi/27_exercises
    - theme: alt
      text: SQL Cheat Sheet
      link: /hi/30_sql_cheat_sheet
    - theme: alt
      text: Learning Roadmaps
      link: /hi/31_learning_roadmaps

features:
  - icon: 🗄️
    title: Unified Enterprise Database (sql_mastery)
    details: Complete 9-table relational database sandbox jo E-commerce, HR, aur Supply Chain ke real data par based hai.
  - icon: ⚡
    title: Modern MySQL 8.0 & ANSI SQL
    details: Window functions, recursive CTEs, JSON operators, EXPLAIN ANALYZE, aur InnoDB concurrency locking ka deep-dive.
  - icon: 🎯
    title: 300 Tiered Practice Exercises
    details: Beginner, Intermediate, Advanced, aur Challenge levels ke 300 questions, complete SQL solutions aur detailed explanations ke sath.
  - icon: 💼
    title: 150 Interview Questions & 5 Projects
    details: Junior, Mid-level, aur Senior Database Architect interview questions aur 5 end-to-end production schemas.
---

## Curriculum Navigation Matrix

| Learning Track | Recommended Modules | Main Objective |
| :--- | :--- | :--- |
| **Foundations (Days 1–7)** | `01` se `10` tak | DDL, DML, Data Types, Constraints, 3VL Filtering, aur Aggregations mein master karein |
| **Relational & Queries (Days 8–15)** | `11` se `14` tak | Multi-table JOINs, Set operations (UNION), Subqueries, aur CTEs |
| **Architecture & Internals (Days 16–25)** | `15` se `25` tak | Schema design, 1NF se BCNF normalization, B+ Trees, Transactions, aur Optimization |
| **Career & Projects (Days 26–30)** | `26` se `33` tak | 5 complete projects, 300 exercises, 150 interview questions, aur production cheat sheets |

```sql
-- Hamare unified database se connect karein:
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
