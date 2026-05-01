select
		t4.tgltr,
		t4.ketproduk ,
		t4.kdproduk,
		t4.kdkantor,
		t4.produksi,
		t4.pendapatan,
		t4.pajak,
		coalesce(case
			when t4.regional_ = '00' then 'MODERN CHANNEL'
		else t3.ketnopen ::VARCHAR
	end,
	'TIDAK TERDEFINISI') as ketnopen,
	coalesce(case
		when t4.regional_ = '00' then 'MODERN CHANNEL'
		else t3.regional::VARCHAR
	end,
	'TIDAK TERDEFINISI') as regional,
	coalesce(case
		when t4.regional_ = '00' then 'MODERN CHANNEL'
		else t3.kcu
	end,
	'TIDAK TERDEFINISI') as kcu,
	coalesce(case
		when t4.regional_ = '00' then 'MODERN CHANNEL'
		else t3.kc
	end,
	'TIDAK TERDEFINISI') as kc
from
		(
	select
			date(tgltr)tgltr,
			ketproduk ,
			kdproduk ,
			kdkantor,
			regional regional_,
			SUM(produksi)produksi,
			SUM(pendapatan)pendapatan,
			SUM(pajak)pajak
	from
			sap.feeder_sap
	group by
			1,
			2,
			3,
			4,
			5
)t4
	--	joinkeun ka referensi kantorexcept 
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
)t3
on
		t4.kdkantor = t3.kdnopen
