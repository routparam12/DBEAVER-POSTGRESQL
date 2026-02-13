-- Fact_AffiliateTraffic AS
with affiliateTraffic as 
	(select 
    atd.id AS trafficId,
    atd."panelistId",
    atd."affiliateId",
    amd."affiliateName" AS affiliate,
    amd.cost AS affiliatecost,
    atd."createdAt" AS trafficDate,
    atd."updatedAt",
    atd."ipAddress" AS uniquehits,
    atd.cost,
    atd.id AS hits
FROM "AffiliateTrafficDetails" atd
LEFT JOIN "AffiliateMasterDetails" amd
    ON amd.id = atd."affiliateId"
WHERE amd."affiliateName" IS NOT null)
select count(*) as traffic_rows from affiliateTraffic 






-- Dim_Panelist AS
with panelists as 
	(SELECT
    p."panelistId",
    p."isActive",
    p."joinDate",
    p."isEmailVerified",
    p.email,
    p."countryId",
    c."countryName",
    p."categoryType",
    ct."categoryType" AS category_name,

    -- First-touch affiliate mapping
    fa."affiliateId"

FROM "Panelists" p
LEFT JOIN "Countries" c 
    ON p."countryId" = c."countryId"
LEFT JOIN "CategoryTypes" ct 
    ON ct.id = p."categoryType"
LEFT JOIN (
    SELECT DISTINCT ON ("panelistId")
        "panelistId",
        "affiliateId"
    FROM "AffiliateTrafficDetails"
    ORDER BY "panelistId", "createdAt") fa 
    ON fa."panelistId" = p."panelistId") 
    select count(*) as rownum from panelists





-- Fact_SurveyActivity AS
with SurveyActivity as (SELECT
    usp.id AS surveyId,
    usp."panelistId",
    usp."createdAt" AS surveyDate,

    CASE WHEN usp."userStatus" IS NOT NULL THEN 1 ELSE 0 END AS starts,
    CASE WHEN usp."userStatus" = 2 THEN 1 ELSE 0 END AS complete,
    CASE WHEN usp."userStatus" = 2 THEN usp.ccpi ELSE 0 END AS revenue,
    CASE WHEN usp."userStatus" = 2 THEN usp.cpi ELSE 0 END AS cost,
    CASE WHEN usp."userStatus" = 16 THEN usp.cpi ELSE 0 END AS reconcilecost,
    CASE WHEN usp."userStatus" = 16 THEN 1 ELSE 0 END AS reconcile

FROM "UserSurveyParticipations" usp)
select count(*) from SurveyActivity





-- Fact_RedemptionActivity AS
with redemptionActivity as 
(SELECT
    prr.id AS redemptionId,
    prr."panelistId",
    prr."createdAt" AS redemptionDate,

    CASE
        WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
        THEN prr.amount
        ELSE 0
    END AS redeemedpoint

FROM "PanelistRedemptionRequests" prr) 
select count(*) from redemptionActivity







with affiliate_powerbi AS 
(SELECT p."panelistId",
    p."isActive",
        CASE
            WHEN p."isActive" = true THEN p."panelistId"
            ELSE NULL::integer
        END AS isactivepanelist,
    p."joinDate",
    to_char(p."joinDate", 'Mon'::text) AS month,
    ct."categoryType",
    usp.id AS starts,
        CASE
            WHEN usp."userStatus" = 2 THEN 1
            ELSE 0
        END AS complete,
    amd."affiliateName" AS affiliate,
    amd.cost AS affiliatecost,
    amd.id,
    atd.id AS hits,
    atd."ipAddress" AS uniquehits,
        CASE
            WHEN p."isEmailVerified" = true THEN p.email
            ELSE NULL::character varying
        END AS doi,
        CASE
            WHEN usp."userStatus" = 2 THEN usp.ccpi
            ELSE 0::numeric
        END AS revenue,
        CASE
            WHEN usp."userStatus" = 2 THEN usp.cpi
            ELSE 0::numeric
        END AS cost,
        CASE
            WHEN usp."userStatus" = 16 THEN usp.cpi
            ELSE 0::numeric
        END AS reconcilecost,
        CASE
            WHEN usp."userStatus" = 16 THEN 1
            ELSE 0
        END AS reconcile,
    usp."createdAt" AS uspcreatedat,
    atd."createdAt" AS atdcreatedat,
    atd."updatedAt",
    c."countryName"
   FROM "AffiliateTrafficDetails" atd
     LEFT JOIN "Panelists" p ON p."panelistId" = atd."panelistId"
     LEFT JOIN "AffiliateMasterDetails" amd ON amd.id = atd."affiliateId"
     LEFT JOIN "UserSurveyParticipations" usp ON usp."panelistId" = p."panelistId"
     LEFT JOIN "Countries" c ON p."countryId" = c."countryId"
     LEFT JOIN "CategoryTypes" ct ON ct.id = p."categoryType"
  WHERE amd."affiliateName" IS NOT null)
  select count(*) from affiliate_powerbi 

  
  
select count(*) from redeempbi r limit 50


select count(*) from affiliate_pbi ap 


with testing as(SELECT 
    amd."affiliateName",
    atd."affiliateId",
    atd."panelistId",

    COALESCE(prr.redeemed_total,0) AS "Redeemed",
    prr.first_redeem_date AS RedeemedAT,

    atd."createdAt" AS AffiliateAT,
    p."createdAt" AS panelistAT

FROM "AffiliateTrafficDetails" atd
LEFT JOIN "Panelists" p 
    ON p."panelistId" = atd."panelistId"
LEFT JOIN "AffiliateMasterDetails" amd 
    ON amd.id = atd."affiliateId"

LEFT JOIN (
    SELECT
        "panelistId",
        SUM(CASE
            WHEN status = 'approved'::"enum_PanelistRedemptionRequests_status"
            THEN amount ELSE 0 END) AS redeemed_total,
        MIN("createdAt") AS first_redeem_date
    FROM "PanelistRedemptionRequests"
    GROUP BY "panelistId"
) prr 
    ON prr."panelistId" = atd."panelistId"

WHERE amd."affiliateName" IS NOT NULL;
 )
     select count(*) from testing 
     

     
    
------------------------------------------     
 drop view if exists panelist_aff
     
     
select * from panelist_aff pa       
-----------------------------------------------------------------------------------------------------------     

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
where p."sourceId" is not null;  
     

select * from Panelist_aff limit 50

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
COALESCE(ph."PPH_Point" , 0) AS "PPH_Point_Value",
po."Games_rev" 
from "Panelists" p
left join "Countries" c on p."countryId"= c."countryId"
left join "CategoryTypes" ct on p."categoryType" = ct.id 
left join (select pph."panelistId",
			sum(case when pph."pointTypeId" <> 1 then points/100.0 else 0 end) as "PPH_Point"
			from "PanelistPointHistories" pph group by pph."panelistId")ph on p."panelistId" = ph."panelistId" 
			left join (select pop."panelistId",
			sum(((coalesce(pop."pointsAwarded",0)/100.0)/NULLIF(pop.cpi,0))* pop.ccpi) as "Games_rev" 
			from "PanelistOfferProgresses" pop  
			where pop.status = 'COMPLETED' and pop.completed = true 
			group by pop."panelistId" ) as Po on po."panelistId" = p."panelistId"
where p."sourceId" is not null






WITH usp_monthly AS (
    SELECT
        usp."panelistId",
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') AS "UspActivityMonth"
    FROM "UserSurveyParticipations" usp
    GROUP BY
        usp."panelistId",
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York')
)
SELECT
    um."panelistId",
    um."UspActivityMonth",
    DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS "AtdCreatedAt"
FROM usp_monthly um
INNER JOIN "AffiliateTrafficDetails" atd 
    ON um."panelistId" = atd."panelistId"








select 
prr.id as "Redemption_id",
prr."panelistId",
(prr."createdAt"  AT TIME ZONE 'America/New_York'::text) as "Redemption_date",
(case WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status" THEN prr.amount 
            ELSE 0
        END )AS "Redeemed"
from "PanelistRedemptionRequests" prr      

select * from "PanelistRedemptionRequests" prr 


select
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
where amd."affiliateName" is not null




-------------------------------------------------------------------------------------


select * from "EmailBatches" eb where eb."emailType" = 2 order by eb.id desc  limit 10



-- public.emailsenddetails source


SELECT to_char(timezone('UTC'::text, eb."createdAt")::date + '1 day'::interval, 'YYYY-MM-DD'::text) AS newdate,
    to_char(timezone('UTC'::text, eb."createdAt")::date::timestamp with time zone, 'YYYY-MM-DD'::text) AS todaydate,
    sum(
        CASE
            WHEN eb."emailType" = 1 THEN eb."batchSize"::integer
            ELSE 0
        END) AS autobatchsize,
    sum(
        CASE
            WHEN eb."emailType" = 1 THEN eb."actualSent"::integer
            ELSE 0
        END) AS autoactualsent,
    sum(
        CASE
            WHEN eb."emailType" = 2 THEN eb."batchSize"::integer
            ELSE 0
        END) AS manualbatchsize,
    sum(
        CASE
            WHEN eb."emailType" = 2 THEN eb."actualSent"::integer
            ELSE 0
        END) AS manualactualsent,
    sum(
        CASE
            WHEN eb."emailType" = 3 THEN eb."batchSize"::integer
            ELSE 0
        END) AS genericbatchsize,
    sum(
        CASE
            WHEN eb."emailType" = 3 THEN eb."actualSent"::integer
            ELSE 0
        END) AS genericactualsent,
    max(eb."updatedAt") AS latestupdatedat,
    max(eb."createdAt") AS latestcreatedat
   FROM "EmailBatches" eb
  GROUP BY (timezone('UTC'::text, eb."createdAt")::date)
  ORDER BY (to_char(timezone('UTC'::text, eb."createdAt")::date::timestamp with time zone, 'YYYY-MM-DD'::text)) DESC;
