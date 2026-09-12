import { defineConfig } from 'vitepress'

const englishSidebar = [
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
];

const hinglishSidebar = [
  {
    text: 'Overview (अवलोकन)',
    items: [
      { text: 'Home & Syllabus (होम)', link: '/hi/index' },
      { text: 'Master Table of Contents (विषय सूची)', link: '/hi/00_master_table_of_contents' }
    ]
  },
  {
    text: 'Phase 1: Foundations (बुनियादी बातें)',
    collapsed: false,
    items: [
      { text: '01. SQL & RDBMS Fundamentals', link: '/hi/01_sql_fundamentals' },
      { text: '02. Database & Table Management', link: '/hi/02_database_and_table_management' },
      { text: '03. Data Types & Storage', link: '/hi/03_data_types' },
      { text: '04. Integrity Constraints', link: '/hi/04_constraints' },
      { text: '05. CRUD Operations (Insert, Update, Delete)', link: '/hi/05_crud_operations' }
    ]
  },
  {
    text: 'Phase 2: Querying & Analytics (डेटा विश्लेषण)',
    collapsed: false,
    items: [
      { text: '06. SELECT & Filtering (3VL Logic)', link: '/hi/06_select_and_filtering' },
      { text: '07. Sorting & Keyset Pagination', link: '/hi/07_sorting_and_limiting' },
      { text: '08. SQL Operators & Precedence', link: '/hi/08_sql_operators' },
      { text: '09. Built-in Functions & CASE', link: '/hi/09_sql_functions' },
      { text: '10. GROUP BY, HAVING & Rollup', link: '/hi/10_group_by_and_having' }
    ]
  },
  {
    text: 'Phase 3: Relational Modeling & Joins (टेबल संबंध)',
    collapsed: false,
    items: [
      { text: '11. JOIN Operations & Venn Diagrams', link: '/hi/11_joins' },
      { text: '12. Set Operations (UNION & UNION ALL)', link: '/hi/12_union' },
      { text: '13. Subqueries & CTEs (WITH Clause)', link: '/hi/13_subqueries' },
      { text: '14. Keys, Cardinality & Junction Tables', link: '/hi/14_keys_and_relationships' }
    ]
  },
  {
    text: 'Phase 4: Schema Architecture (डेटाबेस डिज़ाइन)',
    collapsed: false,
    items: [
      { text: '15. Database Design & ER Modeling', link: '/hi/15_database_design' },
      { text: '16. Normalization (1NF se BCNF tak)', link: '/hi/16_normalization' },
      { text: '17. Views & Security Abstraction', link: '/hi/17_views' }
    ]
  },
  {
    text: 'Phase 5: Engines & Transactions (ट्रांजेक्शन और स्टोरेज)',
    collapsed: false,
    items: [
      { text: '18. Indexes & B+ Tree Internals', link: '/hi/18_indexes' },
      { text: '19. Transactions, ACID & Row Locking', link: '/hi/19_transactions' },
      { text: '20. Stored Procedures & Control Flow', link: '/hi/20_stored_procedures' },
      { text: '21. User-Defined Functions (UDFs)', link: '/hi/21_functions' },
      { text: '22. Triggers & Real-time Audit Logs', link: '/hi/22_triggers' }
    ]
  },
  {
    text: 'Phase 6: Advanced SQL & Performance (एडवांस्ड और ऑप्टिमाइज़ेशन)',
    collapsed: false,
    items: [
      { text: '23. Window Functions & JSON Support', link: '/hi/23_advanced_sql' },
      { text: '24. Query Optimization & EXPLAIN ANALYZE', link: '/hi/24_query_optimization' },
      { text: '25. Security, RBAC Roles & mysqldump', link: '/hi/25_security_and_best_practices' }
    ]
  },
  {
    text: 'Phase 7: Portfolio & Practice (प्रोजेक्ट्स और अभ्यास)',
    collapsed: false,
    items: [
      { text: '26. 5 Real-World Enterprise Projects', link: '/hi/26_real_world_projects' },
      { text: '27. 300 Progressive Exercises', link: '/hi/27_exercises' },
      { text: '28. Comprehensive Answer Key', link: '/hi/28_answer_key' },
      { text: '29. 150 Interview Questions & Answers', link: '/hi/29_interview_questions' }
    ]
  },
  {
    text: 'Phase 8: Toolkits & Reference (टूलकिट और संदर्भ)',
    collapsed: false,
    items: [
      { text: '30. Production SQL Cheat Sheet', link: '/hi/30_sql_cheat_sheet' },
      { text: '31. 7, 14, 30, 60-Day Roadmaps', link: '/hi/31_learning_roadmaps' },
      { text: '32. Final Revision Checkpoints & Quizzes', link: '/hi/32_final_revision_guide' },
      { text: '33. A–Z SQL Lexicon Reference', link: '/hi/33_az_sql_reference' }
    ]
  }
];

export default defineConfig({
  title: "Master SQL Guide",
  description: "Comprehensive, Production-Grade SQL & MySQL Learning Guide",
  cleanUrls: true,
  ignoreDeadLinks: true,

  locales: {
    root: {
      label: 'English',
      lang: 'en-US',
      title: "Master SQL Guide",
      description: "Comprehensive, Production-Grade SQL & MySQL Learning Guide",
      themeConfig: {
        siteTitle: "SQL Mastery",
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
        sidebar: englishSidebar
      }
    },
    hi: {
      label: 'Hinglish (हिंदी)',
      lang: 'hi-IN',
      link: '/hi/',
      title: "Master SQL Guide (Hinglish)",
      description: "Complete SQL & MySQL Course in Simple Hinglish",
      themeConfig: {
        siteTitle: "SQL Mastery (Hinglish)",
        nav: [
          { text: 'विषय सूची', link: '/hi/00_master_table_of_contents' },
          { text: 'मॉड्यूल्स', link: '/hi/01_sql_fundamentals' },
          { text: 'प्रोजेक्ट्स', link: '/hi/26_real_world_projects' },
          { text: '300 अभ्यास प्रश्न', link: '/hi/27_exercises' },
          { text: 'उत्तर कुंजी (Answers)', link: '/hi/28_answer_key' },
          { text: 'इंटरव्यू प्रश्न', link: '/hi/29_interview_questions' },
          { text: 'चीट शीट', link: '/hi/30_sql_cheat_sheet' },
          { text: 'रोडमैप', link: '/hi/31_learning_roadmaps' },
          { text: 'A-Z संदर्भ', link: '/hi/33_az_sql_reference' }
        ],
        sidebar: hinglishSidebar
      }
    }
  },

  themeConfig: {
    search: {
      provider: 'local'
    }
  }
})
