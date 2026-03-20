--Checking to the affiliate

--recruit_cost
with points as (select 
            CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            END
      	 AS point_cost,
        pph."panelistId" 
        from "PanelistPointHistories" pph )
select sum(atd."cost")as recruitcost  from "AffiliateTrafficDetails" atd
inner join points ps on ps."panelistId" = atd."panelistId" 
where atd."createdAt"AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'

select sum(atd."cost")  as recruitcost
from "AffiliateTrafficDetails" atd left join "Panelists" p on atd."panelistId" = p."panelistId" 
where p."emailVerifyDate" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
and atd."panelistId" is not null and p."isEmailVerified" = true


--point cost
select sum(CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            end)
      	 AS point_cost  from "PanelistPointHistories" pph 
inner join "AffiliateTrafficDetails" atd on pph."panelistId" = atd."panelistId" 
where pph."createdAt"AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'

select sum(CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            end)
      	 AS point_cost  from "PanelistPointHistories" pph 
inner join "AffiliateTrafficDetails" atd on pph."panelistId" = atd."panelistId" 
where pph."createdAt"AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
and  atd."affiliateId" = 22 and atd."countryCode"= 'CA' 

--starts

select count(usp.id) from "UserSurveyParticipations" usp 
inner join "AffiliateTrafficDetails" atd 
on atd."panelistId" = usp."panelistId" 
where usp."createdAt"AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
and  atd."affiliateId" = 29 and atd."countryCode"= 'US' 

--complete
select count(usp.id) from "UserSurveyParticipations" usp 
inner join "AffiliateTrafficDetails" atd 
on atd."panelistId" = usp."panelistId" where usp."createdAt"AT TIME ZONE 'America/New_York' between '2026-02-01' and '2026-03-01'
and  atd."affiliateId" = 29 and atd."countryCode"= 'US' and usp."userStatus" = 2

--doi
select 	count(case when p."isEmailVerified" = true then 1 end) as Doi
 from "Panelists" p 
inner join "AffiliateTrafficDetails" atd 
on atd."panelistId" = p."panelistId" 
where p."emailVerifyDate"  AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
and atd."panelistId" = 153078


select 	count(case when p."isEmailVerified" = true then 1 end) as Doi
 from "Panelists" p 
 where p."sourceId" is not null
and p."createdAt" between '2026-01-01' and '2026-02-01'

--reconcile
select SUM(CASE WHEN usp."userStatus" = 16 THEN 1 ELSE 0 END)AS reconcile
 from "UserSurveyParticipations" usp 
 inner join "AffiliateTrafficDetails" atd 
on atd."panelistId" = usp."panelistId" where usp."createdAt"AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'


--starts
select COUNT(usp.id) AS start
from "UserSurveyParticipations" usp 
inner join "AffiliateTrafficDetails" atd 
on atd."panelistId" = usp."panelistId" 
where usp."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'




--starts
select count(usp.id) as starts
from "UserSurveyParticipations" usp 
inner join "Panelists" p 
on p."panelistId" = usp."panelistId" 
where usp."createdAt" between '2026-01-01' and '2026-02-01' and p."sourceId" is not null 


--reedemption
select SUM(
            CASE WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
                 THEN prr.amount
                 ELSE 0
            END
        ) AS redemption_amount 
        from "PanelistRedemptionRequests" prr 
inner join "AffiliateTrafficDetails" atd 
on atd."panelistId" = prr."panelistId" where prr."createdAt" between '2026-01-01' and '2026-02-01'


-- revenue
select SUM(CASE WHEN usp."userStatus" = 2  THEN usp."ccpi" ELSE 0 END) AS revenue 
from "UserSurveyParticipations" usp 
inner join "AffiliateTrafficDetails" atd on usp."panelistId" = atd."panelistId" 
on atd."panelistId" = usp."panelistId" where usp."createdAt" between '2026-01-01' and '2026-02-01' 



select pph."panelistId"  from "PanelistPointHistories" pph 
inner join "Panelists" p on p."panelistId" = pph."panelistId" 
where p."isEmailVerified" is false


select sum(atd."cost") as cost  , count(atd."panelistId") , count(p."panelistId") as doi from "AffiliateTrafficDetails" atd
left join "Panelists" p on p."panelistId" = atd."panelistId"
where p."panelistId" = 153078 and
--atd."campaignId" = '404688' and
--atd."countryCode" = 'FR' and
--atd."affiliateId" = 22 and
--atd."createdAt"   AT TIME ZONE 'America/New_York' between  '2026-02-01' and '2026-04-01'
p."emailVerifyDate"    AT TIME ZONE 'America/New_York' between  '2026-02-01' and '2026-04-01'
and p."isEmailVerified" = true
and p."panelistId" = 153078
and atd."panelistId" is not null





aff_panelist AS (
    SELECT
        DATE_TRUNC('month', (p."emailVerifyDate" AT TIME ZONE 'America/New_York')) AS month,
        atd."panelistId",
        COUNT(atd.id)                                                           AS hit,
        SUM(atd."cost")                                                         AS recruit_cost,
        MAX(CASE WHEN p."isEmailVerified" = true THEN 1 ELSE 0 END)            AS doi
    FROM "AffiliateTrafficDetails" atd
    INNER JOIN "Panelists" p ON atd."panelistId" = p."panelistId"
    WHERE p."isEmailVerified" = true
      AND p."emailVerifyDate"AT TIME ZONE 'America/New_York' >= '2026-03-01'
      AND atd."createdAt"AT TIME ZONE 'America/New_York' >= '2025-03-01' 
      AND p."emailVerifyDate" <  NOW()
    GROUP BY 1,2
)












select * from "Panelists" p where p."panelistId" = 140826



select * from "AffiliateTrafficDetails" atd where atd."panelistId" = 68325


select * from "PanelistPointHistories" pph limit 30

select * from "AffiliateMasterDetails" amd 

select case when atd."campaignId" is not null then atd."campaignId"  atd."subCampaignId"   from "AffiliateTrafficDetails" atd 

select * from "Countries" c 