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
		case
			when left(connote__connote_booking_code ,
			3) in ('PON', 'QOB') then 'DIGITAL CHANNEL'
			else 'NON DIGITAL CHANNEL'
		end as kategori_digital,
		COUNT(connote__connote_code)produksi,
		SUM(coalesce(connote__connote_service_price, 0) + coalesce(connote__connote_surcharge_amount, 0))pendapatan,
		SUM(coalesce(custom_field__fee_value, 0)) fee_cod,
		SUM(coalesce(connote__chargeable_weight , 0))berat,
		SUM((coalesce(connote__connote_service_price, 0) * 0.011)+(coalesce(connote__connote_surcharge_amount, 0)* 0.11))pajak
	from
		nipos__part_2026
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
		9)t1
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
union
--shopee COD
select
	t1.*,
	'RB' subdit_id,
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
		case
			when left(connote__connote_booking_code ,
			3) in ('PON', 'QOB') then 'DIGITAL CHANNEL'
			else 'NON DIGITAL CHANNEL'
		end as kategori_digital,
		COUNT(connote__connote_code)produksi,
		SUM(coalesce(connote__connote_service_price, 0) + coalesce(connote__connote_surcharge_amount, 0))pendapatan,
		SUM(coalesce(t2.good_value, 0)* 0.005) as fee_cod,
		SUM(connote__chargeable_weight)berat,
		SUM((coalesce(t1.connote__connote_service_price, 0) * 0.011)+(coalesce(t1.connote__connote_surcharge_amount, 0)* 0.11))pajak
	from
		(
		select
			distinct connote__created_at,
			pod__timereceive ,
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
		8,
		9
)t1
	--join layanan
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
union
--GLID
select
	t3.*,
	t3.nama_produk group_produk,
	t3.nama_produk kategori_layanan,
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
	'GLID' sumber
from
	(
	select
		DATE(tgl_billing) connote__created_at,
		DATE(null) pod__timereceive ,
		'GLID' status_sla,
		'GLID' customer_code,
		'GLID' transform__channel,
		kode_nopen location_data_created__custom_field__nopen,
		service_code connote__connote_service,
		'NON DIGITAL CHANNEL' kategori_digital,
		'LOGISTIK' as kelompok,
		COUNT(order_code) as produksi,
		cast(SUM(
case 
when LOWER(jenis_produk) like '%include%'
then total_amount / (1 + 0.011)
else total_amount 
end
) as DECIMAL(18,
		2)) as pendapatan,
		0 fee_cod,
		SUM(tot_weight_kg)berat,
		cast(SUM(
case 
when LOWER(jenis_produk) like '%include%'
then total_amount - (total_amount / (1 + 0.011))
else 0
end
) as DECIMAL(18,
		2)) as pajak,
		subdit_id,
		service_name nama_produk
	from
		(
		select
			tgl_billing,
			kode_nopen ,
			service_code,
			service_name ,
			order_code,
			jenis_produk,
			case
				when service_code = 'FFE' then 'EB'
				else 'WIN'
			end as subdit_id,
			SUM(case when g.konversi_berat = g.total_qty or (g.konversi_berat >= 1000 and total_qty>1) then tot_weight_kg / konversi_berat
else tot_weight_kg end)tot_weight_kg,
			MAX(total_amount)total_amount
		from
			glid.glid g
		where
			DATE(tgl_billing) >= '20260101'
		group by
			1,
			2,
			3,
			4,
			5,
			6,
			7)t0
	group by
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		t0.subdit_id,
		t0.service_name)t3
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
	t3.location_data_created__custom_field__nopen = t4.kdnopen
union
--JASKUG
select
	DATE(t1.tgltr) as connote__created_at,
	DATE(null) as pod__timereceive,
	t1.jenis_feeder as status_sla,
	t1.jenis_feeder as customer_code,
	t1.jenis_feeder as transform__channel,
	t1.kdkantor as location_data_created__custom_field__nopen,
	t1.kdproduk as connote__connote_service,
	t1.jenis_feeder as kelompok,
	case
		when t1.regional = '00' then 'DIGITAL CHANNEL'
		else 'BUKAN DIGITAL CHANNEL'
	end kelompok_digital,
	SUM(t1.produksi) as produksi,
	SUM(t1.pendapatan) as pendapatan,
	0 as fee_cod,
	0 as berat,
	SUM(t1.pajak) as pajak,
	t5.kategori_bisnis subdit_id,
	t1.ketproduk nama_produk,
	t5.kategori_layanan group_produk,
	'DALAM NEGERI' kategori_layanan,
	coalesce(
case
		when t1.regional = '00' then 'MODERN CHANNEL'
		else t4.regional::VARCHAR
	end,
	'TIDAK TERDEFINISI') as regional,
	coalesce(
case
		when t1.regional = '00' then 'MODERN CHANNEL'
		else t4.kcu
	end,
	'TIDAK TERDEFINISI') as kcu,
	coalesce(
case
		when t1.regional = '00' then 'MODERN CHANNEL'
		else t4.kc
	end,
	'TIDAK TERDEFINISI') as kc,
	coalesce(
case
		when t1.regional = '00' then 'MODERN CHANNEL'
		else t4.ketnopen::VARCHAR
	end,
	'TIDAK TERDEFINISI') as kcp,
	coalesce(
case
		when t1.regional = '00' then 'MODERN CHANNEL'
		else t4.jenis::VARCHAR
	end,
	'TIDAK TERDEFINISI') as jenis,
	'FEEDER_SAP' sumber
from
	sap.feeder_sap t1
left join (
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
				UPPER(ketnopen) as ketnopen,
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
) t4
on
	t1.kdkantor = t4.kdnopen
	--joinkeun layana jaskug
left join(
	select
		*
	from
		referensi.layanan_jaskug)t5
on
	t1.kdproduk = t5.kdproduk
	and t1.ketproduk = t5.ketproduk
where
	DATE(t1.tgltr) >= '20260101'
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
	12,
	13,
	15,
	16,
	17,
	18,
	19,
	20,
	21,
	22,
	23
union
--CCH
select
	DATE(t1.tanggal_tambah) as connote__created_at,
	DATE(t1.tanggal_status)pod__timereceive,
	t2.deskripsi_status status_sla,
	t1.id_pelanggan::VARCHAR customer_code ,
	UPPER(t4.sumber) transform__channel,
	kantor_asal location_data_created__custom_field__nopen,
	jenis_kiriman connote__connote_service,
	'CCH' kelompok,
	'DIGITAL CHANNEL' kategori_digital,
	COUNT(distinct t1.id_pengaduan)produksi,
	0 pendapatan,
	0 fee_cod,
	0 berat,
	0 pajak,
	'CCH' subdit_id,
	UPPER(t3.deskripsi) nama_produk,
	UPPER(t3.deskripsi) group_produk,
	UPPER(t5.deskripsi) kategori_layanan,
	coalesce(t6.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t6.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t6.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t6.ketnopen),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t6.jenis),
	'TIDAK TERDEFINISI') jenis,
	'CCH' sumber
from
	cch.cchentri t1
	--	jenis penanganan
left join(
	select
		*
	from
		cch.cch_jenis_penanganan
)t2
on
	t1.status_akhir = t2.id_status::int
	--	jenis layanan
left join(
	select
		*
	from
		cch.cch_jenis_layanan
)t3
on
	t1.jenis_kiriman = t3.kode_layanan
	--	sumber pengaduan
left join(
	select
		*
	from
		cch.cch_sumber_pengaduan csp 
)t4
on
	t1.sumber_pengaduan = t4.id
	--	jenis Pengaduan
left join(
	select
		*
	from
		cch.cch_jenis_pengaduan
)t5
on
	t1.jenis_pengaduan = t5.kode_jenis
	--	JOIN ka referensi_kantor
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
)t6
on
	t1.kantor_asal = t6.kdnopen
where
	t1.tanggal_tambah >'20260101'
group by
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	t3.deskripsi,
	t5.deskripsi,
	t6.regional,
	t6.kcu,
	t6.kc,
	t6.ketnopen,
	t6.jenis
