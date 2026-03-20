WITH aff_month AS (
    SELECT
        DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
        atd."countryCode",
        amd."affiliateName",
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost
    FROM "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE atd."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
    GROUP BY 1,2,3
),
usp_month AS (
    SELECT
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') AS month,
--        atd."countryCode",
--        amd."affiliateName",
        SUM(CASE WHEN usp."userStatus" = 2  THEN usp."ccpi" ELSE 0 END) AS revenue,
        SUM(CASE WHEN usp."userStatus" = 16 THEN 1 ELSE 0 END) AS reconcile,
        count(usp.id) as Start
    FROM "UserSurveyParticipations" usp
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = usp."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE usp."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
    GROUP BY 1
),
pph_month AS (
    SELECT
        DATE_TRUNC('month', pph."createdAt") AS month,
--        atd."countryCode",
--        amd."affiliateName",
        SUM(
            CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            END
        ) AS point_cost
    FROM "PanelistPointHistories" pph
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = pph."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE pph."createdAt" between '2026-01-01' and '2026-02-01'
    GROUP BY 1
),
prr_month AS (
    SELECT
        DATE_TRUNC('month', prr."createdAt" AT TIME ZONE 'America/New_York') AS month,
--        atd."countryCode",
--        amd."affiliateName",
        SUM(
            CASE WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
                 THEN prr.amount
                 ELSE 0
            END
        ) AS redemption_amount
    FROM "PanelistRedemptionRequests" prr
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = prr."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE prr."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
    GROUP BY 1
),
panelist_month AS(
    select DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York') AS month,
--    atd."countryCode",
--    amd."affiliateName",
    count(case when p."isEmailVerified" = true then 1 end) as Doi
    from "Panelists" p
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = p."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE p."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
    GROUP BY 1
)
SELECT
    TO_CHAR(a.month, 'YYYY-Mon')  AS "Affiliate_month",
    a."countryCode" ,
    a."affiliateName",
    pm.doi AS "Doi",
    p.point_cost AS "Point_cost",
    a.recruit_cost AS "Recruit_cost",
    u.revenue AS "Revenue",
    u."start" as "Start",
    u.reconcile AS "Reconcile",
    r.redemption_amount AS "Redemption_amount"
FROM aff_month a
LEFT JOIN usp_month u  ON u.month = a.month
--					AND u."affiliateName" = a."affiliateName"
--                           AND u."countryCode"  = a."countryCode" 
LEFT JOIN pph_month p  ON p.month = a.month
--						and p."countryCode" =a."countryCode" 
--						and p."affiliateName" = a."affiliateName" 
LEFT JOIN prr_month r  ON r.month = a.month
--						and r."affiliateName" = a."affiliateName" 
--						and	r."countryCode" = a."countryCode" 
left join panelist_month pm on pm."month" = a."month"
--						and	pm."affiliateName" = a."affiliateName" 
--						and	pm."countryCode" = a."countryCode" 
ORDER BY a.month;





----------------------------
WITH aff_month AS (
    SELECT
        DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
        atd."countryCode",
        amd."affiliateName",
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost
    FROM "AffiliateTrafficDetails" atd left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE atd."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
    GROUP BY 1,2,3
),
pph_month AS (
    SELECT
        DATE_TRUNC('month', pph."createdAt"AT TIME ZONE 'America/New_York') AS month,
        atd."countryCode",
       	amd."affiliateName",
        SUM(
            CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            END
        ) AS point_cost
    FROM "PanelistPointHistories" pph
    inner join "AffiliateTrafficDetails" atd on atd."panelistId" = pph."panelistId"
    left join "AffiliateMasterDetails" amd on atd."affiliateId" = amd.id
    WHERE pph."createdAt" AT TIME ZONE 'America/New_York' between '2026-01-01' and '2026-02-01'
    GROUP BY 1,2,3
)
SELECT
    TO_CHAR(a.month, 'YYYY-Mon')  AS "Affiliate_month",
    a."countryCode" ,
    a."affiliateName",
    p.point_cost AS "Point_cost",
    a.recruit_cost AS "Recruit_cost"
FROM aff_month a
left JOIN pph_month p  ON p.month = a.month
			and p."countryCode" = a."countryCode" and p."affiliateName" = a."affiliateName" 
ORDER BY a.month;


-------------------------

WITH aff_month AS (
    SELECT
        DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
        atd."countryCode",
        amd."affiliateName",
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost
    FROM "AffiliateTrafficDetails" atd
    LEFT JOIN "AffiliateMasterDetails" amd ON atd."affiliateId" = amd.id
    WHERE atd."createdAt" AT TIME ZONE 'America/New_York' BETWEEN '2026-01-01' AND '2026-02-01'
    GROUP BY 1, 2, 3
),
pph_month AS (
    SELECT
--        DATE_TRUNC('month', pph."createdAt" AT TIME ZONE 'America/New_York') AS month,
        -- Resolve countryCode/affiliateName AFTER aggregating points per panelist
        -- to avoid fan-out from multiple pph rows joining multiple atd rows
        atd."countryCode",
--        amd."affiliateName",
        SUM(
            CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0
                 ELSE 0
            END
        ) AS point_cost
    FROM "PanelistPointHistories" pph
    -- Deduplicate atd first: one panelist = one affiliate record
    INNER JOIN (
        SELECT DISTINCT ON ("panelistId")
            "panelistId",
            "countryCode",
            "affiliateId"
        FROM "AffiliateTrafficDetails"
        ORDER BY "panelistId", "createdAt" DESC  -- take the latest entry per panelist
    ) atd ON atd."panelistId" = pph."panelistId"
    LEFT JOIN "AffiliateMasterDetails" amd ON atd."affiliateId" = amd.id
    WHERE pph."createdAt" AT TIME ZONE 'America/New_York' BETWEEN '2026-01-01' AND '2026-02-01'
    GROUP BY 1
)
SELECT
    TO_CHAR(a.month, 'YYYY-Mon')    AS "Affiliate_month",
    a."countryCode",
    a."affiliateName",
    COALESCE(p.point_cost, 0)       AS "Point_cost",   -- NULL → 0 when no points exist
    a.recruit_cost                  AS "Recruit_cost"
FROM aff_month a
LEFT JOIN pph_month p
--       ON p.month         = a.month
       on p."countryCode"    = a."countryCode"
--      AND p."affiliateName"  = a."affiliateName"
ORDER BY a.month;




-----------

WITH panelist_tag AS (
    SELECT DISTINCT ON (atd."panelistId")
        atd."panelistId",
        atd."affiliateId",
        c."countryName"                                 AS country,
        CASE
            WHEN amd."ReportType"::text = 'campaignId'::text
                THEN COALESCE(atd."campaignId"::text, 'None')
            WHEN amd."ReportType"::text = 'subCampaignId'::text
                THEN COALESCE(atd."subCampaignId"::text, 'None')
            ELSE 'None'
        END                                              AS campaign,
        amd."affiliateName"
    FROM "AffiliateTrafficDetails" atd
    LEFT JOIN "AffiliateMasterDetails" amd ON amd.id = atd."affiliateId"
    left join "Countries" c on atd."countryCode" = c."countryCode" 
    ORDER BY atd."panelistId", atd."createdAt" ASC
),
aff_panelist AS (
    SELECT
        DATE_TRUNC('month', atd."createdAt" AT TIME ZONE 'America/New_York') AS month,
        atd."panelistId",
        COUNT(atd.id)   AS hit,
        SUM(atd."cost") AS recruit_cost,
        MAX(CASE WHEN p."isEmailVerified" = true THEN 1 ELSE 0 END)   AS doi
    FROM "AffiliateTrafficDetails" atd 
    left join "Panelists" p on atd."panelistId" = p."panelistId" 
    WHERE p."emailVerifyDate" AT TIME ZONE 'America/New_York' >= '2025-01-01'
--  WHERE atd."createdAt" AT TIME ZONE 'America/New_York' >= '2025-01-01'
--      AND atd."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
      and p."isEmailVerified" = true
    GROUP BY 1, 2
),
pph_panelist AS (
    SELECT
        DATE_TRUNC('month', pph."createdAt" AT TIME ZONE 'America/New_York') AS month,
        pph."panelistId",
        SUM(CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0 ELSE 0 END)                AS point_cost
    FROM "PanelistPointHistories" pph
    INNER JOIN panelist_tag pt ON pt."panelistId" = pph."panelistId"
    WHERE pph."createdAt" AT TIME ZONE 'America/New_York' >= '2025-01-01'
--      AND pph."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY 1, 2
),
usp_panelist AS (
    SELECT
        DATE_TRUNC('month', usp."createdAt" AT TIME ZONE 'America/New_York') AS month,
        usp."panelistId",
        COUNT(usp.id)                                                         AS start,
        sum(case WHEN usp."userStatus" = 2 THEN 1 ELSE 0 END )			  	  AS complete,
        SUM(CASE WHEN usp."userStatus" = 2  THEN usp."ccpi" ELSE 0 END)       AS revenue,
        SUM(CASE WHEN usp."userStatus" = 16 THEN 1          ELSE 0 END)       AS reconcile
    FROM "UserSurveyParticipations" usp
    INNER JOIN panelist_tag pt ON pt."panelistId" = usp."panelistId"
    WHERE usp."createdAt" AT TIME ZONE 'America/New_York' >= '2025-01-01'
--      AND usp."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY 1, 2
),
prr_panelist AS (
    SELECT
        DATE_TRUNC('month', prr."createdAt" AT TIME ZONE 'America/New_York') AS month,
        prr."panelistId",
        SUM(CASE WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
                 THEN prr.amount ELSE 0 END)      AS redemption_amount
    FROM "PanelistRedemptionRequests" prr
    INNER JOIN panelist_tag pt ON pt."panelistId" = prr."panelistId"
    WHERE prr."createdAt" AT TIME ZONE 'America/New_York' >= '2025-01-01'
--      AND prr."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
    GROUP BY 1, 2
),
--doi_panelist AS (
--    SELECT
--        DATE_TRUNC('month', p."createdAt" AT TIME ZONE 'America/New_York')   AS month,
--        p."panelistId",
--        MAX(CASE WHEN p."isEmailVerified" = true THEN 1 ELSE 0 END)   AS doi
--    FROM "Panelists" p
--    INNER JOIN panelist_tag pt ON pt."panelistId" = p."panelistId"
--    WHERE p."createdAt" AT TIME ZONE 'America/New_York' >= '2025-01-01'
----      AND p."createdAt" AT TIME ZONE 'America/New_York' < '2026-02-01'
--    GROUP BY 1, 2
--),
all_months AS (
    SELECT "panelistId", month FROM aff_panelist
    UNION
    SELECT "panelistId", month FROM pph_panelist
    UNION
    SELECT "panelistId", month FROM usp_panelist
    UNION
    SELECT "panelistId", month FROM prr_panelist
)
SELECT
    TO_CHAR(am.month, 'YYYY-Mon')      AS "Month",
    pt."affiliateName"                 AS "Affiliate",
    pt.country                         AS "Country",
    pt.campaign                        AS "Campaign",
    pt."panelistId"                    AS "PanelistId",
    COALESCE(a.doi, 0)                 AS "Doi",
    COALESCE(p.point_cost, 0)          AS "Point_cost",
    COALESCE(a.recruit_cost, 0)        AS "Actual_Recruit_cost",
    COALESCE(u.revenue, 0)             AS "Revenue",
    COALESCE(u.start, 0)               AS "Start",
    COALESCE(u.complete, 0)            AS "Complete",
    COALESCE(u.reconcile, 0)           AS "Reconcile",
    COALESCE(r.redemption_amount, 0)   AS "Redemption_amount"
FROM all_months am
INNER JOIN panelist_tag pt  ON pt."panelistId" = am."panelistId"
LEFT JOIN aff_panelist a    ON a."panelistId"  = am."panelistId"
                           AND a.month         = am.month
LEFT JOIN pph_panelist p    ON p."panelistId"  = am."panelistId"
                           AND p.month         = am.month
LEFT JOIN usp_panelist u    ON u."panelistId"  = am."panelistId"
                           AND u.month         = am.month
LEFT JOIN prr_panelist r    ON r."panelistId"  = am."panelistId"
                           AND r.month         = am.month
ORDER BY pt."affiliateName", pt."panelistId", am.month;

-------------------------------------------------------
WITH panelist_tag AS (
    SELECT DISTINCT ON (atd."panelistId")
        atd."panelistId",
        atd."affiliateId",
        c."countryName"                                  AS country,
        CASE
            WHEN amd."ReportType"::text = 'campaignId'::text
                THEN COALESCE(atd."campaignId"::text, 'None')
            WHEN amd."ReportType"::text = 'subCampaignId'::text
                THEN COALESCE(atd."subCampaignId"::text, 'None')
            ELSE 'None'
        END                                              AS campaign,
        amd."affiliateName"
    FROM "AffiliateTrafficDetails" atd
    LEFT JOIN "AffiliateMasterDetails" amd ON amd.id = atd."affiliateId"
    LEFT JOIN "Countries" c ON atd."countryCode" = c."countryCode"
    WHERE atd."panelistId" IN (
        SELECT DISTINCT p."panelistId"
        FROM "Panelists" p
        WHERE p."isEmailVerified" = true
          AND p."emailVerifyDate"AT TIME ZONE 'America/New_York' >= '2025-04-01'  -- ✅ store as UTC, cast later
    )
    ORDER BY atd."panelistId", atd."createdAt" ASC
),
aff_panelist AS (
    SELECT
        DATE_TRUNC('month', (atd."createdAt" AT TIME ZONE 'America/New_York')) AS month,
        atd."panelistId",
        COUNT(atd.id)                                                           AS hit,
        SUM(atd."cost")                                                         AS recruit_cost,
        MAX(CASE WHEN p."isEmailVerified" = true THEN 1 ELSE 0 END)            AS doi
    FROM "AffiliateTrafficDetails" atd
    INNER JOIN "Panelists" p ON atd."panelistId" = p."panelistId"
    WHERE p."isEmailVerified" = true
      AND p."emailVerifyDate"AT TIME ZONE 'America/New_York' >= '2025-04-01' 
      AND p."emailVerifyDate" <  NOW()
    GROUP BY 1, 2
),
pph_panelist AS (
    SELECT
        DATE_TRUNC('month', (pph."createdAt" AT TIME ZONE 'America/New_York')) AS month,
        pph."panelistId",
        SUM(CASE WHEN pph."pointTypeId" <> 1
                 THEN pph.points::numeric / 100.0 ELSE 0 END)                  AS point_cost
    FROM "PanelistPointHistories" pph
    INNER JOIN aff_panelist ap ON ap."panelistId" = pph."panelistId"
    WHERE pph."createdAt"AT TIME ZONE 'America/New_York' >= '2025-04-01'  -- ✅ no timezone cast in WHERE
    GROUP BY 1, 2
),
usp_panelist AS (
    SELECT
        DATE_TRUNC('month', (usp."createdAt" AT TIME ZONE 'America/New_York')) AS month,
        usp."panelistId",
        COUNT(usp.id)                                                           AS start,
        SUM(CASE WHEN usp."userStatus" = 2 THEN 1    ELSE 0 END)               AS complete,
        SUM(CASE WHEN usp."userStatus" = 2 THEN usp."ccpi" ELSE 0 END)         AS revenue,
        SUM(CASE WHEN usp."userStatus" = 16 THEN 1   ELSE 0 END)               AS reconcile
    FROM "UserSurveyParticipations" usp
    INNER JOIN aff_panelist ap ON ap."panelistId" = usp."panelistId"
    WHERE usp."createdAt"AT TIME ZONE 'America/New_York' >= '2025-04-01'  -- ✅ no timezone cast in WHERE
    GROUP BY 1, 2
),
prr_panelist AS (
    SELECT
        DATE_TRUNC('month', (prr."createdAt" AT TIME ZONE 'America/New_York')) AS month,
        prr."panelistId",
        SUM(CASE WHEN prr.status = 'approved'::"enum_PanelistRedemptionRequests_status"
                 THEN prr.amount ELSE 0 END)                                    AS redemption_amount
    FROM "PanelistRedemptionRequests" prr
    INNER JOIN aff_panelist ap ON ap."panelistId" = prr."panelistId"
    WHERE prr."createdAt"AT TIME ZONE 'America/New_York' >= '2025-04-01'  -- ✅ no timezone cast in WHERE
    GROUP BY 1, 2
),
all_months AS (
    SELECT "panelistId", month FROM aff_panelist
    UNION ALL
    SELECT "panelistId", month FROM pph_panelist
    UNION ALL
    SELECT "panelistId", month FROM usp_panelist
    UNION ALL
    SELECT "panelistId", month FROM prr_panelist
),
all_months_distinct AS (
    SELECT DISTINCT "panelistId", month
    FROM all_months
)
select
    TO_CHAR(am.month, 'YYYY')      	   AS "Year",
    TO_CHAR(am.month, 'Month')         AS "Month",
    pt."affiliateName"                 AS "Affiliate",
    pt.country                         AS "Country",
    pt.campaign                        AS "Campaign",
    pt."panelistId"                    AS "PanelistId",
    COALESCE(a.doi, 0)                 AS "Doi",
    COALESCE(p.point_cost, 0)          AS "Point_cost",
    COALESCE(a.recruit_cost, 0)        AS "Actual_Recruit_cost",
    COALESCE(u.revenue, 0)             AS "Revenue",
    COALESCE(u.start, 0)               AS "Start",
    COALESCE(u.complete, 0)            AS "Complete",
    COALESCE(u.reconcile, 0)           AS "Reconcile",
    COALESCE(r.redemption_amount, 0)   AS "Redemption_amount"
FROM all_months_distinct am
INNER JOIN panelist_tag pt  ON pt."panelistId" = am."panelistId"
LEFT JOIN aff_panelist a    ON a."panelistId"  = am."panelistId"
                           AND a.month         = am.month
LEFT JOIN pph_panelist p    ON p."panelistId"  = am."panelistId"
                           AND p.month         = am.month
LEFT JOIN usp_panelist u    ON u."panelistId"  = am."panelistId"
                           AND u.month         = am.month
LEFT JOIN prr_panelist r    ON r."panelistId"  = am."panelistId"
                           AND r.month         = am.month
ORDER BY pt."affiliateName", pt."panelistId", am.month


