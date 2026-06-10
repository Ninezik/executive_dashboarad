SELECT 
 sdk.id, 
 sdk.regional, 
 sdk.wilayah, 
 sdk.nomor_dirian, 
 sdk.nama_kantor_pos,
 sbsb.biaya 
FROM 
 biaya.sewa_daftar_kantor sdk
join
 biaya.sewa_biaya_sewa_bulanan sbsb on sdk.id = sbsb.id_kantor
where
 sbsb.periode_akhir is NULL; -- biaya dengan PKS aktif saat ini
