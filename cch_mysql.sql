SELECT 
t1.kantor_tujuan_update ,
date(cchentri.Tanggal_Tambah)Tanggal_Tambah ,
date(cchentri.Tanggal_Status)Tanggal_Status ,
cch_jenis_pengaduan.Deskripsi jenis_pengaduan,
cch_sumber_pengaduan.Sumber sumber_pengaduan,
cch_jenis_layanan.Deskripsi jenis_layanan,
cch_jenis_penanganan.Deskripsi_Status ,
COUNT(*)jumlah_pengaduan,
SUM(COUNT(*))OVER() uji_total
FROM (
    -- Langkah 1: Ambil daftar kantor unik yang statusnya '101'
    SELECT DISTINCT cchentridet.Kantor_Tujuan_Update
    FROM cchentridet 
    JOIN cchentri 
    ON cchentri.ID_Pengaduan = cchentridet.ID_Pengaduan
    WHERE cchentridet.Status_Update = '101'
    AND cchentri.Tanggal_Tambah >'20260506'
    and cchentri.Tanggal_Tambah <'20260507'
) AS t1
JOIN cchentri 
ON cchentri.Semua_Tujuan LIKE CONCAT('%', t1.Kantor_Tujuan_Update, '%')
left join cch_sumber_pengaduan
on cchentri.Sumber_Pengaduan =cch_sumber_pengaduan.id
left join cch_jenis_pengaduan
on cchentri.Jenis_Pengaduan =cch_jenis_pengaduan.Kode_Jenis
left join cch_jenis_layanan
on cchentri.Jenis_Kiriman =cch_jenis_layanan.Kode_Layanan 
left join cch_jenis_penanganan
on cchentri.Status_Akhir =cch_jenis_penanganan.ID_Status
WHERE cchentri.Tanggal_Tambah >'20260506'
and cchentri.Tanggal_Tambah <'20260507'
group by 1,2,3,4,5,6,7
