--trx nipos
SELECT
    DATE(np.connote__created_at) AS connote__created_at,
    np.location_data_created__custom_field__nopen nopen,
    UPPER(connote__connote_service) AS connote__connote_service,
    CASE
        WHEN connote__connote_service IN ('KRT', 'KBM', 'FFE', 'FF-LKPP') THEN 'LOGISTIK'
        ELSE 'KURIR'
    END AS kelompok,
    UPPER(customer_code) AS customer_code,
    t_salesforce.nm_perusahaan,
    case when customer_code is null then 'RB'
    else t_salesforce.subdit_id
    end as subdit_id,
coalesce(t_referensi_kantor.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t_referensi_kantor.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t_referensi_kantor.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t_referensi_kantor.ketnopen),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t_referensi_kantor.jenis),
	'TIDAK TERDEFINISI') jenis,
    COUNT(connote__connote_code) AS produksi,
    SUM(
        COALESCE(connote__connote_service_price,0)
        + COALESCE(connote__connote_surcharge_amount,0)
    ) AS pendapatan,
    SUM(
        CASE 
            WHEN UPPER(customer_code) = 'DAGSHOPEE04120A'
             AND UPPER(custom_field__cod) != 'NONCOD'
            THEN COALESCE(t_webhook.good_value, 0) * 0.005
            ELSE COALESCE(np.custom_field__fee_value, 0)
        END
    ) AS fee_cod
FROM nipos.nipos np
LEFT JOIN (
    SELECT DISTINCT resi, good_value
    FROM nipos.webhook_marketplace
    WHERE member_id = 'DAGSHOPEE04120A'
) t_webhook
ON np.connote__connote_booking_code = t_webhook.resi
	--joinkeun ka referensi subdit
left join
(
	select
		distinct idregpelanggan,
		subdit_id,nm_perusahaan
	from
		referensi.m_pelanggan)t_salesforce
on
	coalesce(np.customer_code,'KOSONG') = coalesce(t_salesforce.idregpelanggan,'KOSONG')
	--JOIN ka referensi_kantor
left join
(
	select
		*
	from
		(
		select
			t1.kdnopen,
			t1.ketnopen,
			t2.regional,
			t2.kcu,
			t2.kc,
			t1.jenis,
			row_number() over (partition by t1.kdnopen
		order by
			t1.kdnopen) as rn
		from
			(
			select
				kdnopen,
				ketnopen,
				kdkantor,
				jenis
			from
				referensi.refrensikantorbaru
) t1
		join (
			select
				distinct
nopend_dirian,
				kc,
				kcu,
				regional
			from
				referensi.ref_kcu_kc_2023
) t2
on
			t1.kdkantor = t2.nopend_dirian
) x
	where
		rn = 1
)t_referensi_kantor
on
	np.location_data_created__custom_field__nopen = t_referensi_kantor.kdnopen
WHERE
    UPPER(connote__location_name) != 'AGP TESTING LOCATION'
    AND connote__connote_amount >= 0
    AND connote__connote_service != 'LNINCOMING'
    AND UPPER(connote__connote_state) NOT IN ('CANCEL', 'PENDING')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
union
--trx glid
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
