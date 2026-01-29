select * from livereports_pi lp where lp."date" between '2026-01-13' and '2026-01-14'

select * from "Panelists" p limit 10 where 

select * from "UserSurveyParticipations" usp limit 10

select * from livereport_pi lp where lp."date" between '2026-01-12' and '2026-01-20'

select * from live_survey_count lsc

select * from livereports_pi lp 

select sum(amd.id )as count,sum(amd."cost") as cost,amd."affiliateName",amd."panelId"   
from "AffiliateMasterDetails" amd 
group by amd.id, amd."cost", amd."affiliateName" 

select * from "AffiliateMasterDetails" amd limit 100

select count(case when usp."userStatus" is not null then 1 else 0 end)as starts  from "UserSurveyParticipations" usp
where (usp."createdAt" AT TIME ZONE 'America/New_York')::date > CURRENT_DATE - INTERVAL '7 days'


select sum(case when usp."userStatus" is not null then 1 else 0 end)as starts,
sum(case when usp."userStatus" = 2 then 1 else 0 end )as completes,p."sourceId" 
from "UserSurveyParticipations" usp left join "Panelists" p on p."panelistId" = usp."panelistId" 
left join "AffiliateTrafficDetails" atd on atd."affiliateId" = p."sourceId" 
where usp."updatedAt" > '2026-01-20 10:30'group by usp."userStatus",usp.

select * from "Panelists" p 
where (p."joinDate" AT TIME ZONE 'America/New_York')::time  > CURRENT_TIME - INTERVAL '1 DAY' 


select count(distinct (p."panelistId")) from "Panelists" p 
inner join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId" 
where  p."joinDate" > '2026-01-20 10:30'

select distinct p.*  from "Panelists" p 
inner join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId" 
where  p."joinDate" > '2026-01-20 10:30'

select  
from "AffiliateTrafficDetails" atd 
left join "Panelists" p on p."sourceId" = atd."affiliateId"
left join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId"
 

select count(atd.id),count(atd."panelistId") from "AffiliateTrafficDetails" atd
inner join "Panelists" p  on atd."affiliateId" = p."sourceId" 
where atd."updatedAt" > '2026-01-20 10:30'



select count(distinct(atd.id))as"Traffic", count(distinct(atd."panelistId"))as"Join",
count(distinct(case when p."sourceId" is not null and p."isEmailVerified" = true and p."joinDate" > '2026-01-20 10:30' then p."panelistId"  else 0 end))as "DOI"
from "AffiliateTrafficDetails" atd 
inner join "Panelists" p on atd."affiliateId" = p."sourceId" 
where atd."updatedAt" > '2026-01-21 10:30' 



select count(case when p."isEmailVerified" is true then 1 else 0 end) from "Panelists" p 
where p."joinDate" > '2026-01-20 10:30' and p."sourceId" is not null



select (case when p."sourceId" is null then 99 else p."sourceId" end) 




select (case when p."sourceId" is null then 99 else p."sourceId" end) , 
amd."affiliateName",
count(atd.id) as "Hits",
sum(case when usp."userStatus" is not null then 1 else 0 end)as "Starts",
sum(case when usp."userStatus" = 2 then 1 else 0 end )as "Completes",
sum(case when usp."userStatus" = 2 then usp.ccpi else 0 end )as "Revenue",
sum(case when usp."userStatus" = 2 then usp.cpi  else 0 end ) as "Cost",
sum(case when usp."isReconcile" = true then 1 else 0 end) as "Reconcile",
count(distinct(atd.id))as Traffic,
count(distinct(atd."panelistId"))as join,
count(distinct(case when p."sourceId" is not null and p."isEmailVerified" = true  then p."panelistId"  else 0 end))
from "AffiliateTrafficDetails" atd 
inner join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
inner join "Panelists" p on atd."affiliateId" = p."sourceId" 
left join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId"
group by p."sourceId",amd."affiliateName" 



select count(atd.id) as Traffic,count(distinct(atd."panelistId"))as"Join" from "AffiliateTrafficDetails" atd use


select sum(case when p."sourceId" is not null  then usp.ccpi else 0 end)as revenue  
from "Panelists" p left join "UserSurveyParticipations" usp on p."panelistId" = usp."panelistId" 
where usp."userStatus" = 2

select * from "UserSurveyParticipations" usp limit 10
select * from "Panelists" p limit 10
select * from "CampaignParticipations" limit 10
select * from "AffiliateTrafficDetails" limit 10
select * from "AffiliateMasterDetails" amd  limit 10

select count(atd.) from "AffiliateTrafficDetails" atd where atd."updatedAt"  between '2026-01-15' and '2026-01-20'
left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
where atd."createdAt" between '2026-01-01' and '2026-01-20'