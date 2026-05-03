select
	t3.*,
	coalesce(t4.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t4.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t4.kc,
	'TIDAK TERDEFINISI') kc,
	coalesce(UPPER(t4.ketnopen),
	'TIDAK TERDEFINISI') kcp,
	coalesce(UPPER(t4.jenis),
	'TIDAK TERDEFINISI') jenis
from
	(select
		DATE(tgl_billing) connote__created_at,
		DATE(null) pod__timereceive ,
		'GLID' status_sla,
		'GLID' customer_code,
		'GLID' transform__channel,
		kode_nopen location_data_created__custom_field__nopen,
		service_code connote__connote_service,
		service_name nama_produk,
		'LOGISTIK' as kelompok,
		COUNT(order_code) as produksi,
		cast(SUM(
        case 
            when LOWER(jenis_produk) like '%include%'
            then total_amount / (1 + 0.011)
            else total_amount 
        end
    ) as DECIMAL(18,
		2)) as pendapatan,
		0 fee_cod,
		SUM(tot_weight_kg)berat,
		cast(SUM(
        case 
            when LOWER(jenis_produk) like '%include%'
            then total_amount - (total_amount / (1 + 0.011))
            else 0
        end
    ) as DECIMAL(18,2)) as pajak,
    subdit_id,
		'GLID' as sumber
	from
		(
		select
			tgl_billing,
			kode_nopen ,
			service_code,
			service_name ,
			order_code,
			jenis_produk,
			case
			when service_code = 'FFE' then 'EB'
			else 'WIN'
		end as subdit_id,
			SUM(case when g.konversi_berat = g.total_qty or (g.konversi_berat >= 1000 and total_qty>1) then tot_weight_kg / konversi_berat
    else tot_weight_kg end)tot_weight_kg,
			MAX(total_amount)total_amount
		from
			glid.glid g
		where DATE(tgl_billing) >='20260101'
		group by 1,2,3,4,5,6,7
)t0
group by 1,2,3,4,5,6,7,8,9,t0.subdit_id)t3
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
)t4
on
	t3.location_data_created__custom_field__nopen  = t4.kdnopen
order by
	1,
	2
