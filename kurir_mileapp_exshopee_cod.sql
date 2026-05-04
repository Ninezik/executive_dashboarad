select t5.*,
coalesce(t4.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t4.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t4.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t4.ketnopen),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t4.jenis),
	'TIDAK TERDEFINISI') jenis
FROM
(select t3.*,
t2.nama_produk ,
t2.group_produk ,
t2.kategori kategori_layanan
FROM
(select
		DATE(connote__created_at) as connote__created_at,
		DATE(pod__timereceive)pod__timereceive ,
		--		cek data swp
case
			when custom_field__final_swp is null then 'NILAI SWP TIDAK TERDEFINISI'
			--		cek status swp
			--		ketika pod ada
			when pod__timereceive is not null
			and date(pod__timereceive)<= DATE(connote__created_at)+ custom_field__final_swp then 'ON TIME'
			--		ketika pod tidak ada
			else
(
case
				when date(connote__created_at) = CURRENT_DATE
				or CURRENT_DATE <= date(connote__created_at)+ custom_field__final_swp
then 'ON PROCESS'
				else 'LATE'
			end
)
		end as status_sla,
		UPPER(customer_code)customer_code,
		UPPER(transform__channel)transform__channel,
		location_data_created__custom_field__nopen,
		UPPER(connote__connote_service) as connote__connote_service,
		case
			when connote__connote_service in ('KRT', 'KBM', 'FFE', 'FF-LKPP') then 'LOGISTIK'
			else 'KURIR'
		end as kelompok,
		case when LEFT(connote__connote_booking_code,3) in ('PON','QOB') then 'DIGITAL CHANNEL'
		else 'NON DIGITAL CHANNEL' end as kategori_digital,
		COUNT(connote__connote_code)produksi,
		SUM(coalesce(connote__connote_service_price, 0) + coalesce(connote__connote_surcharge_amount, 0))pendapatan,
		SUM(coalesce(custom_field__fee_value, 0)) fee_cod,
		SUM(coalesce(connote__chargeable_weight , 0))berat,
		SUM((coalesce(connote__connote_service_price, 0) * 0.011)+(coalesce(connote__connote_surcharge_amount, 0)* 0.11))pajak
	from
		nipos__part_2026 np
	where
		UPPER(connote__location_name) != 'AGP TESTING LOCATION'
		and UPPER(connote__connote_state) not in ('CANCEL', 'PENDING')
		and not(coalesce(UPPER(customer_code) ,
		'')= 'DAGSHOPEE04120A'
			and coalesce(UPPER(custom_field__cod),
			'')!= 'NONCOD')
		and connote__connote_amount >= 0
		and connote__connote_service != 'LNINCOMING'
	group by
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9)t3
--		join ka referensi produk
left join 
(
select connote__connote_service,
nama_produk,
group_produk,
kategori
FROM
(
--cegah duplikat
select *,row_number() OVER(partition by connote__connote_service order by nama_produk) rn
from referensi.layanan_kurlog)t1
where t1.rn=1
)t2
on coalesce(t3.connote__connote_service,'KOSONG')=coalesce(t2.connote__connote_service,'KOSONG')
)t5
--join ka referensi kantor
left join 
(SELECT *
FROM (
    SELECT
        t1.kdnopen,
        t1.ketnopen,
        t2.regional,
        t2.kcu,
        t2.kc,
        t1.jenis,
        ROW_NUMBER() OVER (PARTITION BY t1.kdnopen ORDER BY t1.kdnopen) AS rn
    FROM (
        SELECT
            kdnopen,
            ketnopen,
            kdkantor,
            jenis
        FROM referensi.refrensikantorbaru
    ) t1
    JOIN (
        SELECT DISTINCT
            nopend_dirian,
            kc,
            kcu,
            regional
        FROM referensi.ref_kcu_kc_2023
    ) t2
    ON t1.kdkantor = t2.nopend_dirian
) x
WHERE rn = 1
)t4
on 
t5.location_data_created__custom_field__nopen  = t4.kdnopen
order by connote__created_at desc ,pod__timereceive DESC
