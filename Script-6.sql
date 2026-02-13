with affiliate as(select distinct count(atd."panelistId")as ID,
sum(atd."cost")as recruit_cost 
from "AffiliateTrafficDetails" atd 
left join "Panelists" p on atd."panelistId" = p."panelistId"
left join "AffiliateMasterDetails" amd on amd.id = atd."affiliateId" 
where p."isEmailVerified"= true and p."sourceId"  is not null  )
select * from affiliate at



select count(*),sum(aa."cost")  from affiliate_aff aa 
left join panelist_aff pa on aa."panelistId" = pa."User_id" 
where pa."EmailV" = true


select * from emailsenddetails e 
select * from emailsendsummary es

select count(*) from "EmailRecipientsLogs" erl where erl."sentDate" between '2026-02-09 10:30' and '2026-02-10 10:30'


select * from "UserSurveyParticipations" usp limit 50


select sum(atd."cost")  from "AffiliateTrafficDetails" atd


select count(*) from panelist_aff pa where pa."EmailV" = true




select count(atd."panelistId") from "AffiliateTrafficDetails" atd 
