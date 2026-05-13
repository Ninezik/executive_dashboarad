select date(cchentri.Tanggal_Tambah)Tanggal_Tambah ,
DATE(cchentri.Tanggal_Status)Tanggal_Status ,
t1.kantor_tujuan_update,
cch_jenis_penanganan.Deskripsi_Status,
cch_sumber_pengaduan.Sumber ,
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
COUNT(ID_Pengaduan)jumlah_pengaduan,
SUM(COUNT(id_pengaduan)) OVER() total
FROM
(    SELECT DISTINCT u.Kantor_Tujuan_Update
    FROM cchentridet u
    JOIN cchentri e ON e.ID_Pengaduan = u.ID_Pengaduan
    WHERE u.Status_Update = '101'
    AND e.Tanggal_Tambah >'20260101'
)t1
join cchentri
on cchentri.Semua_Tujuan LIKE CONCAT('%', t1.Kantor_Tujuan_Update, '%')
join cch_jenis_penanganan
on cchentri.Status_Akhir =cch_jenis_penanganan.id_status
join (select distinct id, UPPER(sumber)sumber from cch_sumber_pengaduan)cch_sumber_pengaduan
on cchentri.Sumber_Pengaduan =cch_sumber_pengaduan.ID 
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
where Tanggal_Tambah >'20260101' 
group by 1,2,3,4,5,6,7,8,9
order by 1
