SELECT
    t3.connote__created_at,
    t3.nopen,
    t3.connote__connote_service,
    'LOGISTIK' AS kelompok,
    t3.customer_code,
    'GLID' AS nm_perusahaan,
    t3.subdit_id,
    COALESCE(t4.regional::varchar, 'TIDAK TERDEFINISI') AS regional,
    COALESCE(t4.kcu, 'TIDAK TERDEFINISI') AS kcu,
    COALESCE(t4.kc, 'TIDAK TERDEFINISI') AS kc,
    COALESCE(UPPER(t4.ketnopen), 'TIDAK TERDEFINISI') AS kcp,
    COALESCE(UPPER(t4.jenis), 'TIDAK TERDEFINISI') AS jenis,
    COUNT(t3.order_code) AS produksi,
    CAST(
        SUM(
            CASE 
                WHEN LOWER(t3.jenis_produk) LIKE '%include%'
                THEN t3.total_amount / (1 + 0.011)
                ELSE t3.total_amount 
            END
        ) AS DECIMAL(18,2)
    ) AS pendapatan,
    0 AS fee_cod

FROM (
    SELECT
        DATE(tgl_billing) AS connote__created_at,
        kode_nopen AS nopen,
        customer_code,
        service_code AS connote__connote_service,
        service_name,
        order_code,
        jenis_produk,
        CASE
            WHEN service_code = 'FFE' THEN 'EB'
            ELSE 'WIN'
        END AS subdit_id,
        MAX(total_amount) AS total_amount
    FROM glid.glid g
    WHERE DATE(tgl_billing) >= DATE '2026-01-01'
    GROUP BY
        DATE(tgl_billing),
        kode_nopen,
        customer_code,
        service_code,
        service_name,
        order_code,
        jenis_produk,
        CASE
            WHEN service_code = 'FFE' THEN 'EB'
            ELSE 'WIN'
        END
) t3

LEFT JOIN (
    SELECT *
    FROM (
        SELECT
            t1.kdnopen,
            t1.ketnopen,
            t2.regional,
            t2.kcu,
            t2.kc,
            t1.jenis,
            ROW_NUMBER() OVER (PARTITION BY t1.kdnopen ORDER BY t1.kdnopen) AS rn
        FROM referensi.refrensikantorbaru t1
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
ON t3.nopen = t4.kdnopen
GROUP by 1,2,3,4,5,6,7,8,9,10,11,12
