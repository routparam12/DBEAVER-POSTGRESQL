select usp.id, usp."panelistId", usp."createdAt"  from "UserSurveyParticipations" usp 
where usp.id = 16978496 and 16978498 and 16978480 and 16978489 and 16978495

select usp.id, usp."createdAt",usp."panelistId" from "UserSurveyParticipations" usp 
where usp.id in ( 16990677, 16990676 ,16990675 ,16990674, 16990673)






select SUM(CASE WHEN usp."userStatus" = 2 THEN usp."ccpi" ELSE 0 END) AS revenue 
		    		from "UserSurveyParticipations" usp
		    inner join "Panelists" p on p."panelistId" = usp."panelistId" 
		    where 
			p."joinDate" between '2025-01-01' and '2025-02-01'
		    and usp."createdAt" between '2025-01-01' and '2025-02-01'
		    
-------------------------------
 
WITH Target_Cohorts AS (
    SELECT
        "panelistId",
        DATE_TRUNC('month', "joinDate" AT TIME ZONE 'America/New_York') AS join_month,
        "joinDate"
    FROM "Panelists"
    WHERE "joinDate" AT TIME ZONE 'America/New_York' >= '2025-01-01' 
    AND "joinDate" AT TIME ZONE 'America/New_York' < '2026-03-01'
),
Monthly_Revenue AS (
    -- Step 2: Revenue activity ko joiner se link karo
    SELECT
        usp."panelistId",
        tc.join_month,
        DATE_TRUNC('month', usp."createdAt"AT TIME ZONE 'America/New_York') AS activity_month,
        SUM(CASE WHEN usp."userStatus" = 2 THEN usp."ccpi" ELSE 0 END) AS revenue
    FROM "UserSurveyParticipations" usp
    INNER JOIN Target_Cohorts tc ON usp."panelistId" = tc."panelistId"
    WHERE (usp."createdAt" AT TIME ZONE 'America/New_York') >= tc.join_month -- Sakht condition: Activity join ke baad hi honi chahiye
      AND (usp."createdAt" AT TIME ZONE 'America/New_York') < '2026-03-01'
    GROUP BY 1, 2, 3
)
SELECT
    TO_CHAR(c.join_month, 'YYYY-Mon') AS "Joining_Cohort",
    COUNT(DISTINCT c."panelistId") AS "Total_Users",
    -- Ab Feb joiners ka Jan column automatically $0 dikhayega
    ROUND(SUM(CASE WHEN r.activity_month = '2025-01-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Jan_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-02-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Feb_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-03-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Mar_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-04-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Apr_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-05-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "May_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-06-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Jun_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-07-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Jul_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-08-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Aug_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-09-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Sep_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-10-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Oct_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-11-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Nov_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2025-12-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Dec_25",
    ROUND(SUM(CASE WHEN r.activity_month = '2026-01-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Jan_26",
    ROUND(SUM(CASE WHEN r.activity_month = '2026-02-01' THEN r.revenue ELSE 0 END)::numeric, 2) AS "Feb_26",
    ROUND(SUM(COALESCE(r.revenue, 0))::numeric, 2) AS "Total_LTV"
FROM Target_Cohorts c
LEFT JOIN Monthly_Revenue r ON c."panelistId" = r."panelistId"
GROUP BY c.join_month
ORDER BY c.join_month