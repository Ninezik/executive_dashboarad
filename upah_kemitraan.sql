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
    WHERE LEFT(t_upah.bulan_transaksi, 4)>'2025'
    UNION ALL
--    mitra lpu
SELECT
	coalesce(t_mitra.kantor,t_upah_lpu.nopend) nopend,
	CONVERT(date,LEFT(t_upah_lpu.bulan_transaksi,7) + '-01') AS bulan_transaksi,
	t_upah_lpu.id_mitra,
	t_upah_lpu.total_kolekting_antaran total_fee,
	t_upah_lpu.produksi
FROM
	t_upah_lpu
LEFT JOIN t_mitra
	ON
	t_upah_lpu.id_mitra = t_mitra.id_mitra
	WHERE left(bulan_transaksi,4)>'2025'
) a
LEFT JOIN ref_jbt
    ON LEFT(a.id_mitra, 3) = ref_jbt.id_regmitra
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
