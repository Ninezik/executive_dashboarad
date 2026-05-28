SELECT 
    COUNT(DISTINCT connote__connote_code),
    connote__connote_state,
    DATEDIFF('day', custom_field__first_attempt_time, pod__timereceive) AS diff_day,
    datediff('day',custom_field__final_swp_date_new,pod__timereceive) as diff_dayswp
FROM nipos.nipos__part_2026
WHERE 
    customer_code = 'DAGSHOPEE04120A'
    AND partition_year_month = '2026-04'
    AND pod__timereceive > custom_field__first_attempt_time
    and pod__timereceive > custom_field__final_swp_date_new 
GROUP BY 
    connote__connote_state,
    DATEDIFF('day', custom_field__first_attempt_time, pod__timereceive),
    datediff('day',custom_field__final_swp_date_new,pod__timereceive)
