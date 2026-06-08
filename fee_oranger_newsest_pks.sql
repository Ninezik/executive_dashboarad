SELECT *
FROM (
    SELECT
        CASE
            WHEN CHARINDEX('-', t_pajak_a.id_mitra) > 0
                THEN LEFT(t_pajak_a.id_mitra, CHARINDEX('-', t_pajak_a.id_mitra) - 1)
            ELSE t_pajak_a.id_mitra
        END AS id_mitra_clean,
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
        ON CASE
            WHEN CHARINDEX('-', t_pajak_a.id_mitra) > 0
                THEN LEFT(t_pajak_a.id_mitra, CHARINDEX('-', t_pajak_a.id_mitra) - 1)
            ELSE t_pajak_a.id_mitra
        END
        =
        CASE
            WHEN CHARINDEX('-', t_upah_lengkap.id_mitra) > 0
                THEN LEFT(t_upah_lengkap.id_mitra, CHARINDEX('-', t_upah_lengkap.id_mitra) - 1)
            ELSE t_upah_lengkap.id_mitra
        END
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
        ON CASE
            WHEN CHARINDEX('-', t_pajak_a.id_mitra) > 0
                THEN LEFT(t_pajak_a.id_mitra, CHARINDEX('-', t_pajak_a.id_mitra) - 1)
            ELSE t_pajak_a.id_mitra
        END
        =
        CASE
            WHEN CHARINDEX('-', t_pks.id_mitra) > 0
                THEN LEFT(t_pks.id_mitra, CHARINDEX('-', t_pks.id_mitra) - 1)
            ELSE t_pks.id_mitra
        END
    LEFT JOIN db_kemitraan.dbo.t_mitra t_mitra
        ON CASE
            WHEN CHARINDEX('-', t_pajak_a.id_mitra) > 0
                THEN LEFT(t_pajak_a.id_mitra, CHARINDEX('-', t_pajak_a.id_mitra) - 1)
            ELSE t_pajak_a.id_mitra
        END
        =
        CASE
            WHEN CHARINDEX('-', t_mitra.id_mitra) > 0
                THEN LEFT(t_mitra.id_mitra, CHARINDEX('-', t_mitra.id_mitra) - 1)
            ELSE t_mitra.id_mitra
        END
    LEFT JOIN (
        SELECT
            CASE
                WHEN CHARINDEX('-', t_mutasi.id_mitra) > 0
                    THEN LEFT(t_mutasi.id_mitra, CHARINDEX('-', t_mutasi.id_mitra) - 1)
                ELSE t_mutasi.id_mitra
            END AS id_mitra_clean,
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
        ON CASE
            WHEN CHARINDEX('-', t_pajak_a.id_mitra) > 0
                THEN LEFT(t_pajak_a.id_mitra, CHARINDEX('-', t_pajak_a.id_mitra) - 1)
            ELSE t_pajak_a.id_mitra
        END
        = t_mutasi.id_mitra_clean
) t5;
