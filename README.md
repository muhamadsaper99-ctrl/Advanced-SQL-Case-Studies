# Advanced SQL Case Studies

## Overview

This repository showcases advanced SQL solutions designed to solve real-world business problems and demonstrate database programming concepts using Microsoft SQL Server.

The project combines analytical SQL techniques with database development practices, covering customer analytics, revenue analysis, inventory management, and examination management systems.

## Project Structure

```text
Advanced-SQL-Case-Studies
│
├── database
│   └── BikeStores.bak
│
├── schemas
│   ├── BikeStores_Schema.png
│   └── ExamGenerator_Schema.png
│
├── scripts
│   ├── 01_Business_Case_Studies.sql
│   ├── 02_Advanced_Analytics.sql
│   ├── 03_Exam_Generator.sql
│   └── 04_Exam_Correction.sql
│
└── README.md
```

## Databases Used

### BikeStores Database

Used for solving analytical business scenarios including:

* Customer Analytics
* Revenue Analysis
* Product Performance Analysis
* Inventory Insights
* Store Performance Evaluation

### ITI_PRO Database (Generated Database)

A custom database designed to simulate an examination management system.

Features include:

* Exam Generation
* Random Question Selection
* Student Exam Assignment
* Automatic Exam Correction
* Grade Calculation

## Database Schemas

Schema diagrams for all databases used in this project are available in the `schemas` folder.

These diagrams help understand:

* Table Relationships
* Primary Keys
* Foreign Keys
* Database Structure

## Project Modules

### 1. Business Case Studies

A collection of advanced SQL business scenarios designed to improve analytical thinking and SQL problem-solving skills.

Example topics:

* Customers who ordered from every store
* Revenue contribution by category
* Product purchasing patterns
* Inventory analysis
* Store performance tracking

### 2. Advanced Analytics

Advanced SQL challenges utilizing:

* Common Table Expressions (CTEs)
* Window Functions
* Ranking Functions
* Running Totals
* Revenue Contribution Analysis
* Performance Gap Calculations

### 3. Exam Generator

A stored procedure that automatically generates exams by selecting randomized questions from the database.

Key concepts demonstrated:

* Stored Procedures
* Dynamic Logic
* Random Question Selection
* Business Rule Implementation

### 4. Exam Correction

A stored procedure that evaluates student answers and calculates final scores automatically.

Key concepts demonstrated:

* Cursor Operations
* Automatic Answer Validation
* Grade Calculation
* Error Handling
* Result Generation

## Advanced SQL Concepts Demonstrated

### Query Techniques

* Complex Joins
* Nested Queries
* Correlated Subqueries
* Aggregations
* Conditional Logic

### Common Table Expressions (CTEs)

```sql
WITH CTE AS (...)
```

### Window Functions

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
LAG()
LEAD()
SUM() OVER()
```

### Database Programming

```sql
Stored Procedures
Cursors
TRY...CATCH
Transactions
```

## Example Business Questions Solved

* Which customers have purchased from every store?
* Which categories contribute more than 20% of total revenue?
* Which products are frequently purchased together?
* Which store has the fastest shipping performance?
* Which categories have inventory but no recent sales?
* How can exams be generated dynamically from a question bank?
* How can student exams be graded automatically?

## Database Setup

### Restore BikeStores Database

1. Download the backup file from the `database` folder.
2. Restore the database using SQL Server Management Studio (SSMS).
3. Execute the SQL scripts inside the `scripts` folder.

## Technologies Used

* Microsoft SQL Server
* T-SQL
* SQL Server Management Studio (SSMS)

## Learning Outcomes

Through these projects, I strengthened my skills in:

* Writing advanced SQL queries
* Solving real-world business problems
* Database design analysis
* Developing stored procedures
* Working with cursors
* Implementing automated database solutions
* Using analytical SQL for decision-making

## Author

Mohamed Saber

Data Analyst | Data Engineer | SQL Developer
```
```
