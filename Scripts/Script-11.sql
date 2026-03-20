select 
sum(atd."cost"),sum(ph."PPH_Point"),sum(rev.revenue)   from 
"AffiliateTrafficDetails" atd 
left join  ( SELECT pph."panelistId",
            sum(
                CASE
                    WHEN pph."pointTypeId" <> 1 THEN pph.points::numeric / 100.0
                    ELSE 0::numeric
                END) AS "PPH_Point",
                DATE_TRUNC('month', pph."createdAt") AS month
                FROM "PanelistPointHistories" pph
          GROUP BY pph."panelistId",pph."createdAt" ) ph ON atd."panelistId" = ph."panelistId"  
left  join (select usp.ccpi as revenue,usp."panelistId",DATE_TRUNC('month', usp."createdAt") AS month
from  "UserSurveyParticipations" usp 
group by usp."panelistId",usp.ccpi,usp."createdAt" )rev ON atd."panelistId" = rev."panelistId"
where atd."createdAt" > '2026-03-15' and atd."panelistId" is not null
group by atd."createdAt", atd.cost ,ph."PPH_Point",rev.revenue  



select * from "UserSurveyParticipations" usp where usp."panelistId" =152692



select atd.cost,atd."panelistId"  from "AffiliateTrafficDetails" atd 
where atd."createdAt" > '2026-03-15' and atd."panelistId" is not null

----------------------------------

WITH aff_month AS (
    SELECT
        DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost
    FROM "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE atd."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND atd."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York')
),
usp_month AS (
    SELECT
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') AS month,
        SUM(CASE WHEN usp."userStatus" = 2  THEN usp."ccpi" ELSE 0 END) AS revenue,
        SUM(CASE WHEN usp."userStatus" = 16 THEN 1 ELSE 0 END) AS reconcile,
        count(usp.id) as Start
    FROM "UserSurveyParticipations" usp
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = usp."panelistId"
    WHERE usp."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND usp."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York')
),
pph_month AS (
    SELECT
        DATE_TRUNC('month', pph."createdAt") AS month,
        SUM(
            CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            END
        ) AS point_cost
    FROM "PanelistPointHistories" pph
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = pph."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE pph."createdAt" >= '2026-01-01'
      AND pph."createdAt" < '2026-02-01'
    GROUP BY DATE_TRUNC('month', pph."createdAt")
),
prr_month AS (
    SELECT
        DATE_TRUNC('month', prr."createdAt" AT TIME ZONE 'America/New_York') AS month,
        SUM(
            CASE WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
                 THEN prr.amount
                 ELSE 0
            END
        ) AS redemption_amount
    FROM "PanelistRedemptionRequests" prr
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = prr."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE prr."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND prr."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY DATE_TRUNC('month', prr."createdAt" AT TIME ZONE 'America/New_York')
),
panelist_month AS(
    select DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York') AS month,
    count(case when p."isEmailVerified" = true then 1 end) as Doi
    from "Panelists" p
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = p."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE p."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND p."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York')
)
SELECT
    TO_CHAR(a.month, 'YYYY-Mon')  AS "Affiliate_month",
    pm.doi AS "Doi",
    p.point_cost AS "Point_cost",
    a.recruit_cost AS "Recruit_cost",
    u.revenue AS "Revenue",
    u."start" as "Start",
    u.reconcile AS "Reconcile",
    r.redemption_amount AS "Redemption_amount"
FROM aff_month a
LEFT JOIN usp_month u  ON u.month = a.month
LEFT JOIN pph_month p  ON p.month = a.month
LEFT JOIN prr_month r  ON r.month = a.month
left join panelist_month pm on pm."month" = a."month"
ORDER BY a.month;



--updated
---------------------------------
with aff_month as
(select CASE
            WHEN amd."ReportType"::text = 'campaignId'::text THEN COALESCE(atd."campaignId", 'None'::character varying)
            WHEN amd."ReportType"::text = 'subCampaignId'::text THEN COALESCE(atd."subCampaignId", 'None'::character varying)
            ELSE 'None'::character varying
        END AS campaign,
        atd."countryCode",
        amd."affiliateName",
		DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost   
    FROM "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE atd."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND atd."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY 1,2,3,4
),
usp_month AS (
    SELECT
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') AS month,
        amd."affiliateName",
        atd."countryCode", 
        SUM(CASE WHEN usp."userStatus" = 2  THEN usp."ccpi" ELSE 0 END) AS revenue,
        SUM(CASE WHEN usp."userStatus" = 16 THEN 1 ELSE 0 END) AS reconcile,
        count(usp.id) as start
    FROM "UserSurveyParticipations" usp
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = usp."panelistId"
    inner join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
    WHERE usp."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND usp."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY 1,2,3
),
pph_month AS (
    SELECT
        DATE_TRUNC('month', pph."createdAt") AS month,
        SUM(
            CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            END
        ) AS point_cost
    FROM "PanelistPointHistories" pph
    inner join "Panelists" p on pph."panelistId" = p."panelistId" 
    WHERE pph."createdAt" >= '2026-01-01'
      AND pph."createdAt" < '2026-02-01'
      and p."sourceId" is not null
    GROUP BY DATE_TRUNC('month', pph."createdAt")
),
prr_month AS (
    SELECT
        DATE_TRUNC('month', prr."createdAt" AT TIME ZONE 'America/New_York') AS month,
        SUM(
            CASE WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
                 THEN prr.amount
                 ELSE 0
            END
        ) AS redemption_amount
    FROM "PanelistRedemptionRequests" prr
    inner join "Panelists" p on prr."panelistId" = p."panelistId" 
    WHERE prr."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND prr."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
      and p."sourceId" is not null
    GROUP BY DATE_TRUNC('month', prr."createdAt" AT TIME ZONE 'America/New_York')
),
panelist_month AS(
    select DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York') AS month,
    count(case when p."isEmailVerified" = true then 1 end) as Doi
    from "Panelists" p
    WHERE p."createdAt" AT TIME ZONE 'America/New_York' >= '2026-01-01'
      AND p."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
      and p."sourceId" is not null
    GROUP BY DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York')
)
SELECT
    TO_CHAR(a.month, 'YYYY-Mon')  AS "Affiliate_month",
    a.campaign,
    a."countryCode",
    a."affiliateName", 
    pm.doi AS "Doi",
    p.point_cost AS "Point_cost",
    a.recruit_cost AS "Recruit_cost",
    u.revenue AS "Revenue",
    u."start" as "Start",
    u.reconcile AS "Reconcile",
    r.redemption_amount AS "Redemption_amount"
FROM aff_month a
LEFT JOIN usp_month u  ON u.month = a.month
--			and u."affiliateName" = a."affiliateName" 
--			and u."countryCode"  = a.campaign 
LEFT JOIN pph_month p  ON p.month = a.month
LEFT JOIN prr_month r  ON r.month = a.month
left join panelist_month pm on pm."month" = a."month"
ORDER BY a.month,a."countryCode",a."affiliateName",a.campaign ;



---------------------


with affiliate as
(select atd."cost", DATE_TRUNC('month', atd."createdAt"AT TIME ZONE 'America/New_York') AS month,
atd."panelistId",atd.id 
from "AffiliateTrafficDetails" atd 
where atd."createdAt"  AT TIME ZONE 'America/New_York' >= '2024-01-01' 
    AND atd."createdAt"  AT TIME ZONE 'America/New_York' < '2026-04-01'),
pointhistory as 
(SELECT pph."panelistId",
         sum(CASE
                WHEN pph."pointTypeId" <> 1 THEN pph.points::numeric / 100.0
                    ELSE 0::numeric
                END) AS "PPH_Point",
                DATE_TRUNC('month', pph."createdAt") AS month
                FROM "PanelistPointHistories" pph
                left join affiliate a on a."panelistId" = pph."panelistId" 
          GROUP BY pph."panelistId",pph."createdAt" ),
survey as (SELECT
        usp."panelistId", 
        a.month,
        DATE_TRUNC('month', usp."createdAt"AT TIME ZONE 'America/New_York') AS activity_month,
        SUM(CASE WHEN usp."userStatus" = 2 THEN usp."ccpi" ELSE 0 END) AS revenue
    FROM "UserSurveyParticipations" usp
    INNER JOIN affiliate a ON usp."panelistId" = a."panelistId" 
    GROUP BY 1, 2, 3)
select
TO_CHAR(a."month" ,'YYYY-Mon') AS "Affiliate_month",
count(a.id) as Hit,
sum(ph."PPH_Point")as Point_cost,
sum(a."cost")as Recruit_cost,sum(s.revenue)as Revenue   
from affiliate a
inner join pointhistory ph on ph."panelistId" = a."panelistId" 
inner join survey s on s."panelistId" = a."panelistId"
group by a."month" 
order by a."month" 
    

select   from "Panelists" p 

select atd."subCampaignId"   from "AffiliateTrafficDetails" atd limit 40



---------------

with aff_month as
(select 
		DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
		CASE
            WHEN amd."ReportType"::text = 'campaignId'::text THEN COALESCE(atd."campaignId", 'None'::character varying)
            WHEN amd."ReportType"::text = 'subCampaignId'::text THEN COALESCE(atd."subCampaignId", 'None'::character varying)
            ELSE 'None'::character varying
        END AS campaign,
        atd."countryCode",
        amd."affiliateName", 
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost
    FROM "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE atd."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and'2026-02-01'
    GROUP BY 1,2,3,4
),
point_month as(
	select 
	DATE_TRUNC('month', pph."createdAt" AT TIME ZONE 'America/New_York') AS month,
	SUM(
        CASE WHEN pph."pointTypeId" <> 1
             THEN pph.points::numeric / 100.0
              ELSE 0
            END
        ) AS point_cost
        from "PanelistPointHistories" pph 
        inner join "AffiliateTrafficDetails" atd on atd."panelistId" = pph."panelistId" 
        WHERE pph."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and'2026-02-01'
    GROUP BY 1       
),
usp_month AS (
    SELECT
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') AS month,
        SUM(CASE WHEN usp."userStatus" = 2  THEN usp."ccpi" ELSE 0 END) AS revenue,
        SUM(CASE WHEN usp."userStatus" = 16 THEN 1 ELSE 0 END) AS reconcile,
        count(usp.id) as start
    FROM "UserSurveyParticipations" usp
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = usp."panelistId"
    inner join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
    WHERE usp."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and'2026-02-01'
    GROUP BY 1
),
panelist_month AS(
    select DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York') AS month,
    count(case when p."isEmailVerified" = true then 1 end) as Doi
    from "Panelists" p
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = p."panelistId"
    WHERE p."createdAt" AT TIME ZONE 'America/New_York'  between '2026-01-01' and'2026-02-01'
    GROUP BY 1
)
SELECT
    TO_CHAR(a.month, 'YYYY-Mon')  AS "Affiliate_month",
    a.campaign,
    a."countryCode",
    a."affiliateName", 
    pm.doi AS "Doi",
    p.point_cost AS "Point_cost",
    a.recruit_cost AS "Recruit_cost",
    u.revenue AS "Revenue",
    u."start" as "Start",
    u.reconcile AS "Reconcile"
--    r.redemption_amount AS "Redemption_amount"
FROM aff_month a
LEFT JOIN usp_month u  ON u.month = a.month 
left join point_month p on p.month = a.month
left join panelist_month pm on pm."month" = a."month"
ORDER BY a.month,a.campaign ;
