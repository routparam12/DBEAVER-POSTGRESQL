select count(*) from "Panelists" p 

SELECT
    DATE_TRUNC('month', "joinDate" AT TIME ZONE 'America/New_York') AS month,
    COUNT(*) AS joins
FROM "Panelists" 
group by DATE_TRUNC('month', "joinDate" AT TIME ZONE 'America/New_York')

--- Active users --- 
select count(distinct usp."panelistId") as active_users,
	DATE_TRUNC('month',usp."createdAt" AT TIME ZONE 'America/New_York') as Month
	from "UserSurveyParticipations" usp 
	group by DATE_TRUNC('month',usp."createdAt" AT TIME ZONE 'America/New_York')

	
	
-- Total user -- 
select count(*) as total_user from "Panelists" p 
where p."joinDate" AT TIME ZONE 'America/New_York' < '2026-01-01'


-- New user --
select count(*)
from "Panelists" p 
where p."joinDate"AT TIME ZONE 'America/New_York' between '2026-03-01' and '2026-04-01'



--- joined and at least 1 survey in the join month --
SELECT COUNT(DISTINCT p."panelistId")
FROM "Panelists" p
INNER JOIN "UserSurveyParticipations" usp ON usp."panelistId" = p."panelistId"
WHERE DATE_TRUNC('month', p."joinDate" AT TIME ZONE 'America/New_York') = '2026-03-01'
  AND DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') = '2026-03-01';



-- reactivated user --
SELECT COUNT(DISTINCT nov."panelistId")
FROM (
  SELECT DISTINCT "panelistId" 
  FROM "UserSurveyParticipations"
  WHERE DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') = '2025-03-01'
) nov
LEFT JOIN (
  SELECT DISTINCT "panelistId" 
  FROM "UserSurveyParticipations"
  WHERE DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') = '2025-02-01'
) oct ON nov."panelistId" = oct."panelistId"
INNER JOIN (
  SELECT DISTINCT "panelistId"
  FROM "Panelists" 
  WHERE DATE_TRUNC('month', "joinDate" AT TIME ZONE 'America/New_York') < '2025-03-01'
) prior ON nov."panelistId" = prior."panelistId"
WHERE oct."panelistId" IS NULL;



-- active_last_month_not_this_month --
SELECT COUNT(DISTINCT Lastm."panelistId")
FROM (
  SELECT DISTINCT "panelistId"
  FROM "UserSurveyParticipations"
  WHERE DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') = '2024-10-01'
) Lastm
LEFT JOIN (
  SELECT DISTINCT "panelistId"
  FROM "UserSurveyParticipations"
  WHERE DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') = '2024-11-01'
) currentm ON currentm."panelistId" = Lastm."panelistId"
WHERE currentm."panelistId" IS NULL;


-- Churn Rate for NOV 2025
WITH oct_active AS (
  SELECT DISTINCT "panelistId"
  FROM "UserSurveyParticipations"
  WHERE DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') = '2025-10-01'
),
nov_active AS (
  SELECT DISTINCT "panelistId"
  FROM "UserSurveyParticipations"
  WHERE DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') = '2025-11-01'
)
SELECT
  COUNT(DISTINCT oct."panelistId") AS oct_total_active,
  COUNT(DISTINCT CASE WHEN nov."panelistId" IS NULL THEN oct."panelistId" END) AS churned,
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN nov."panelistId" IS NULL THEN oct."panelistId" END)
    / NULLIF(COUNT(DISTINCT oct."panelistId"), 0),
  2) AS churn_rate_pct
FROM oct_active oct
LEFT JOIN nov_active nov ON oct."panelistId" = nov."panelistId";