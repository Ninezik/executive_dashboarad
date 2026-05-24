SELECT 
    a.nopend,
    a.bulan_transaksi,
--    LEFT(a.id_mitra, 3) AS kode_mitra,
    UPPER(COALESCE(
        ref_jbt.keterangan,
        SUBSTRING(
            a.id_mitra,
            CHARINDEX('-', a.id_mitra) + 1,
            LEN(a.id_mitra)
        )
    )) AS keterangan,
    SUM(a.total_fee) AS total_fee,
    SUM(a.produksi) AS produksi
FROM (
    SELECT 
        nopend,
        CONVERT(date, LEFT(bulan_transaksi, 7) + '-01') AS bulan_transaksi,
        id_mitra,
        total_fee,
        produksi
    FROM t_upah
    UNION ALL
    SELECT 
        nopend,
        CONVERT(date, LEFT(bulan_transaksi, 7) + '-01') AS bulan_transaksi,
        id_mitra,
        total_kolekting_antaran AS total_fee,
        produksi
    FROM t_upah_lpu
) a
LEFT JOIN ref_jbt
    ON LEFT(a.id_mitra, 3) = ref_jbt.id_regmitra
WHERE YEAR(a.bulan_transaksi) > 2025
GROUP BY 
    a.nopend,
    a.bulan_transaksi,
--    LEFT(a.id_mitra, 3),
    UPPER(COALESCE(
        ref_jbt.keterangan,
        SUBSTRING(
            a.id_mitra,
            CHARINDEX('-', a.id_mitra) + 1,
            LEN(a.id_mitra)
        )
    ))
