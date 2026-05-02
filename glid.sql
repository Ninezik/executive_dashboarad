select
	t3.*,
	coalesce(UPPER(t4.ketnopen),
	'TIDAK TERDEFINISI') ketnopen,
	coalesce(t4.regional::varchar,
	'TIDAK TERDEFINISI') regional,
	coalesce(t4.kcu,
	'TIDAK TERDEFINISI') kcu,
	coalesce(t4.kc,
	'TIDAK TERDEFINISI') kc
from
	(select
		DATE(tgl_billing) as connote__created_at,
		null pod__timereceive ,
		'GLID' status_sla,
		'GLID' customer_code,
		'GLID' transform__channel,
		location_data_created__custom_field__nopen,
		service_code as connote__connote_service,
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
			kode_nopen location_data_created__custom_field__nopen,
			service_code,
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
		group by 1,2,3,4,5,6
)t0
group by 1,2,3,4,5,6,7,8,t0.subdit_id)t3
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
on
	t3.location_data_created__custom_field__nopen  = t4.kdnopen
order by
	1,
	2
