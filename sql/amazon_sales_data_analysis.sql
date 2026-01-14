USE amazon;


/* =========================================================
   PROJECT: Amazon Sales Data Analysis (Myanmar)
   AUTHOR: Neha Kumari
   ROLE: Data Analyst (SQL)
   =========================================================
   DATASET OVERVIEW:
   • Sales transaction data from three Amazon branches
     located in Myanmar (Naypyitaw, Yangon, Mandalay)
   • Time Period: Q1 2019
   • Total Records: 1000
   • Total Columns: 17
   ========================================================= */


/* ---------------------------------------------------------
   BUSINESS OBJECTIVES
   ---------------------------------------------------------
   1. Evaluate branch and city-level sales performance
   2. Identify revenue trends and seasonality
   3. Analyze customer purchasing behavior
   4. Measure profitability and high-value transactions
   5. Support data-driven business decisions
   --------------------------------------------------------- */


/* ---------------------------------------------------------
   DATA PREVIEW
   --------------------------------------------------------- */
SELECT
    *
FROM amazon;


/* ---------------------------------------------------------
   UNIQUE CITIES IN DATASET
   --------------------------------------------------------- */
SELECT
    DISTINCT City
FROM amazon;


/* ---------------------------------------------------------
   1. TOTAL REVENUE GENERATED
   --------------------------------------------------------- */
SELECT
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon;


/* ---------------------------------------------------------
   2. CITY-WISE TRANSACTION COUNT
   --------------------------------------------------------- */
SELECT
    City,
    COUNT(`Invoice ID`) AS total_transactions
FROM amazon
GROUP BY City;


/* ---------------------------------------------------------
   3. AVERAGE CUSTOMER RATING BY CITY
   --------------------------------------------------------- */
SELECT
    City,
    ROUND(AVG(Rating), 2) AS avg_customer_rating
FROM amazon
GROUP BY city order by avg_customer_rating DESC;


/* ---------------------------------------------------------
   4. BRANCH AND CITY PERFORMANCE SUMMARY
   --------------------------------------------------------- */
SELECT
    City,
    Branch,
    COUNT(`Invoice ID`) AS total_invoices,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(AVG(Total), 2) AS avg_invoice_value,
    ROUND(AVG(Rating), 2) AS avg_rating,
    ROUND(SUM(`Gross income`), 2) AS total_profit
FROM amazon
GROUP BY city, branch
ORDER BY total_revenue DESC;


/* ---------------------------------------------------------
   5. CUSTOMER TYPE CONTRIBUTION TO REVENUE
   --------------------------------------------------------- */
SELECT
    `Customer type`,
    ROUND(SUM(total), 2) AS total_revenue
FROM amazon
GROUP BY `Customer type`;


/* ---------------------------------------------------------
   6. TOP-SELLING PRODUCT LINES
   --------------------------------------------------------- */
SELECT
    `product line`,
    SUM(quantity) AS total_quantity_sold
FROM amazon
GROUP BY `product line`
ORDER BY total_quantity_sold DESC;


/* ---------------------------------------------------------
   7. SALES BY TIME OF DAY
   --------------------------------------------------------- */
SELECT
    CASE
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    ROUND(SUM(total), 2) AS total_sales
FROM amazon
GROUP BY time_of_day;


/* ---------------------------------------------------------
   8. PREFERRED PAYMENT METHODS
   --------------------------------------------------------- */
SELECT
    payment,
    COUNT(*) AS transaction_count
FROM amazon
GROUP BY payment
ORDER BY transaction_count DESC;


/* ---------------------------------------------------------
   9. HIGH-VALUE TRANSACTIONS
   ---------------------------------------------------------
   Identifies transactions above average invoice value
   --------------------------------------------------------- */
SELECT
    *
FROM amazon
WHERE total > (
    SELECT
        AVG(total)
    FROM amazon
);


/* ---------------------------------------------------------
   10. CITY REVENUE RANKING (WINDOW FUNCTION)
   --------------------------------------------------------- */
SELECT
    city,
    ROUND(SUM(total), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(total) DESC) AS revenue_rank
FROM amazon
GROUP BY city;


/* ---------------------------------------------------------
   11. DAILY SALES WITH CUMULATIVE TOTAL
   --------------------------------------------------------- */
SELECT
    date,
    ROUND(SUM(total), 2) AS daily_sales,
    ROUND(
        SUM(SUM(total)) OVER (ORDER BY date),
        2
    ) AS cumulative_sales
FROM amazon
GROUP BY date
ORDER BY date;


/* ---------------------------------------------------------
   12. MONTH-OVER-MONTH SALES GROWTH
   --------------------------------------------------------- */
WITH monthly_sales AS (
    SELECT
        MONTH(date) AS month,
        ROUND(SUM(total), 2) AS monthly_revenue
    FROM amazon
    GROUP BY MONTH(date)
)
SELECT
    month,
    monthly_revenue,
    monthly_revenue
        - LAG(monthly_revenue) OVER (ORDER BY month)
        AS month_over_month_growth
FROM monthly_sales;


/* ---------------------------------------------------------
   13. CITY-WISE REVENUE CONTRIBUTION (%)
   --------------------------------------------------------- */
SELECT
    City,
    ROUND(
        SUM(total) * 100.0 /
        (SELECT SUM(total) FROM amazon),
        2
    ) AS revenue_percentage
FROM amazon
GROUP BY city;


/* ---------------------------------------------------------
   14. PROFITABILITY ANALYSIS BY PRODUCT LINE (ADVANCED)
   --------------------------------------------------------- */
SELECT
    `Product line`,
    ROUND(SUM(`gross income`), 2) AS total_profit,
    ROUND(SUM(`gross income`) / SUM(total) * 100, 2)
        AS profit_margin_percentage
FROM amazon
GROUP BY `Product line`
ORDER BY profit_margin_percentage DESC;


/* ---------------------------------------------------------
   15. TOP 5 DAYS WITH HIGHEST SALES (ADVANCED)
   --------------------------------------------------------- */
SELECT
    Date,
    ROUND(SUM(total), 2) AS daily_revenue
FROM amazon
GROUP BY date
ORDER BY daily_revenue DESC
LIMIT 5;
