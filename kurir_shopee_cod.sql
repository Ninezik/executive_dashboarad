select
	DATE(t1.connote__created_at) as connote__created_at,
	DATE(pod__timereceive)pod__timereceive,
	status_sla,
	t1.customer_code ,
	t1.transform__channel,
	t1.location_data_created__custom_field__nopen,
	t1.connote__connote_service,
	case
		when t1.connote__connote_service in ('KRT', 'KBM', 'FFE', 'FF-LKPP') then 'LOGISTIK'
		else 'KURIR'
	end as kelompok,
	COUNT(connote__connote_code)produksi,
	SUM(coalesce(connote__connote_service_price, 0) + coalesce(connote__connote_surcharge_amount, 0))pendapatan,
	SUM(coalesce(t2.good_value, 0)* 0.005) as fee_cod,
	SUM(connote__chargeable_weight)berat,
	SUM((coalesce(t1.connote__connote_service_price, 0) * 0.011)+(coalesce(t1.connote__connote_surcharge_amount, 0)* 0.11))pajak,
	'RB' subdit_id,
	'NIPOS' sumber
from
	(
	select
		distinct connote__created_at,
		pod__timereceive ,
		--		cek data swp
case
			when np.custom_field__final_swp is null then 'TANGGAL SWP TIDAK TERDEFINISI'
			--		cek status swp
			--		ketika pod ada
			when np.pod__timereceive is not null
			and date(np.pod__timereceive)<= DATE(connote__created_at)+ np.custom_field__final_swp then 'ON TIME'
			--		ketika pod tidak ada
			else
(
case
				when date(np.connote__created_at) = CURRENT_DATE
				or CURRENT_DATE <= date(connote__created_at)+ custom_field__final_swp
then 'ON PROCESS'
				else 'LATE'
			end
)
		end as status_sla,
		customer_code,
		UPPER(transform__channel)transform__channel,
		location_data_created__custom_field__nopen,
		UPPER(connote__connote_service) as connote__connote_service,
		case
			when connote__connote_service in ('KRT', 'KBM', 'FFE', 'FF-LKPP') then 'LOGISTIK'
			else 'KURIR'
		end as kelompok,
		connote__connote_code,
		connote__connote_service_price,
		connote__connote_surcharge_amount,
		np.connote__connote_booking_code ,
		connote__chargeable_weight
	from
		nipos.nipos__part_2026 np
	where
		UPPER(connote__location_name) != 'AGP TESTING LOCATION'
		and connote__connote_amount >= 0
		and np.connote__connote_service != 'LNINCOMING'
		and UPPER(connote__connote_state) not in ('CANCEL', 'PENDING')
		and (
coalesce(UPPER(customer_code) ,
		'')= 'DAGSHOPEE04120A'
			and coalesce(UPPER(custom_field__cod),
			'')!= 'NONCOD')
)
t1
left join 
(
	select
		distinct resi,
		good_value
	from
		webhook_marketplace wm
	where
		wm.member_id = 'DAGSHOPEE04120A')t2
on
	t1.connote__connote_booking_code = t2.resi
group by
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8
