WITH Target_Cohorts AS (
    SELECT
        "panelistId",
        DATE_TRUNC('month', "joinDate") AS join_month,
        "joinDate"
    FROM "Panelists"
    WHERE "joinDate" >= '2025-01-01' AND "joinDate" < '2026-03-01' and "panelistId" = 77043
),
Monthly_Cost AS (
    SELECT
        pph."panelistId",
        tc.join_month,
        DATE_TRUNC('month', pph."createdAt" AT TIME ZONE 'est') AS activity_month,
        COALESCE(
        SUM(pph.points::numeric / 100.0)
        FILTER (WHERE pph."pointTypeId" <> 1),
    0) AS "cost" 
    FROM "PanelistPointHistories" pph
    INNER JOIN Target_Cohorts tc ON pph."panelistId" = tc."panelistId"
    WHERE (pph."createdAt" AT TIME ZONE 'est') >= tc.join_month 
      AND (pph."createdAt" AT TIME ZONE 'est') < '2026-03-01'
    GROUP BY 1, 2, 3
)
SELECT
    TO_CHAR(c.join_month, 'YYYY-Mon') AS "Joining_Cohort",TO_CHAR(c.join_month, 'YYYY-Mon') AS "Joining_CohortDate",
    COUNT(DISTINCT c."panelistId") AS "Total_Users",
    -- Ab Feb joiners ka Jan column automatically $0 dikhayega
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
    ROUND(SUM(COALESCE(mc.cost, 0))::numeric, 2) AS "Total_LTV"
FROM Target_Cohorts c
LEFT JOIN Monthly_Cost mc ON c."panelistId" = mc."panelistId"
GROUP BY c.join_month
ORDER BY c.join_month


select * from "Panelists" p limit 50


WITH Target_Cohorts AS (
    SELECT
        "panelistId",
        DATE_TRUNC('month', "joinDate") AS join_month,
        "joinDate"
    FROM "Panelists"
    WHERE "joinDate" >= '2025-01-01' AND "joinDate" < '2026-03-01'
),
select sum(CASE
            WHEN usp."userStatus" = 2 THEN usp.ccpi
            ELSE 0::numeric
        end) AS "Revenue",
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'est') AS activity_month,
        count(tc."panelistId") from "UserSurveyParticipations" usp
        left join Target_Cohorts tc on tc."panelistId"













select * from "UserSurveyParticipations" usp where usp."panelistId" = 77043 
and usp."createdAt" AT TIME ZONE 'America/New_York' between '2025-02-01' and '2025-03-01'
and usp."userStatus" = 2
