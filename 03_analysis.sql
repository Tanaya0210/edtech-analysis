-- =========================================================
-- EdTech Analytics
-- File: 03_analysis.sql
-- Purpose: Core business analysis queries for conversion, revenue, customer segments, engagement, and funnel.
-- =========================================================


-- ---------------------------------------------------------
-- 1. Acquisition channel conversion performance
-- ---------------------------------------------------------

SELECT
    l.acquisition_channel,
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        COUNT(DISTINCT l.lead_id) * 100,
        2
    ) AS conversion_rate
FROM leads l
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY l.acquisition_channel
ORDER BY conversion_rate DESC;


-- ---------------------------------------------------------
-- 2. Programme conversion performance
-- ---------------------------------------------------------

SELECT
    p.programme_name,
    COUNT(DISTINCT l.lead_id) AS interested_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        COUNT(DISTINCT l.lead_id) * 100,
        2
    ) AS conversion_rate
FROM programmes p
JOIN leads l
    ON p.programme_id = l.programme_interest
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY p.programme_name
ORDER BY conversion_rate DESC;


-- ---------------------------------------------------------
-- 3. Customer segment conversion performance
-- ---------------------------------------------------------

SELECT
    l.education_level,
    l.employment_status,
    l.age_group,
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        COUNT(DISTINCT l.lead_id) * 100,
        2
    ) AS conversion_rate
FROM leads l
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY
    l.education_level,
    l.employment_status,
    l.age_group
HAVING COUNT(DISTINCT l.lead_id) >= 100
ORDER BY conversion_rate DESC;


-- ---------------------------------------------------------
-- 4. Channel performance by customer segment
-- ---------------------------------------------------------

SELECT
    l.education_level,
    l.employment_status,
    l.age_group,
    l.acquisition_channel,
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        COUNT(DISTINCT l.lead_id) * 100,
        2
    ) AS conversion_rate
FROM leads l
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY
    l.education_level,
    l.employment_status,
    l.age_group,
    l.acquisition_channel
HAVING COUNT(DISTINCT l.lead_id) >= 50
ORDER BY conversion_rate DESC;


-- ---------------------------------------------------------
-- 5. Revenue by customer segment
-- ---------------------------------------------------------

SELECT
    l.education_level,
    l.employment_status,
    l.age_group,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(SUM(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN p.amount
            ELSE 0
        END
    ), 2) AS total_revenue,
    ROUND(AVG(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN p.amount
        END
    ), 2) AS avg_revenue_per_enrolment
FROM leads l
JOIN enrolments e
    ON l.lead_id = e.lead_id
JOIN payments p
    ON e.enrolment_id = p.enrolment_id
GROUP BY
    l.education_level,
    l.employment_status,
    l.age_group
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------
-- 6. Marketing efficiency
-- ---------------------------------------------------------

WITH campaign_costs AS (
    SELECT
        channel,
        SUM(campaign_spend) AS total_spend
    FROM campaigns
    GROUP BY channel
),

channel_results AS (
    SELECT
        l.acquisition_channel AS channel,
        COUNT(DISTINCT l.lead_id) AS total_leads,
        COUNT(DISTINCT e.enrolment_id) AS enrolments
    FROM leads l
    LEFT JOIN enrolments e
        ON l.lead_id = e.lead_id
    WHERE l.campaign_id IS NOT NULL
    GROUP BY l.acquisition_channel
)

SELECT
    c.channel,
    ROUND(c.total_spend, 2) AS total_spend,
    r.total_leads,
    r.enrolments,
    ROUND(c.total_spend / NULLIF(r.total_leads, 0), 2) AS cost_per_lead,
    ROUND(c.total_spend / NULLIF(r.enrolments, 0), 2) AS cost_per_enrolment
FROM campaign_costs c
LEFT JOIN channel_results r
    ON c.channel = r.channel
ORDER BY cost_per_enrolment;


-- ---------------------------------------------------------
-- 7. Marketing ROI
-- ---------------------------------------------------------

WITH campaign_costs AS (
    SELECT
        channel,
        SUM(campaign_spend) AS total_spend
    FROM campaigns
    GROUP BY channel
),

channel_revenue AS (
    SELECT
        c.channel,
        SUM(
            CASE
                WHEN p.payment_status = 'Successful'
                THEN p.amount
                ELSE 0
            END
        ) AS revenue
    FROM campaigns c
    LEFT JOIN leads l
        ON c.campaign_id = l.campaign_id
    LEFT JOIN enrolments e
        ON l.lead_id = e.lead_id
    LEFT JOIN payments p
        ON e.enrolment_id = p.enrolment_id
    GROUP BY c.channel
)

SELECT
    cc.channel,
    ROUND(cc.total_spend, 2) AS total_spend,
    ROUND(cr.revenue, 2) AS revenue,
    ROUND(cr.revenue - cc.total_spend, 2) AS net_return,
    ROUND(
        (cr.revenue - cc.total_spend)
        / NULLIF(cc.total_spend, 0) * 100,
        2
    ) AS roi_percent
FROM campaign_costs cc
JOIN channel_revenue cr
    ON cc.channel = cr.channel
ORDER BY roi_percent DESC;


-- ---------------------------------------------------------
-- 8. Engagement level vs conversion
-- ---------------------------------------------------------

WITH interaction_summary AS (
    SELECT
        l.lead_id,
        COUNT(i.interaction_id) AS interaction_count,
        CASE
            WHEN COUNT(i.interaction_id) = 0 THEN '0 interactions'
            WHEN COUNT(i.interaction_id) = 1 THEN '1 interaction'
            WHEN COUNT(i.interaction_id) BETWEEN 2 AND 3 THEN '2-3 interactions'
            ELSE '4+ interactions'
        END AS engagement_level
    FROM leads l
    LEFT JOIN interactions i
        ON l.lead_id = i.lead_id
    GROUP BY l.lead_id
)

SELECT
    s.engagement_level,
    COUNT(DISTINCT s.lead_id) AS total_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        COUNT(DISTINCT s.lead_id) * 100,
        2
    ) AS conversion_rate
FROM interaction_summary s
LEFT JOIN enrolments e
    ON s.lead_id = e.lead_id
GROUP BY s.engagement_level
ORDER BY MIN(s.interaction_count);


-- ---------------------------------------------------------
-- 9. Interaction type vs conversion
-- ---------------------------------------------------------

SELECT
    i.interaction_type,
    COUNT(DISTINCT i.lead_id) AS engaged_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT i.lead_id), 0) * 100,
        2
    ) AS conversion_rate
FROM interactions i
LEFT JOIN enrolments e
    ON i.lead_id = e.lead_id
GROUP BY i.interaction_type
ORDER BY conversion_rate DESC;


-- ---------------------------------------------------------
-- 10. Lead-to-enrolment conversion speed
-- ---------------------------------------------------------

SELECT
    l.acquisition_channel,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        AVG(e.enrolment_date - l.created_date),
        2
    ) AS avg_days_to_enrol,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY e.enrolment_date - l.created_date
    ) AS median_days_to_enrol
FROM leads l
JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY l.acquisition_channel
ORDER BY avg_days_to_enrol;


-- ---------------------------------------------------------
-- 11. Overall conversion funnel
-- ---------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM leads) AS total_leads,

    (SELECT COUNT(DISTINCT lead_id)
     FROM interactions) AS engaged_leads,

    (SELECT COUNT(*)
     FROM enrolments) AS enrolments,

    (SELECT COUNT(*)
     FROM payments
     WHERE payment_status = 'Successful') AS successful_payments,

    (SELECT COUNT(*)
     FROM enrolments
     WHERE status = 'Completed') AS completed_programmes;