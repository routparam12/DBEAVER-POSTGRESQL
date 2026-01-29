select "panelistId", "firstName"|| ' ' ||"lastName" as Name,COALESCE("dailyrank",0) as Dailyrank,coalesce("report_date",'2025-08-20') as Date_reported
from "Panelists" p 
left join dailyrankings d 
on p."panelistId" = d.panelistid where date(report_date)= date '2025-08-20' ;


select "panelistId", "firstName"|| ' ' ||"lastName" as Name,COALESCE("dailyrank",0) as Dailyrank,
coalesce("report_date",'2025-08-19') as Date_submission
from "Panelists" p 
left join dailyrankings d 
on p."panelistId" = d.panelistid 
and d.report_date BETWEEN DATE '2025-08-20' AND DATE '2025-08-27'
order by "report_date" desc nulls last;


WITH date_range AS (
    SELECT generate_series(
        DATE '2025-08-20', 
        current_date, 
        INTERVAL '1 day'
    )::DATE AS report_date
)
select coalesce(p."panelistId",171)as "panelistId" ,
coalesce(P."firstName"|| ' ' ||P."lastName",'Mohit Singh') as Name,
COALESCE("dailyrank",0) as Dailyrank,
dr.report_date as Date_submission
from date_range dr
cross join "Panelists" p 
left join dailyrankings d 
	on p."panelistId" = d.panelistid 
	AND d.report_date = dr.report_date
where P."panelistId" = 171
order by dr.report_date desc;



,coalesce("report_date",'2025-10-28') as report_date
select * from "Panelists" p 
select * from dailyrankings d where date(report_date)= date '2025-08-20';


select "panelistId", "firstName"|| ' '||"lastName" as Name, dailyrankings 
from "Panelists" p left join dailyrankings d2  on p."panelistId" =  ;   


select * from "PointTypes" pt limit 100;


select * from "UserSurveyParticipations" usp  order by  usp."createdAt"  desc  limit 100;


select  
* 
from 
"Panelists" p  left join "UserSurveyParticipations" usp 
on usp."panelistId" = p."panelistId" 

where p."panelistId" = 139726  ;


select  
p."panelistId" ,sum(usp."completedPoints")
from 
"Panelists" p  
left join "UserSurveyParticipations" usp on p."panelistId" = usp."panelistId" 
where p."panelistId" = 171 
group by p."panelistId" ;

select pph."panelistId", sum(pph.points) as total_points
from "PanelistPointHistories" pph 
where pph."panelistId"= 171 and pph."pointTypeId" <> 1 
group by pph."panelistId"  ; 


select count("panelistId") from "Panelists" p where p."createdAt" >= '12-29-2025';



select * from "UserSurveyParticipations" usp where usp."createdAt"  >= '12-29-2025';



select s.starts,s.complete,p.points,s.cpi,round(s.ccpi) as ccpi
from (select 
count(usp."userStatus") AS starts,
sum(case when usp."userStatus"=2  then usp."cpi" else 0 end)as cpi,
sum(case when usp."userStatus"=2  then usp."ccpi"else 0 end)as ccpi,
count(case when usp."userStatus"=2 then 1 end)as Complete
from "UserSurveyParticipations" usp 
where usp."updatedAt" > '12-01-2025') s
cross join (select sum(pph."points") as points
from "PanelistPointHistories" pph 
where pph."createdAt" > '12-01-2025' ) p ;




select sum(pph.points) from "PanelistPointHistories" pph where pph."createdAt" > '12-29-2025';

select * from "PointTypes" pt

select * from "PanelistPointHistories" pph join "Panelists" p on pph."panelistId" = p."panelistId" where p."panelistId" = 139726 ;

select * from "PanelistPointHistories" pph join "Panelists" p on pph."panelistId" = p."panelistId" order by p."createdAt" desc limit 100;

select * from "PanelistPointHistories" pph order by pph."createdAt" desc limit 100;



select
distinct amd."affiliateName", p."sourceId",
count (distinct(case when p."sourceId" is not null then p."panelistId" end))as panelist_count,
count(usp."userStatus")as Starts,
count(case when usp."userStatus" = 2 then 1 end)as complete
from "Panelists" p left join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId" 
left join "AffiliateTrafficDetails" atd on atd."panelistId"  = p."panelistId"  
left join "AffiliateMasterDetails" amd on amd.id = atd."affiliateId"  
where p."sourceId" is not null and p."joinDate" > '2025-12-01'
group by amd."affiliateName", p."sourceId" 





select
distinct amd."affiliateName", p."sourceId",
count (distinct(case when p."sourceId" is not null then p."panelistId" end))as panelist_count,
count(usp."userStatus")as Starts,
count(case when usp."userStatus" = 2 then 1 end)as complete,
sum(case when usp."userStatus"  = 2 then usp.cpi  end) as cpi, sum(case when usp."userStatus"  = 2 then usp.ccpi end ) as ccpi,	
sum(case when usp."userStatus"=2 then (usp.ccpi - usp.cpi) end )as profit
from "Panelists" p left join "UserSurveyParticipations" usp on usp."panelistId" = p."panelistId" 
left join "AffiliateTrafficDetails" atd on atd."panelistId"  = p."panelistId"  
left join "AffiliateMasterDetails" amd on amd.id = atd."affiliateId"  
where p."sourceId" is not null and p."joinDate" > '2025-12-01'
group by amd."affiliateName", p."sourceId" 



select count(atd."affiliateId") as Daily_affiliate_count,
--date_trunc('day',(atd."createdAt"))as dates
atd."createdAt"::date as dates
from "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
where atd."createdAt" >= '2025-12-01' and atd."createdAt"<'2026-01-01' 
group by dates
order by  dates




select count(atd.id) from "AffiliateTrafficDetails" atd 
left join "AffiliateMasterDetails" amd 
on atd."affiliateId" = amd.id 
where atd."affiliateId" = 22


select * from "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id 
where atd."createdAt" > '2025-11-30' and atd."createdAt" < '2026-01-01'


select * from "AffiliateTrafficDetails" atd order by atd."createdAt" desc limit 10


select usp."panelistId", sum(usp."completedPoints") as Points, 
p."sourceId" AS source from "UserSurveyParticipations" usp
left join "Panelists" p on p."panelistId" = usp."panelistId" 
where usp."panelistId" = 137272 group by usp."panelistId",p."sourceId" 


select * from "Panelists" p limit 10
select * from "UserSurveyParticipations" usp limit 100
select * from "PanelistPointHistories" pph limit 100
select * from "AffiliateTrafficDetails" atd limit 10
select * from "AffiliateMasterDetails" amd  limit 100


select count(usp."panelistId")as total_people,sum(usp.cpi)as cpi ,sum(usp.ccpi)as ccpi from "UserSurveyParticipations" usp where usp."createdAt" > '12-30-2025';

select * from "UserSurveyParticipations" usp where usp."userStatus" = 16 and usp."createdAt" > '2025-12-01';

select distinct us."userStatus", usp."userStatus",
count(usp."userStatus")
from "UserStatuses" us 
join "UserSurveyParticipations" usp on us.id = usp."userStatus" 
where usp."createdAt" > '2025-12-01' group by us."userStatus",usp."userStatus" ;

select count(trrh."panelistRedemRequestId"),sum(trrh.amount),trrh from "TangoRedemptionRequestHistories" trrh where trrh."createdAt" > '2025-12-30' ;

select * from "Campaigns" c  limit 100
