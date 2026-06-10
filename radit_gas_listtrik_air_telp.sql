SELECT id_pk, id_pelanggan, jenis, regional, kode_dirian, nama_dirian, nama_pelanggan, system_bayar, etl_process
FROM referensi.ref_kantor_listrik_air_telp;

SELECT id_pk, idpelanggan, yyyymm, biaya, etl_process
FROM referensi.biaya_kantor_listrik_air_telp;


SELECT 
    ROW_NUMBER() OVER (ORDER BY ref.regional, ref.kode_dirian, ref.id_pelanggan) AS no,
    ref.jenis,
    ref.regional,
    ref.kode_dirian,
    ref.nama_dirian,
    ref.id_pelanggan,
    ref.nama_pelanggan,
    ref.system_bayar,
    -- Proses pivot untuk mengubah baris bulan menjadi kolom biaya
    COALESCE(SUM(CASE WHEN RIGHT(bio.yyyymm, 2) = '01' THEN bio.biaya END), 0) AS jan,
    COALESCE(SUM(CASE WHEN RIGHT(bio.yyyymm, 2) = '02' THEN bio.biaya END), 0) AS feb,
    COALESCE(SUM(CASE WHEN RIGHT(bio.yyyymm, 2) = '03' THEN bio.biaya END), 0) AS mar,
    COALESCE(SUM(CASE WHEN RIGHT(bio.yyyymm, 2) = '04' THEN bio.biaya END), 0) AS april,
    COALESCE(SUM(CASE WHEN RIGHT(bio.yyyymm, 2) = '05' THEN bio.biaya END), 0) AS mei
FROM referensi.ref_kantor_listrik_air_telp ref
LEFT JOIN referensi.biaya_kantor_listrik_air_telp bio 
    ON ref.id_pelanggan = bio.idpelanggan WHERE bio.yyyymm LIKE '2026%' 
GROUP BY 
ref.jenis
    ,ref.regional,
    ref.kode_dirian,
    ref.nama_dirian,
    ref.id_pelanggan,
    ref.nama_pelanggan,
    ref.system_bayar;
