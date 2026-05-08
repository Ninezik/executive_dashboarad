select*
from sap.sap_piutang t1
left join 
(
SELECT distinct kode_customer,sap_produk_jaskug.segment 
FROM referensi.sap_produk_jaskug
)t2
on replace(t1.customer_account,'.00','') =t2.kode_customer
