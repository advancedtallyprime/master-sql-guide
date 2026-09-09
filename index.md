---
layout: home

hero:
  name: "Master SQL & MySQL Guide"
  text: "Production-Grade Database Engineering"
  tagline: "34 comprehensive modules, 300 practice exercises, 5 real-world systems, 150 interview questions, and a unified enterprise sandbox."
  actions:
    - theme: brand
      text: Browse Syllabus
      link: /00_master_table_of_contents
    - theme: alt
      text: 300 Practice Exercises
      link: /27_exercises
    - theme: alt
      text: Production Cheat Sheet
      link: /30_sql_cheat_sheet
    - theme: alt
      text: Learning Roadmaps
      link: /31_learning_roadmaps

features:
  - icon: 🗄️
    title: Unified Enterprise Database
    details: Complete 9-table relational sandbox (sql_mastery) with realistic enterprise seed data covering E-commerce, HR, and Supply Chain.
  - icon: ⚡
    title: Modern MySQL 8.0 & ANSI SQL
    details: Window functions, recursive CTEs, JSON operators, EXPLAIN ANALYZE, and InnoDB concurrency locking internals.
  - icon: 🎯
    title: 300 Tiered Practice Exercises
    details: 10 Beginner, 10 Intermediate, 5 Advanced, and 5 Challenge problems across 10 modules with complete query solutions.
  - icon: 💼
    title: 150 Interview Questions & 5 Projects
    details: Junior, Mid-level, and Senior architect interview questions with in-depth answers plus 5 end-to-end portfolio schemas.
---

## Curriculum Navigation Matrix

| Learning Track | Recommended Modules | Objective |
| :--- | :--- | :--- |
| **Foundations (Days 1–7)** | `01` through `10` | Master DDL, DML, Data Types, Constraints, 3VL Filtering, and Aggregations |
| **Relational & Queries (Days 8–15)** | `11` through `14` | Complex multi-table JOINs, Set operations, Subqueries, and CTEs |
| **Architecture & Internals (Days 16–25)** | `15` through `25` | Schema design, 1NF–BCNF normalization, B+ Trees, Transactions, and Optimizer tuning |
| **Career & Projects (Days 26–30)** | `26` through `33` | 5 complete projects, 300 exercises, 150 interview questions, and production cheat sheets |

```sql
-- Connect to the unified sandbox:
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
