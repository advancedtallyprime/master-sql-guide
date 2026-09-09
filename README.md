# Master SQL & MySQL Learning Guide

[![SQL](https://img.shields.io/badge/SQL-ANSI%20%7C%20MySQL%208.0-blue.svg)](https://dev.mysql.com/doc/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![VitePress](https://img.shields.io/badge/Docs-VitePress-indigo.svg)](https://vitepress.dev/)

A comprehensive, production-grade SQL & MySQL master curriculum synthesized and engineered for software engineers, data analysts, database administrators, and technical interview candidates.

---

## 🌟 Highlights

- **Unified Relational Sandbox (`sql_mastery`)**: All 34 modules, 300 practice exercises, and queries run on a unified 9-table enterprise database covering E-commerce, Human Resources, and Supply Chain.
- **Enterprise Curriculum (34 Modules)**: From RDBMS storage engines (InnoDB vs MyISAM), B+ Tree indexing, and 1NF–BCNF normalization to Recursive CTEs, Window Functions, and `EXPLAIN ANALYZE` optimization.
- **300 Tiered Exercises + Complete Solutions**: 10 sections with Beginner, Intermediate, Advanced, and Challenge questions with verified SQL queries and execution explanations.
- **150 Technical Interview Questions**: Categorized across Junior, Mid-level, and Senior Architect levels.
- **5 Full-Scale Production Projects**: Student Information Portal, Enterprise HR System, Multi-Warehouse Inventory System, E-Commerce Platform, and Dimensional Sales Data Mart.
- **Production Reference & Toolkits**: High-yield SQL Cheat Sheet, 7/14/30/60-Day Structured Study Roadmaps, Revision Checkpoints, and exhaustive A–Z SQL Lexicon.

---

## 🗄️ Database Setup (`sql_mastery`)

Stand up the complete schema and seed data in your MySQL 8.0+ server:

```bash
mysql -u root -p < sql_mastery_schema.sql
```

```sql
USE sql_mastery;
SHOW TABLES;
```

---

## 📖 Curriculum Structure

| Phase | Modules | Topics Covered |
| :--- | :--- | :--- |
| **Phase 1: Foundations** | `01` – `05` | SQL Architecture, Databases & Tables, Storage Data Types, Integrity Constraints, Full CRUD & UPSERT |
| **Phase 2: Querying & Analytics** | `06` – `10` | Three-Valued Logic (3VL), Keyset vs Offset Pagination, Operators, Built-in Functions, GROUP BY, HAVING, WITH ROLLUP |
| **Phase 3: Relational & Joins** | `11` – `14` | INNER, LEFT, RIGHT, FULL OUTER emulation, Self JOINs, UNION ALL, Correlated Subqueries, Recursive CTEs, Cardinality |
| **Phase 4: Schema Architecture** | `15` – `17` | Conceptual/Logical/Physical ER Modeling, 1NF to BCNF Normalization, Intentional Denormalization, Views & Security Abstraction |
| **Phase 5: Engines & Concurrency** | `18` – `22` | B+ Tree Internals, Clustered/Secondary Indexes, ACID Transactions, Isolation Levels, Next-Key Locks, Stored Procedures, UDFs, Triggers |
| **Phase 6: Advanced & Optimization** | `23` – `25` | Window Functions (`ROW_NUMBER`, `RANK`, `LEAD`, `LAG`), JSON Operators (`->`, `->>`), Cost-Based Optimizer, `EXPLAIN ANALYZE`, RBAC Security |
| **Phase 7: Projects & Practice** | `26` – `28` | 5 Real-World Enterprise Systems, 300 Tiered Practice Exercises, Comprehensive Answer Key |
| **Phase 8: Career & Toolkits** | `29` – `33` | 150 Interview Questions, Production Cheat Sheet, 7/14/30/60-Day Roadmaps, Final Revision Guide, A–Z SQL Lexicon |

---

## 🚀 Running Documentation Site Locally

```bash
# Install dependencies
npm install

# Start local preview server
npm run docs:dev

# Build production static website
npm run docs:build
```

---

## 📄 License
MIT License. Free to use for personal, academic, and enterprise learning.
