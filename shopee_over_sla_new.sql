
select*
FROM
(SELECT DISTINCT
nipos__part_2026.location_data_created__custom_field__nokprk ,
nipos__part_2026.custom_field__destination_kprk ,
nipos__part_2026.connote__connote_state ,
case when pod__timereceive is null then 'ON PROCESS OVER SLA'
else 'OVER SLA' end as kategori,
CASE when 
	date_part('weekday',coalesce(pod__timereceive,current_date)) in (0,6) then 'WEEKEND'
else 'WEEKDAY' end as kategori_hari,
datediff('day',
custom_field__final_swp_date_new,
coalesce(pod__timereceive,current_date)
)aging_hari,
custom_field__cod ,
UPPER(custom_field__irregularityreason)custom_field__irregularityreason ,
case when coalesce(pod__timereceive,current_date)=custom_field__first_attempt_time 
then 'BERHASIL DI FIRST_ATTEMPT'
else 'GAGAL DI FIRST_ATTMPT'
end as kategori_dikirim,
COUNT(*)jumlah_kiriman,
COUNT(distinct custom_field__usernamedeliveredby )petugas_antaran
FROM nipos.nipos__part_2026
where nipos__part_2026.customer_code ='DAGSHOPEE04120A'
and nipos__part_2026.connote__created_at >'20260401'
and nipos__part_2026.connote__created_at <'20260501'
and UPPER(connote__location_name) != 'AGP TESTING LOCATION'        
and UPPER(connote__connote_state) not in ('CANCEL', 'PENDING')         
and connote__connote_amount >= 0         
and connote__connote_service != 'LNINCOMING'
and coalesce(pod__timereceive,current_date) >nipos__part_2026.custom_field__final_swp_date_new
group by 1,2,3,4,5,6,7,8,9)
t1
where t1.kategori ='OVER SLA'
