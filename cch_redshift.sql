WITH sumber AS (
    SELECT 
        date(tanggal_tambah)tanggal_tambah,
        date(tanggal_status)tanggal_status,
        sumber_pengaduan,
        jenis_pengaduan,
        jenis_kiriman,
        semua_tujuan,
        status_akhir,
        COUNT(distinct id_pengaduan) total_pengaduan
    FROM cchentri
    WHERE tanggal_tambah >'20260101'
--      AND tanggal_tambah <'20260508'
    GROUP BY 1,2,3,4,5,6,7
),
numbers AS (
    SELECT 1 AS n
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
    UNION ALL SELECT 7
    UNION ALL SELECT 8
    UNION ALL SELECT 9
    UNION ALL SELECT 10
),
explode AS (
    SELECT
        s.tanggal_tambah,
        s.tanggal_status,
        s.sumber_pengaduan,
        s.jenis_kiriman,
        s.jenis_pengaduan,
        s.status_akhir,
        s.total_pengaduan,
        TRIM(
            SPLIT_PART(
                s.semua_tujuan,
                ',',
                numbers.n
            )
        ) AS nopen
    FROM sumber s
    JOIN numbers
        ON numbers.n <= REGEXP_COUNT(s.semua_tujuan, ',') + 1
)
SELECT 
    tanggal_tambah,
    tanggal_status,
--    sumber_pengaduan,
--    jenis_pengaduan,
    nopen,
    t7.deskripsi_status,
--    UPPER(t4.sumber) sumber_pengaduan,
    coalesce(t6.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t6.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t6.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t6.kcp),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t6.jenis),
	'TIDAK TERDEFINISI') jenis,
	UPPER(coalesce(t3.deskripsi,'tidak terdefinisi')) nama_produk,
	UPPER(coalesce(t4.sumber,'tidak terdefinisi')) sumber_pengaduan,
	UPPER(coalesce(t5.deskripsi,'tidak terdefinisi')) jenis_pengaduan,
    SUM(total_pengaduan) total_nilai,
    SUM(SUM(total_pengaduan)) OVER() uji_total_seluruh,
	'CCH' sumber
FROM explode t_utama
--	JOIN ka referensi_kantor
left join
(
	select
		*
	from
		(
		select
			t1.kdnopen,
			t1.ketnopen kcp,
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
	t_utama.nopen= t6.kdnopen
--	jenis layanan
	left JOIN(
	select distinct kode_layanan,deskripsi
	from cch.cch_jenis_layanan
	)t3
	on t_utama.jenis_kiriman=t3.kode_layanan
--	sumber pengaduan
	left JOIN(
	select distinct id,sumber
	from cch.cch_sumber_pengaduan csp 
	)t4
	on t_utama.sumber_pengaduan=t4.id
--	jenis Pengaduan
	left JOIN(
	select distinct kode_jenis,deskripsi
	from cch.cch_jenis_pengaduan
	)t5
	on t_utama.jenis_pengaduan=t5.kode_jenis
	
-- status penanganan
	left JOIN(
	SELECT distinct id_status, deskripsi_status
FROM cch.cch_jenis_penanganan
	)t7
	on t_utama.status_akhir=t7.id_status
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
