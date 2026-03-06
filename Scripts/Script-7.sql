WITH Target_Cohorts AS (
    SELECT
        "panelistId",
        DATE_TRUNC('month', "joinDate"AT TIME ZONE 'America/New_York') AS join_month,
        "joinDate"
    FROM "Panelists"
    WHERE "joinDate"AT TIME ZONE 'America/New_York' >= '2025-01-01' 
    AND "joinDate"AT TIME ZONE 'America/New_York' < '2026-03-01'
),
Monthly_Cost AS (
    SELECT
        pph."panelistId",
        tc.join_month,
        DATE_TRUNC('month', pph."createdAt" AT TIME ZONE 'America/New_York') AS activity_month,
        COALESCE(
        SUM(pph.points::numeric / 100.0)
        FILTER (WHERE pph."pointTypeId" <> 1),
    0) AS "cost" 
    FROM "PanelistPointHistories" pph
    INNER JOIN Target_Cohorts tc ON pph."panelistId" = tc."panelistId"
    WHERE (pph."createdAt" AT TIME ZONE 'America/New_York') >= tc.join_month 
      AND (pph."createdAt" AT TIME ZONE 'America/New_York') < '2026-03-01'
    GROUP BY 1, 2, 3
)
SELECT
    TO_CHAR(c.join_month, 'YYYY-Mon') AS "Joining_Cohort",TO_CHAR(c.join_month, 'YYYY-Mon') AS "Joining_CohortDate",
    COUNT(DISTINCT c."panelistId") AS "Total_Users",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-01-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Jan_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-02-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Feb_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-03-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Mar_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-04-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Apr_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-05-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "May_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-06-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Jun_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-07-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Jul_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-08-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Aug_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-09-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Sep_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-10-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Oct_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-11-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Nov_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2025-12-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Dec_25",
    ROUND(SUM(CASE WHEN mc.activity_month = '2026-01-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Jan_26",
    ROUND(SUM(CASE WHEN mc.activity_month = '2026-02-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Feb_26",
    ROUND(SUM(CASE WHEN mc.activity_month = '2026-03-01' THEN mc.cost ELSE 0 END)::numeric, 2) AS "Mar_26",
    ROUND(SUM(COALESCE(mc.cost, 0))::numeric, 2) AS "Total_LTV"
FROM Target_Cohorts c
LEFT JOIN Monthly_Cost mc ON c."panelistId" = mc."panelistId"
GROUP BY c.join_month
ORDER BY c.join_month


select * from "Panelists" p limit 50

