	select
	DATE(t1.tanggal_tambah) as connote__created_at,
	DATE(t1.tanggal_status)pod__timereceive,
	t2.deskripsi_status status_sla,
	t1.id_pelanggan::VARCHAR  customer_code ,
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
	left JOIN(
	select*
	from cch.cch_jenis_penanganan
	)t2
	on t1.status_akhir=t2.id_status::int
		
--	jenis layanan
	left JOIN(
	select*
	from cch.cch_jenis_layanan
	)t3
	on t1.jenis_kiriman=t3.kode_layanan

--	sumber pengaduan
	left JOIN(
	select*
	from cch.cch_sumber_pengaduan csp 
	)t4
	on t1.sumber_pengaduan=t4.id
	
--	jenis Pengaduan
	left JOIN(
	select*
	from cch.cch_jenis_pengaduan
	)t5
	on t1.jenis_pengaduan=t5.kode_jenis
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
	t1.kantor_asal= t6.kdnopen
where t1.tanggal_tambah >'20260101'
	group by 1,2,3,4,5,6,7,8,t3.deskripsi,t5.deskripsi,t6.regional,t6.kcu,t6.kc,t6.ketnopen,t6.jenis
