select 
(case when p."sourceId" is null then 99 else p."sourceId" end)as "Source",
sum(case when usp."userStatus" is not null then 1 else 0 end)as "Starts",
sum(case when usp."userStatus" = 2 then 1 else 0 end )as "Completes"
from "Panelists" p
	left join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId"
	group by p."sourceId"
	
	

	
select amd."affiliateName",count(atd.id) from "AffiliateMasterDetails" amd 
left join "AffiliateTrafficDetails" atd on atd."affiliateId" = amd.id 
group by amd."affiliateName" 
	


select 
amd."affiliateName",
count(atd.id) as "Hits", 
ps."Source",
ps."Starts", 
ps."Completes" 
from "AffiliateMasterDetails" amd 
left join "AffiliateTrafficDetails" atd on atd."affiliateId" = amd.id 
inner join(select 
	COALESCE(p."sourceId", 99) AS "Source",
	sum(case when usp."userStatus" is not null then 1 else 0 end)as "Starts",
	sum(case when usp."userStatus" = 2 then 1 else 0 end )as "Completes",
	p."sourceId" 
	from "Panelists" p
	left join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId"
	group by p."sourceId") ps on  ps."sourceId" = atd."affiliateId"  
group by 
ps."Source",
ps."Starts",
ps."Completes",
amd."affiliateName" 






select (case when p."sourceId" is not null then p."sourceId" end) as "SourceId",
(case when p."sourceId" is not null then p."joinDate" end)as "JoinDate",
uspp."Starts", uspp."Completes"    
from  "AffiliateTrafficDetails" atd 
left join "Panelists" p on atd."panelistId" = p."panelistId" 
left join(select sum(case when usp."userStatus" is not null and p."sourceId" is not null then 1 end)as "Starts",
	sum(case when usp."userStatus" = 2 and p."sourceId" is not null then 1  end )as "Completes",usp."panelistId"  
	from "UserSurveyParticipations" usp left join "Panelists" p on usp."panelistId" = p."panelistId" 
	group by usp."panelistId"  )uspp  
	on p."panelistId" = uspp."panelistId"




drop view if exists Affiliate_test 	
	
	



select 
atd."affiliateId",
amd."affiliateName", 
DATE(atd."createdAt") as "date",
amd."cost" as "Affiliate_Cost",
count(distinct(atd."panelistId"))as "join",
sum(case when usp."userStatus" is not null then 1 else 0 end)as "Starts",
sum(case when usp."userStatus" = 2 then 1 else 0 end )as "Completes",
sum(case when usp."userStatus" = 2 and atd."affiliateId" is not null then usp."cpi" else 0 end)as "Cost",
sum(case when usp."userStatus" = 2 and atd."affiliateId" is not null then usp."ccpi" else 0 end)as "Revenue",
sum(case when usp."isReconcile" = true then 1 else 0 end) as "Reconcile"
from "AffiliateTrafficDetails" atd
left join "UserSurveyParticipations" usp  on atd."panelistId" = usp."panelistId" 
left join "AffiliateMasterDetails" amd on atd."affiliateId"  = amd.id
group by atd."affiliateId",amd."affiliateName", DATE(atd."createdAt"),amd."cost"
 order by "date" desc


select 
(case when p."sourceId" is not null then p."sourceId" end) as "AffiliateId"  ,
count(case when p."sourceId" is not null and p."isActive" is true then 1 else 0 end) as "ActiveStatus",
count(case when p."sourceId" is not null and p."isEmailVerified" is true then 1 else 0 end) as EmailVerified,
p."categoryType",
c."countryName",
DATE(p."createdAt") as "Date" 
from "Panelists" p 
left join "Countries" c ON p."countryId" = c."countryId"
group by p."sourceId", p."categoryType", c."countryName",p."createdAt"   
limit 10



select 
p."sourceId",
p."isActive",
p."isEmailVerified",
p."joinDate",
p."categoryType",
c."countryName",
p."createdAt" 
from "Panelists" p 
left join "Countries" c ON p."countryId" = c."countryId"      
limit 10

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
order by "date" desc
 
 
 select sum(case when usp."userStatus" is not null then 1 else 0 end)as "Starts"
 from "AffiliateTrafficDetails" atd 
 left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId" 
 left join "AffiliateMasterDetails" amd on atd."affiliateId"  = amd.id
 where atd."createdAt" > '2026-01-28 10:00'

 
 select count(case when usp."userStatus" is not null and case when atd."affiliateId" is not null then 1 else 0 end) as "Starts" 
 from "AffiliateTrafficDetails" atd left join "UserSurveyParticipations" usp on usp."panelistId" = atd."panelistId" 
  where atd."createdAt" > '2026-01-28'

 
 
 select sum(case when usp."userStatus" is not null and atd."affiliateId" is not null then 1 else 0 end)as "Starts"
 from "AffiliateTrafficDetails" atd  
 left join "UserSurveyParticipations" usp  on atd."panelistId" = usp."panelistId" 
 left join "AffiliateMasterDetails" amd on atd."affiliateId"  = amd.id 
 where atd."createdAt" > '2026-01-28 10:00'

 select * from test t limit 20
 select count(*) from livereports_pi limit 20
 
 
select count(usp.id) from "AffiliateTrafficDetails" atd left join "UserSurveyParticipations" usp on atd."panelistId" = usp."panelistId" 
where atd."createdAt" between '2025-11-01' and '2025-11-30'
 
 

 

select * from "AffiliateTrafficDetails" atd 
where atd."createdAt" > '2026-01-27 10:30'
 
 
 
 select sum(at."Starts") from Affiliate_test at limit 10
 select * from Affiliate_test at limit 10
 select count(*) from Affiliate_test at
 
 select count(distinct(case when p."sourceId" is not null and p."isEmailVerified" = true  then p."panelistId"  else 0 end))
 from "Panelists" p 



--select p."sourceId",p."joinDate",(case when p."sourceId" is not null then 0 end)as "Start",
--(case when p."sourceId" is not null then ps."Completes" end)as "Complete" from "Panelists" p 
--(select count(case when usp."userStatus" is not null then 1 else 0 end)as "Starts",
--	count(case when usp."userStatus" = 2 then 1 else 0 end )as "Completes",
--	usp."panelistId" 
--	from "UserSurveyParticipations" usp
--where usp."updatedAt" > '2026-01-01 10:30' group by usp."panelistId", usp."updatedAt") ps 
--on ps."panelistId" = p."panelistId"

select * from "UserSurveyParticipations" usp  limit 10


select amd."affiliateName"  from "AffiliateMasterDetails" amd limit 10

select * from livereports_pi lp 

select distinct lp."date" ,sum(lp.starts),sum(lp.complete) from livereport_pi lp 

select * from "AffiliateTrafficDetails" atd  order by atd."createdAt" desc limit 10
select * from "AffiliateMasterDetails" amd
select * from "Panelists" p limit 10

	left join "AffiliateMasterDetails" amd on amd.id= atd."affiliateId" 
	group by p."sourceId", amd."affiliateName" 
	
select * from live_survey_count lsc 
	
	
select * from affiliate_PBI limit 10
