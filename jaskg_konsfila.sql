select
	t4.*,
	t3.ketnopen,
	t3.regional,
	t3.kcu,
	t3.kc
from
	(
	select
		date(tgltr)tgltr,
		ketproduk ,
		kdproduk ,
		kdkantor,
		SUM(produksi)produksi,
		SUM(pendapatan)pendapatan,
		SUM(pajak)pajak
	from
		sap.feeder_sap
	group by
		1,
		2,
		3,
		4
)t4
	--	joinkeun ka referensi kantorexcept 
left join
(
	select
		distinct t1.kdnopen,
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
on t4.kdkantor =t3.kdnopen 
