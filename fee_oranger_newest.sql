WITH mut AS (
    SELECT
        id_mitra,
        nopend_t,
        tgl_update,
        ROW_NUMBER() OVER (
            PARTITION BY id_mitra
            ORDER BY tgl_update DESC
        ) AS rn
    FROM db_kemitraan.dbo.t_mutasi
)
SELECT
    CONVERT(date, pjk.tgl , 103)  AS tanggal,
    pjk.id_mitra,
    UPPER(COALESCE(mit.nama_mitra, 'TIDAK DIKETAHUI')) AS nama_mitra,
    UPPER(COALESCE(mit.jabatan, 'TIDAK DIKETAHUI')) AS jabatan,
    COALESCE(mut.nopend_t, up.nopend) AS nopend,
    pjk.pph21,
    pjk.total_fee,
    pjk.terbayar,
    COALESCE(up.produksi, 0) + COALESCE(upu.produksi, 0) AS produksi
FROM db_kemitraan.dbo.t_pajak_a pjk
LEFT JOIN db_kemitraan.dbo.t_mitra mit
    ON pjk.id_mitra = mit.id_mitra
LEFT JOIN mut
    ON pjk.id_mitra = mut.id_mitra
    AND mut.rn = 1
LEFT JOIN db_kemitraan.dbo.t_upah up
    ON pjk.id_mitra = up.id_mitra
    AND pjk.bulan_transaksi = up.bulan_transaksi
LEFT JOIN db_kemitraan.dbo.t_upah_lpu upu
    ON pjk.id_mitra = upu.id_mitra
    AND pjk.bulan_transaksi = upu.bulan_transaksi
where CONVERT(date, pjk.tgl , 103) >= '2026-01-01'
