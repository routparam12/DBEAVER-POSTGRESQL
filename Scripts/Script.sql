    SELECT
        usp."panelistId",
        max(DATE_TRUNC('month',usp."createdAt" AT TIME ZONE 'America/New_York')) AS "UspActivity",
        count(*) as SurveyCount,
        max(usp."createdAt" AT TIME ZONE 'America/New_York'::text) AS "UspActivitydate",
        CASE WHEN lm."panelistId" IS NOT NULL THEN 1 ELSE 0 END AS "Active_last_month",
		CASE WHEN date_trunc('month', p."createdAt") = date_trunc('month', usp."createdAt")
        THEN 1 ELSE 0
    END AS "Joined_and_attempted_in_join_month"    
    FROM "UserSurveyParticipations" usp
    left join "Panelists" p 
    left join 
    (SELECT DISTINCT "panelistId"
    	FROM "UserSurveyParticipations"
    	WHERE "createdAt" >= date_trunc('month', CURRENT_DATE) - interval '1 month'
      	AND "createdAt" <  date_trunc('month', CURRENT_DATE)
			) lm ON usp."panelistId" = lm."panelistId"
	group by usp."panelistId",lm."panelistId"  
	
	
	
	select count(*), DATE_TRUNC('month',p."createdAt" AT TIME ZONE 'America/New_York')
	from "Panelists" p 
	group by DATE_TRUNC('month',p."createdAt" AT TIME ZONE 'America/New_York')
	order by DATE_TRUNC('month',p."createdAt" AT TIME ZONE 'America/New_York') desc
	
	
	select count(distinct usp."panelistId"),
	DATE_TRUNC('month',usp."createdAt" AT TIME ZONE 'America/New_York') 
	from "UserSurveyParticipations" usp 
	group by DATE_TRUNC('month',usp."createdAt" AT TIME ZONE 'America/New_York')
	order by DATE_TRUNC('month',usp."createdAt" AT TIME ZONE 'America/New_York')
	
	
	select count(*) from "Panelists" p 
	
	select * from "UserSurveyParticipations" usp 
	
	
	
	
	

WITH panelist_join_months AS (
  SELECT 
    "panelistId",
    DATE_TRUNC('month', "joinDate" AT TIME ZONE 'America/New_York') AS join_month
  FROM "Panelists"
),
monthly_active AS (
  SELECT DISTINCT
    "panelistId",
    DATE_TRUNC('month', "createdAt" AT TIME ZONE 'America/New_York') AS month
  FROM "UserSurveyParticipations"
),
monthly_aggregates AS (
  SELECT
    pjm.join_month AS month,
    COUNT(DISTINCT pjm."panelistId") AS joins,
    COUNT(DISTINCT usp."panelistId") AS joined_with_attempt
  FROM panelist_join_months pjm
  LEFT JOIN "UserSurveyParticipations" usp 
    ON pjm."panelistId" = usp."panelistId"
    AND DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') = pjm.join_month
  GROUP BY pjm.join_month
),
panelist_status AS (
  SELECT
    ma.month,
    ma."panelistId",
    CASE
      WHEN ROW_NUMBER() OVER w = 1 AND pjm.join_month = ma.month THEN 'New'
      WHEN ROW_NUMBER() OVER w = 1 AND pjm.join_month < ma.month THEN 'Reactivated'
      WHEN LAG(ma.month) OVER w + INTERVAL '1 month' = ma.month THEN 'Retained'
      WHEN LAG(ma.month) OVER w + INTERVAL '1 month' < ma.month THEN 'Reactivated'
      ELSE 'First Activity'
    END AS user_status,
    CASE
      WHEN LEAD(ma.month) OVER w IS NULL 
        OR LEAD(ma.month) OVER w > ma.month + INTERVAL '1 month'
      THEN 1 ELSE 0
    END AS will_churn
  FROM monthly_active ma
  INNER JOIN panelist_join_months pjm ON ma."panelistId" = pjm."panelistId"
  WINDOW w AS (PARTITION BY ma."panelistId" ORDER BY ma.month)
),
cumulative_panelists AS (
  SELECT
    join_month AS month,
    SUM(COUNT(*)) OVER (ORDER BY join_month) AS cumulative_total_panelists
  FROM panelist_join_months
  GROUP BY join_month
),
-- monthly unsubscribe counts
monthly_unsubscribes AS (
  SELECT
    DATE_TRUNC('month', "unsubscribeDate" AT TIME ZONE 'America/New_York') AS month,
    COUNT(*) AS unsubscribed_users
  FROM "Panelists"
  WHERE unsubscribe = TRUE
  GROUP BY 1
),
monthly_summary AS (
  SELECT
    ps.month,
    COALESCE(ma.joins, 0) AS joins,
    COALESCE(ma.joined_with_attempt, 0) AS joined_and_attempted,
    COALESCE(cp.cumulative_total_panelists, 0) AS cumulative_total_panelists,
    COUNT(*) AS total_active,
    COUNT(*) FILTER (WHERE user_status = 'New') AS usp_new_users,
    COUNT(*) FILTER (WHERE user_status = 'Retained') AS retained_users,
    COUNT(*) FILTER (WHERE user_status = 'Reactivated') AS reactivated_users,
    SUM(will_churn) AS churned_users,
    COALESCE(mu.unsubscribed_users, 0) AS unsubscribed_users
  FROM panelist_status ps
  LEFT JOIN monthly_aggregates ma ON ps.month = ma.month
  LEFT JOIN cumulative_panelists cp ON ps.month = cp.month
  LEFT JOIN monthly_unsubscribes mu ON ps.month = mu.month
  GROUP BY ps.month, ma.joins, ma.joined_with_attempt, cp.cumulative_total_panelists, mu.unsubscribed_users
)
SELECT
  month,
    cumulative_total_panelists as total_user,
      total_active,
        reactivated_users,
          LAG(churned_users) OVER (ORDER BY month) AS active_last_month_not_this_month,
  	    unsubscribed_users,
        joins,
  	joined_and_attempted,
  	  --  Churn Rate = churned this month / last month's active users
   	1.0 * LAG(churned_users) OVER (ORDER BY month) 
    / NULLIF(LAG(total_active) OVER (ORDER BY month), 0) AS churn_rate_pct,
  --  Recovery Rate = reactivated this month / last month's churned users
    1.0 * reactivated_users 
    / NULLIF(LAG(churned_users) OVER (ORDER BY month), 0) AS recovery_rate_pct
FROM monthly_summary
ORDER BY month;