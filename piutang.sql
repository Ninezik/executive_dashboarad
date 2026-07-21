SELECT 
    sp.gl_account_number,
    sp.gl_account_text,
    sp.external_customer_no,
    t4.regional,
    t4.kcu,
    t4.kc,
    t4.ketnopen AS kcp,
    t4.kdnopen,
    t4.jenis,
    COALESCE(tsubdit.subdit_id, 'TIDAK TERDEFINISI') AS subdit_id,
    SUM(sp.amount) AS nilai,
    SUM(SUM(sp.amount)) OVER () AS total
FROM sap.sap_piutang sp
LEFT JOIN (
    SELECT *
    FROM (
        SELECT
            t1.kdnopen,
            UPPER(t1.ketnopen) AS ketnopen,
            t2.regional,
            t2.kcu,
            t2.kc,
            t1.jenis,
            ROW_NUMBER() OVER (
                PARTITION BY t1.kdnopen
                ORDER BY t1.kdnopen
            ) AS rn
        FROM (
            SELECT
                kdnopen,
                ketnopen,
                kdkantor,
                jenis
            FROM referensi.refrensikantorbaru
        ) t1
        JOIN (
            SELECT DISTINCT
                nopend_dirian,
                kc,
                kcu,
                regional
            FROM referensi.ref_kcu_kc_2023
        ) t2
            ON t1.kdkantor = t2.nopend_dirian
    ) x
    WHERE rn = 1
) t4
    ON SUBSTRING(sp.profit_center, 4, 5) = t4.kdnopen
LEFT JOIN (
    SELECT DISTINCT
        idregpelanggan,
        subdit_id
    FROM referensi.m_pelanggan
) tsubdit
    ON sp.external_customer_no = tsubdit.idregpelanggan
WHERE sp.gl_account_number <> '2101010001'
GROUP BY
    sp.gl_account_number,
    sp.gl_account_text,
    sp.external_customer_no,
    t4.regional,
    t4.kcu,
    t4.kc,
    t4.ketnopen,
    t4.kdnopen,
    t4.jenis,
    COALESCE(tsubdit.subdit_id, 'TIDAK TERDEFINISI');
