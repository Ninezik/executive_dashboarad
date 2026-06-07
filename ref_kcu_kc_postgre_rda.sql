select*
FROM
(SELECT
    rkb."KDNOPEN",
    UPPER(rkb."KETNOPEN")ketnopen,
    rkk."REGIONAL",
    rkk."KCU",
    rkk."KC",
    UPPER(rkb."JENIS")jenis,
    ROW_NUMBER() OVER (
        PARTITION BY rkb."KDNOPEN"
        ORDER BY rkb."KDNOPEN"
    ) AS rn
FROM public."REFRENSIKANTORBARU" rkb
JOIN (
    SELECT DISTINCT
        "NOPEND_DIRIAN",
        "KC",
        "KCU",
        "REGIONAL"
    FROM public."REF_KCU_KC_2023"
) rkk
    ON rkb."KDKANTOR" = rkk."NOPEND_DIRIAN")
t1
--pastikeun unik
where t1.rn='1'
