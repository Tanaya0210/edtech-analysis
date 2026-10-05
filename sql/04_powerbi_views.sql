-- =========================================================
-- EdTech Analytics
-- File: 04_powerbi_views.sql
-- Purpose: Create reusable PostgreSQL views for Power BI.
-- =========================================================


-- 1. Funnel summary
CREATE OR REPLACE VIEW vw_funnel_summary AS
SELECT 'Leads' AS stage, COUNT(*) AS total, 1 AS stage_order
FROM leads
UNION ALL
SELECT 'Engaged Leads', COUNT(DISTINCT lead_id), 2
FROM interactions
UNION ALL
SELECT 'Enrolments', COUNT(*), 3
FROM enrolments
UNION ALL
SELECT 'Successful Payments', COUNT(*), 4
FROM payments
WHERE payment_status = 'Successful'
UNION ALL
SELECT 'Completed Programmes', COUNT(*), 5
FROM enrolments
WHERE status = 'Completed';


-- 2. Channel performance
CREATE OR REPLACE VIEW vw_channel_performance AS
SELECT
    l.acquisition_channel,
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT l.lead_id), 0) * 100,
        2
    ) AS conversion_rate
FROM leads l
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY l.acquisition_channel;


-- 3. Programme performance
CREATE OR REPLACE VIEW vw_programme_performance AS
SELECT
    p.programme_name,
    COUNT(DISTINCT l.lead_id) AS interested_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT l.lead_id), 0) * 100,
        2
    ) AS conversion_rate
FROM programmes p
JOIN leads l
    ON p.programme_id = l.programme_interest
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY p.programme_name;


-- 4. Marketing ROI
CREATE OR REPLACE VIEW vw_marketing_roi AS
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
    ON cc.channel = cr.channel;


-- 5. Customer segments
CREATE OR REPLACE VIEW vw_customer_segments AS
SELECT
    l.education_level,
    l.employment_status,
    l.age_group,
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT e.enrolment_id) AS enrolments,
    ROUND(
        COUNT(DISTINCT e.enrolment_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT l.lead_id), 0) * 100,
        2
    ) AS conversion_rate
FROM leads l
LEFT JOIN enrolments e
    ON l.lead_id = e.lead_id
GROUP BY
    l.education_level,
    l.employment_status,
    l.age_group;


-- 6. Engagement performance
CREATE OR REPLACE VIEW vw_engagement_performance AS
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
        NULLIF(COUNT(DISTINCT s.lead_id), 0) * 100,
        2
    ) AS conversion_rate
FROM interaction_summary s
LEFT JOIN enrolments e
    ON s.lead_id = e.lead_id
GROUP BY s.engagement_level;


-- 7. Conversion speed
CREATE OR REPLACE VIEW vw_conversion_speed AS
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
GROUP BY l.acquisition_channel;


-- 8. Executive KPIs
CREATE OR REPLACE VIEW vw_executive_kpis AS
SELECT
    (SELECT COUNT(*) FROM leads) AS total_leads,
    (SELECT COUNT(*) FROM enrolments) AS total_enrolments,
    ROUND(
        (SELECT COUNT(*) FROM enrolments)::NUMERIC /
        (SELECT COUNT(*) FROM leads) * 100,
        2
    ) AS enrolment_rate,
    (SELECT COUNT(*) FROM payments
     WHERE payment_status = 'Successful') AS successful_payments,
    ROUND(
        (SELECT SUM(amount)
         FROM payments
         WHERE payment_status = 'Successful'),
        2
    ) AS total_revenue,
    (SELECT COUNT(*)
     FROM enrolments
     WHERE status = 'Completed') AS completed_programmes;


-- 9. Interaction performance
CREATE OR REPLACE VIEW vw_interaction_performance AS
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
GROUP BY i.interaction_type;
