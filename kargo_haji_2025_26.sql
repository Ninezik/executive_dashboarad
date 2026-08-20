SELECT date(created_at)connote__created_at,
'KARGO HAJI' customer_code,
'KARGO HAJI' custom_field__jenis_barang,
'KARGO HAJI' location_data_created__custom_field__nokprk,
'KARGO HAJI' transform__channel,
'KARGO HAJI' connote__connote_service,
NULL connote_sender_custom_field__pks_no__to_be_verified,
SUM(coalesce(total_fee_idr,0))connote__connote_amount,
COUNT(distinct no_resi)connote__connote_code,
SUM(coalesce(total_fee_idr,0))/(1+(1.1/100)) pendapatan,
SUM(coalesce(total_fee_idr,0))-(SUM(coalesce(total_fee_idr,0))/(1+(1.1/100))) pajak,
0 fee_cod,
'KARGO HAJI' sumber,
SUM(coalesce(total_weight,0))connote__chargeable_weight
FROM kargo.kargo_haji_kolekting
where UPPER(status)!='CANCEL'
and is_paid='t'
and created_at>DATE_TRUNC('year', CURRENT_DATE)
GROUP BY
1,2,3,4,5,6,7
