select
	t1.tanggal_tambah ,
	t1.tanggal_status ,
	--t1.kantor_asal ,
	SUM(case 
    when t1.status_akhir = 109 then t1.jumlah 
    else 0 
end) as jumlah_aduan_selesai,
	SUM(t1.jumlah) as jumlah_aduan,
    ROUND(SUM(case 
        when t1.status_akhir = 109 then t1.jumlah 
        else 0
    end)::DECIMAL(18,2)
    /SUM(t1.jumlah),2) persentase
from
	(
	select
		DATE(tanggal_tambah)tanggal_tambah,
		DATE(tanggal_status)tanggal_status,
		--	kantor_asal ,
		status_akhir ,
		COUNT(distinct id_pengaduan)jumlah
	from
		cch.cchentri
	where
		cchentri.tanggal_tambah >'20260101'
	group by
		1,
		2,
		3
	order by
		1,
		2,
		3)t1
group by
	1,
	2
order by
	1,
	2
