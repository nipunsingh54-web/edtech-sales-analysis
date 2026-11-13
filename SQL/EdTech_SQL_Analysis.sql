-- EDTECH SALES ANALYSIS | PostgreSQL
-- Run one query at a time. All queries are read-only.
-- Data source: validated staging tables in testdb.

-- 1. Preview the dataset
SELECT *
FROM public.edtech_sales_data_import
ORDER BY record_id
LIMIT 10;

-- 2. Enrollment Health KPIs
SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE enrollment_status = 'Enrolled') AS enrolled_records,
    COUNT(*) FILTER (WHERE enrollment_status IN ('Dropped', 'Refunded')) AS dropout_refund_records,
    SUM(fees) FILTER (WHERE enrollment_status = 'Enrolled') AS recorded_enrolled_fee_value,
    ROUND(AVG(fees) FILTER (WHERE enrollment_status = 'Enrolled'), 2) AS average_fee_per_enrolled_record,
    ROUND(100.0 * COUNT(*) FILTER (WHERE enrollment_status IN ('Dropped', 'Refunded')) / COUNT(*), 2) AS dropout_refund_rate_pct
FROM public.edtech_sales_data_import;

-- 3. Monthly enrolled-record trend
SELECT
    DATE_TRUNC('month', enrollment_date)::DATE AS enrollment_month,
    COUNT(*) AS enrolled_records
FROM public.edtech_sales_data_import
WHERE enrollment_status = 'Enrolled'
GROUP BY DATE_TRUNC('month', enrollment_date)
ORDER BY enrollment_month;

-- 4. Enrollment status breakdown
SELECT
    enrollment_status,
    COUNT(*) AS records,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM public.edtech_sales_data_import),
        2
    ) AS percentage_of_all_records
FROM public.edtech_sales_data_import
GROUP BY enrollment_status
ORDER BY records DESC;

-- 5. Enrolled records by course
SELECT
    course,
    COUNT(*) AS enrolled_records
FROM public.edtech_sales_data_import
WHERE enrollment_status = 'Enrolled'
GROUP BY course
ORDER BY enrolled_records DESC, course;

-- 6. Top 10 cities by enrolled records
SELECT
    city,
    COUNT(*) AS enrolled_records
FROM public.edtech_sales_data_import
WHERE enrollment_status = 'Enrolled'
GROUP BY city
ORDER BY enrolled_records DESC, city
LIMIT 10;

-- 7. Lead-source volume and lead-to-enrolment conversion
SELECT
    l.lead_source,
    l.total_leads_received,
    COUNT(e.record_id) FILTER (WHERE e.enrollment_status = 'Enrolled') AS enrolled_records,
    ROUND(
        100.0 * COUNT(e.record_id) FILTER (WHERE e.enrollment_status = 'Enrolled')
        / NULLIF(l.total_leads_received, 0),
        2
    ) AS lead_to_enrolment_conversion_pct
FROM public.lead_source_inputs_import AS l
LEFT JOIN public.edtech_sales_data_import AS e
    ON LOWER(TRIM(e.lead_source)) = LOWER(TRIM(l.lead_source))
GROUP BY l.lead_source, l.total_leads_received
ORDER BY lead_to_enrolment_conversion_pct DESC, l.lead_source;

-- 8. Recorded enrolled fee value by course
SELECT
    course,
    COUNT(*) AS enrolled_records,
    SUM(fees) AS recorded_enrolled_fee_value
FROM public.edtech_sales_data_import
WHERE enrollment_status = 'Enrolled'
GROUP BY course
ORDER BY recorded_enrolled_fee_value DESC, course;

-- 9. Dropout and refund outcome rate by course
SELECT
    course,
    COUNT(*) AS total_course_records,
    COUNT(*) FILTER (WHERE enrollment_status IN ('Dropped', 'Refunded')) AS dropout_refund_records,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE enrollment_status IN ('Dropped', 'Refunded')) / COUNT(*),
        2
    ) AS dropout_refund_outcome_rate_pct
FROM public.edtech_sales_data_import
GROUP BY course
ORDER BY dropout_refund_outcome_rate_pct DESC, total_course_records DESC, course;
