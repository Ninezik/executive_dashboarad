select*
FROM
(SELECT
    t1."KDNOPEN",
    UPPER(t1."KETNOPEN")ketnopen,
    t2."REGIONAL",
    t2."KCU",
    t2."KC",
    UPPER(t1."JENIS")jenis,
    ROW_NUMBER() OVER (
        PARTITION BY t1."KDNOPEN"
        ORDER BY t1."KDNOPEN"
    ) AS rn
FROM public."REFRENSIKANTORBARU" t1
JOIN (
    SELECT DISTINCT
        "NOPEND_DIRIAN",
        "KC",
        "KCU",
        "REGIONAL"
    FROM public."REF_KCU_KC_2023"
) t2
    ON t1."KDKANTOR" = t2."NOPEND_DIRIAN")
t3
--pastikeun unik
where t3.rn='1'
