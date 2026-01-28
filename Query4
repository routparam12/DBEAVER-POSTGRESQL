SELECT DISTINCT
    "panelistId",
    DATE("participateTime") AS "participateDate"
FROM "UserSurveyParticipations" usp
WHERE DATE("participateTime") > '2025-10-20'
LIMIT 100

select * from "PanelSurveys" ps limit 100

select * from "UserSurveyParticipations" usp limit 100;


select usp.id,usp."surveyId",usp."panelistId", usp."userStatus",usp.cpi ,usp."participateTime" , 
usp.ccpi,usp."isReconcile" 
from "UserSurveyParticipations" usp 
limit 100

  select usp.id,
  SUM(CASE WHEN "userStatus" = 2 THEN 1 ELSE 0 END) AS complete, 
  sum(case when usp."userStatus" = 2 then usp.cpi else 0 end) as cost ,
  sum(case when usp."userStatus" = 2 then usp.ccpi else 0 end) as revenue,
  CAST(usp."participateTime" AS DATE) AS start_date, usp."createdAt"  
 	from "UserSurveyParticipations"usp
  where usp."participateTime"  > NOW() - INTERVAL '7 days'
  group by usp.id ;
  INNER JOIN "PanelSurveys" ps ON ps.id = usp."surveyId"
 
 
  select
  usp.id, 
  usp."userStatus" ,usp."surveyId", 
  usp.cpi,usp.ccpi,
  CAST(usp."participateTime" AS DATE) AS Survey_date
 	from "UserSurveyParticipations"usp 
  where usp."participateTime" > current_date - INTERVAL '7 days'
  group by usp.id,usp.cpi,usp.ccpi,usp."participateTime" limit 100;
  
 
  select usp.id,usp."surveyId", usp."userStatus",usp.cpi ,CAST(usp."createdAt" AS DATE) AS start_date,
  cast(usp."createdAt" as TIME)as Hour,usp."createdAt",
  usp.ccpi from "UserSurveyParticipations"usp
WHERE usp."createdAt" > current_date  - INTERVAL '7 days'


