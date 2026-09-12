import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Master SQL Guide",
  description: "Comprehensive, Production-Grade SQL & MySQL Learning Guide",
  cleanUrls: true,
  ignoreDeadLinks: true,
  themeConfig: {
    siteTitle: "SQL Mastery",
    search: {
      provider: 'local'
    },
    nav: [
      { text: 'Table of Contents', link: '/00_master_table_of_contents' },
      { text: 'Modules', link: '/01_sql_fundamentals' },
      { text: 'Projects', link: '/26_real_world_projects' },
      { text: '300 Exercises', link: '/27_exercises' },
      { text: 'Answer Key', link: '/28_answer_key' },
      { text: 'Interview Prep', link: '/29_interview_questions' },
      { text: 'Cheat Sheet', link: '/30_sql_cheat_sheet' },
      { text: 'Roadmaps', link: '/31_learning_roadmaps' },
      { text: 'A-Z Reference', link: '/33_az_sql_reference' }
    ],
    sidebar: [
      {
        text: 'Overview',
        items: [
          { text: 'Home & Syllabus', link: '/index' },
          { text: 'Master Table of Contents', link: '/00_master_table_of_contents' }
        ]
      },
      {
        text: 'Phase 1: Foundations',
        collapsed: false,
        items: [
          { text: '01. SQL & RDBMS Fundamentals', link: '/01_sql_fundamentals' },
          { text: '02. Database & Table Management', link: '/02_database_and_table_management' },
          { text: '03. Data Types & Storage', link: '/03_data_types' },
          { text: '04. Integrity Constraints', link: '/04_constraints' },
          { text: '05. CRUD Operations', link: '/05_crud_operations' }
        ]
      },
      {
        text: 'Phase 2: Querying & Analytics',
        collapsed: false,
        items: [
          { text: '06. SELECT & Filtering (3VL)', link: '/06_select_and_filtering' },
          { text: '07. Sorting & Keyset Pagination', link: '/07_sorting_and_limiting' },
          { text: '08. SQL Operators & Precedence', link: '/08_sql_operators' },
          { text: '09. Built-in Functions & CASE', link: '/09_sql_functions' },
          { text: '10. GROUP BY, HAVING & Rollup', link: '/10_group_by_and_having' }
        ]
      },
      {
        text: 'Phase 3: Relational Modeling & Joins',
        collapsed: false,
        items: [
          { text: '11. JOIN Operations & Venn Analysis', link: '/11_joins' },
          { text: '12. Set Operations (UNION)', link: '/12_union' },
          { text: '13. Subqueries & CTEs', link: '/13_subqueries' },
          { text: '14. Keys, Cardinality & Junctions', link: '/14_keys_and_relationships' }
        ]
      },
      {
        text: 'Phase 4: Schema Architecture',
        collapsed: false,
        items: [
          { text: '15. Database Design & ER Modeling', link: '/15_database_design' },
          { text: '16. Normalization (1NF to BCNF)', link: '/16_normalization' },
          { text: '17. Views & Security Abstraction', link: '/17_views' }
        ]
      },
      {
        text: 'Phase 5: Engines, Concurrency & Programmability',
        collapsed: false,
        items: [
          { text: '18. Indexes & B+ Tree Internals', link: '/18_indexes' },
          { text: '19. Transactions, ACID & Locking', link: '/19_transactions' },
          { text: '20. Stored Procedures & Control Flow', link: '/20_stored_procedures' },
          { text: '21. User-Defined Functions (UDFs)', link: '/21_functions' },
          { text: '22. Triggers & Real-time Auditing', link: '/22_triggers' }
        ]
      },
      {
        text: 'Phase 6: Advanced SQL & Production Tuning',
        collapsed: false,
        items: [
          { text: '23. Window Functions & JSON', link: '/23_advanced_sql' },
          { text: '24. Query Optimization & EXPLAIN', link: '/24_query_optimization' },
          { text: '25. Security, RBAC & Backup Ops', link: '/25_security_and_best_practices' }
        ]
      },
      {
        text: 'Phase 7: Portfolio, Practice & Career',
        collapsed: false,
        items: [
          { text: '26. 5 Real-World Enterprise Projects', link: '/26_real_world_projects' },
          { text: '27. 300 Progressive Exercises', link: '/27_exercises' },
          { text: '28. Comprehensive Answer Key', link: '/28_answer_key' },
          { text: '29. 150 Interview Questions', link: '/29_interview_questions' }
        ]
      },
      {
        text: 'Phase 8: Toolkits & Reference',
        collapsed: false,
        items: [
          { text: '30. SQL & MySQL Cheat Sheet', link: '/30_sql_cheat_sheet' },
          { text: '31. 7, 14, 30, 60-Day Roadmaps', link: '/31_learning_roadmaps' },
          { text: '32. Final Revision Checkpoints', link: '/32_final_revision_guide' },
          { text: '33. A–Z SQL Lexicon Reference', link: '/33_az_sql_reference' }
        ]
      }
    ]
  }
})
