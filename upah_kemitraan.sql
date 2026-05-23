SELECT 
    a.nopend,
    bulan_transaksi,
    LEFT(a.id_mitra,3)kode_mitra,
    UPPER(ref_jbt.keterangan) AS keterangan,
    SUM(a.total_fee) AS total_fee,
    SUM(a.produksi) AS produksi
FROM (
    SELECT 
        nopend,
        convert(date,LEFT(bulan_transaksi, 7)+'-01')bulan_transaksi,
        id_mitra,
        total_fee,
        produksi
    FROM t_upah
    UNION ALL
    SELECT 
        nopend,
        convert(date,LEFT(bulan_transaksi, 7)+'-01')bulan_transaksi,
        id_mitra,
        total_kolekting_antaran total_fee,
        produksi
    FROM t_upah_lpu
) a
LEFT JOIN ref_jbt
    ON LEFT(a.id_mitra, 3) = ref_jbt.id_regmitra
WHERE LEFT(a.bulan_transaksi, 4) > '2025'
GROUP BY 
    a.nopend,
    LEFT(a.id_mitra, 3),
    a.bulan_transaksi,
    ref_jbt.keterangan
