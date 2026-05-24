SELECT 
        coalesce(t_mutasi.nopend_t,t_upah.nopend)nopend,
        CONVERT(date, LEFT(t_upah.bulan_transaksi, 7) + '-01') AS bulan_transaksi,
        t_upah.id_mitra,
        UPPER(COALESCE(
        t_mitra.jabatan,
        SUBSTRING(
            t_upah.id_mitra,
            CHARINDEX('-', t_upah.id_mitra) + 1,
            LEN(t_upah.id_mitra)
        )
    ))jabatan,
        SUM(t_upah.total_fee)total_fee,
        SUM(t_upah.produksi)produksi,
        't_upah' sumber
    FROM t_upah
LEFT JOIN (
SELECT id_mitra,nopend_t
FROM
(SELECT id_mitra,nopend_t,
ROW_NUMBER () OVER(partition by id_mitra ORDER BY tgl_update DESC)urutan
FROM t_mutasi
)t1
WHERE t1.urutan=1
)t_mutasi
ON t_upah.id_mitra=t_mutasi.id_Mitra
LEFT JOIN t_mitra
ON t_upah.id_mitra=t_mitra.id_mitra
WHERE LEFT(t_upah.bulan_transaksi, 4)>'2025'
GROUP BY coalesce(t_mutasi.nopend_t,t_upah.nopend),
        CONVERT(date, LEFT(t_upah.bulan_transaksi, 7) + '-01'),
        t_upah.id_mitra,
        UPPER(COALESCE(
        t_mitra.jabatan,
        SUBSTRING(
            t_upah.id_mitra,
            CHARINDEX('-', t_upah.id_mitra) + 1,
            LEN(t_upah.id_mitra)
        )
    ))
 UNION ALL
-- mitra lpu
SELECT 
        coalesce(t_mutasi.nopend_t,t_upah_lpu.nopend)nopend,
        CONVERT(date, LEFT(t_upah_lpu.bulan_transaksi, 7) + '-01') AS bulan_transaksi,
        t_upah_lpu.id_mitra,
        UPPER(COALESCE(
        t_mitra.jabatan,
        SUBSTRING(
            t_upah_lpu.id_mitra,
            CHARINDEX('-', t_upah_lpu.id_mitra) + 1,
            LEN(t_upah_lpu.id_mitra)
        )
    ))jabatan,
        SUM(t_upah_lpu.total_kolekting_antaran)total_fee,
        SUM(t_upah_lpu.produksi)produksi,
        't_upah_lpu' sumber
    FROM t_upah_lpu
LEFT JOIN (
SELECT id_mitra,nopend_t
FROM
(SELECT id_mitra,nopend_t,
ROW_NUMBER () OVER(partition by id_mitra ORDER BY tgl_update DESC)urutan
FROM t_mutasi
)t1
WHERE t1.urutan=1
)t_mutasi
ON t_upah_lpu.id_mitra=t_mutasi.id_Mitra
LEFT JOIN t_mitra
ON t_upah_lpu.id_mitra=t_mitra.id_mitra
WHERE LEFT(t_upah_lpu.bulan_transaksi, 4)>'2025'
GROUP BY coalesce(t_mutasi.nopend_t,t_upah_lpu.nopend),
        CONVERT(date, LEFT(t_upah_lpu.bulan_transaksi, 7) + '-01'),
        t_upah_lpu.id_mitra,
        UPPER(COALESCE(
        t_mitra.jabatan,
        SUBSTRING(
            t_upah_lpu.id_mitra,
            CHARINDEX('-', t_upah_lpu.id_mitra) + 1,
            LEN(t_upah_lpu.id_mitra)
        )
    ))
