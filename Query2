
    
select p."panelistId" ,p."firstName"||' '||p."lastName" as name,
	p.email , usp.ccpi as Cost,sum(usp.cpi) as Revenue ,sum(usp.ccpi - usp.cpi) as profit 
from "Panelists" p 
join "UserSurveyParticipations" usp on p."panelistId" = usp."panelistId" group by p."panelistId",usp.cpi ,usp.ccpi  ;


SELECT 
    p."panelistId",
    usp."userStatus", 
    MAX(p."firstName" || ' ' || p."lastName") AS name,
    MAX(p.email) AS email,
    SUM(usp.ccpi) AS revenue,
    SUM(usp.cpi) AS cost,
    SUM(usp.ccpi - usp.cpi) AS profit
FROM 
    "Panelists" p
JOIN 
    "UserSurveyParticipations" usp ON p."panelistId" = usp."panelistId"
GROUP BY 
    p."panelistId",
   	usp."userStatus" ;
    
--select * from "UserStatuses" us 
   
 

select "panelistId", "firstName"|| ' '||"lastName" as Name, dailyrankings 
from "Panelists" p join dailyrankings d2  on p."panelistId" =  ;   

select * from dailyrankings d 
select * from dailyrankings d2 
select * from "Panelists" p 

select * from dailyrankings d 


select * from dailyrankings
   select D.drdailyrank  from dailyrank d  
   
   
  
   
select pph."panelistId",
				case when pph."pointTypeId" != 1
				then sum(pph.points) end
				 as individual_Point_sum 
		from "PanelistPointHistories" pph 
	   group by "panelistId","pointTypeId";
   
 select * from "PanelistPointHistories" pph 
   
 
 
SELECT
    p."panelistId",
				case when pph."pointTypeId" != 1
				then sum(pph.points) end
				as indivisual_point_sum,
				
    MAX(p."firstName" || ' ' || p."lastName") AS name,
    MAX(p.email) AS email,
--    SUM(usp.ccpi) AS revenue2,
    SUM(case when USP."userStatus" = 2 then usp.ccpi else 0 END) as REVENUE,
    COUNT(p."panelistId") AS START,
--    SUM(usp.cpi) AS cost2,
    SUM(case when USP."userStatus" = 2 then USP.CPI else 0 END) as cost,
--    SUM(usp.ccpi - usp.cpi) AS profit2,
    sum(case when usp."userStatus" = 2 then (usp.ccpi - usp.cpi)else 0 end) as PROFIT,
    COUNT(CASE WHEN usp."userStatus" = 2 THEN 1 END) AS complete
FROM
    "Panelists" p
left join "PanelistPointHistories" pph on p."panelistId" = pph."panelistId"  
JOIN
    "UserSurveyParticipations" usp ON p."panelistId" = usp."panelistId"
GROUP BY
    p."panelistId", pph."pointTypeId";

   
   
   
SUM(CASE WHEN usp."userStatus" = 2 THEN (usp.ccpi - usp.cpi) END) AS profit2,

   
   
select * FROM 
    "Panelists" p
JOIN 
    "UserSurveyParticipations" usp ON p."panelistId" = usp."panelistId" ;   
    
   
   
   
select * from "DailyRankings";
