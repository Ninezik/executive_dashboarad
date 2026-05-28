SELECT 
    COALESCE(t_mutasi.nopend_t, t_upah.nopend) AS nopend,
    
    CAST(LEFT(t_upah.bulan_transaksi, 7) || '-01' AS date) AS bulan_transaksi,
    
    t_upah.id_mitra,

    UPPER(
        COALESCE(
            t_mitra.jabatan,
            SUBSTRING(
                t_upah.id_mitra
                FROM POSITION('-' IN t_upah.id_mitra) + 1
            )
        )
    ) AS jabatan,

    SUM(t_upah.total_fee) AS total_fee,
    SUM(t_upah.produksi) AS produksi,
    
    't_upah' AS sumber

FROM t_upah

LEFT JOIN (
    SELECT id_mitra, nopend_t
    FROM (
        SELECT 
            id_mitra,
            nopend_t,
            ROW_NUMBER() OVER (
                PARTITION BY id_mitra 
                ORDER BY tgl_update DESC
            ) AS urutan
        FROM t_mutasi
    ) t1
    WHERE t1.urutan = 1
) t_mutasi
ON t_upah.id_mitra = t_mutasi.id_mitra

LEFT JOIN t_mitra
ON t_upah.id_mitra = t_mitra.id_mitra

WHERE LEFT(t_upah.bulan_transaksi, 4) > '2025'

GROUP BY 
    COALESCE(t_mutasi.nopend_t, t_upah.nopend),

    CAST(LEFT(t_upah.bulan_transaksi, 7) || '-01' AS date),

    t_upah.id_mitra,

    UPPER(
        COALESCE(
            t_mitra.jabatan,
            SUBSTRING(
                t_upah.id_mitra
                FROM POSITION('-' IN t_upah.id_mitra) + 1
            )
        )
    )

UNION ALL

-- mitra lpu
SELECT 
    COALESCE(t_mutasi.nopend_t, t_upah_lpu.nopend) AS nopend,

    CAST(LEFT(t_upah_lpu.bulan_transaksi, 7) || '-01' AS date) AS bulan_transaksi,

    t_upah_lpu.id_mitra,

    UPPER(
        COALESCE(
            t_mitra.jabatan,
            SUBSTRING(
                t_upah_lpu.id_mitra
                FROM POSITION('-' IN t_upah_lpu.id_mitra) + 1
            )
        )
    ) AS jabatan,

    SUM(t_upah_lpu.total_kolekting_antaran) AS total_fee,
    SUM(t_upah_lpu.produksi) AS produksi,

    't_upah_lpu' AS sumber

FROM t_upah_lpu

LEFT JOIN (
    SELECT id_mitra, nopend_t
    FROM (
        SELECT 
            id_mitra,
            nopend_t,
            ROW_NUMBER() OVER (
                PARTITION BY id_mitra 
                ORDER BY tgl_update DESC
            ) AS urutan
        FROM t_mutasi
    ) t1
    WHERE t1.urutan = 1
) t_mutasi
ON t_upah_lpu.id_mitra = t_mutasi.id_mitra
LEFT JOIN t_mitra
ON t_upah_lpu.id_mitra = t_mitra.id_mitra
WHERE LEFT(t_upah_lpu.bulan_transaksi, 4) > '2025'
GROUP BY 
    COALESCE(t_mutasi.nopend_t, t_upah_lpu.nopend),
    CAST(LEFT(t_upah_lpu.bulan_transaksi, 7) || '-01' AS date),
    t_upah_lpu.id_mitra,
    UPPER(
        COALESCE(
            t_mitra.jabatan,
            SUBSTRING(
                t_upah_lpu.id_mitra
                FROM POSITION('-' IN t_upah_lpu.id_mitra) + 1
            )
        )
    )
