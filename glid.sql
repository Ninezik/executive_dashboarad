SELECT
    DATE(tgl_billing) AS connote__created_at,
    service_code AS connote__connote_service,
    CASE
        WHEN service_code = 'FFE' THEN 'EB'
        ELSE 'WIN'
    END AS segment,
    COUNT(order_code) AS produksi,
    CAST(SUM(
        CASE 
            WHEN LOWER(jenis_produk) LIKE '%include%'
            THEN total_amount / (1 + 0.011)
            ELSE total_amount 
        END
    ) AS DECIMAL(18,2)) AS pendapatan,
    CAST(SUM(
        CASE 
            WHEN LOWER(jenis_produk) LIKE '%include%'
            THEN total_amount - (total_amount / (1 + 0.011))
            ELSE 0
        END
    ) AS DECIMAL(18,2)) AS pajak,
    'LOGISTIK' AS kelompok,
    'GLID' AS sumber
FROM glid.glid g
WHERE DATE(tgl_billing) > DATE '2026-01-01'
GROUP by 1,2,3
