-- =========================================================
-- EdTech Analytics
-- File: 02_data_quality_checks.sql
-- Purpose: Validate uniqueness, relationships, NULLs, logical consistency, categories, and value ranges.
-- =========================================================


-- ---------------------------------------------------------
-- 1. Primary-key uniqueness
-- ---------------------------------------------------------

SELECT 'programmes' AS table_name,
       COUNT(*) AS total_rows,
       COUNT(DISTINCT programme_id) AS unique_ids
FROM programmes

UNION ALL

SELECT 'campaigns',
       COUNT(*),
       COUNT(DISTINCT campaign_id)
FROM campaigns

UNION ALL

SELECT 'leads',
       COUNT(*),
       COUNT(DISTINCT lead_id)
FROM leads

UNION ALL

SELECT 'interactions',
       COUNT(*),
       COUNT(DISTINCT interaction_id)
FROM interactions

UNION ALL

SELECT 'enrolments',
       COUNT(*),
       COUNT(DISTINCT enrolment_id)
FROM enrolments

UNION ALL

SELECT 'payments',
       COUNT(*),
       COUNT(DISTINCT payment_id)
FROM payments;


-- ---------------------------------------------------------
-- 2. Orphan / broken foreign-key relationships
-- ---------------------------------------------------------

SELECT 'leads → programmes' AS relationship,
       COUNT(*) AS orphan_records
FROM leads l
LEFT JOIN programmes p
    ON l.programme_interest = p.programme_id
WHERE l.programme_interest IS NOT NULL
  AND p.programme_id IS NULL

UNION ALL

SELECT 'leads → campaigns',
       COUNT(*)
FROM leads l
LEFT JOIN campaigns c
    ON l.campaign_id = c.campaign_id
WHERE l.campaign_id IS NOT NULL
  AND c.campaign_id IS NULL

UNION ALL

SELECT 'interactions → leads',
       COUNT(*)
FROM interactions i
LEFT JOIN leads l
    ON i.lead_id = l.lead_id
WHERE l.lead_id IS NULL

UNION ALL

SELECT 'enrolments → leads',
       COUNT(*)
FROM enrolments e
LEFT JOIN leads l
    ON e.lead_id = l.lead_id
WHERE l.lead_id IS NULL

UNION ALL

SELECT 'enrolments → programmes',
       COUNT(*)
FROM enrolments e
LEFT JOIN programmes p
    ON e.programme_id = p.programme_id
WHERE p.programme_id IS NULL

UNION ALL

SELECT 'payments → enrolments',
       COUNT(*)
FROM payments py
LEFT JOIN enrolments e
    ON py.enrolment_id = e.enrolment_id
WHERE e.enrolment_id IS NULL;


-- ---------------------------------------------------------
-- 3. Critical NULL audit
-- ---------------------------------------------------------

SELECT
    'leads' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE acquisition_channel IS NULL) AS missing_1,
    COUNT(*) FILTER (WHERE programme_interest IS NULL) AS missing_2,
    COUNT(*) FILTER (WHERE created_date IS NULL) AS missing_3
FROM leads

UNION ALL

SELECT
    'enrolments',
    COUNT(*),
    COUNT(*) FILTER (WHERE lead_id IS NULL),
    COUNT(*) FILTER (WHERE programme_id IS NULL),
    COUNT(*) FILTER (WHERE enrolment_date IS NULL OR status IS NULL)
FROM enrolments

UNION ALL

SELECT
    'payments',
    COUNT(*),
    COUNT(*) FILTER (WHERE enrolment_id IS NULL),
    COUNT(*) FILTER (WHERE amount IS NULL),
    COUNT(*) FILTER (WHERE payment_status IS NULL)
FROM payments

UNION ALL

SELECT
    'interactions',
    COUNT(*),
    COUNT(*) FILTER (WHERE lead_id IS NULL),
    COUNT(*) FILTER (WHERE interaction_type IS NULL),
    0
FROM interactions;


-- ---------------------------------------------------------
-- 4. Logical consistency checks
-- ---------------------------------------------------------

SELECT 'enrolment before lead creation' AS issue,
       COUNT(*) AS affected_rows
FROM enrolments e
JOIN leads l
    ON e.lead_id = l.lead_id
WHERE e.enrolment_date < l.created_date

UNION ALL

SELECT 'payment before enrolment',
       COUNT(*)
FROM payments p
JOIN enrolments e
    ON p.enrolment_id = e.enrolment_id
WHERE p.payment_date < e.enrolment_date

UNION ALL

SELECT 'negative payment amount',
       COUNT(*)
FROM payments
WHERE amount < 0

UNION ALL

SELECT 'zero payment amount',
       COUNT(*)
FROM payments
WHERE amount = 0;


-- ---------------------------------------------------------
-- 5. Categorical-value validation
-- ---------------------------------------------------------

SELECT 'enrolment_status' AS field,
       status AS value,
       COUNT(*) AS records
FROM enrolments
GROUP BY status

UNION ALL

SELECT 'payment_status',
       payment_status,
       COUNT(*)
FROM payments
GROUP BY payment_status

UNION ALL

SELECT 'interaction_type',
       interaction_type,
       COUNT(*)
FROM interactions
GROUP BY interaction_type

UNION ALL

SELECT 'acquisition_channel',
       acquisition_channel,
       COUNT(*)
FROM leads
GROUP BY acquisition_channel

ORDER BY field, value;


-- ---------------------------------------------------------
-- 6. Range / domain validation
-- ---------------------------------------------------------

SELECT
    'negative campaign spend' AS issue,
    COUNT(*) AS affected_rows
FROM campaigns
WHERE campaign_spend < 0

UNION ALL

SELECT
    'clicks greater than impressions',
    COUNT(*)
FROM campaigns
WHERE clicks > impressions

UNION ALL

SELECT
    'campaign end before start',
    COUNT(*)
FROM campaigns
WHERE end_date < start_date

UNION ALL

SELECT
    'negative programme price',
    COUNT(*)
FROM programmes
WHERE price < 0

UNION ALL

SELECT
    'invalid programme duration',
    COUNT(*)
FROM programmes
WHERE duration_weeks <= 0

UNION ALL

SELECT
    'negative refund amount',
    COUNT(*)
FROM payments
WHERE refund_amount < 0;
