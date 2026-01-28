select* from    
    (select atd."campaignId",count(atd."id") as TotalHit,count(distinct(atd."ipAddress")) as UniqueHit,
    sum(case when atd."panelistId" is not null then 1 else 0 end) as Joined,
    sum(case when atd."panelistId" is not null and p."isEmailVerified" ='true' then 1 else 0 end) as DOI
    from "AffiliateTrafficDetails" atd
    left join "Panelists" p on p."panelistId" =atd."panelistId"
    where atd."affiliateId" in (22)
    --and date_part('year', atd."createdAt") = 2025
    --and date_part('month', atd."createdAt") = 8
    --and atd."countryCode" IN ('US')
    group by atd."campaignId") a
   
    left join (
    select ass."campaignId",count(usp."id") as starts,
    sum(case when usp."userStatus" = 2 then 1 else 0 end) as Completes,
    sum(case when usp."userStatus" = 9 then 1 else 0 end) as SecurityTerm,
    sum(case when usp."userStatus" = 16 then 1 else 0 end) as Reconcile
    from "AffiliateTrafficDetails" ass
    inner join "UserSurveyParticipations" usp on ass."panelistId"=usp."panelistId"
    where ass."affiliateId" in (22)
    --and date_part('year', ass."createdAt") = 2025
    --and date_part('month', ass."createdAt") = 8
    --and ass."countryCode" IN ('US')
    group by ass."campaignId") b on b."campaignId"=a."campaignId"
    
    
    
    
     select* from    
    (select atd."subCampaignId" ,count(atd."id") as TotalHit,count(distinct(atd."ipAddress")) as UniqueHit,
    sum(case when atd."panelistId" is not null then 1 else 0 end) as Joined,
    sum(case when atd."panelistId" is not null and p."isEmailVerified" ='true' then 1 else 0 end) as DOI
    from "AffiliateTrafficDetails" atd
    left join "Panelists" p on p."panelistId" =atd."panelistId"
    where atd."affiliateId" in (22)
    --and date_part('year', atd."createdAt") = 2025
    --and date_part('month', atd."createdAt") = 8
    --and atd."subCampaignId" IN ('US')
    group by atd."subCampaignId") a
   
    left join (
    select ass."subCampaignId",count(usp."id") as starts,
    sum(case when usp."userStatus" = 2 then 1 else 0 end) as Completes,
    sum(case when usp."userStatus" = 9 then 1 else 0 end) as SecurityTerm,
    sum(case when usp."userStatus" = 16 then 1 else 0 end) as Reconcile
    from "AffiliateTrafficDetails" ass
    inner join "UserSurveyParticipations" usp on ass."panelistId"=usp."panelistId"
    where ass."affiliateId" in (22)
   -- and date_part('year', ass."createdAt") = 2025
   -- and date_part('month', ass."createdAt") = 8
   -- and ass."countryCode" IN ('US')
    group by ass."subCampaignId") b on b."subCampaignId"=a."subCampaignId"
