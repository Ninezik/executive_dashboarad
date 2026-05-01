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
	(
	select
		DATE(tgl_billing) as connote__created_at,
		kode_nopen,
		service_code as connote__connote_service,
		case
			when service_code = 'FFE' then 'EB'
			else 'WIN'
		end as segment,
		COUNT(order_code) as produksi,
		cast(SUM(
        case 
            when LOWER(jenis_produk) like '%include%'
            then total_amount / (1 + 0.011)
            else total_amount 
        end
    ) as DECIMAL(18,
		2)) as pendapatan,
		cast(SUM(
        case 
            when LOWER(jenis_produk) like '%include%'
            then total_amount - (total_amount / (1 + 0.011))
            else 0
        end
    ) as DECIMAL(18,2)) as pajak,
		SUM(tot_weight_kg)berat,
		'LOGISTIK' as kelompok,
		'GLID' as sumber
	from
		(
		select
			tgl_billing,
			kode_nopen,
			service_code,
			order_code,
			jenis_produk,
			SUM(case when g.konversi_berat = g.total_qty or (g.konversi_berat >= 1000 and total_qty>1) then tot_weight_kg / konversi_berat
    else tot_weight_kg end)tot_weight_kg,
			MAX(total_amount)total_amount
		from
			glid.glid g
		group by
			1,
			2,
			3,
			4,
			5
)t0
	where
		DATE(tgl_billing) > DATE '2026-01-01'
	group by
		1,
		2,
		3,
		4)t3
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
	t3.kode_nopen = t4.kdnopen
order by
	1,
	2
