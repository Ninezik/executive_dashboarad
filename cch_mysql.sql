WITH sumber AS (
    SELECT 
    date(tanggal_tambah)tanggal_tambah,
    date(tanggal_status)tanggal_status,
    Sumber_Pengaduan ,
    jenis_pengaduan,
        semua_tujuan,
        status_akhir,
        COUNT(*) AS nilai
    FROM cchentri
    where tanggal_tambah>'20260507'
and tanggal_tambah<'20260508'
    GROUP BY 1,2,3,4,5,6
)
SELECT 
s.tanggal_tambah ,
s.tanggal_status ,
s.sumber_pengaduan ,
s.jenis_pengaduan ,
    jt.nopen,
    s.status_akhir,
    SUM(s.nilai) AS total_nilai,
    SUM(sum(s.nilai)) OVER() total_seluruh
FROM sumber s
CROSS JOIN JSON_TABLE(
    CONCAT('["', REPLACE(s.semua_tujuan, ',', '","'), '"]'),
    '$[*]' COLUMNS (
        nopen VARCHAR(20) PATH '$'
    )
) jt
GROUP BY 1,2,3,4,5,6
ORDER BY total_nilai desc
