SELECT 
t1.kantor_tujuan_update ,
date(cchentri.Tanggal_Tambah)Tanggal_Tambah ,
date(cchentri.Tanggal_Status)Tanggal_Status ,
cch_jenis_pengaduan.Deskripsi jenis_pengaduan,
cch_sumber_pengaduan.Sumber sumber_pengaduan,
cch_jenis_layanan.Deskripsi jenis_layanan,
cch_jenis_penanganan.Deskripsi_Status ,
coalesce(t4.regional :: VARCHAR,
	'TIDAK TERDEFINISI') regional,
coalesce(t4.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t4.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t4.ketnopen),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t4.jenis),
	'TIDAK TERDEFINISI') jenis,
COUNT(*)jumlah_pengaduan,
SUM(COUNT(*))OVER() uji_total
FROM (
    -- Langkah 1: Ambil daftar kantor unik yang statusnya '101'
    SELECT DISTINCT cchentridet.Kantor_Tujuan_Update
    FROM cchentridet 
    JOIN cchentri 
    ON cchentri.ID_Pengaduan = cchentridet.ID_Pengaduan
    WHERE cchentridet.Status_Update = '101'
    AND cchentri.Tanggal_Tambah >'20260101'
) AS t1
JOIN cchentri 
ON cchentri.Semua_Tujuan LIKE '%' || t1.Kantor_Tujuan_Update || '%'
left join cch_sumber_pengaduan
on cchentri.Sumber_Pengaduan =cch_sumber_pengaduan.id
left join cch_jenis_pengaduan
on cchentri.Jenis_Pengaduan =cch_jenis_pengaduan.Kode_Jenis
left join cch_jenis_layanan
on cchentri.Jenis_Kiriman =cch_jenis_layanan.Kode_Layanan 
left join cch_jenis_penanganan
on cchentri.Status_Akhir =cch_jenis_penanganan.ID_Status
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
	t1.kantor_tujuan_update= t4.kdnopen
WHERE cchentri.Tanggal_Tambah >'20260101'
group by 1,2,3,4,5,6,7,8,9,10,11,12
