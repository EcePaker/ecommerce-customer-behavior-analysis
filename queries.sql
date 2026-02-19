-- ============================================================
-- E-COMMERCE CUSTOMER BEHAVIOR ANALYSIS (KAGGLE ONLINE RETAIL)
-- Tools: Google Sheets (cleaning), SQL (analysis), Tableau (viz)
-- Table: Kaggle_Projesi_T
-- ============================================================

-- NOTE:
-- Revenue = Quantity * UnitPrice

-- ------------------------------------------------------------
-- 1) Top 10 Revenue-Generating Products (SQL Task)
-- ------------------------------------------------------------
SELECT
  StockCode,
  Description,
  ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM Kaggle_Projesi_T
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 2) Customer Total Spending (SQL Task)
-- ------------------------------------------------------------
SELECT
  CustomerID,
  ROUND(SUM(Quantity * UnitPrice), 2) AS total_spending
FROM Kaggle_Projesi_T
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_spending DESC;

-- ------------------------------------------------------------
-- 3) Revenue by Country (SQL Task: group by country)
-- ------------------------------------------------------------
SELECT
  Country,
  ROUND(SUM(Quantity * UnitPrice), 2) AS country_revenue
FROM Kaggle_Projesi_T
GROUP BY Country
ORDER BY country_revenue DESC;

-- ------------------------------------------------------------
-- 4) Monthly Revenue Trend (SQL Task: group by date)
-- (Optional: Tableau already visualizes this, but keeping here
--  is useful for validation.)
-- ------------------------------------------------------------
SELECT
  strftime('%Y-%m', InvoiceDate) AS year_month,
  ROUND(SUM(Quantity * UnitPrice), 2) AS monthly_revenue
FROM Kaggle_Projesi_T
GROUP BY year_month
ORDER BY year_month;

-- ============================================================
-- PORTFOLIO EXTENSION (Additional Insights)
-- ============================================================

-- ------------------------------------------------------------
-- 5) Top 10 Countries + Top 5 Products in Each (Revenue)
-- ------------------------------------------------------------
WITH top_country AS (
  SELECT Country
  FROM Kaggle_Projesi_T
  GROUP BY Country
  ORDER BY SUM(Quantity * UnitPrice) DESC
  LIMIT 10
),
country_product AS (
  SELECT
    kpt.Country,
    kpt.Description,
    SUM(kpt.Quantity * kpt.UnitPrice) AS total_revenue
  FROM Kaggle_Projesi_T kpt
  JOIN top_country tc
    ON tc.Country = kpt.Country
  GROUP BY kpt.Country, kpt.Description
),
ranked AS (
  SELECT
    Country,
    Description,
    total_revenue,
    ROW_NUMBER() OVER (PARTITION BY Country ORDER BY total_revenue DESC) AS rn
  FROM country_product
)
SELECT
  Country,
  Description,
  ROUND(total_revenue, 2) AS revenue
FROM ranked
WHERE rn <= 5
ORDER BY Country, revenue DESC;

-- ------------------------------------------------------------
-- 6) Most Popular Products by Unique Customers (Top 10)
-- ------------------------------------------------------------
SELECT
  Description,
  COUNT(DISTINCT CustomerID) AS unique_customers,
  SUM(Quantity) AS total_units_sold
FROM Kaggle_Projesi_T
WHERE CustomerID IS NOT NULL
GROUP BY Description
ORDER BY unique_customers DESC
LIMIT 10;