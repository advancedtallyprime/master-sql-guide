# Master SQL & MySQL Learning Guide (Roman Hinglish Edition)

[![SQL](https://img.shields.io/badge/SQL-ANSI%20%7C%20MySQL%208.0-blue.svg)](https://dev.mysql.com/doc/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](/LICENSE)
[![VitePress](https://img.shields.io/badge/Docs-VitePress-indigo.svg)](https://vitepress.dev/)

Comprehensive, production-grade SQL & MySQL master curriculum natural Roman Hinglish mein engineered kiya gaya hai software engineers, data analysts, database administrators, aur technical interview candidates ke liye.

---

## Highlights

- **Unified Relational Sandbox (`sql_mastery`)**: Saare 34 modules, 300 practice exercises, aur queries ek unified 9-table enterprise database par chalte hain jo E-commerce, Human Resources, aur Supply Chain cover karta hai.
- **Enterprise Curriculum (34 Modules)**: RDBMS storage engines (InnoDB vs MyISAM), B+ Tree indexing, aur 1NF–BCNF normalization se lekar Recursive CTEs, Window Functions, aur `EXPLAIN ANALYZE` optimization tak.
- **300 Tiered Exercises + Complete Solutions**: 10 sections with Beginner, Intermediate, Advanced, aur Challenge questions verified SQL queries aur execution explanations ke sath.
- **150 Technical Interview Questions**: Junior, Mid-level, aur Senior Architect levels mein categorized.
- **5 Full-Scale Production Projects**: Student Information Portal, Enterprise HR System, Multi-Warehouse Inventory System, E-Commerce Platform, aur Dimensional Sales Data Mart.
- **Production Reference & Toolkits**: High-yield SQL Cheat Sheet, 7/14/30/60-Day Structured Study Roadmaps, Revision Checkpoints, aur exhaustive A–Z SQL Lexicon.

---

## Database Setup (`sql_mastery`)

Complete schema aur seed data ko apne MySQL 8.0+ server mein run karein:

```bash
mysql -u root -p < sql_mastery_schema.sql
```

```sql
USE sql_mastery;
SHOW TABLES;
```

---

## Local Documentation Server

```bash
# Dependencies install karein
npm install

# Local preview server start karein
npm run docs:dev

# Production static website build karein
npm run docs:build
```
