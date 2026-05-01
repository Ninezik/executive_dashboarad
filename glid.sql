select  t3.*,
coalesce(UPPER(t4.ketnopen),'TIDAK TERDEFINISI') ketnopen,
coalesce(t4.regional::varchar,'TIDAK TERDEFINISI') regional,
coalesce(t4.kcu,'TIDAK TERDEFINISI')  kcu,
coalesce(t4.kc,'TIDAK TERDEFINISI')  kc
FROM
(SELECT
    DATE(tgl_billing) AS connote__created_at,
    kode_nopen,
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
    SUM(tot_weight_kg)berat,
    'LOGISTIK' AS kelompok,
    'GLID' AS sumber
FROM (
select
	tgl_billing,
    kode_nopen,
    service_code,
    order_code,
    jenis_produk,
    SUM(case when g.konversi_berat =g.total_qty or g.konversi_berat >=1000 then tot_weight_kg/konversi_berat
    else tot_weight_kg end)tot_weight_kg,
   MAX(total_amount)total_amount
FROM glid.glid g
group by 1,2,3,4,5
)t0
WHERE DATE(tgl_billing) > DATE '2026-01-01'
GROUP by 1,2,3,4)t3
left join
(
	select
			distinct 
			t1.kdnopen,
			t1.ketnopen,
			t2.regional,
			t2.kcu,
			t2.kc
	from
			(
		select
				kdnopen,
				ketnopen,
				kdkantor
		from
				referensi.refrensikantorbaru
)t1
		--referensi_lengkap
	join
(
		select
			distinct 
			nopend_dirian,
				kc,
				kcu,
				regional
		from
				referensi.ref_kcu_kc_2023
)t2
on
			t1.kdkantor = t2.nopend_dirian
)t4
on t3.kode_nopen=t4.kdnopen
order by 1,2
