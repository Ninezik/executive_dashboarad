SELECT *
FROM (
    SELECT
        t_pajak_a.id_mitra,
        UPPER(t_mitra.jabatan) AS jabatan,
        CONVERT(DATE, t_pajak_a.tgl, 103) AS tgl,
        t_pajak_a.bulan_transaksi,
        t_pajak_a.pph21,
        t_pajak_a.terbayar,
        t_upah_lengkap.produksi,
        t_upah_lengkap.sumber,
        UPPER(t_pks.no_pks) AS no_pks,
        COALESCE(t_mutasi.nopend_t, t_upah_lengkap.nopend) AS nopen
    FROM (
        SELECT *
        FROM db_kemitraan.dbo.t_pajak_a
        WHERE LEFT(bulan_transaksi, 4) = '2026'
          AND status = '01'
    ) t_pajak_a
    LEFT JOIN (
        SELECT id_mitra, produksi, bulan_transaksi, sumber, nopend
        FROM (
            SELECT
                id_mitra,
                produksi,
                bulan_transaksi,
                't_upah' AS sumber,
                nopend
            FROM t_upah
            WHERE LEFT(bulan_transaksi, 4) = '2026'
            UNION
            SELECT
                id_mitra,
                produksi,
                bulan_transaksi,
                't_upah_lpu' AS sumber,
                nopend
            FROM t_upah_lpu
            WHERE LEFT(bulan_transaksi, 4) = '2026'
        ) t_upah_lengkap
    ) t_upah_lengkap
        ON t_pajak_a.id_mitra=t_upah_lengkap.id_mitra
       AND t_pajak_a.bulan_transaksi = t_upah_lengkap.bulan_transaksi
    LEFT JOIN (
        SELECT id_mitra, no_pks, tgl_selesai
        FROM (
            SELECT
                id_mitra,
                no_pks,
                tgl_selesai,
                ROW_NUMBER() OVER (
                    PARTITION BY id_mitra
                    ORDER BY tgl_selesai DESC
                ) rn
            FROM db_kemitraan.dbo.t_pks
        ) t1
        WHERE rn = 1
    ) t_pks
        ON t_pajak_a.id_mitra=t_pks.id_mitra
    LEFT JOIN db_kemitraan.dbo.t_mitra t_mitra
        ON  t_pajak_a.id_mitra= t_mitra.id_mitra
    LEFT JOIN (
        SELECT
            t_mutasi.id_mitra,
            t_mutasi.nopend_t
        FROM (
            SELECT
                id_mitra,
                nopend_t,
                ROW_NUMBER() OVER (
                    PARTITION BY id_mitra
                    ORDER BY tgl_update DESC
                ) rn
            FROM t_mutasi
        ) t_mutasi
        WHERE rn = 1
    ) t_mutasi
        ON t_pajak_a.id_mitra= t_mutasi.id_mitra
) t5;
