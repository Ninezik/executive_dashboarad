SELECT  COUNT(*)jumlah_data_tidak_terlapor,
SUM(produksi)produksi_tidak_terlapor,
SUM(uang)pengeluaran_tidak_terlapor
FROM
(SELECT*
FROM
(SELECT*
FROM t_pajak_a
WHERE LEFT(bulan_transaksi,4)='2026'
AND status='01')t_pajak_a
RIGHT JOIN
(SELECT id_mitra idm,produksi,bulan_transaksi bt,total_fee uang
FROM t_upah
WHERE LEFT(bulan_transaksi,4)='2026'
UNION
SELECT id_mitra idm,produksi,bulan_transaksi bt, antaran_tot_feenya uang
FROM t_upah_lpu
WHERE LEFT(bulan_transaksi,4)='2026')t_upah_full
ON t_pajak_a.id_mitra=t_upah_full.idm
AND t_pajak_a.bulan_transaksi=t_upah_full.bt)tfinal
WHERE tfinal.id_mitra IS NULL
