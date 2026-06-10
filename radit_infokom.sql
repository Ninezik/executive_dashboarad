SELECT 
 irk.nopen, 
 irk.nopen_lama, 
 irk.nama_kantor, 
 irk.nopen_induk, 
 irk.regional, 
 irk.jenis_kantor, 
 irk.alamat, 
 irk.alamat_baru, 
 irk.provinsi, 
 irk.paket_layanan, 
 irk.kantor_tutup, 
 irk.status_baso,
 case 
  when ip.start_period = '2025-01-01' and  ip.end_period = '2025-12-31' then ip.pso 
 end as pso_2025,
 case 
  when ip.start_period = '2026-01-01' and  ip.end_period is null then ip.pso 
 end as pso_2026,
 ip2.bulan_tagih,
 ip2.total 
FROM 
 biaya.infokom_ref_kantor irk
join 
 biaya.infokom_pso ip on irk.id = ip.id_kantor
join 
 biaya.infokom_pembayaran ip2 on irk.id = ip2.id_kantor
where 
 ip2.bulan_tagih = '2026-01'; -- parameter bulan tagihnya kapan
