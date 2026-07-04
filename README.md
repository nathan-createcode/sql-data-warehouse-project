# Data Warehouse & Analytics — Portfolio Project

A personal data engineering portfolio project, evolving from a single SQL Server implementation into a multi-stack showcase of the same Medallion Architecture (Bronze → Silver → Gold) data warehouse, rebuilt using different tools as I learn them.

The goal isn't to compare tools for their own sake, but to demonstrate the same core data engineering concepts — layered architecture, data cleansing, star schema modeling, testing, and documentation — implemented across different parts of the modern data stack.

---

## Implementations

| Version | Stack | Status | Folder |
|---|---|---|---|
| v1 | SQL Server, T-SQL stored procedures | ✅ Complete (legacy) | [`warehouse-sql-server/`](./warehouse-sql-server) |
| v2 | Python (ingestion) + dbt + PostgreSQL | ✅ Complete (current) | [`warehouse-dbt-postgres/`](./warehouse-dbt-postgres) |
| v3 | PySpark / Databricks | 🔜 Planned | — |
| v4 | Apache Airflow (orchestration) | 🔜 Planned | — |
| v5 | AWS (S3, Glue, Redshift) | 🔜 Planned | — |

Each folder is self-contained with its own README, setup instructions, and documentation.

---

## Why This Structure

Rather than starting a new repository for every new tool learned, this project intentionally keeps every version in one place. It's meant to show a progression, not just a snapshot: the same problem (build a data warehouse from raw CRM/ERP CSVs, model it into a star schema, make it analytics-ready), solved and re-solved as new skills are picked up.

## Data Source & Attribution

This project uses a sample CRM/ERP dataset originally provided as part of the "SQL Data Warehouse" course by Data With Baraa, used here strictly for personal learning and portfolio purposes. Raw dataset files are not included in this repository (see `.gitignore`) as they are third-party learning material.

All transformation logic, pipeline code, testing, and documentation across every version in this repository are original work.

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## ⭐ About Me

Hi, I'm **Nathan Maulana Achmadi** — a student and data engineering enthusiast, currently learning cloud systems and modern data architecture.