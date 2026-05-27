select
datediff
(day,
nipos.custom_field__final_swp_date_new,
nipos.pod__timereceive) aging_hari,
case 
	when date_part('weekday',nipos.pod__timereceive) in (0,6) then 'WEEKEND'
	else 'WEEKDAY'
end kategori_hari,
UPPER(nipos.custom_field__irregularityreason)custom_field__irregularityreason ,
--nipos.pod__timereceive<=nipos.custom_field__final_swp_date_new kiriman_tepat_waktu,
date_part('hour',nipos.pod__timereceive)jam,
--nipos.connote__connote_state ,
CASE 
    WHEN nipos.pod__timereceive IS NULL THEN 'ON PROCESS'
    WHEN nipos.custom_field__final_swp_date_new IS NULL THEN 'SWP KOSONG'
    WHEN nipos.pod__timereceive <= nipos.custom_field__final_swp_date_new THEN 'ON TIME'
    ELSE 'OVER SLA'
END AS kategori,
COUNT(*)jumlah
from nipos.nipos
where nipos.connote__connote_state not in ('CANCEL','PENDING')
AND nipos.customer_code='DAGSHOPEE04120A'
and nipos.connote__created_at >'20260401'
and nipos.connote__created_at <'20260501'
group by 1,2,3,4,5
