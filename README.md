<div align="center">

# 🚀 KICKSTARTER CROWDFUNDING DATA ANALYSIS

### *Uncovering What Makes a Crowdfunding Campaign Succeed*

<br>

<br>

[![Tableau Live](https://img.shields.io/badge/🔴%20LIVE-Tableau%20Dashboard-E97627?style=for-the-badge)](https://public.tableau.com/app/profile/bibha.kumari/viz/crowdfunding_tableauDashboard/CROWDFUNDINGDASHBOARD)
[![Power BI Live](https://img.shields.io/badge/🟡%20LIVE-Power%20BI%20Dashboard-F2C811?style=for-the-badge)](https://app.powerbi.com/groups/me/reports/ab0fd8ee-ffb5-48e9-a2aa-3750c6f334a7/01e9bf483c23c125b203?experience=power-bi)

<br>

</div>

---

<div align="center">

## 📊 PROJECT AT A GLANCE

| 📁 Total Projects | ✅ Successful | 📈 Success Rate | 💰 Amount Raised | 👥 Backers | ⏱️ Avg Days |
|:-:|:-:|:-:|:-:|:-:|:-:|
| **366K** | **140K** | **38%** | **$3.48 Bn** | **40M** | **32 Days** |

</div>

---

## 📌 About This Project

> **Kickstarter** is one of the world's largest crowdfunding platforms, connecting creative entrepreneurs with backers who fund their ideas.

This project performs an **end-to-end data analysis** of a real Kickstarter dataset spanning **2009–2019**, covering **366,000+ projects** across 10 categories and multiple countries. The analysis was built across four industry-standard tools to demonstrate versatility and depth.

**The core question this project answers:**
> *What separates a successful Kickstarter campaign from one that fails — and what can data tell us about how to improve those odds?*

---

## 📁 Repository Structure

```
📦 Kickstarter-Crowdfunding-Analysis
 ┣ 📂 SQL
 ┃ ┗ 📄 QUERIES.sql               → All transformation & analysis queries
 ┣ 📂 Excel
 ┃ ┗ 📄 Kickstarter.xlsx          → Cleaned data, calendar table, pivot KPIs & charts
 ┣ 📂 PowerBI
 ┃ ┗ 📄 Kickstarter.pbix          → Star schema model and DAX measures
 ┣ 📂 Tableau
 ┃ ┗ 📄 Kickstarter.twbx          → Calculated fields & interactive dashboard
 ┣ 📂 data
 ┃ ┗ 📄 sample_data.csv           → Sample 500-row dataset
 ┣ 📂 screenshots
 ┃ ┣ 🖼️ excel_dashboard.png
 ┃ ┣ 🖼️ tableau_dashboard.png
 ┃ ┗ 🖼️ powerbi_dashboard.png
 ┗ 📄 README.md
```

---

## 🎯 Project Objectives

- [x] Convert all **Epoch timestamp** fields to human-readable dates
- [x] Build a **Calendar / Date dimension** table from `created_at`
- [x] Build a **Star Schema** data model across all source files
- [x] Convert goal amounts to **USD** using a static exchange rate
- [x] Report KPIs — total projects, success %, amount raised, backers, avg days
- [x] Identify **top successful projects** by backers and amount raised
- [x] Analyse success rates by **category, goal range, year, and location**

---

## 🔄 Project Workflow

```
Raw CSV Data
     │
     ▼
┌─────────────────────────────┐
│  1. Data Import & Cleaning  │  Handle nulls, standardise types
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  2. Epoch Time Conversion   │  Unix → human-readable DATE fields
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  3. Calendar Table          │  FM / FQ financial calendar via CTE
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  4. Star Schema Modeling    │  Fact + 3 Dimension tables
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  5. KPI Development         │  DAX, Calculated Fields, Pivot KPIs
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  6. Dashboard & Visuals     │  Excel · Power BI · Tableau
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  7. Insights & Findings     │  Data-backed business recommendations
└─────────────────────────────┘
```

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|:--|:--|
| **Microsoft Excel** | Data cleaning, calendar table, pivot KPIs, chart visualisations |
| **SQL (MySQL)** | Epoch conversion, recursive CTE calendar, conditional aggregation |
| **Power BI** | Star schema model, DAX measures, interactive dashboard |
| **Tableau** | Calculated fields, geographic mapping, visual storytelling |

---

## 🗄️ Dataset & Data Model

### Source Tables

| Table | Type | Key Columns |
|:--|:--|:--|
| `Crowdfunding_projects` | ⭐ Fact Table | id, goal, usd_pledged, state, backers_count, timestamps |
| `Crowdfunding_Category` | 📋 Dimension | id, name, parent_category |
| `Crowdfunding_Location` | 📋 Dimension | id, displayable_name, country |
| `Crowdfunding_Creator` | 📋 Dimension | id, creator details |
| `Calendar` | 📅 Date Dimension | dt, year, month, FM, FQ (built via SQL) |

### Star Schema Relationships

```
                    ┌──────────────────┐
                    │  crowdfunding_   │
                    │    Category      │
                    └────────┬─────────┘
                             │ category_id
                             │
┌──────────┐    location_id  │   created_date    ┌──────────┐
│ Location │◄───────────────►│◄──────────────────│ Calendar │
└──────────┘                 │                   └──────────┘
                    ┌────────┴─────────┐
                    │    projects      │
                    │  (Fact Table)    │
                    └──────────────────┘
```

---

## 🔧 Data Transformations

### ⏰ Epoch to Date Conversion

All 6 date columns were stored as Unix timestamps and converted to readable `DATE` values:

| Tool | Formula Used |
|:--|:--|
| **Excel** | `(epoch / 86400) + DATE(1970,1,1)` |
| **SQL** | `DATE(FROM_UNIXTIME(epoch_column))` |
| **Power BI** | `#datetime(1970,1,1,0,0,0) + #duration(0,0,0,epoch)` |
| **Tableau** | `DATEADD('second', [epoch], #1970-01-01#)` |

### 📅 Financial Calendar Logic

| Financial Month | Financial Quarter | Actual Calendar Months |
|:-:|:-:|:--|
| FM1 – FM3 | **FQ-1** | April → June |
| FM4 – FM6 | **FQ-2** | July → September |
| FM7 – FM9 | **FQ-3** | October → December |
| FM10 – FM12 | **FQ-4** | January → March |

### 💱 Currency Conversion

The `static_usd_rate` column was used to standardise all goal amounts to USD across all tools:

| Tool | Formula |
|:--|:--|
| **Excel** | `= goal * static_usd_rate` |
| **SQL** | `goal * static_usd_rate AS goal_usd` |
| **Power BI (DAX)** | `Goal in USD = [goal] * [static_usd_rate]` |
| **Tableau** | `[goal] * [static_usd_rate]` |

---

## 💻 SQL — What Was Built

> 📄 **Full script:** [`/SQL/QUERIES.sql`](./SQL/QUERIES.sql)
>
> All queries written and tested in **MySQL**

| # | Query | Technique Used | Output |
|:-:|:--|:--|:--|
| Q1 | Epoch → Date Conversion | `FROM_UNIXTIME()`, `ALTER TABLE`, `UPDATE` | 6 new DATE columns |
| Q2 | Calendar Dimension Table | **Recursive CTE**, financial month logic | Full date dimension |
| Q3 | Star Schema Validation | Multi-table `LEFT JOIN` | Unified analytical view |
| Q4 | Goal → USD | Column multiplication | Standardised goal amounts |
| Q5 | Projects by Outcome / Location / Category | `GROUP BY`, `ORDER BY` | Distribution breakdown |
| Q6 | Successful Projects KPIs | **Conditional aggregation** (`CASE WHEN` in `SUM`/`AVG`) | 4 headline KPIs |
| Q7 | Top 10 Projects | `WHERE`, `ORDER BY DESC`, `LIMIT` | Ranked project lists |
| Q8 | Success Rate Analysis | **CASE bucketing subquery**, % calculation | Success % by 4 dimensions |

---

## 📊 Dashboard Previews

### 📗 Excel Dashboard

![Excel Dashboard](https://github.com/bbhakumari123/Kickstarter_Crowdfunding_analysis/blob/49c6f1102b8de2da7fab8a7fa823564d221f5d1e/Kickstarter_crowdfunding_Analysis/SCREENSHOT/Excel_Dashboard.png)

<br>

### 📙 Tableau Dashboard

> 🔴 **[Click to view the live interactive dashboard →](https://public.tableau.com/app/profile/bibha.kumari/viz/crowdfunding_tableauDashboard/CROWDFUNDINGDASHBOARD)**

![Tableau Dashboard](screenshots/tableau_dashboard.png)

<br>

### 📘 Power BI Dashboard

> 🟡 **[Click to view the live interactive dashboard →](https://app.powerbi.com/groups/me/reports/ab0fd8ee-ffb5-48e9-a2aa-3750c6f334a7/01e9bf483c23c125b203?experience=power-bi)**

![Power BI Dashboard](screenshots/powerbi_dashboard.png)

---

## 📈 Goal Range — Success Rate Breakdown

> **Key Finding:** Projects with smaller goals succeed at 26x the rate of large-goal projects

| Goal Range (USD) | Label | Success Rate | Trend |
|:--|:-:|:-:|:-:|
| $1 – $1,000 | Below 1K | **~53%** | 🟢 Highest |
| $1,001 – $10,000 | 1K–10K | **~42%** | 🟢 Strong |
| $10,001 – $50,000 | 10K–50K | **~29%** | 🟡 Moderate |
| $50,001 – $100,000 | 50K–100K | **~15%** | 🔴 Low |
| $100,001+ | 100K+ | **~2%** | 🔴 Very Low |

---

## 💡 Key Insights

> 📌 *Data-backed findings from the analysis*

**1. Small Goals Win Big**
> Projects with goals below $1,000 succeed **53%** of the time vs only **2%** for goals above $100K — a **26x difference**. Realistic goal-setting is the single biggest predictor of success.

**2. Category Matters**
> Product Design (22K projects), Tabletop Games (16K), and Music (15K) dominate by volume. But **Theater** and **Music** lead by success rate, showing quality categories are underrepresented.

**3. A Few Projects Dominate Funding**
> The top 5 projects raised **$29.7M from 658K backers** combined. Exploding Kittens alone attracted **219K backers**; Fidget Cube raised **$6.47M** — a tiny fraction of projects drives the majority of platform revenue.

**4. Geography is Concentrated**
> **Los Angeles** (18.6K), **New York** (14.2K), and **London** (11.6K) account for a disproportionate share of all projects. 90%+ of activity is US-based.

**5. Platform Growth Has Stalled**
> Success rates held steady at **38–45%** from 2010–2018 before dropping sharply in **2019–2020**, suggesting market saturation or declining backer trust in the platform.

---

## 📋 Business Recommendations

| # | Recommendation | Based On |
|:-:|:--|:--|
| 1 | **Goal Advisor Tool** — Warn creators when target exceeds $50K; success drops below 15% at that level | Goal range analysis |
| 2 | **Promote Theater & Music** — These categories maintain 50%+ success rates despite lower volume | Category success rate |
| 3 | **Optimal Launch Window** — Q2–Q3 launches show stronger backer activity; avoid Q1 post-holiday | Time series analysis |
| 4 | **First-Timer Strategy** — Encourage sub-$1K goals to validate audience before scaling campaigns | Goal range + top projects |

---

## 🗃️ Dataset



🔗 **Full dataset:** [Kickstarter Crowdfunding on Kaggle](https://www.kaggle.com/datasets/bbhakumari/kickstarter-crowdfunding)

**Dataset Coverage:**
- 📅 Time Period: 2009 – 2019
- 📁 Total Records: ~366,000 projects
- 🌍 Countries: 170+
- 📂 Categories: 10 main, 150+ subcategories

---

<div align="center">




---

*⭐ If you found this project helpful, consider giving it a star!*

**Kickstarter Crowdfunding Data Analysis • Excel | SQL | Power BI | Tableau**

</div>
