select 
sp.gl_account_number ,
sp.gl_account_text,
sp.external_customer_no ,
t4.regional,
t4.kcu,
t4.kc,
t4.ketnopen kcp,
t4.kdnopen,
t4.jenis,
coalesce(tsubdit.subdit_id,'TIDAK TERDEFINISI'),
SUM(sp.amount)nilai
--SUM(SUM(amount))OVER() total
from sap.sap_piutang sp 
left join
(
	select
		*
	from
		(
		select
			t1.kdnopen,
			UPPER(t1.ketnopen) ketnopen,
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
)t4
on
	SUBSTRING(sp.profit_center,4,5) = t4.kdnopen

--subdit
left join
(
	select
		distinct idregpelanggan,
		subdit_id
	from
		referensi.m_pelanggan)tsubdit
on
	sp.external_customer_no= tsubdit.idregpelanggan
group by 1,2,3,4,5,6,7,8,9,10
