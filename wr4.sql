select 
date(custom_field__final_swp_date_new)custom_field__final_swp_date_new,
COUNT(distinct case when nipos.connote__connote_state in('DELIVERED','DELIVERED (RETURN DELIVERY)') then nipos.connote__connote_code
else null end) as berhasil_antar,
COUNT(distinct case when nipos.connote__connote_state in('ON PROCESS','FAILEDTODELIVERED') then nipos.connote__connote_code
else null end) as gagal_antar,
COUNT(distinct nipos.connote__connote_code)total_kiriman,
COUNT(DISTINCT CASE 
  WHEN nipos.connote__connote_state IN ('DELIVERED','DELIVERED (RETURN DELIVERY)')
  THEN nipos.connote__connote_code
END)::FLOAT
/
NULLIF(COUNT(DISTINCT nipos.connote__connote_code), 0)sla_berhasil_antar
from nipos.nipos
where nipos.connote__connote_state not in ('CANCEL','PENDING')
and nipos.location_data_created__location_name!='AGP TESTING LOCATION'
and nipos.connote__connote_service NOT IN ('LNINCOMING','010','3PE','312','311','3LX','331','332','3LP')
and nipos.custom_field__final_swp_date_new  >'20260101'
and coalesce(nipos.nipos.customer_code,'-') 
not in('ASRPRUDEN04120A',
 'LNBAPENDA05651D',
 'LNBAPENDA05651E',
 'BANKMANDIRI02110C',
 'BANKMANDIRI02110D',
 'INDHMS07603B',
 'KESGLOALKES02130A')
group by 1
order by 1
