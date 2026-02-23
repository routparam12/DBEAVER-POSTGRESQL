select 
count(usp."userStatus") as "Start",
count(case when usp."userStatus"= 2 then 1 end) as "complete",
count(distinct(atd."panelistId" ))as "Join",
SUM(CASE WHEN usp."userStatus" = 2 THEN usp."cpi" END) as "Cost",
SUM(CASE WHEN usp."userStatus" = 2 THEN usp."ccpi" END) as "Revenue",
SUM(CASE WHEN usp."isReconcile" = true THEN 1 END) as "Reconcile",
--amd."cost", amd."affiliateName"
--DATE(atd."createdAt") as "date"
from "AffiliateTrafficDetails" atd  
left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId"
LEFT JOIN "AffiliateMasterDetails" amd ON atd."affiliateId" = amd.id
group by amd.cost,amd."affiliateName", DATE(atd."createdAt") 

-------------------------------------

select
atd."affiliateId",
amd."affiliateName",
DATE(atd."createdAt") as "date",
amd."cost" as "Affiliate_Cost",
count(distinct(atd."panelistId"))as "join",
sum(case when usp."userStatus" is not null and atd."affiliateId" is not null then 1 else 0 end)as "Starts",
sum(case when usp."userStatus" = 2 and atd."affiliateId" is not null then 1 else 0 end )as "Completes",
sum(case when usp."userStatus" = 2 and atd."affiliateId" is not null then usp."cpi" else 0 end)as "Cost",
sum(case when usp."userStatus" = 2 and atd."affiliateId" is not null then usp."ccpi" else 0 end)as "Revenue",
sum(case when usp."isReconcile" = true then 1 else 0 end) as "Reconcile"
from "AffiliateTrafficDetails" atd
left join "UserSurveyParticipations" usp  on atd."panelistId" = usp."panelistId"
left join "AffiliateMasterDetails" amd on atd."affiliateId"  = amd.id
group by atd."affiliateId",amd."affiliateName", DATE(atd."createdAt"),amd."cost"



select * from redeempbi rp limit 50


select count(ap.starts ),sum(ap.complete ) from affiliate_pbi ap 

select amd."affiliateName",atd."panelistId", 
        (CASE
            WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status" THEN prr.amount 
            ELSE 0
        END )AS "Redeemed"
        from "AffiliateTrafficDetails" atd 
left join "PanelistRedemptionRequests" prr on atd."panelistId" = prr."panelistId"
left join "AffiliateMasterDetails" amd on amd.id = atd."affiliateId"
group by amd."affiliateName",atd."panelistId"  


select sum(prr.amount) from "PanelistRedemptionRequests" prr limit 50

select * from "PanelistRedemptionRequests" prr limit 50


select usp."userStatus",usp."isReconcile",usp.cpi,usp.ccpi,usp."panelistId" from "UserSurveyParticipations" usp limit 50

select usp."panelistId",(case when usp."userStatus" is not null then 1 end)as "Starts",
(case when usp."userStatus" = 2 then 1 end )as "Completes",
(case when usp."userStatus" = 2 then usp."cpi" end)as "Cost",
(case when usp."userStatus" = 2 then usp."ccpi" end)as "Revenue",
(case when usp."isReconcile" = true then 1 end) as "Reconcile",
usp."createdAt" 
from "UserSurveyParticipations" usp


select amd."affiliateName",amd.id  from "AffiliateMasterDetails" amd limit 50

select atd."panelistId",atd."createdAt",atd."affiliateId",atd."cost" from "AffiliateTrafficDetails" atd limit 50



select p."panelistId",p."isActive",p."isEmailVerified",
p."sourceId",p."categoryType",p."countryId",p."createdAt" from "Panelists" p 


select usp."panelistId",usp."userStatus",usp."isReconcile",usp."createdAt" 
from "UserSurveyParticipations" usp


select p."panelistId",
(case when p."sourceId" is not null then p."isActive" end) as "Active",
(case when p."sourceId" is not null then p."isEmailVerified" end) as "EmailV",
(case when p."sourceId" is not null then p."sourceId" end) as "SourceId",
(case when p."sourceId" is not null then p."categoryType" end) as "Category",
(case when p."sourceId" is not null then p."countryId" end) as "Country",
(case when p."sourceId" is not null then p."createdAt" end) as "CreatedAt"
from "Panelists" p 


------------------------------------------------------------------------------------
select SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."cpi" ELSE 0 END) as "Cost",
        SUM(CASE WHEN usp."userStatus" = 2 AND atd."affiliateId" IS NOT NULL THEN usp."ccpi" ELSE 0 END) as "Revenue"
from "AffiliateTrafficDetails" atd 
left join "UserSurveyParticipations" usp  on atd."panelistId" = usp."panelistId"




select SUM(CASE WHEN usp."userStatus" = 2 THEN usp."cpi" ELSE 0 END) as "Cost",
        SUM(CASE WHEN usp."userStatus" = 2 THEN usp."ccpi" ELSE 0 END) as "Revenue"
from "AffiliateTrafficDetails" atd 
left join "UserSurveyParticipations" usp  on atd."panelistId" = usp."panelistId"
