# 🌍 COVID-19 Data Exploration using SQL

## 📘 Project Overview
This project explores the **COVID-19 global dataset** using **SQL Server (SSMS)**.  
It focuses on **data exploration, aggregation, and visualization preparation**, helping to uncover trends such as:
- Infection rates across countries  
- Death rates and fatality percentages  
- Vaccination progress by population  
- Rolling vaccination trends over time  

The project demonstrates the use of **SQL joins, aggregate functions, CTEs, temporary tables, and views** to analyze pandemic data efficiently.

---

## 🧠 Key Concepts Used

| 🧩 Concept | 💡 Description | 🛠️ Where & How Used |
|-------------|----------------|----------------------|
| **Data Exploration** | Understanding dataset fields and relationships. | Examined `CovidDeaths` and `CovidVaccination` tables for structure and metrics. |
| **Data Type Standardization** | Ensuring correct numeric types for calculations. | Changed `new_vaccinations` to `FLOAT` for precise mathematical operations. |
| **Joins** | Combining related data from multiple tables. | Joined `CovidDeaths` and `CovidVaccination` on `location` and `date`. |
| **Aggregate Functions** | Computing totals, max values, and percentages. | Used `SUM()`, `MAX()`, `AVG()` for cumulative cases, deaths, and vaccination totals. |
| **Window Functions** | Calculating rolling and cumulative totals. | Used `SUM() OVER (PARTITION BY location ORDER BY date)` to compute rolling vaccinations. |
| **CTE (Common Table Expression)** | Temporary result set for modular queries. | Created `popVSvac` CTE to calculate vaccination percentages by population. |
| **Temporary Tables** | Store intermediate results for testing or analysis. | Built `#PercentagePopulationVaccinated` to compare vaccinated vs population. |
| **Views** | Saved complex queries for reuse. | Created a view `PercentagePopulationVaccinated` for dashboard or BI integration. |
| **Grouping & Ordering** | Country and continent-level aggregations. | Grouped data to find top infected/deadliest countries and continents. |

---

## ⚙️ Step-by-Step Workflow

### 1️⃣ Inspecting Vaccination Data
```sql
SELECT * FROM PortfolioProject..CovidVaccination;
ALTER TABLE CovidVaccination
ALTER COLUMN new_vaccinations FLOAT;
````

🧠 *Ensures the vaccination counts can be summed accurately using numeric precision.*

---

### 2️⃣ Joining Deaths and Vaccination Data

```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;
```

🧠 *Combines both datasets to analyze vaccination rollout alongside population and date.*

---

### 3️⃣ Using a CTE for Population vs Vaccination Percentage

```sql
WITH popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date)
  FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM popVSvac;
```

🧠 *Calculates cumulative vaccination percentages for each country.*

---

### 4️⃣ Using a Temporary Table for Vaccination Analysis

```sql
DROP TABLE IF EXISTS #PercentagePopulationVaccinated;
CREATE TABLE #PercentagePopulationVaccinated (
  continent NVARCHAR(255),
  location NVARCHAR(255),
  date DATETIME,
  population NUMERIC,
  new_vaccination NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM #PercentagePopulationVaccinated;
```

🧠 *Stores intermediate vaccination analysis for testing and BI reporting.*

---

### 5️⃣ Creating a View for Future Use

```sql
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```

🧠 *Allows easy access for dashboards (e.g., Power BI, Tableau).*

---

### 6️⃣ Country-Level Analysis

#### 🧩 Highest Infection Rate per Population

```sql
SELECT location, population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX(total_cases / population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;
```

#### ⚰️ Countries with Highest Death Count

```sql
SELECT location, population, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC;
```

#### 🌍 Continents with Highest Death Count

```sql
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```

---

### 7️⃣ Global Aggregations

```sql
-- Daily global summary
SELECT date,
       SUM(new_cases) AS CasesByDate,
       SUM(new_deaths) AS DeathsByDate,
       SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY date
ORDER BY date;

-- Overall totals
SELECT SUM(new_cases) AS TotalCases,
       SUM(new_deaths) AS TotalDeaths,
       SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths;
```

🧠 *Summarizes global case and death trends and computes worldwide fatality ratio.*

---

## 📊 Results & Insights

✅ Calculated rolling vaccination progress by country
✅ Found top infected and deadliest countries and continents
✅ Computed vaccination percentages relative to population
✅ Derived global case-fatality ratios
✅ Prepared reusable views for BI integration

---

## 🛠️ Tools & Technologies

* **Microsoft SQL Server Management Studio (SSMS)**
* **T-SQL (Transact-SQL)**
* **COVID-19 Datasets:** `CovidDeaths`, `CovidVaccination`
* **Concepts:** Joins, Aggregation, CTEs, Temp Tables, Views, Window Functions

---

## 🎯 Learning Outcomes

* Performed **end-to-end data exploration** with SQL.
* Learned **data joining and cumulative calculations** using window functions.
* Created **reusable components** (views, temp tables) for analytics.
* Understood **data-driven insights** about infection and vaccination trends.

---

## 🚀 Future Enhancements

* Connect this SQL dataset to **Power BI** for interactive dashboards.
* Automate daily refresh using **SQL Agent Jobs**.
* Integrate additional data sources like GDP or hospital capacity for correlation analysis.

---

## 👨‍💻 Author

**Rohan Goswami**
🎓 Final Year BCA Student | 💡 Aspiring Data Analyst | ⚙️ SQL, Python & Power BI Enthusiast

🔗 **LinkedIn:** https://www.linkedin.com/in/rohan-goswami-039755249/
