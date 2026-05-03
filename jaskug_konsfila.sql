select
		t3.tgltr connote__created_at,
		DATE(null) pod__timereceive ,
		t3.jenis_feeder  status_sla,
		t3.jenis_feeder  customer_code,
		t3.jenis_feeder  transform__channel,
		t3.kdkantor  location_data_created__custom_field__nopen,
		t3.kdproduk  connote__connote_service,
		t3.ketproduk  nama_produk,
		t3.jenis_feeder  as kelompok,
		t3.produksi,
		t3.pendapatan,
		0 fee_cod,
		0 berat,
		t3.pajak,
		'MENUGGU DATA REFERENSI' subdit_id,
		t3.jenis_feeder sumber,
	coalesce(case
		when t3.regional_ = '00' then 'MODERN CHANNEL'
		else t4.regional::VARCHAR
	end,
	'TIDAK TERDEFINISI') as regional,
	coalesce(case
		when t3.regional_ = '00' then 'MODERN CHANNEL'
		else t4.kcu
	end,
	'TIDAK TERDEFINISI') as kcu,
	coalesce(case
		when t3.regional_ = '00' then 'MODERN CHANNEL'
		else t4.kc
	end,
	'TIDAK TERDEFINISI') as kc,
	coalesce(case
			when t3.regional_ = '00' then 'MODERN CHANNEL'
		else t4.ketnopen ::VARCHAR
	end,
	'TIDAK TERDEFINISI') as kcp,
	coalesce(case
			when t3.regional_ = '00' then 'MODERN CHANNEL'
		else t4.jenis::VARCHAR
	end,
	'TIDAK TERDEFINISI') as jenis
from
		(
	select
			date(tgltr)tgltr,
			ketproduk ,
			kdproduk ,
			kdkantor,
			jenis_feeder,
			regional regional_,
			SUM(produksi)produksi,
			SUM(pendapatan)pendapatan,
			SUM(pajak)pajak
	from
			sap.feeder_sap
	where date(tgltr)>='20260101'
	group by
			1,
			2,
			3,
			4,
			5,
			6
)t3	--	joinkeun ka referensi kantor 
left join
(SELECT *
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
            UPPER(ketnopen)ketnopen,
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
)t4
on
	t3.kdkantor  = t4.kdnopen
