select
		t1.*,
		case
			when t1.customer_code = 'KOSONG' then 'RB'
		when length(t2.subdit_id)<2
		or t2.subdit_id is null then 'EB'
		else t2.subdit_id
	end as subdit_id
from
		(
	select
			DATE(connote__created_at) as connote__created_at,
			coalesce(UPPER(customer_code),
		'KOSONG') as customer_code,
			UPPER(transform__channel)transform__channel,
			np.location_data_created__custom_field__nopen,
			UPPER(connote__connote_service) as connote__connote_service,
			case when connote__connote_service in ('KRT','KBM','FFE','FF-LKPP') then 'LOGISTIK'
			else 'KURIR' end as kelompok,
		--coalesce(custom_field__final_swp,np.connote__connote_sla_day) custom_field__final_swp,
--coalesce(coalesce(date(pod__timereceive),DATE(custom_field__first_attempt_time)),DATE(connote__updated_at))pod__timereceive ,
--custom_field__is_over_sla ,
COUNT(connote__connote_code)produksi,
SUM(coalesce(connote__connote_service_price,0) +coalesce(connote__connote_surcharge_amount,0))pendapatan,
SUM(coalesce(custom_field__fee_value,0)) fee_cod,
SUM(coalesce(np.connote__chargeable_weight ,0))berat
FROM nipos__part_2026 np 
where UPPER(connote__location_name) != 'AGP TESTING LOCATION'
AND UPPER(connote__connote_state) NOT IN ('CANCEL','PENDING')
AND NOT(
    coalesce(UPPER(customer_code) ,'')= 'DAGSHOPEE04120A'
    AND coalesce(UPPER(custom_field__cod),'')!= 'NONCOD'
)
AND connote__connote_amount >=0
and np.connote__connote_service !='LNINCOMING'
GROUP BY
1,2,3,4,5,6)t1
--joinkeun ka referensi subdit
left join
(select distinct idregpelanggan,subdit_id
from nipos.m_pelanggan)t2
on t1.customer_code=t2.idregpelanggan
