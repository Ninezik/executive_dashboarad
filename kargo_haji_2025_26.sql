SELECT date(created_at)created_at ,
COUNT(distinct no_resi)trx,
SUM(total_fee_idr)/(1+(1.1/100)) pendapatan,
SUM(total_fee_idr)-(SUM(total_fee_idr)/(1+(1.1/100))) pajak,
'KARGO HAJI' sumber,
'KURIR' kelompok,
'WIN' subdit_id
FROM kargo.kargo_haji_kolekting
where UPPER(status)!='CANCEL'
and kargo_haji_kolekting.created_at >'20260101'
and is_paid='t'
GROUP by 1
