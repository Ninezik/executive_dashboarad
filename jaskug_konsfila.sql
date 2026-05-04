SELECT
    DATE(t1.tgltr) AS connote__created_at,
    DATE(NULL) AS pod__timereceive,
    t1.jenis_feeder AS status_sla,
    t1.jenis_feeder AS customer_code,
    t1.jenis_feeder AS transform__channel,
    t1.kdkantor AS location_data_created__custom_field__nopen,
    t1.kdproduk AS connote__connote_service,
    t1.jenis_feeder AS kelompok,
    CASE 
            WHEN t1.regional = '00' THEN 'DIGITAL CHANNEL'
            ELSE 'BUKAN DIGITAL CHANNEL'
        end kelompok_digital,
    SUM(t1.produksi) AS produksi,
    SUM(t1.pendapatan) AS pendapatan,
    0 AS fee_cod,
    0 AS berat,
    SUM(t1.pajak) AS pajak,
    t5.kategori_bisnis subdit_id,
    t1.ketproduk nama_produk,
    t5.kategori_layanan group_produk,
    'DALAM NEGERI' kategori_layanan,
    COALESCE(
        CASE 
            WHEN t1.regional = '00' THEN 'MODERN CHANNEL'
            ELSE t4.regional::VARCHAR
        END,
    'TIDAK TERDEFINISI') AS regional,

    COALESCE(
        CASE 
            WHEN t1.regional = '00' THEN 'MODERN CHANNEL'
            ELSE t4.kcu
        END,
    'TIDAK TERDEFINISI') AS kcu,

    COALESCE(
        CASE 
            WHEN t1.regional = '00' THEN 'MODERN CHANNEL'
            ELSE t4.kc
        END,
    'TIDAK TERDEFINISI') AS kc,

    COALESCE(
        CASE 
            WHEN t1.regional= '00' THEN 'MODERN CHANNEL'
            ELSE t4.ketnopen::VARCHAR
        END,
    'TIDAK TERDEFINISI') AS kcp,

    COALESCE(
        CASE 
            WHEN t1.regional = '00' THEN 'MODERN CHANNEL'
            ELSE t4.jenis::VARCHAR
        END,
    'TIDAK TERDEFINISI') AS jenis,
    'FEEDER_SAP'sumber

FROM sap.feeder_sap t1

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
        FROM (
            SELECT
                kdnopen,
                UPPER(ketnopen) AS ketnopen,
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
ON t1.kdkantor = t4.kdnopen

--joinkeun layana jaskug
left join(select*
from referensi.layanan_jaskug)t5
on t1.kdproduk=t5.kdproduk
and t1.ketproduk=t5.ketproduk

WHERE DATE(t1.tgltr) >= '20260101'

GROUP BY
    1,2,3,4,5,6,7,8,9,12,13,15,16,17,18,19,20,21,22,23
