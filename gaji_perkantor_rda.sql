select 
date_trunc('month',tfinal.tgltransaksi )tgltransaksi,
tfinal.deskripsi,
tfinal.kpc,
coalesce(case when tfinal.kpc='40005' then 'KANTOR PUSAT BANDUNG'
else tfinal.regional  end,'TIDAK TERDEFINISI') as regional,
coalesce(case when tfinal.kpc='40005' then 'KANTOR PUSAT BANDUNG'
else tfinal.kcu  end,'TIDAK TERDEFINISI') as kcu,
coalesce(case when tfinal.kpc='40005' then 'KANTOR PUSAT BANDUNG'
else tfinal.kc  end,'TIDAK TERDEFINISI') as kc,
coalesce(tfinal.ketnopen,'TIDAK TERDEFINISI')ketnopen,
SUM(tfinal.amount)amount
FROM
(SELECT
    bp.*,
    ref.ketnopen,
    ref.regional,
    ref.kcu,
    ref.kc,
    ref.jenis
FROM public."Biaya_Pegawai" bp
LEFT JOIN
(
    SELECT *
    FROM
    (
        SELECT
            t1.kdnopen,
            t1.ketnopen,
            t2.regional,
            t2.kcu,
            t2.kc,
            t1.jenis,
            ROW_NUMBER() OVER (
                PARTITION BY t1.kdnopen
                ORDER BY t1.ketnopen
            ) AS rn
        FROM
        (
            SELECT
                "KDNOPEN"  AS kdnopen,
                UPPER("KETNOPEN") AS ketnopen,
                "KDKANTOR" AS kdkantor,
                "JENIS"    AS jenis
            FROM public."REFRENSIKANTORBARU"
        ) t1
        LEFT JOIN
        (
            SELECT DISTINCT
                "NOPEND_DIRIAN" AS nopend_dirian,
                "KC" AS kc,
                "KCU" AS kcu,
                "REGIONAL" AS regional
            FROM public."ref_kcu_kc_2023"
        ) t2
            ON t1.kdkantor = t2.nopend_dirian
    ) a
    WHERE rn = 1
) ref
    ON bp.kpc = ref.kdnopen
)tfinal
group by 1,2,3,4,5,6,7
