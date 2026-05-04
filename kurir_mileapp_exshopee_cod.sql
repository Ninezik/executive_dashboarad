select
	t1.*,
	case
		when t1.customer_code is null then 'RB'
		when length(t2.subdit_id)<2
		or t2.subdit_id is null then 'EB'
		else t2.subdit_id
	end as subdit_id,
	tlayanan.nama_produk,
	tlayanan.group_produk,
	tlayanan.kategori kategori_layanan,
	coalesce(t4.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t4.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t4.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t4.ketnopen),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t4.jenis),
	'TIDAK TERDEFINISI') jenis,
	'NIPOS' sumber
from
	(
	select
		DATE(connote__created_at) as connote__created_at,
		DATE(np.pod__timereceive)pod__timereceive ,
		--		cek data swp
case
			when np.custom_field__final_swp is null then 'NILAI SWP TIDAK TERDEFINISI'
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
		UPPER(customer_code)customer_code,
		UPPER(transform__channel)transform__channel,
		np.location_data_created__custom_field__nopen,
		UPPER(connote__connote_service) as connote__connote_service,
		'MENUNGGU DATA REFERENSI' nama_produk,
		case
			when connote__connote_service in ('KRT', 'KBM', 'FFE', 'FF-LKPP') then 'LOGISTIK'
			else 'KURIR'
		end as kelompok,
		case
			when left(connote__connote_booking_code ,
			3) in ('PON', 'QOB') then 'DIGITAL CHANNEL'
			else 'NON DIGITAL CHANNEL'
		end as kategori_digital,
		COUNT(connote__connote_code)produksi,
		SUM(coalesce(connote__connote_service_price, 0) + coalesce(connote__connote_surcharge_amount, 0))pendapatan,
		SUM(coalesce(custom_field__fee_value, 0)) fee_cod,
		SUM(coalesce(np.connote__chargeable_weight , 0))berat,
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
		and np.connote__connote_service != 'LNINCOMING'
	group by
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10)t1
	--joinkeun ka referensi subdit
left join
(
	select
		distinct idregpelanggan,
		subdit_id
	from
		nipos.m_pelanggan)t2
on
	t1.customer_code = t2.idregpelanggan
	--join ka rerensi layanan
left join
(
	select
		*
	from
		referensi.layanan_kurlog
)tlayanan
on
	coalesce(t1.connote__connote_service,
	'KOSONG') = coalesce(tlayanan.connote__connote_service,
	'KOSONG')
	--JOIN ka referensi_kantor
left join
(
	select
		*
	from
		(
		select
			t1.kdnopen,
			t1.ketnopen,
			t2.regional,
			t2.kcu,
			t2.kc,
			t1.jenis,
			row_number() over (partition by t1.kdnopen
		order by
			t1.kdnopen) as rn
		from
			(
			select
				kdnopen,
				ketnopen,
				kdkantor,
				jenis
			from
				referensi.refrensikantorbaru
) t1
		join (
			select
				distinct
nopend_dirian,
				kc,
				kcu,
				regional
			from
				referensi.ref_kcu_kc_2023
) t2
on
			t1.kdkantor = t2.nopend_dirian
) x
	where
		rn = 1
)t4
on
	t1.location_data_created__custom_field__nopen = t4.kdnopen
