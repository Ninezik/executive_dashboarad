SELECT*
FROM
(SELECT
t1.nippos,
t1.idpenghasilan,
t1.deskripsi,
t1.tgltransaksi,
t1.amount,
coalesce(t1.kpc,t_tambal.kpc_tambal)kpc
FROM
(SELECT dbkug12a.dbo.kug12_h_penghasilan.nippos, 
kug12_h_penghasilan.idpenghasilan, 
UPPER(kug12_r_penghasilan.deskripsi )deskripsi ,
kug12_h_penghasilan.tgltransaksi, 
kug12_h_penghasilan.amount,
data_gaji.kpc 
FROM dbkug12a.dbo.kug12_h_penghasilan
LEFT JOIN (SELECT DISTINCT NIPPOS nippos_data_gaji,kpc ,WKT_UPDATE 
FROM dbsdm.payroll.DATA_GAJI)data_gaji
ON kug12_h_penghasilan.nippos=data_gaji.nippos_data_gaji
AND DATEFROMPARTS(YEAR(tgltransaksi), MONTH(tgltransaksi), 1)=DATEFROMPARTS(YEAR(data_gaji.WKT_UPDATE ), MONTH(data_gaji.WKT_UPDATE ), 1)
LEFT JOIN kug12_r_penghasilan
ON kug12_h_penghasilan.idpenghasilan =kug12_r_penghasilan.idpenghasilan 
WHERE kug12_h_penghasilan.tgltransaksi>'20260101'
AND kug12_h_penghasilan.idpenghasilan IN ('H001','H002','H026','P001','P002','P026')
)t1
LEFT JOIN 
--tambal
(SELECT nippos nippos_tambal,kpc kpc_tambal
FROM
(SELECT nippos,kpc,wkt_update,
ROW_NUMBER() OVER(PARTITION BY nippos ORDER BY wkt_update DESC)urutan
FROM dbsdm.payroll.DATA_GAJI
)t1
WHERE t1.urutan=1)t_tambal
ON t1.nippos =t_tambal.nippos_tambal
)t_final
