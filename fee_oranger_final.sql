SELECT id_mitra, 
nama_mitra, 
UPPER(jabatan)jabatan, 
TO_DATE(tgl, 'DD/MM/YYYY')tgl, 
kantor, 
total_fee, 
produksi,
coalesce(case when t2.kdnopen='40005' then 'KANTOR PUSAT BANDUNG'
else t2.regional  end,'TIDAK TERDEFINISI') as regional,
coalesce(case when t2.kdnopen='40005' then 'KANTOR PUSAT BANDUNG'
else t2.kcu  end,'TIDAK TERDEFINISI') as kcu,
coalesce(case when t2.kdnopen='40005' then 'KANTOR PUSAT BANDUNG'
else t2.kc  end,'TIDAK TERDEFINISI') as kc,
coalesce(t2.ketnopen,'TIDAK TERDEFINISI')ketnopen
FROM public.v_pajak_pembayaran
left join 
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
            FROM ref_data."REFRENSIKANTORBARU"
        ) t1
        LEFT JOIN
        (
            SELECT DISTINCT
                "NOPEND_DIRIAN" AS nopend_dirian,
                "KC" AS kc,
                "KCU" AS kcu,
                "REGIONAL" AS regional
            FROM ref_data."REF_KCU_KC_2023" rkk 
        ) t2
            ON t1.kdkantor = t2.nopend_dirian
    ) a
    WHERE rn = 1
)t2
on v_pajak_pembayaran.kantor =t2.kdnopen 
