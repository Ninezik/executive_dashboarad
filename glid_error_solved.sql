select
date(tgl_billing) connote__created_at,
customer_code,
'GLID' custom_field__jenis_barang,
kode_nopen location_data_created__custom_field__nokprk,
'GLID' transform__channel,
service_code connote__connote_service,
NULL connote_sender_custom_field__pks_no__to_be_verified,
SUM(total_amount)  connote__connote_amount,
COUNT(order_code) connote__connote_code,
cast(SUM(
case
when LOWER(jenis_produk) like '%include%'
then total_amount / (1 + 0.011)
else total_amount
end
) as DECIMAL(18,
2)) as pendapatan,
cast(SUM(
case
when LOWER(jenis_produk) like '%include%'
then total_amount - (total_amount / (1 + 0.011))
else 0
end
) as DECIMAL(18,2)) as pajak,
0 fee_cod,
SUM(tot_weight_kg)connote__chargeable_weight,
'GLID' sumber
from
(
select
tgl_billing,
customer_code,
kode_nopen ,
service_code,
service_name ,
order_code,
jenis_produk,
case
when service_code = 'FFE' then 'EB'
else 'WIN'
end as subdit_id,
SUM(case when cast(g.konversi_berat as numeric) = cast(g.total_qty as numeric) or (cast(g.konversi_berat as numeric) >= 1000 and cast(total_qty as numeric)>1) then cast(tot_weight_kg as numeric)/ cast(konversi_berat as numeric)
else cast(tot_weight_kg as numeric) end)tot_weight_kg,
MAX(cast(total_amount as numeric))total_amount
from
glid.glid g
where date(tgl_billing) >DATE_TRUNC('year', CURRENT_DATE)
group by 1,2,3,4,5,6,7,8)t0
group by 1,2,3,4,5,6,7
