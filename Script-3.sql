
SELECT 
    -- Affiliate metrics (from query 2)
    atd."affiliateId",
    amd."affiliateName",
    DATE(atd."createdAt") as "date",
    amd."cost" as "Affiliate_Cost",
    
    -- Panelist details (from query 1)
    p."sourceId",
    p."isActive",
    p."isEmailVerified",
    p."joinDate",
    p."categoryType",
    c."countryName",
    p."createdAt" as "panelistCreatedAt",
    
    -- Aggregated metrics
    COUNT(DISTINCT atd."panelistId") as "join",
    SUM(CASE WHEN usp."userStatus" IS NOT NULL AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Starts",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Completes",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) as "Cost",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) as "Revenue",
    SUM(CASE WHEN usp."isReconcile" = true THEN 1 ELSE 0 END) as "Reconcile"
    
FROM "AffiliateTrafficDetails" atd

-- Join with Panelists (your join condition: p.sourceId = atd.affiliateId)
LEFT JOIN "Panelists" p ON p."sourceId" = atd."affiliateId" 
                          AND p."panelistId" = atd."panelistId"

-- Join with Countries for panelist location
LEFT JOIN "Countries" c ON p."countryId" = c."countryId"

-- Join with UserSurveyParticipations (your existing join)
LEFT JOIN "UserSurveyParticipations" usp ON atd."panelistId" = usp."panelistId"

-- Join with AffiliateMasterDetails (your existing join)
LEFT JOIN "AffiliateMasterDetails" amd ON atd."affiliateId" = amd.id

GROUP BY 
    atd."affiliateId",
    amd."affiliateName",
    DATE(atd."createdAt"),
    amd."cost",
    p."sourceId",
    p."isActive",
    p."isEmailVerified",
    p."joinDate",
    p."categoryType",
    c."countryName",
    p."createdAt" 
order by p."joinDate"  limit 100;





SELECT 
    -- Your original columns (EXACT same names & structure)
    atd."affiliateId",
    amd."affiliateName", 
    DATE(atd."createdAt") as "date",
    amd."cost" as "Affiliate_Cost",
    
    -- Your original metrics
    COUNT(DISTINCT(atd."panelistId")) as "join",
    SUM(CASE WHEN usp."userStatus" IS NOT NULL AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Starts",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Completes",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) as "Cost",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) as "Revenue",
    SUM(CASE WHEN usp."isReconcile" = true THEN 1 ELSE 0 END) as "Reconcile",
    
    -- Additional metrics from new query (added at the end)
    SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "PPH_Cost",
    SUM(COALESCE(pops.gamecost, 0)) AS "Game_Cost",
    SUM(COALESCE(pops.gamerevenue, 0)) AS "Game_Revenue",
    
    -- Calculated totals
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) + 
    SUM(COALESCE(pops.gamerevenue, 0)) AS "Total_Revenue",
    
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) + 
    SUM(COALESCE(pops.gamecost, 0)) + 
    SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "Total_Cost"
    
FROM "AffiliateTrafficDetails" atd

-- Your original joins
LEFT JOIN "UserSurveyParticipations" usp  
    ON atd."panelistId" = usp."panelistId"

LEFT JOIN "AffiliateMasterDetails" amd 
    ON atd."affiliateId" = amd.id

-- New joins for additional metrics
LEFT JOIN "PanelistPointHistories" pph 
    ON pph."panelistId" = atd."panelistId"
    AND DATE_TRUNC('day', pph."createdAt") = DATE_TRUNC('day', atd."createdAt")

-- Pre-filtered game data (efficient subquery)
LEFT JOIN (
    SELECT 
        "panelistId",
        cpi AS gamecost,
        ccpi AS gamerevenue,
        DATE_TRUNC('day', "createdAt")::date AS pop_date
    FROM "PanelistOfferProgresses"
    WHERE completed = true
) pops 
    ON pops."panelistId" = atd."panelistId"
    AND pops.pop_date = DATE(atd."createdAt")

GROUP BY 
    atd."affiliateId",
    amd."affiliateName", 
    DATE(atd."createdAt"),
    amd."cost" 
order by DATE(atd."createdAt") desc;




SELECT 
    -- Keys & Dimensions
    atd."affiliateId",
    amd."affiliateName", 
    DATE(atd."createdAt") as "date",
    amd."cost" as "Affiliate_Cost",
    
    -- Your original metrics (UNCHANGED)
    COUNT(DISTINCT(atd."panelistId")) as "join",
    SUM(CASE WHEN usp."userStatus" IS NOT NULL AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Starts",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Completes",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) as "Cost",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) as "Revenue",
    SUM(CASE WHEN usp."isReconcile" = true THEN 1 ELSE 0 END) as "Reconcile",
    
    -- Additional metrics from new query
    SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "PPH_Cost",
    SUM(COALESCE(pops.gamecost, 0)) AS "Game_Cost",
    SUM(COALESCE(pops.gamerevenue, 0)) AS "Game_Revenue",
    
    -- Calculated totals
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) + 
    SUM(COALESCE(pops.gamerevenue, 0)) AS "Total_Revenue",
    
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) + 
    SUM(COALESCE(pops.gamecost, 0)) + 
    SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "Total_Cost"
    
FROM "AffiliateTrafficDetails" atd

LEFT JOIN "UserSurveyParticipations" usp  
    ON atd."panelistId" = usp."panelistId"

LEFT JOIN "AffiliateMasterDetails" amd 
    ON atd."affiliateId" = amd.id

LEFT JOIN "PanelistPointHistories" pph 
    ON pph."panelistId" = atd."panelistId"
    AND DATE_TRUNC('day', pph."createdAt") = DATE_TRUNC('day', atd."createdAt")

LEFT JOIN (
    SELECT 
        "panelistId",
        cpi AS gamecost,
        ccpi AS gamerevenue,
        DATE_TRUNC('day', "createdAt")::date AS pop_date
    FROM "PanelistOfferProgresses"
    WHERE completed = true
) pops 
    ON pops."panelistId" = atd."panelistId"
    AND pops.pop_date = DATE(atd."createdAt")

GROUP BY 
    atd."affiliateId",
    amd."affiliateName", 
    DATE(atd."createdAt"),
    amd."cost";



select count(usp.id) from "AffiliateTrafficDetails" atd 
left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId" 	
where atd."createdAt" > '2026-01-28'






WITH daily_metrics AS (
    SELECT 
        atd."affiliateId",
        amd."affiliateName", 
        DATE(atd."createdAt") as "date",
        amd."cost" as "Affiliate_Cost",
        COUNT(DISTINCT(atd."panelistId")) as "join",
        SUM(CASE WHEN usp."userStatus" IS NOT NULL AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Starts",
        SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Completes",
        SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) as "Cost",
        SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) as "Revenue",
        SUM(CASE WHEN usp."isReconcile" = true THEN 1 ELSE 0 END) as "Reconcile",
        SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "PPH_Cost",
        SUM(COALESCE(pops.gamecost, 0)) AS "Game_Cost",
        SUM(COALESCE(pops.gamerevenue, 0)) AS "Game_Revenue"
    FROM "AffiliateTrafficDetails" atd
    LEFT JOIN "UserSurveyParticipations" usp ON atd."panelistId" = usp."panelistId"
    LEFT JOIN "AffiliateMasterDetails" amd ON atd."affiliateId" = amd.id
    LEFT JOIN "PanelistPointHistories" pph 
        ON pph."panelistId" = atd."panelistId"
        AND DATE_TRUNC('day', pph."createdAt") = DATE_TRUNC('day', atd."createdAt")
    LEFT JOIN (
        SELECT 
            "panelistId",
            cpi AS gamecost,
            ccpi AS gamerevenue,
            DATE_TRUNC('day', "createdAt")::date AS pop_date
        FROM "PanelistOfferProgresses"
        WHERE completed = true
    ) pops 
        ON pops."panelistId" = atd."panelistId"
        AND pops.pop_date = DATE(atd."createdAt")
    GROUP BY atd."affiliateId", amd."affiliateName", DATE(atd."createdAt"), amd."cost"
),
panelist_stats AS (
    SELECT 
        p."sourceId" as "affiliateId",
        c."countryName",
        p."categoryType",
        COUNT(DISTINCT p."panelistId") as "Total_Panelists_By_Country_Category",
        COUNT(DISTINCT CASE WHEN p."isActive" = true THEN p."panelistId" END) as "Active_Panelists_By_Country_Category",
        COUNT(DISTINCT CASE WHEN p."isEmailVerified" = true THEN p."panelistId" END) as "Verified_Panelists_By_Country_Category"
    FROM "Panelists" p
    LEFT JOIN "Countries" c ON p."countryId" = c."countryId"
    WHERE p."sourceId" IS NOT NULL
    GROUP BY p."sourceId", c."countryName", p."categoryType"
)
SELECT 
    dm.*,
    ps."countryName",
    ps."categoryType",
    ps."Total_Panelists_By_Country_Category",
    ps."Active_Panelists_By_Country_Category",
    ps."Verified_Panelists_By_Country_Category",
    
    -- Calculate totals
    dm."Revenue" + dm."Game_Revenue" AS "Total_Revenue",
    dm."Cost" + dm."Game_Cost" + dm."PPH_Cost" AS "Total_Cost"
    
FROM daily_metrics dm
CROSS JOIN panelist_stats ps
WHERE dm."affiliateId" = ps."affiliateId";


---------------------------
select count(
        CASE
            WHEN usp."userStatus" IS NOT NULL THEN 1
            ELSE 0
        END) AS starts,
        (usp."createdAt" AT TIME ZONE 'America/New_York'::text)::date AS date 
        from "UserSurveyParticipations" usp where usp."createdAt" between '2026-01-28 10:30' and '2026-01-29 10:30'
        group by usp."createdAt" 


        
        
select count(usp."userStatus")as "Starts",
DATE_TRUNC('hour', usp."createdAt" AT TIME ZONE 'America/New_York') AS date_hour
FROM "UserSurveyParticipations" usp 
WHERE usp."createdAt" BETWEEN '2026-01-28 10:30' AND '2026-01-29 10:30'
GROUP BY DATE_TRUNC('hour', usp."createdAt" AT TIME ZONE 'America/New_York')
ORDER BY date_hour;


select count(usp."userStatus")as "Starts",
DATE_TRUNC('hour', usp."createdAt") AS hour
FROM "UserSurveyParticipations" usp 
WHERE usp."createdAt" BETWEEN '2026-01-28 10:30' AND '2026-01-29 10:30'
GROUP BY DATE_TRUNC('hour', usp."createdAt")
ORDER BY "hour" desc;


  
-------------
--Checker Query

select 
count(usp."userStatus") as "Start",
count(case when usp."userStatus"= 2 then 1 end) as "complete",
count(distinct(atd."panelistId" ))as "Join",
sum(case when usp."userStatus"= 2 then usp.cpi end) as cost,
sum(case when usp."userStatus"= 2 then usp.ccpi end)as revenue
from "AffiliateTrafficDetails" atd  
left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId"   

select  count(case when atd."panelistId" is not null then 1 end) from "AffiliateTrafficDetails" atd     


select * from usp_aff ua 

select  from "AffiliateTrafficDetails" atd 

WITH last_month_active AS (
    SELECT DISTINCT "panelistId"
    FROM "UserSurveyParticipations"
    WHERE "createdAt" >= date_trunc('month', CURRENT_DATE) - interval '1 month'
      AND "createdAt" <  date_trunc('month', CURRENT_DATE)
)

select sum(usp.cpi),sum(usp.ccpi) from "UserSurveyParticipations" usp 

select 
usp.id as "Survey_id",
usp."panelistId",
(usp."createdAt" AT TIME ZONE 'America/New_York'::text) as "Survey_date",
case when usp."userStatus" is not null then 1 else 0 end as "Starts",
case when usp."userStatus" = 2 then 1 else 0 end as "Complete",
case when usp."userStatus" = 2 then usp.cpi else 0 end as "Cost",
case when usp."userStatus" = 2 then usp.ccpi else 0 end as "Revenue", 
case when usp."isReconcile" = true then 1 else 0 end as "Reconcile",
CASE WHEN lm."panelistId" IS NOT NULL THEN 1 ELSE 0 END AS "Active_last_month",
CASE WHEN date_trunc('month', p."createdAt") = date_trunc('month', usp."createdAt")
        THEN 1 ELSE 0
    END AS "Joined_and_attempted_in_join_month"
from  "UserSurveyParticipations" usp
left join "Panelists" p on usp."panelistId" = p."panelistId" 
LEFT JOIN (
    SELECT DISTINCT "panelistId"
    FROM "UserSurveyParticipations"
    WHERE "createdAt" >= date_trunc('month', CURRENT_DATE) - interval '1 month'
      AND "createdAt" <  date_trunc('month', CURRENT_DATE)
) lm ON usp."panelistId" = lm."panelistId"
where p."sourceId" is not null






with uspp_aff as(select 
usp.id as "Survey_id",
usp."panelistId",
(usp."createdAt" AT TIME ZONE 'America/New_York'::text) as "Survey_date",
case when usp."userStatus" is not null then 1 else 0 end as "Starts",
case when usp."userStatus" = 2 then 1 else 0 end as "Complete",
case when usp."userStatus" = 2 then usp.cpi else 0 end as "Cost",
case when usp."userStatus" = 2 then usp.ccpi else 0 end as "Revenue", 
case when usp."isReconcile" = true then 1 else 0 end as "Reconcile",
CASE WHEN lm."panelistId" IS NOT NULL THEN 1 ELSE 0 END AS "Active_last_month",
CASE WHEN date_trunc('month', p."createdAt") = date_trunc('month', usp."createdAt")
        THEN 1 ELSE 0
    END AS "Joined_and_attempted_in_join_month"
from  "AffiliateTrafficDetails" atd 
left join "UserSurveyParticipations" usp
left join "Panelists" p on usp."panelistId" = p."panelistId" 
LEFT JOIN (
    SELECT DISTINCT "panelistId"
    FROM "UserSurveyParticipations"
    WHERE "createdAt" >= date_trunc('month', CURRENT_DATE) - interval '1 month'
      AND "createdAt" <  date_trunc('month', CURRENT_DATE)
) lm ON usp."panelistId" = lm."panelistId"
where p."sourceId" is not null )
select sum(upa."Starts") as "starts",sum(upa."Cost") as cost,sum(upa."Revenue") as revenue,
sum(upa."Reconcile" ),
sum(upa."Active_last_month" )as "Active_last_month",
sum(upa."Joined_and_attempted_in_join_month") as "Joined_and_attempted_in_join_month" 
from uspp_aff upa




WITH survey AS (
    SELECT
        "panelistId",
        SUM(ccpi) FILTER (WHERE "userStatus" = 2)      AS revenue,
        SUM(cpi)  FILTER (WHERE "userStatus" IN (2,16)) AS survey_cost
    FROM "UserSurveyParticipations"
    GROUP BY "panelistId"
),
points AS (
    SELECT
        "panelistId",
        SUM(points) FILTER (WHERE "pointTypeId" <> 1) / 100.0 AS issued_points_value
    FROM "PanelistPointHistories"
    GROUP BY "panelistId"
),
redeem AS (
    SELECT
        "panelistId",
        SUM(point) FILTER (WHERE status = 'approved') / 100.0 AS redeemed_value
    FROM "PanelistRedemptionRequests"
    GROUP BY "panelistId"
)
--------------------
--point check  

WITH survey AS (
    SELECT
        "panelistId",
        SUM(ccpi) FILTER (WHERE "userStatus" = 2) AS revenue,
        SUM(cpi)  FILTER (WHERE "userStatus" IN (2,16)) AS survey_cost
    FROM "UserSurveyParticipations"
    GROUP BY "panelistId"
),
points AS (
    SELECT
        "panelistId",
        SUM(points) FILTER (WHERE "pointTypeId" <> 1) / 100.0 AS issued_points_value
    FROM "PanelistPointHistories"
    GROUP BY "panelistId"
),
redeem AS (
    SELECT
        "panelistId",
        SUM(point) FILTER (WHERE status = 'approved') / 100.0 AS redeemed_value
    FROM "PanelistRedemptionRequests"
    GROUP BY "panelistId"
)
SELECT
    p."panelistId",
    COALESCE(s.revenue,0) AS revenue,
    (
        COALESCE(s.survey_cost,0)
      + COALESCE(pt.issued_points_value,0)
    )::numeric(12,2) AS cost,
    (
        COALESCE(s.revenue,0)
      - (COALESCE(s.survey_cost,0) + COALESCE(pt.issued_points_value,0))
      - CASE
            WHEN p.device IN (1,2) AND p."sourceId" IS NOT NULL THEN 4
            WHEN p.device = 3       AND p."sourceId" IS NOT NULL THEN 3
            ELSE 0
        END
    )::numeric(12,2) AS profit,
    (
        COALESCE(s.revenue,0)
      - COALESCE(s.survey_cost,0)
      - COALESCE(r.redeemed_value,0)
      - CASE
            WHEN p.device IN (1,2) AND p."sourceId" IS NOT NULL THEN 4
            WHEN p.device = 3       AND p."sourceId" IS NOT NULL THEN 3
            ELSE 0
        END
    )::numeric(12,2) AS actual_profit
FROM "Panelists" p
LEFT JOIN survey s ON s."panelistId" = p."panelistId"
LEFT JOIN points pt ON pt."panelistId" = p."panelistId"
LEFT JOIN redeem r ON r."panelistId" = p."panelistId";


------------------------------------------------------------


SELECT pph."panelistId" as panelist,pph."pointTypeId",
case when pph."pointTypeId"<>1 then pph.points/100.0 else 0 end as "Issued_points_value",
(pph."createdAt" AT TIME ZONE 'America/New_York'::text) as "CreatedAt" 
FROM "PanelistPointHistories" pph
-----------


SELECT pph."panelistId",pph."pointTypeId",pph.points,
--        SUM(points) FILTER (WHERE "pointTypeId" <> 1) / 100.0 AS issued_points_value,
        (pph."createdAt" AT TIME ZONE 'America/New_York'::text) as "CreatedAt"
    FROM "PanelistPointHistories" pph
 
---------------    
    
SELECT pph."panelistId",
        SUM(points) FILTER (WHERE "pointTypeId" <> 1) / 100.0 AS issued_points_value,
        (pph."createdAt" AT TIME ZONE 'America/New_York'::text) as "CreatedAt", 
    FROM "PanelistPointHistories" pph
    group by pph."panelistId" 

--------------
select pph.points,pph."pointTypeId"   from "PanelistPointHistories" pph 






-----------------------

select count(ua."Starts" ) 
from usp_aff ua left join  affiliate_aff aa on ua."panelistId" = aa."panelistId"  



select pph."pointTypeId"  from "PanelistPointHistories" pph limit 40 

select * from affiliate_aff aa left join  panelist_aff pa
on aa."panelistId" = pa."User_id"  
where pa."Games_rev" is not null


select pop."panelistId",
			sum(((coalesce(pop."pointsAwarded",0)/100.0)/NULLIF(pop.cpi,0))* pop.ccpi) as "Games_rev" 
			from  "AffiliateTrafficDetails" atd 
			left join "PanelistOfferProgresses" pop on atd."panelistId" = pop."panelistId"   
			where pop.status = 'COMPLETED' and pop.completed = true 
			group by pop."panelistId"


select 
p."panelistId" as "User_id" ,
p."isActive" as "Active",
p."isEmailVerified" as "EmailV",
p."sourceId" as "SourceId",
ct."categoryType" as "Category",
c."countryName" as "Country",
(p."createdAt" AT TIME ZONE 'America/New_York'::text) as "CreatedAt",
CASE WHEN p."createdAt" < date_trunc('month', CURRENT_DATE)
        THEN 1 ELSE 0 
    END AS "Not_joined_this_month",
COALESCE(ph."PPH_Point" , 0) AS "PPH_Point",
po."Games_rev" 
--COALESCE(ph."PPH_Issue_Date" , NULL) AS "PPH_Issue_Date"    
from "Panelists" p
left join "Countries" c on p."countryId"= c."countryId"
left join "CategoryTypes" ct on p."categoryType" = ct.id 
left join (select pph."panelistId",
			sum(case when pph."pointTypeId" <> 1 then points/100.0 else 0 end) as "PPH_Point"
--			MAX(pph."createdAt" AT TIME ZONE 'America/New_York') AS "PPH_Issue_Date"
			from "PanelistPointHistories" pph group by pph."panelistId")ph on p."panelistId" = ph."panelistId" 
			left join (select pop."panelistId",
			sum(((coalesce(pop."pointsAwarded",0)/100.0)/NULLIF(pop.cpi,0))* pop.ccpi) as "Games_rev" 
			from "PanelistOfferProgresses" pop  
			where pop.status = 'COMPLETED' and pop.completed = true 
			group by pop."panelistId" ) as Po on po."panelistId" = p."panelistId" 
where p."sourceId" is not null




with cost as
(select atd."panelistId",sum(atd."cost") as "ATDCOST",
sum(case when pph."pointTypeId" <> 1 then points/100.0 else 0 end) as "PPH_Point",
po."Games_rev",up.ccpi
  from "AffiliateTrafficDetails" atd  
left join "PanelistPointHistories" pph on atd."panelistId" = pph.points
left join (select pop."panelistId",
			sum(((coalesce(pop."pointsAwarded",0)/100.0)/NULLIF(pop.cpi,0))* pop.ccpi) as "Games_rev" 
			from "PanelistOfferProgresses" pop  
			where pop.status = 'COMPLETED' and pop.completed = true 
			group by pop."panelistId" ) as Po on po."panelistId" = atd."panelistId" 
left join (select usp."panelistId",usp.ccpi  from "UserSurveyParticipations" usp group by usp."panelistId",usp.ccpi) as up on up."panelistId" = atd."panelistId"  			
group by atd."panelistId",po."Games_rev",up.ccpi) 
select  sum(c."Games_rev"+c.ccpi) as Total_rev, sum(c."ATDCOST"+c."PPH_Point" )as "Total_cost" from cost c  group by c."Games_rev",c."ATDCOST",c."PPH_Point",c.ccpi 




select p."panelistId",p."createdAt",c.date_trunc  
from "Panelists" p 
left join (select usp."panelistId",date_trunc('month',usp."createdAt") 
from "UserSurveyParticipations" usp group by 1,2 )c on c."panelistId" = p."panelistId" 




select count(atd.id) as "Total_user",count(atd."panelistId") as "Join"

from "AffiliateTrafficDetails" atd 
left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId" 


SELECT
    atd."panelistId",
    date_trunc('month', usp."participateTime") as "ActivityMonth",
    COUNT(usp."participateTime") as "AttemptCount"
FROM "AffiliateTrafficDetails" atd
LEFT JOIN "UserSurveyParticipations" usp
    ON atd."panelistId" = usp."panelistId"
GROUP BY 
    atd."affiliateId",
    atd."panelistId",
    date_trunc('month', usp."participateTime");



SELECT
    p."panelistId",
    date_trunc('month', usp."participateTime") as "ActivityMonth",
    COUNT(usp."participateTime") as "AttemptCount"
FROM "Panelists" p 
LEFT JOIN "UserSurveyParticipations" usp
    ON p."panelistId" = usp."panelistId"
GROUP BY 
    p."panelistId",
    date_trunc('month', usp."participateTime");






with sup as (SELECT 
   usp."panelistId", usp.last_participation    
FROM "AffiliateTrafficDetails" atd 
left join 
(select distinct "panelistId",max("participateTime") as Last_Participation  from "UserSurveyParticipations" group by "panelistId") as usp on atd."panelistId" = usp."panelistId" )
select count(*) from sup 

select count(*) from "AffiliateTrafficDetails" atd 


select * from "PointTypes" pt 
select * from "PanelistOfferProgresses" 


select sum(atd."cost") FROM "AffiliateTrafficDetails" atd
    inner join "Panelists" p on p."panelistId" =atd."panelistId"
    where p."isEmailVerified" =true and atd."createdAt" between '2024-01-01' and '2024-02-01'


with affi as(select
atd.id as "Aff_id",
atd."panelistId",
atd."affiliateId",
case when atd."campaignId" is not null then atd."campaignId" else 'None' end as "Campaign" , 
(atd."createdAt"  AT TIME ZONE 'America/New_York'::text) as "ATD_Date",
atd."ipAddress",
atd."cost", amd."affiliateName" as "Aff_Name" 
from "AffiliateTrafficDetails" atd 
left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
where amd."affiliateName" is not null)
select count(*) from affi af



with affi as(select
atd.id as "Aff_id",
atd."panelistId",
atd."affiliateId",
case when atd."campaignId" is not null then atd."campaignId" else 'None' end as "Campaign" , 
(atd."createdAt"  AT TIME ZONE 'America/New_York'::text) as "ATD_Date",
atd."ipAddress",
case when p."isEmailVerified" = true then atd."cost" end as cost,
amd."affiliateName" as "Aff_Name" 
from "AffiliateTrafficDetails" atd 
left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
left join "Panelists" p on atd."panelistId" = p."panelistId" 
where amd."affiliateName" is not null)
select count(af."Aff_id") as Hit,
count(af."panelistId") as join, 
sum(af."cost") as Recruitcost
from affi af where af."ATD_Date" between '2024-01-01' and '2024-02-01'








  
select * from "AffiliateTrafficDetails" atd where atd."panelistId" =   
  


select p."panelistId", p."createdAt",p."isActive", usp."createdAt"  from "Panelists" p 
left join "UserSurveyParticipations" usp on p."panelistId" = usp."panelistId" 
limit 50

select * from "UserSurveyParticipations" usp limit 40

select * from "Panelists" p limit 40


select p."deleteReason" from "Panelists" p where p."deleteReason" is not null  limit 50
select  from 


select
atd.id as "Aff_id",
atd."panelistId",
atd."affiliateId",
case when atd."campaignId" is not null then atd."campaignId" else 'None' end as "Campaign" , 
(atd."createdAt"  AT TIME ZONE 'America/New_York'::text) as "ATD_Date",
atd."ipAddress",
atd."cost", amd."affiliateName" as "Aff_Name" 
from "AffiliateTrafficDetails" atd 
left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
where amd."affiliateName" is not null



select * from affiliate_pbi ap limit 50

--
--select ap.affiliate ,count(ap.starts)as start, sum(ap.complete) as complete,
--count(distinct(ap.hits))as hit, sum(ap.reconcile) as reconcile,
--sum(ap.affiliatecost ),sum(ap.revenue),sum(ap.reconcilecost )  
--from affiliate_PBI ap 
--group by ap.affiliate 


select sum(atd."cost")  from "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on amd.id = atd."affiliateId" 

select sum(amd."cost") from "AffiliateMasterDetails" amd
left join "AffiliateTrafficDetails" atd ON atd."affiliateId" = amd.id




select 
sum(case WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status" THEN prr.amount 
            ELSE 0
        END )AS "Redeemed"
from "AffiliateTrafficDetails" atd
left join "PanelistRedemptionRequests" prr on atd."panelistId" = prr."panelistId" 



select sum(pa."Redeemed")  from  affiliate_aff aa  left join prr_aff pa on aa."panelistId" = pa."panelistId" 



select SUM(aa."cost" ) from affiliate_aff aa 



select sum(ua."Starts" ),sum(ua."Complete" ) from affiliate_aff aa left join usp_aff ua on aa."panelistId" = ua."Survey_id" 

select * from usp_aff ua limit 50


select
sum(case when usp."userStatus" is not null then 1 end)as "Starts",
sum(case when usp."userStatus" = 2 then 1 end )as "Completes"
from "AffiliateTrafficDetails" atd left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId" 



--------------------------------------



WITH panelist_stats_by_affiliate AS (
    -- Aggregate panelist stats at AFFILIATE level only (not by country/category)
    SELECT 
        p."sourceId" as "affiliateId",
        COUNT(DISTINCT p."panelistId") as "Total_Panelists",
        COUNT(DISTINCT CASE WHEN p."isActive" = true THEN p."panelistId" END) as "Active_Panelists",
        COUNT(DISTINCT CASE WHEN p."isEmailVerified" = true THEN p."panelistId" END) as "Email_Verified_Panelists",
        
        -- Dominant country (most common)
        MODE() WITHIN GROUP (ORDER BY c."countryName") as "Primary_Country",
        
        -- Dominant category (most common)
        MODE() WITHIN GROUP (ORDER BY p."categoryType") as "Primary_Category",
        
        -- Count of unique countries
        COUNT(DISTINCT c."countryName") as "Country_Count",
        
        -- Count of unique categories
        COUNT(DISTINCT p."categoryType") as "Category_Count"
        
    FROM "Panelists" p
    LEFT JOIN "Countries" c ON p."countryId" = c."countryId"
    WHERE p."sourceId" IS NOT NULL
    GROUP BY p."sourceId"
)
SELECT 
    -- Primary keys
    atd."affiliateId",
    amd."affiliateName", 
    DATE(atd."createdAt") as "date",
    amd."cost" as "Affiliate_Cost",
    
    -- Panelist stats (ONE value per affiliate, no duplication)
    ps."Total_Panelists",
    ps."Active_Panelists",
    ps."Email_Verified_Panelists",
    ps."Primary_Country",
    ps."Primary_Category",
    ps."Country_Count",
    ps."Category_Count",
    
    -- Your original metrics (UNCHANGED)
    COUNT(DISTINCT(atd."panelistId")) as "join",
    SUM(CASE WHEN usp."userStatus" IS NOT NULL AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Starts",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN 1 ELSE 0 END) as "Completes",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) as "Cost",
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) as "Revenue",
    SUM(CASE WHEN usp."isReconcile" = true THEN 1 ELSE 0 END) as "Reconcile",
    
    -- Additional metrics from new query
    SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "PPH_Cost",
    SUM(COALESCE(pops.gamecost, 0)) AS "Game_Cost",
    SUM(COALESCE(pops.gamerevenue, 0)) AS "Game_Revenue",
    
    -- Calculated totals
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) + 
    SUM(COALESCE(pops.gamerevenue, 0)) AS "Total_Revenue",
    
    SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) + 
    SUM(COALESCE(pops.gamecost, 0)) + 
    SUM(CASE WHEN pph."pointTypeId" <> 1 THEN pph.points ELSE 0 END) AS "Total_Cost"
    
FROM "AffiliateTrafficDetails" atd

LEFT JOIN "UserSurveyParticipations" usp  
    ON atd."panelistId" = usp."panelistId"

LEFT JOIN "AffiliateMasterDetails" amd 
    ON atd."affiliateId" = amd.id

-- Join panelist stats ONCE per affiliate (no multiplication)
LEFT JOIN panelist_stats_by_affiliate ps
    ON atd."affiliateId" = ps."affiliateId"

LEFT JOIN "PanelistPointHistories" pph 
    ON pph."panelistId" = atd."panelistId"
    AND DATE_TRUNC('day', pph."createdAt") = DATE_TRUNC('day', atd."createdAt")

LEFT JOIN (
    SELECT 
        "panelistId",
        cpi AS gamecost,
        ccpi AS gamerevenue,
        DATE_TRUNC('day', "createdAt")::date AS pop_date
    FROM "PanelistOfferProgresses"
    WHERE completed = true
) pops 
    ON pops."panelistId" = atd."panelistId"
    AND pops.pop_date = DATE(atd."createdAt")

GROUP BY 
    atd."affiliateId",
    amd."affiliateName", 
    DATE(atd."createdAt"),
    amd."cost",
    ps."Total_Panelists",
    ps."Active_Panelists",
    ps."Email_Verified_Panelists",
    ps."Primary_Country",
    ps."Primary_Category",
    ps."Country_Count",
    ps."Category_Count";













select * from "Panelists" p where p."isEmailVerified" is false


SELECT 
    p."sourceId" as "affiliateId",
    
    -- Aggregate counts by country
    c."countryName",
    COUNT(DISTINCT p."panelistId") as "Total_Panelists",
    COUNT(DISTINCT CASE WHEN p."isActive" = true THEN p."panelistId" END) as "Active_Panelists",
    COUNT(DISTINCT CASE WHEN p."isEmailVerified" = true THEN p."panelistId" END) as "Email_Verified_Panelists",
    
    -- Percentage calculations
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN p."isActive" = true THEN p."panelistId" END) / 
          NULLIF(COUNT(DISTINCT p."panelistId"), 0), 2) as "Active_Percentage",
    
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN p."isEmailVerified" = true THEN p."panelistId" END) / 
          NULLIF(COUNT(DISTINCT p."panelistId"), 0), 2) as "Verified_Percentage",
    
    -- Category breakdown
    p."categoryType",
    
    -- Date ranges
   
    MIN(p."createdAt") as "First_Created_Date"   
    
FROM "Panelists" p
LEFT JOIN "Countries" c ON p."countryId" = c."countryId"
WHERE p."sourceId" IS NOT NULL  -- Only affiliates
GROUP BY 
    p."sourceId",
    c."countryName",
    p."categoryType";


select sum(t."starts") from test t


---------------

